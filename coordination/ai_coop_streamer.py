import subprocess
import threading
import time
import json
import os
import sys

JOURNAL_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "inter_site_collab_journal.md")

def record_collab_msg(ts, sender, msg_type, content):
    # ponytail: naive marker split; upgrade to markdown AST if journal layout changes
    if not os.path.exists(JOURNAL_FILE):
        return
    row = f"| `{ts[:19]}` | `{sender}` | `{msg_type}` | {content} |\n"
    with open(JOURNAL_FILE, "r+", encoding="utf-8") as f:
        text = f.read()
        marker = "\n---\n\n## 2."
        if marker in text and row not in text:
            parts = text.split(marker, 1)
            f.seek(0)
            f.write(parts[0] + row + marker + parts[1])
            f.truncate()

def record_security_event(event_line):
    # ponytail: append format; replace with circular buffer if log volume surges
    if not os.path.exists(JOURNAL_FILE):
        return
    ts = time.strftime("%Y-%m-%dT%H:%M:%S")
    entry = f"- `{ts}`: `{event_line}`\n"
    with open(JOURNAL_FILE, "r+", encoding="utf-8") as f:
        text = f.read()
        placeholder = "*(Đang chờ AI của Bảo bắn kịch bản test)*\n"
        if placeholder in text:
            text = text.replace(placeholder, "")
        elif "*(Đang chờ AI của Bảo bắn kịch bản test)*" in text:
            text = text.replace("*(Đang chờ AI của Bảo bắn kịch bản test)*", "")
        f.seek(0)
        f.write(text.rstrip() + "\n\n" + entry)
        f.truncate()

def _self_check():
    sample = "## 1.\n| col |\n\n---\n\n## 2.\ncontent"
    marker = "\n---\n\n## 2."
    row = "| `test` | `A` | `chat` | hello |\n"
    parts = sample.split(marker, 1)
    res = parts[0] + row + marker + parts[1]
    assert row in res and res.endswith("## 2.\ncontent"), "Self check failed"
    print("[AI-COOP-BRIDGE] Self-check passed.", flush=True)

def stream_messages():
    """Stream incoming collaboration messages from Transit-B"""
    cmd = ["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=5", "ops@172.20.20.6", "tail -f -n 0 /home/ops/ai-bridge/messages.jsonl"]
    while True:
        try:
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, bufsize=1)
            for line in proc.stdout:
                line = line.strip()
                if not line:
                    continue
                try:
                    data = json.loads(line)
                    sender = data.get("from", "Unknown")
                    msg_type = data.get("type", "chat")
                    content = data.get("content", "")
                    ts = data.get("timestamp", time.strftime("%Y-%m-%dT%H:%M:%S"))
                    print(f"[AI-COLLAB-INCOMING] [{sender}] ({msg_type}): {content}", flush=True)
                    record_collab_msg(ts, sender, msg_type, content)
                except Exception:
                    print(f"[AI-COLLAB-RAW]: {line}", flush=True)
            proc.wait()
        except Exception as e:
            time.sleep(3)

def stream_firewall():
    """Stream relevant security events from Log-Monitor (excluding syslog loops)"""
    cmd = ["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=5", "ops@172.20.50.10", "sudo tail -f -n 0 /var/log/central/fw-a/kernel.log"]
    while True:
        try:
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, bufsize=1)
            for line in proc.stdout:
                line = line.strip()
                if not line:
                    continue
                # Filter out noisy syslog messages, local Windows broadcast discovery, local Tailscale disco and TCP teardowns
                if any(noise in line for noise in ["FW-ALLOW-SYSLOG", "DPT=137", "DPT=138", "DPT=5355", "FW-DENY-INVALID"]):
                    continue
                if "DST=172.20.50.254" in line and "DPT=41641" in line:
                    continue
                if any(k in line for k in ["FW-DENY", "FW-DEFAULT-DENY", "FW-ALLOW-SITE-A-JUMP", "FW-ALLOW-WEB-DB", "FW-ALLOW-MGMT-SSH", "FW-ALLOW-MGMT-ICMP", "TRANSIT-B-"]):
                    # Extract concise summary
                    print(f"[SECURITY-EVENT] {line}", flush=True)
                    record_security_event(line)
            proc.wait()
        except Exception as e:
            time.sleep(3)

def poll_git():
    """Periodically check for new commits or branches from Bao on origin"""
    last_head = ""
    repo_dir = "D:/Lab/ha-lb-security-lab"
    while True:
        try:
            subprocess.run(["git", "-C", repo_dir, "fetch", "origin", "main"], capture_output=True, timeout=10)
            res = subprocess.run(["git", "-C", repo_dir, "rev-parse", "origin/main"], capture_output=True, text=True, timeout=5)
            curr_head = res.stdout.strip()
            if last_head and curr_head and curr_head != last_head:
                log_res = subprocess.run(["git", "-C", repo_dir, "log", "-1", "--format=%h | %an <%ae> | %s", "origin/main"], capture_output=True, text=True, timeout=5)
                commit_info = log_res.stdout.strip()
                print(f"[GIT-COLLAB-UPDATE] New commit on origin/main: {commit_info}", flush=True)
                record_collab_msg(time.strftime("%Y-%m-%dT%H:%M:%S"), "Git-Origin", "commit", f"New commit on main: {commit_info}")
            last_head = curr_head
        except Exception:
            pass
        time.sleep(20)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--check":
        _self_check()
        sys.exit(0)

    print("[AI-COOP-BRIDGE] Site B Collaboration & Security Streaming Daemon started.", flush=True)
    t_msg = threading.Thread(target=stream_messages, daemon=True)
    t_fw = threading.Thread(target=stream_firewall, daemon=True)
    t_git = threading.Thread(target=poll_git, daemon=True)

    t_msg.start()
    t_fw.start()
    t_git.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("[AI-COOP-BRIDGE] Stopped.", flush=True)
