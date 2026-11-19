import http.server
import socketserver
import json
import os
import subprocess
import threading
import time
from datetime import datetime

PORT = 8088
LOG_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "bridge_activity.log")
STATE_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "bridge_state.json")

def log_event(source, message, data=None):
    ts = datetime.now().isoformat()
    entry = {"timestamp": ts, "source": source, "message": message, "data": data or {}}
    line = json.dumps(entry, ensure_ascii=False)
    print(f"[{ts}] [{source}] {message}")
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(line + "\n")

class CoordinationHandler(http.server.BaseHTTPRequestHandler):
    def _send_json(self, status_code, data):
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(json.dumps(data, ensure_ascii=False, indent=2).encode("utf-8"))

    def do_GET(self):
        if self.path == "/health":
            self._send_json(200, {"status": "ok", "site": "Site-B-MinhHung", "timestamp": datetime.now().isoformat()})
        elif self.path == "/status":
            try:
                # Query quick health from Site B
                res = subprocess.run(["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=2", "ops@172.20.20.6", "tailscale status"], capture_output=True, text=True, timeout=5)
                ts_status = "online" if res.returncode == 0 else "offline"
            except Exception as e:
                ts_status = str(e)
            self._send_json(200, {"site": "Site B (Minh Hùng)", "tailscale_router": "172.20.20.6", "ts_status": ts_status, "vm_active": ["Transit-B (172.20.20.6)", "Firewall-A (172.20.50.2)", "DB-Primary (172.20.40.11)", "Log-Monitor (172.20.50.10)"]})
        elif self.path == "/logs":
            if os.path.exists(LOG_FILE):
                with open(LOG_FILE, "r", encoding="utf-8") as f:
                    lines = [json.loads(l) for l in f.readlines()[-50:] if l.strip()]
                self._send_json(200, {"recent_logs": lines})
            else:
                self._send_json(200, {"recent_logs": []})
        else:
            self._send_json(404, {"error": "not found"})

    def do_POST(self):
        content_length = int(self.headers.get("Content-Length", 0))
        post_data = self.rfile.read(content_length)
        try:
            payload = json.loads(post_data.decode("utf-8")) if post_data else {}
        except Exception:
            payload = {"raw": post_data.decode("utf-8", errors="ignore")}

        if self.path == "/notify" or self.path == "/message":
            sender = payload.get("sender", "Site-A-QuanBao")
            action = payload.get("action", "message")
            content = payload.get("content", "")
            log_event(sender, f"Action: {action} - {content}", payload)
            self._send_json(200, {"status": "received", "action": action, "timestamp": datetime.now().isoformat()})
        elif self.path == "/test-trigger":
            # Bảo triggers a verification probe
            test_type = payload.get("test_type", "icmp_check")
            log_event("Site-A-QuanBao", f"Requested trigger test: {test_type}", payload)
            self._send_json(200, {"status": "accepted", "test_type": test_type, "note": "Processing request"})
        else:
            self._send_json(400, {"error": "unknown endpoint"})

def stream_firewall_logs():
    """Tail firewall logs from Log-Monitor and stream to bridge_activity.log"""
    time.sleep(2)
    log_event("Stream-Worker", "Starting live firewall & audit log monitor...")
    while True:
        try:
            # Monitor journal on Firewall-A
            proc = subprocess.Popen(
                ["ssh", "-o", "BatchMode=yes", "ops@172.20.50.2", "sudo journalctl -k -f --grep='FW-' -n 0 --no-pager"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1
            )
            for line in proc.stdout:
                line_str = line.strip()
                if line_str:
                    log_event("Firewall-A-Kernel", line_str)
            proc.wait()
        except Exception as e:
            log_event("Stream-Worker-Error", str(e))
            time.sleep(5)

if __name__ == "__main__":
    t = threading.Thread(target=stream_firewall_logs, daemon=True)
    t.start()
    log_event("System", f"Starting Coordination Bridge HTTP server on port {PORT}...")
    with socketserver.TCPServer(("0.0.0.0", PORT), CoordinationHandler) as httpd:
        httpd.serve_forever()
