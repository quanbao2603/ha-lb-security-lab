# Firewall Rule Matrix — Shared Cybersecurity HA Lab

> **Phụ trách:** Minh Hùng (Site B / Firewall / Database / Monitoring)  
> **Tham chiếu thiết kế:** `lab-v2.html` (Mục 3 & Mục 5)  
> **Nguyên tắc cốt lõi:** `Deny-by-default`, kiểm soát theo IP/Port tối thiểu, chống giả mạo IP (Anti-spoofing), NAT giới hạn duy nhất vào VIP, và ghi log đầy đủ cả `ALLOW` lẫn `DENY`.

---

## 1. Quy hoạch Vùng mạng (Zones) & Interface trên Firewall

| Zone | Dải mạng (Subnet) | Interface (Logic) | Gateway IP (Firewall) | Mục đích & Nguyên tắc bảo mật |
|---|---|---|---|---|
| **WAN-LAB** | `172.20.10.0/24` | `eth0` | `172.20.10.1/24` | Mạng phía ngoài mô phỏng (`Test-Client: 172.20.10.10`). Chỉ được phép vào `VIP 172.20.20.100` ở port `80, 443/TCP`. |
| **DMZ** | `172.20.20.0/24` | `eth1` | `172.20.20.1/24` | Vùng đệm chứa `LB-A (.10)`, `LB-B (.11)`, `VIP (.100)`, `Web-A (.21)`, `Web-B (.22)`, `Transit-A (.5)`, `Transit-B (.6)`. Không cho phép WAN đi thẳng vào Web node. |
| **APP** | `172.20.30.0/24` | `eth2` | `172.20.30.1/24` | Vùng Application thiết kế sẵn cho mở rộng tầng xử lý backend (xem giải thích APP network baseline ở Mục 3). |
| **DATABASE** | `172.20.40.0/24` | `eth3` | `172.20.40.1/24` | Vùng cơ sở dữ liệu cô lập chứa `DB-Primary (.11)` và `DB-Replica (.12)`. Tuyệt đối không nhận kết nối từ `WAN-LAB`. |
| **MGMT** | `172.20.50.0/24` | `eth4` | `172.20.50.1/24` | Vùng quản trị hệ thống & giám sát (`Log-Monitor: 172.20.50.10`). Chỉ mở SSH (`22/TCP`, key-only) từ `MGMT` tới các Linux VM. |

---

## 2. Bảng Firewall Rule Matrix Đầy Đủ

Thứ tự duyệt rule từ trên xuống dưới (First-match wins đối với các rule `drop`/`accept` tường minh):

| Rule ID | Nguồn (Source Zone / IP) | Đích (Destination Zone / IP) | Giao thức / Port | Policy | Log | Log Prefix | Mục đích & Ràng buộc kỹ thuật |
|---|---|---|---|---|---|---|---|
| **FW-00** | Any (Gói tin giả mạo IP / Invalid state) | Any | Any | **DENY (DROP)** | Có | `[FW-DENY-SPOOF]` / `[FW-DENY-INVALID]` | Anti-spoofing: chặn gói từ `WAN-LAB` giả mạo IP nội bộ (`172.20.20.0/16`, loopback `127.0.0.0/8`) và gói `ct state invalid`. |
| **FW-01** | `WAN-LAB` (`172.20.10.0/24`) | `VIP` (`172.20.20.100`) *(hoặc DNAT qua `172.20.10.1`)* | `TCP / 80, 443` | **ALLOW** | Có | `[FW-ALLOW-WAN-VIP]` | Cho phép client ngoài `WAN-LAB` truy cập dịch vụ Web qua HAProxy VIP (HTTP redirect & HTTPS lab). |
| **FW-02** | `WAN-LAB` (`172.20.10.0/24`) | `Web-A/B` trực tiếp (`172.20.20.21`, `172.20.20.22`) | `Any` | **DENY** | Có | `[FW-DENY-WAN-WEB-DIRECT]` | Chặn truy cập trực tiếp vào IP thực của Web server (chống bypass Load Balancer/VIP). |
| **FW-03** | `WAN-LAB` (`172.20.10.0/24`) | `DATABASE` (`172.20.40.0/24`) | `Any` | **DENY** | Có | `[FW-DENY-WAN-DB]` | Cô lập hoàn toàn vùng Database khỏi `WAN-LAB`. |
| **FW-04** | `WAN-LAB` (`172.20.10.0/24`) | `MGMT` (`172.20.50.0/24`) & `APP` (`172.20.30.0/24`) | `Any` | **DENY** | Có | `[FW-DENY-WAN-MGMT]` / `[FW-DENY-WAN-APP]` | Chặn mọi kết nối từ `WAN-LAB` vào mạng quản trị, SSH và tầng nội bộ. |
| **FW-05** | `LB-A, LB-B` (`172.20.20.10`, `172.20.20.11`) | `Web-A, Web-B` (`172.20.20.21`, `172.20.20.22`) | `TCP / 80` | **ALLOW** | Có | `[FW-ALLOW-LB-WEB]` | Chỉ Load Balancer được chuyển tiếp HTTP request và thăm dò `GET /healthz` vào 2 node Web. |
| **FW-06** | `Web-A, Web-B` (`172.20.20.21`, `172.20.20.22`) | `DB-Primary, DB-Replica` (`172.20.40.11`, `172.20.40.12`) | `TCP / 5432` | **ALLOW** | Có | `[FW-ALLOW-WEB-DB]` | Cho phép Web/App node truy vấn PostgreSQL theo đúng IP nguồn/đích cố định (kể cả sau khi promote Replica). |
| **FW-07** | `DB-Primary` (`172.20.40.11`) `<->` `DB-Replica` (`172.20.40.12`) | `DB-Replica` (`172.20.40.12`) `<->` `DB-Primary` (`172.20.40.11`) | `TCP / 5432` | **ALLOW** | Có | `[FW-ALLOW-DB-REPL]` | Mở hai chiều giữa đúng 2 IP Database để phục vụ Streaming Replication và đảo chiều sau failover/rejoin. |
| **FW-08** | `MGMT` (`172.20.50.0/24`) | Tất cả Linux VMs (`172.20.10.0/24` – `172.20.50.0/24`) | `TCP / 22` | **ALLOW** | Có | `[FW-ALLOW-MGMT-SSH]` | Quản trị tập trung từ vùng `MGMT`. Bắt buộc kết hợp hardening trên từng VM: **SSH key-only**, `PermitRootLogin no`, `PasswordAuthentication no`. |
| **FW-09** | Các VM nội bộ (`DMZ`, `DATABASE`, `MGMT`) | `Log-Monitor` (`172.20.50.10`) | `UDP, TCP / 514` | **ALLOW** | Có | `[FW-ALLOW-SYSLOG]` | Cho phép đẩy log tập trung (Firewall, HAProxy, Web, PostgreSQL) về máy `Log-Monitor`. |
| **FW-99** | `Any` | `Any` | `Any` | **DENY** | Có | `[FW-DENY-FWD-DEFAULT]` / `[FW-DENY-INPUT-DEFAULT]` | Rule mặc định cuối bảng (`policy drop`). Mọi luồng không khai báo tường minh ở trên đều bị chặn và ghi log. |

