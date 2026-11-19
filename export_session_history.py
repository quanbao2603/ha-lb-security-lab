#!/usr/bin/env python3
"""Export full DSH session + subagent history (chat, thinking, tools, events) to Markdown."""
import collections
import datetime
import json
import pathlib
import zstandard

# ponytail: hardcoded current session IDs -> pass via sys.argv or auto-scan latest session dir when exporting multiple sessions
BASE_DIR = pathlib.Path(r"C:\Users\Administrator\.dsh\sessions\--D-Lab--")
MAIN_ID = "session-0467938f-1b0b-474c-86ca-2a382379b55b"
SUB_ID = "2ae324d7-d0d1-47c1-a4b7-f442d3d0cdb2"
OUT_PATH = pathlib.Path(r"D:\Lab\Lịch_sử_phiên_Triển_khai_Lab_Tailscale_SSH_2026-11-07.md")

TZ_VN = datetime.timezone(datetime.timedelta(hours=7))


def fmt_ts(ms):
    if not isinstance(ms, (int, float)):
        return str(ms or "N/A")
    dt = datetime.datetime.fromtimestamp(ms / 1000.0, tz=TZ_VN)
    return dt.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3] + " +07:00"


def load_events(session_id: str) -> list[dict]:
    path = BASE_DIR / session_id / "session.v4.jsonl.zstd"
    if not path.is_file():
        raise FileNotFoundError(f"Missing session file: {path}")
    with open(path, "rb") as fh:
        raw = zstandard.ZstdDecompressor().stream_reader(fh).read().decode("utf-8", errors="replace")
    return [json.loads(line) for line in raw.splitlines() if line.strip()]


def fence(text: str, lang: str = "text") -> str:
    text = text or ""
    ticks = "````" if "```" in text else "```"
    return f"{ticks}{lang}\n{text.rstrip()}\n{ticks}"


def render_tool_summary_table(events: list[dict]) -> list[str]:
    lines = [
        "| Seq | Thời gian (+07) | Turn.Step | Tool | Call ID | Tóm tắt tham số |",
        "|---:|---|---|---|---|---|",
    ]
    for ev in events:
        if ev.get("type") == "tool/call":
            d = ev.get("data") or {}
            args_raw = d.get("arguments", "")
            try:
                args_obj = json.loads(args_raw) if isinstance(args_raw, str) else args_raw
                if isinstance(args_obj, dict):
                    summary = ", ".join(f"{k}={repr(v)[:60]}" for k, v in list(args_obj.items())[:3])
                else:
                    summary = str(args_obj)[:100]
            except Exception:
                summary = str(args_raw)[:100]
            summary = summary.replace("|", "\\|").replace("\n", " ")
            lines.append(
                f"| `{ev.get('seq')}` | `{fmt_ts(ev.get('time'))}` | "
                f"`{d.get('turn')}.{d.get('step')}` | **`{d.get('name')}`** | "
                f"`{d.get('callId')}` | {summary} |"
            )
    return lines


