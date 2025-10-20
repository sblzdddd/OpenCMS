# OpenCMS Web Proxy

A reverse proxy server for the OpenCMS Flutter web application that handles CORS and cookie domain rewriting.

## Features

- **Reverse Proxy**: Proxies requests to original OpenCMS domains
- **Cookie Rewriting**: Automatically rewrites cookie domains for localhost development
- **CORS Support**: Handles cross-origin requests for web clients
- **URL Rewriting**: Rewrites URLs in HTML/JS/CSS content to use proxy endpoints

## Setup

1. Install dependencies:
```bash
npm install
```

2. Start the proxy server:
```bash
npm start
```

Or for development with auto-reload:
```bash
npm run dev
```

The proxy server will start on `http://localhost:42441`

## Usage

The proxy exposes endpoints in the format:
```
http://localhost:42441/proxy/{domain}/{path}
```

### Supported Domains

- `cms.XXXXXX.com.cn` - New CMS API
- `www.XXXXXX.com.cn` - Legacy CMS

### Examples

- Original: `https://cms.XXXXXX.com.cn/api/token/`
- Proxied: `http://localhost:42441/proxy/cms.XXXXXX.com.cn/api/token/`

- Original: `https://www.XXXXXX.com.cn/user/login`
- Proxied: `http://localhost:42441/proxy/www.XXXXXX.com.cn/user/login`

## Health Check

Check if the proxy is running:
```
GET http://localhost:42441/health
```

## Configuration

The proxy configuration can be modified in `server.js`:

- `PROXY_PORT`: Port for the proxy server (default: 42441)
- `PROXY_HOST`: Host for the proxy server (default: localhost)
- `TARGET_DOMAINS`: Mapping of domains to proxy