---

## 3. Giải thích về Thiết kế Vùng `APP` (`172.20.30.0/24`) trong Baseline Tuần Đầu

1. **Vai trò trong kiến trúc chuẩn:**
   - Trong sơ đồ kiến trúc 5 vùng (`WAN-LAB`, `DMZ`, `APP`, `DATABASE`, `MGMT`), dải mạng `APP (172.20.30.0/24)` được quy hoạch để đặt các Application Server xử lý nghiệp vụ tách biệt với tầng Web reverse-proxy ở `DMZ`.
2. **Quyết định Baseline tuần đầu (Tiết kiệm RAM trên VMware Workstation):**
   - Để đảm bảo tổng số VM chạy đồng thời nằm trong ngưỡng an toàn (6–7 VM active mỗi thời điểm trên 2 máy vật lý của Quan Bảo và Minh Hùng), **baseline tuần đầu không bắt buộc dựng thêm cặp App VM riêng**.
   - Hai máy `Web-A (172.20.20.21)` và `Web-B (172.20.20.22)` đóng vai trò **Web kiêm Application node tối giản** và được cấp rule tường minh (`FW-06`) kết nối tới `DB-Primary (172.20.40.11)` và `DB-Replica (172.20.40.12)` trên cổng `5432/TCP`.
3. **Lộ trình mở rộng (Upgrade Path sau khi đạt Baseline):**
   - Subnet `172.20.30.0/24` đã được khai báo sẵn biến `$APP_NET` và rule chống truy cập trái phép từ `WAN-LAB` trong `configs/firewall/nftables-firewall.conf`.
   - Khi bổ sung `App-A/App-B` vào `172.20.30.0/24`, chỉ cần thay `$WEB_NODES` bằng `$APP_NODES` tại rule `FW-06` và thêm rule `$WEB_NODES -> $APP_NODES` mà không cần thiết kế lại kiến trúc phân vùng.

---

## 4. Nguyên tắc Phối hợp với Tailscale & Transit VM

- Tailscale chỉ chạy trên `Transit-A (172.20.20.5)` và `Transit-B (172.20.20.6)` để nối mạng giữa máy Quan Bảo và máy Minh Hùng.
- **Không** cài Tailscale trên `Web-A/B`, `DB-Primary/Replica` hay `LB-A/B` nhằm ngăn chặn việc tạo đường hầm đi vòng qua (bypass) `Firewall-A/B`.
- Lưu lượng từ Site A (`Test-Client`, `LB-A`, `Web-A/B`) đi qua `Transit-A -> Transit-B` vào Site B (`DATABASE`, `MGMT`) đều bắt buộc đi qua `Firewall-A` (hoặc `Firewall-B` khi failover) để kiểm tra theo đúng bảng Rule Matrix trên.

<!-- ponytail: static IP sets in nftables for lab baseline; upgrade to dynamic nft named sets or VRRP conntrack-sync when scaling beyond 2 nodes per tier -->
