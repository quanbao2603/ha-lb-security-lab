# GIAO THỨC LIÊN LẠC PEER-TO-PEER ĐA KÊNH CHO AI-AGENT (PEERAGENT LINK - PAL)

## 1. Giới thiệu & Mục tiêu Kiến trúc

**PeerAgent Link (PAL)** là giao thức liên lạc ngang hàng (Peer-to-Peer) chuyên biệt, kết nối trực tiếp giữa hai máy thật (Minh Hùng: `192.168.1.26` và Quan Bảo: `192.168.1.7`) cùng các AI-Agent của hai bên.

### Các ưu điểm vượt trội:
- **Zero-Dependency:** 100% Python 3 Standard Library (không cần `pip install`), chạy tức thời trên cả Windows và Linux.
- **Kênh kép chịu lỗi cao (Dual-Channel HA):**
  - **Kênh chính (Primary - LAN Direct):** Đi trực tiếp qua switch/Wi-Fi nội bộ `192.168.1.0/24`, băng thông Gigabit, độ trễ RTT `< 1ms`.
  - **Kênh dự phòng (Fallback - Tailscale Mesh):** Đi qua overlay WireGuard `100.x.x.x`, tự động kích hoạt khi đứt cáp LAN hoặc đổi mạng.
- **Tự phục hồi & Chuyển vùng động (Self-Healing & Auto-Failover):** Heartbeat probe mỗi 3 giây; tự động chuyển sang Fallback khi Primary rớt 2 nhịp và tự động quay về Primary ngay khi phục hồi (Failback).
- **Đảm bảo toàn vẹn dữ liệu (Reliable Message Delivery):**
  - Mỗi bản tin mang mã định danh duy nhất `UUIDv4`, chữ ký kiểm tra toàn vẹn `SHA-256`.
  - Phản hồi biên nhận `ACK` bắt buộc. Tự động loại bỏ trùng lặp (Deduplication) qua SQLite Ledger.
- **Truyền tệp & Chứng cứ tốc độ cao (High-Speed Artifact Transfer):** Endpoint truyền tệp nhị phân trực tiếp (`/api/file/upload` & `/api/file/download`) đạt tốc độ dây (wire-speed), cho phép trao đổi ảnh chụp console, file dump DB, packet pcap ngay lập tức mà không cần đợi Git.
- **Agent Remote Procedure Call (RPC):** Cho phép AI bên này gọi trực tiếp hàm kiểm tra trên máy bên kia (ví dụ: `query_db_replication`, `ping`, `get_system_status`) và nhận JSON kết quả sau vài mili-giây.

---

## 2. Thông số Cấu hình Mạng Giữa Hai Máy Thật

| Tham số | Máy Minh Hùng (Site B) | Máy Quan Bảo (Site A) |
| :--- | :--- | :--- |
| **Node ID** | `site-b-minhhung` | `site-a-quanbao` |
| **IP LAN (Primary)** | `192.168.1.26` | `192.168.1.7` |
| **IP Tailscale (Fallback)**| `100.76.150.63` | `100.82.115.17` |
| **Port dịch vụ** | `8088` (Đã mở Windows Firewall) | `8088` (Cần mở Windows Firewall) |
| **File thực thi** | `scripts/p2p/agent_peer.py` | `scripts/p2p/agent_peer.py` |

---

## 3. Hướng dẫn Triển khai Trên Máy Quan Bảo

Bảo chỉ cần kéo git mới nhất về máy và chạy một lệnh:

### Bước 1: Mở Port 8088 trên Windows Firewall (PowerShell Run as Administrator)
```powershell
netsh advfirewall firewall add rule name="PeerAgent-8088" dir=in action=allow protocol=TCP localport=8088
```

### Bước 2: Chạy kiểm tra tự động (Self-Test)
```bash
python scripts/p2p/agent_peer.py --self-test
# Expected: [PAL-TEST] 3/3 Core Assertions PASSED (EXIT=0).
```

### Bước 3: Khởi động Daemon PAL trên máy Bảo
```bash
python scripts/p2p/agent_peer.py --node-id site-a-quanbao --peer-id site-b-minhhung --primary-url http://192.168.1.26:8088 --fallback-url http://100.76.150.63:8088 --server
```

---

## 4. Các Lệnh Điều Khiển & Giao Tiếp Dành Cho AI-Agent

### 4.1. Gửi thông điệp văn bản (Auto Channel Selection + ACK)
```bash
python scripts/p2p/agent_peer.py --send "Bao-AI: Đã khởi động xong module kiểm thử Web HA"
```

### 4.2. Gọi RPC truy vấn trực tiếp từ xa
```bash
# Kiểm tra trạng thái hệ thống máy Hùng:
python scripts/p2p/agent_peer.py --rpc get_system_status

# Truy vấn trực tiếp trạng thái streaming PostgreSQL:
python scripts/p2p/agent_peer.py --rpc query_db_replication
```

### 4.3. Bắn tệp tin/ảnh chụp màn hình sang máy đối tác (Wire-Speed)
```bash
python scripts/p2p/agent_peer.py --send-file D:/Lab/Evidance/20261110-web-failover.png
```

### 4.4. Xem trạng thái liên kết và độ trễ (RTT) của 2 kênh
```bash
python scripts/p2p/agent_peer.py --status
```
Output mẫu:
```text
=== PEERAGENT LINK (PAL) STATUS ===
Node ID:          site-b-minhhung
Target Peer:      site-a-quanbao
Primary LAN:      http://192.168.1.7:8088 -> Status: HEALTHY (RTT: 0.82 ms)
Fallback TS:      http://100.82.115.17:8088 -> Status: HEALTHY (RTT: 4.15 ms)
Active Route:     PRIMARY_LAN
```
