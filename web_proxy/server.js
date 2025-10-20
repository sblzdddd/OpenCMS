import Fastify from 'fastify';
import { request } from 'undici';

const fastify = Fastify({ logger: true, bodyLimit: 10485760 });

// Register content type parsers with a single handler function
const parseAsString = (req, body, done) => done(null, body || (body === '' ? {} : body));
['application/json', 'application/x-www-form-urlencoded', 'text/plain', 'text/html']
  .forEach(type => fastify.addContentTypeParser(type, { parseAs: 'string' }, 
    type === 'application/json' ? 
      (req, body, done) => {
        try {
          done(null, !body || body.trim() === '' ? {} : JSON.parse(body));
        } catch (err) {
          err.statusCode = 400;
          done(null, body);
        }
      } : parseAsString
  ));

// Configuration
const PROXY_PORT = 45678;
const PROXY_HOST = 'localhost';
const PROXY_BASE_URL = `http://${PROXY_HOST}:${PROXY_PORT}`;

const a = 'c'+'ms.a'+'lev'+'el.c'+'om.cn';
const b = 'w'+'ww.a'+'lev'+'el.c'+'om.cn';

// Target domains to proxy
const TARGET_DOMAINS = {
  [a]: 'https://'+a,
  [b]: 'https://'+b
};

// Utility functions
const rewriteCookies = (cookies) => cookies && (Array.isArray(cookies) ? cookies : [cookies])
  .map(cookie => cookie
    .replace(/domain=([^;]+)/gi, `domain=${PROXY_HOST}`)
    .replace(/;\s*secure/gi, '')
    .replace(/samesite=none/gi, 'samesite=lax')
  );

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Credentials': 'true',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS,PATCH',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization,X-Requested-With,Accept,Origin,Referer,User-Agent,X-Original-Host,X-Proxy-Request'
};

// Global CORS and OPTIONS handling
fastify.addHook('onSend', async (request, reply, payload) => {
  reply.headers({ ...corsHeaders, 'Access-Control-Allow-Origin': request.headers.origin || '*' });
  return payload;
});

fastify.options('/*', async (req, reply) => 
  reply.headers({ ...corsHeaders, 'Access-Control-Allow-Origin': req.headers.origin || '*' }).code(200).send());

fastify.get('/health', async () => ({ status: 'ok', timestamp: new Date().toISOString() }));

// Main proxy route
fastify.register(async function (fastify) {
  fastify.all('/proxy/:domain/*', async (req, reply) => {
    const { domain } = req.params;
    const path = req.params['*'];
    
    if (!TARGET_DOMAINS[domain]) return reply.code(400).send({ error: 'Invalid domain' });
    if (req.method === 'OPTIONS') return reply.headers(corsHeaders).code(200).send();
    
    const targetUrl = `${TARGET_DOMAINS[domain]}/${path}`;
    const fullUrl = req.query && Object.keys(req.query).length ? 
      `${targetUrl}?${new URLSearchParams(req.query)}` : targetUrl;
    
    try {
      // Prepare headers and body
      const { host, origin, 'x-forwarded-for': xff, 'x-forwarded-proto': xfp, 
              'content-type': ct, 'content-length': cl, ...upstreamHeaders } = req.headers;
      upstreamHeaders.referer = TARGET_DOMAINS[domain] + '/cms';
      
      let requestBody;
      if (!['GET', 'HEAD'].includes(req.method) && req.body !== undefined) {
        requestBody = typeof req.body === 'object' && !Buffer.isBuffer(req.body) ? 
          JSON.stringify(req.body) : req.body;
        if (typeof requestBody === 'string' && typeof req.body === 'object') {
          upstreamHeaders['content-type'] = 'application/json';
          upstreamHeaders['content-length'] = Buffer.byteLength(requestBody, 'utf8').toString();
        }
      }
      
      const response = await request(fullUrl, { method: req.method, headers: upstreamHeaders, body: requestBody });
      
      // Process response headers
      const responseHeaders = {};
      const isGzipped = response.headers['content-encoding'] === 'gzip';
      
      Object.entries(response.headers).forEach(([key, value]) => {
        const lowerKey = key.toLowerCase();
        if (lowerKey === 'set-cookie') {
          responseHeaders[key] = rewriteCookies(value);
        } else if (lowerKey === 'location') {
          let location = value;
          Object.entries(TARGET_DOMAINS).forEach(([targetDomain, targetUrl]) => {
            location = location.replace(new RegExp(targetUrl.replace('https://', 'https?://'), 'g'),
              `${PROXY_BASE_URL}/proxy/${targetDomain}`);
          });
          responseHeaders[key] = location;
        } else if (!['transfer-encoding', 'content-length'].includes(lowerKey)) {
          responseHeaders[key] = value;
        }
      });
      
      reply.headers(responseHeaders).header('Transfer-Encoding', 'chunked').code(response.statusCode);
      
      // Handle response body
      let responseBody = Buffer.from(await response.body.arrayBuffer());
      const contentType = response.headers['content-type'] || '';
      const isTextContent = ['text/html', 'application/javascript', 'text/css', 'application/json', 'text/plain']
        .some(type => contentType.includes(type));
        
      if (isTextContent && !isGzipped && responseBody.length > 0) {
        try {
          let bodyText = responseBody.toString('utf-8');
          if (!bodyText.includes('\0') && !bodyText.includes('\uFFFD')) {
            Object.entries(TARGET_DOMAINS).forEach(([targetDomain, targetUrl]) => {
              const escapedUrl = targetUrl.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
              bodyText = bodyText
                .replace(new RegExp(escapedUrl.replace('https\\:\\/\\/', 'https?:\\/\\/'), 'g'),
                  `${PROXY_BASE_URL}/proxy/${targetDomain}`)
                .replace(new RegExp(`\\/\\/${targetDomain.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}`, 'g'),
                  `${PROXY_BASE_URL}/proxy/${targetDomain}`)
                .replace(new RegExp(`(href|src|action)=["']\\/((?!\\/)(?!proxy)[^"']*?)["']`, 'g'),
                  `$1="${PROXY_BASE_URL}/proxy/${targetDomain}/$2"`);
            });
            responseBody = Buffer.from(bodyText, 'utf-8');
          }
        } catch (error) {
          fastify.log.error('URL rewriting error:', error);
        }
      }
      
      return reply.send(responseBody);
      
    } catch (error) {
      fastify.log.error(`Proxy error for ${fullUrl}:`, error);
      return reply.code(500).send({ error: 'Proxy request failed', message: error.message });
    }
  });
});

// Start server
(async () => {
  try {
    await fastify.listen({ port: PROXY_PORT, host: '0.0.0.0' });
    console.log(`🚀 OpenCMS Web Proxy running on ${PROXY_BASE_URL}`);
    console.log(`📍 Proxying domains: ${Object.keys(TARGET_DOMAINS).join(', ')}`);
    console.log(`🔧 Health check: ${PROXY_BASE_URL}/health`);
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
})();