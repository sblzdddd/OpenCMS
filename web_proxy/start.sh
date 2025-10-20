#!/bin/bash
cd "$(dirname "$0")"

echo "🚀 Starting OpenCMS Web Proxy..."

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Start the proxy server
echo "🌐 Starting proxy server on http://localhost:42441"
npm start