def render_session_events(events: list[dict], session_label: str) -> list[str]:
    out = [f"## {session_label}", ""]
    translations = {}
    for ev in events:
        if ev.get("type") == "plugin:translator/result":
            d = ev.get("data") or {}
            req_seq = d.get("requestSeq")
            if req_seq is not None:
                translations[req_seq] = d.get("text", "")

    for ev in events:
        etype = ev.get("type", "unknown")
        seq = ev.get("seq", 0)
        ts = fmt_ts(ev.get("time"))
        d = ev.get("data") or {}

        if etype == "session":
            out.append(f"### [Header] Khởi tạo Session `{ev.get('id')}`")
            out.append(fence(json.dumps(ev, ensure_ascii=False, indent=2), "json"))
            out.append("")
            continue

        if etype == "turn/start":
            out.append(f"---")
            out.append(f"### 🟢 TURN {d.get('turn')} START — `seq {seq}` ({ts})")
            out.append("")
            continue

        if etype == "turn/end":
            out.append(f"### 🔴 TURN {d.get('turn')} END (`reason: {d.get('reason')}`) — `seq {seq}` ({ts})")
            out.append("")
            continue

        if etype == "step/start":
            out.append(f"#### ▶️ Step {d.get('turn')}.{d.get('step')} Start — `seq {seq}` ({ts})")
            out.append("")
            continue

        if etype == "step/end":
            out.append(f"#### ⏹️ Step {d.get('turn')}.{d.get('step')} End — `seq {seq}` ({ts})")
            out.append("")
            continue

        if etype == "user/message":
            src = d.get("source") or {}
            kind = src.get("kind", "user")
            parts = d.get("content") or []
            full_text = "\n\n".join(p.get("text", "") for p in parts if isinstance(p, dict))
            if kind == "user":
                out.append(f"### 👤 USER MESSAGE — `seq {seq}` ({ts})")
                out.append(f"- **Message ID:** `{d.get('id')}` | **Source:** `{json.dumps(src, ensure_ascii=False)}`")
                out.append("")
                out.append(full_text)
                out.append("")
            elif kind in ("agent-message", "subagent-settled"):
                out.append(f"### 🤝 SUB-AGENT → LEAD MESSAGE (`{kind}`) — `seq {seq}` ({ts})")
                out.append(f"- **Source metadata:** `{json.dumps(src, ensure_ascii=False)}`")
                out.append("")
                out.append(full_text)
                out.append("")
            else:
                out.append(f"<details><summary>⚙️ Context Injection (<code>user/message</code> | kind=<code>{kind}</code> | <code>seq {seq}</code> | {ts} | {len(full_text)} chars)</summary>\n")
                out.append(fence(full_text, "xml"))
                out.append("</details>\n")
            continue

        if etype in ("system/message", "developer/message"):
            msg = d.get("message") or {}
            parts = msg.get("content") or []
            out.append(f"<details><summary>🛠️ {etype} (Turn {d.get('turn')}, Step {d.get('step')} | <code>seq {seq}</code> | {ts})</summary>\n")
            out.append(fence(json.dumps(parts, ensure_ascii=False, indent=2), "json"))
            out.append("</details>\n")
            continue

        if etype == "assistant/message":
            msg = d.get("message") or {}
            usage = d.get("usage") or {}
            parts = msg.get("content") or []
            out.append(
                f"### 🤖 ASSISTANT MESSAGE (Turn {d.get('turn')}, Step {d.get('step')}) — `seq {seq}` ({ts})"
            )
            if usage:
                out.append(f"- **Token Usage:** `{json.dumps(usage, ensure_ascii=False)}`")
            out.append("")
            for idx, p in enumerate(parts, 1):
                ptype = p.get("type")
                if ptype == "reasoning":
                    out.append(f"#### 🧠 Thinking / Reasoning (Part {idx})")
                    out.append(fence(p.get("text", ""), "text"))
                    out.append("")
                elif ptype == "text":
                    out.append(f"#### 💬 Assistant Response Text (Part {idx})")
                    out.append(p.get("text", ""))
                    out.append("")
                elif ptype == "tool-call":
                    out.append(
                        f"#### 🔧 Assistant Tool Invocation Intent (Part {idx}): `{p.get('name')}` (`{p.get('id')}`)"
                    )
                    try:
                        parsed_args = json.dumps(json.loads(p.get("arguments", "{}")), ensure_ascii=False, indent=2)
                        out.append(fence(parsed_args, "json"))
                    except Exception:
                        out.append(fence(str(p.get("arguments", "")), "json"))
                    out.append("")
                else:
                    out.append(fence(json.dumps(p, ensure_ascii=False, indent=2), "json"))
                    out.append("")
            continue

        if etype == "tool/call":
            out.append(
                f"### 🛠️ TOOL CALL: `{d.get('name')}` (`{d.get('callId')}`) — `seq {seq}` ({ts})"
            )
            out.append(f"- **Turn.Step:** `{d.get('turn')}.{d.get('step')}`")
            args_raw = d.get("arguments", "")
            try:
                pretty = json.dumps(json.loads(args_raw), ensure_ascii=False, indent=2)
                out.append(fence(pretty, "json"))
            except Exception:
                out.append(fence(str(args_raw), "json"))
            out.append("")
            continue

        if etype == "tool/result":
            msg = d.get("message") or {}
            call_id = msg.get("toolCallId") or (msg.get("source") or {}).get("callId")
            is_err = msg.get("isError", False)
            meta = d.get("meta") or {}
            parts = msg.get("content") or []
            full_res = "\n".join(p.get("text", "") for p in parts if isinstance(p, dict))
            out.append(
                f"### 📥 TOOL RESULT (`{call_id}` | `isError={is_err}`) — `seq {seq}` ({ts})"
            )
            if meta:
                out.append(f"- **Meta:** `{json.dumps(meta, ensure_ascii=False)}`")
            out.append(fence(full_res, "text"))
            out.append("")
            continue

        if etype in ("subagent/catalog", "subagent/descriptor", "job/registered", "job/settled", "llm/retry", "llm/retry-started", "assistant/attempt"):
            out.append(f"#### 📌 Runtime Event `{etype}` — `seq {seq}` ({ts})")
            out.append(fence(json.dumps(d, ensure_ascii=False, indent=2), "json"))
            out.append("")
            continue

        if etype in ("plugin:translator/request", "plugin:translator/result"):
            out.append(f"<details><summary>🌐 Translator Event <code>{etype}</code> (<code>seq {seq}</code> | {ts})</summary>\n")
            out.append(fence(json.dumps(d, ensure_ascii=False, indent=2), "json"))
            out.append("</details>\n")
            continue

        # Any other event (sandbox/mode, approval/policy, request/header, session/title, agent/inbox/spliced, etc.)
        out.append(f"<details><summary>🔹 System Event <code>{etype}</code> (<code>seq {seq}</code> | {ts})</summary>\n")
        out.append(fence(json.dumps(ev, ensure_ascii=False, indent=2), "json"))
        out.append("</details>\n")

    return out


