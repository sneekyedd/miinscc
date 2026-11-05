"""serve.py - a tiny web server for MiiNSCC on this computer only (http://localhost:8765).
start-miinscc.sh starts it (Mac / Linux). Only this computer can reach it, it only hands out
files from this folder, and it tells the browser not to keep old copies (always the newest)."""
import http.server, json, os, sys

ROOT = os.path.dirname(os.path.abspath(__file__))
PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8765

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **k):
        super().__init__(*a, directory=ROOT, **k)
    def do_GET(self):
        if self.path.split("?")[0] == "/__nscc/folder":  # (for Settings: which folder this is)
            body = json.dumps({"folder": ROOT, "os": "Mac / Linux"}).encode()
            self.send_response(200); self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body))); self.end_headers(); self.wfile.write(body); return
        if any(p.startswith(".") for p in self.path.split("?")[0].split("/") if p):  # (no hidden files, e.g. .git)
            self.send_error(404); return
        super().do_GET()
    def end_headers(self):
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        super().end_headers()
    def log_message(self, *a):
        pass

http.server.ThreadingHTTPServer.allow_reuse_address = True
http.server.ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
