@echo off
cd /d "%~dp0"

echo 🚀 Starting OpenCMS Web Proxy...

REM Check if node_modules exists
if not exist "node_modules" (
    echo 📦 Installing dependencies...
    call npm install
)

REM Start the proxy server
echo 🌐 Starting proxy server on http://localhost:42441
call npm start

pause