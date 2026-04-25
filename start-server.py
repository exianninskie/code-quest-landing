#!/usr/bin/env python3
import http.server
import webbrowser
import os

# Change to the directory containing index.html
os.chdir(os.path.dirname(os.path.abspath(__file__)))

# Start server on port 8000
server_address = ('localhost', 8000)
httpd = http.server.HTTPServer(server_address, http.server.SimpleHTTPRequestHandler)

print(f"Server running at http://localhost:8000")
print("Press Ctrl+C to stop the server")

# Open browser automatically
webbrowser.open('http://localhost:8000')

try:
    httpd.serve_forever()
except KeyboardInterrupt:
    print("\nServer stopped")
