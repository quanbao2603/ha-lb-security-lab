import http.server
import socketserver
import json
import os
import sys
from datetime import datetime

PORT = 8080
BASE_DIR = "/home/ops/ai-bridge"
MSG_FILE = os.path.join(BASE_DIR, "messages.jsonl")

def record_message(sender, content, msg_type="chat", extra=None):
    ts = datetime.now().isoformat()
    record = {
        "timestamp": ts,
        "from": sender,
        "type": msg_type,
        "content": content,
        "extra": extra or {}
    }
    line = json.dumps(record, ensure_ascii=False)
    with open(MSG_FILE, "a", encoding="utf-8") as f:
        f.write(line + "\n")
    print(f"[AI-MSG] [{sender}] ({msg_type}) {content}", flush=True)
    return record

class Handler(http.server.BaseHTTPRequestHandler):
    def _send_json(self, code, data):
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(json.dumps(data, ensure_ascii=False, indent=2).encode("utf-8"))

    def do_GET(self):
        if self.path == "/health":
            self._send_json(200, {"status": "ok", "site": "Site B (Minh Hùng)", "time": datetime.now().isoformat()})
        elif self.path == "/messages":
            msgs = []
            if os.path.exists(MSG_FILE):
                with open(MSG_FILE, "r", encoding="utf-8") as f:
                    for line in f:
                        if line.strip():
                            try:
                                msgs.append(json.loads(line))
                            except Exception:
                                pass
            self._send_json(200, {"count": len(msgs), "messages": msgs[-30:]})
        elif self.path == "/status":
            info = {
                "site": "Site B (Minh Hùng)",
                "transit_b": "172.20.20.6 / 100.64.115.23",
                "firewall_a": "172.20.50.2 (VIP Gateway: 172.20.x.1)",
                "db_primary": "172.20.40.11",
                "db_replica": "172.20.40.12 (Standby)",
                "log_monitor": "172.20.50.10",
                "status": "ready"
            }
            self._send_json(200, info)
        else:
            self._send_json(404, {"error": "endpoint not found"})

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        raw = self.rfile.read(length)
        try:
            data = json.loads(raw.decode("utf-8"))
        except Exception:
            data = {"content": raw.decode("utf-8", errors="ignore")}
        
        sender = data.get("from", "Site-A-QuanBao")
        content = data.get("content", "")
        msg_type = data.get("type", "chat")
        extra = data.get("extra", {})

        record = record_message(sender, content, msg_type, extra)
        self._send_json(200, {"status": "saved", "message": record})

class ThreadingHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True

if __name__ == "__main__":
    os.makedirs(BASE_DIR, exist_ok=True)
    if not os.path.exists(MSG_FILE):
        with open(MSG_FILE, "w", encoding="utf-8") as f:
            pass
    print(f"Bridge server running on port {PORT}...", flush=True)
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    server.serve_forever()
