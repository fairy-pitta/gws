#!/bin/bash
# Setup script for portree demo environment
# This creates a temporary project with the necessary structure for recording demos

set -e

DEMO_DIR="${1:-/tmp/portree-demo}"
PORTREE_BIN="${2:-$(pwd)/portree}"

echo "Setting up demo environment in: $DEMO_DIR"
echo "Using portree binary: $PORTREE_BIN"

# Clean up existing demo directory
rm -rf "$DEMO_DIR"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR"

# Initialize git repository
git init
git config user.email "demo@example.com"
git config user.name "Demo User"

# Create a simple project structure
mkdir -p frontend backend

# Create a simple frontend (using Python http.server as mock)
cat > frontend/server.py << 'EOF'
import http.server
import socketserver
import os

PORT = int(os.environ.get('PORT', 3100))
BRANCH = os.environ.get('PT_BRANCH', 'unknown')

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        response = f"""
        <html>
        <head><title>Frontend - {BRANCH}</title></head>
        <body style="font-family: system-ui; padding: 40px; background: #1a1a2e; color: #eee;">
            <h1>🌳 portree Demo Frontend</h1>
            <p>Branch: <strong>{BRANCH}</strong></p>
            <p>Port: <strong>{PORT}</strong></p>
        </body>
        </html>
        """
        self.wfile.write(response.encode())

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Frontend serving on port {PORT} (branch: {BRANCH})")
    httpd.serve_forever()
EOF

# Create a simple backend (using Python http.server as mock)
cat > backend/server.py << 'EOF'
import http.server
import socketserver
import os
import json

PORT = int(os.environ.get('PORT', 8100))
BRANCH = os.environ.get('PT_BRANCH', 'unknown')

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        response = json.dumps({
            "service": "backend",
            "branch": BRANCH,
            "port": PORT,
            "status": "ok"
        }, indent=2)
        self.wfile.write(response.encode())

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Backend API serving on port {PORT} (branch: {BRANCH})")
    httpd.serve_forever()
EOF

# Create .portree.toml configuration
cat > .portree.toml << 'EOF'
# portree configuration for demo project

[services.frontend]
command = "python3 server.py"
dir = "frontend"
port_range = { min = 3100, max = 3199 }
proxy_port = 3000

[services.backend]
command = "python3 server.py"
dir = "backend"
port_range = { min = 8100, max = 8199 }
proxy_port = 8000

[env]
DEMO_MODE = "true"
EOF

# Initial commit
git add .
git commit -m "Initial commit: demo project setup"

# Create a feature branch (for worktree demo)
git branch feature/new-api

# Add portree to PATH for this session
export PATH="$(dirname "$PORTREE_BIN"):$PATH"

echo ""
echo "✅ Demo environment ready!"
echo ""
echo "To record demos:"
echo "  cd $DEMO_DIR"
echo "  export PATH=\"$(dirname "$PORTREE_BIN"):\$PATH\""
echo ""
echo "Then run VHS:"
echo "  vhs /path/to/demo-quickstart.tape"
echo "  vhs /path/to/demo-tui.tape"
echo "  vhs /path/to/demo-workflow.tape"
echo ""