def main():
    main_events = load_events(MAIN_ID)
    sub_events = load_events(SUB_ID)

    # Self-checks (assert-based verification)
    assert len(main_events) >= 230, f"Expected >=230 main events, got {len(main_events)}"
    assert len(sub_events) >= 120, f"Expected >=120 subagent events, got {len(sub_events)}"

    main_counts = collections.Counter(e.get("type") for e in main_events)
    sub_counts = collections.Counter(e.get("type") for e in sub_events)
    now_str = datetime.datetime.now(tz=TZ_VN).strftime("%Y-%m-%d %H:%M:%S +07:00")

    doc = [
        "# HỒ SƠ XUẤT TOÀN BỘ LỊCH SỬ PHIÊN LÀM VIỆC, TOOL CALLS & SUB-AGENT",
        "",
        f"- **Thời điểm xuất:** `{now_str}`",
        f"- **Thư mục làm việc:** `D:\\Lab`",
        f"- **Phiên chính (Team Lead):** `{MAIN_ID}` (*Triển khai Lab HA-LB-Security với Tailscale & SSH*)",
        f"- **Phiên Sub-Agent (Child Agent):** `{SUB_ID}` (*Configure Windows Tailscale, OpenSSH, and Firewall Rules*)",
        f"- **Tổng số sự kiện đã ghi nhận:** `{len(main_events)}` sự kiện (Phiên chính) + `{len(sub_events)}` sự kiện (Sub-Agent) = **`{len(main_events) + len(sub_events)}` sự kiện**",
        "",
        "---",
        "",
        "## 1. Thống kê tổng hợp & Mục lục nhanh",
        "",
        "### 1.1. Phân bố sự kiện theo loại (Event Types)",
        "",
        "| Loại sự kiện (`type`) | Số lượng ở Phiên chính (`lead`) | Số lượng ở Sub-Agent (`2ae324d7`) |",
        "|---|---:|---:|",
    ]

    all_types = sorted(set(main_counts.keys()) | set(sub_counts.keys()))
    for t in all_types:
        doc.append(f"| `{t}` | {main_counts.get(t, 0)} | {sub_counts.get(t, 0)} |")

    doc.extend([
        "",
        "### 1.2. Danh sách toàn bộ Tool Calls trong Phiên chính (`lead`)",
        "",
        *render_tool_summary_table(main_events),
        "",
        "### 1.3. Danh sách toàn bộ Tool Calls trong Phiên Sub-Agent (`2ae324d7-d0d1-47c1-a4b7-f442d3d0cdb2`)",
        "",
        *render_tool_summary_table(sub_events),
        "",
        "---",
        "",
        *render_session_events(
            main_events,
            f"2. Toàn bộ lịch sử chi tiết Phiên chính (Team Lead — `{MAIN_ID}`)",
        ),
        "---",
        "",
        *render_session_events(
            sub_events,
            f"3. Toàn bộ lịch sử chi tiết Phiên Sub-Agent (`{SUB_ID}` — Setup Tailscale and OpenSSH host)",
        ),
    ])

    content = "\n".join(doc) + "\n"
    OUT_PATH.write_text(content, encoding="utf-8")

    # Post-write integrity assertions
    assert OUT_PATH.is_file(), "Output file was not created"
    written = OUT_PATH.read_text(encoding="utf-8")
    assert MAIN_ID in written and SUB_ID in written, "Missing session IDs in output"
    assert "### 🛠️ TOOL CALL:" in written and "### 📥 TOOL RESULT" in written, "Missing tool call/result blocks"
    assert "### 🤝 SUB-AGENT → LEAD MESSAGE" in written, "Missing subagent collaboration block"
    print(f"OK: Exported {len(main_events)} main events + {len(sub_events)} subagent events")
    print(f"File: {OUT_PATH} ({OUT_PATH.stat().st_size:,} bytes, {len(written.splitlines()):,} lines)")


if __name__ == "__main__":
    main()
