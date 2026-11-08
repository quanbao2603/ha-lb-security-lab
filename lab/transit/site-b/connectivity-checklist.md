# Checklist Kiểm Tra Kết Nối & Route: Transit-B (172.20.20.6) ↔ Transit-A (172.20.20.5)

## 1. Điều kiện tiên quyết (Pre-flight Checks)

- [ ] **Transit-B (`172.20.20.6/24`)** và **Firewall-A (`172.20.20.1/24`)** đã bật theo Profile P1 hoặc P2.
- [ ] **Transit-A (`172.20.20.5/24`)** phía máy Quan Bảo đã bật và online trên cùng Tailnet.
- [ ] Cả hai node đã bật `net.ipv4.ip_forward = 1`.
- [ ] Subnet routes của `Transit-A` và `Transit-B` đã được **Approve** trên Tailscale Admin Console.
- [ ] Không cài Tailscale trực tiếp trên `DB-Primary`, `DB-Replica`, `Web-A`, `Web-B`.

---

## 2. Kiểm tra tại chỗ và kết nối từ Transit-B (`172.20.20.6`) sang Transit-A (`172.20.20.5`)

| Bước | Hạng mục kiểm tra | Lệnh thực thi trên `Transit-B` | Kết quả kỳ vọng (Expected) | Đạt |
|---:|---|---|---|---|
| 1 | Kiểm tra IP DMZ & Tailscale IF | `ip -br addr show` | Card LAN có `172.20.20.6/24`, `tailscale0` trạng thái `UP` | [ ] |
| 2 | Kiểm tra IP Forwarding | `sysctl net.ipv4.ip_forward` | `net.ipv4.ip_forward = 1` | [ ] |
| 3 | Kiểm tra route nội bộ về Firewall-A | `ip route show` | `172.20.40.0/24 via 172.20.20.1` và `172.20.50.0/24 via 172.20.20.1` | [ ] |
| 4 | Kiểm tra bộ lọc nftables | `sudo nft list table inet transit_filter` | Policy `drop` mặc định, có rule `[TRANSIT-B-BYPASS-DROP]` | [ ] |
| 5 | Ping Gateway Firewall-A | `ping -c 3 172.20.20.1` | `0% packet loss` | [ ] |
| 6 | Kiểm tra Tailscale peer tới Transit-A | `tailscale ping -c 3 transit-a` | Nhận phản hồi `pong` từ `transit-a` | [ ] |
| 7 | Ping IP DMZ của Transit-A | `ping -c 3 172.20.20.5` | `0% packet loss` (đi qua subnet route Tailscale) | [ ] |
| 8 | Kiểm tra đường đi tới Transit-A | `traceroute -n 172.20.20.5` | Đi qua `tailscale0` sang `Transit-A` (`172.20.20.5`) | [ ] |
| 9 | Ping VIP / Web phía Site A | `ping -c 3 172.20.20.21` | `0% packet loss` từ `Transit-B` tới `Web-A` (nếu Web-A đã bật) | [ ] |

---

## 3. Kiểm tra chiều ngược lại & Xác minh Không Bypass Firewall (Từ Transit-A / Site A sang Site B)

Thực hiện phối hợp với Quan Bảo từ `Transit-A (172.20.20.5)` và `Web-A (172.20.20.21)`:

| Bước | Kịch bản kiểm thử | Lệnh thực thi từ Site A | Kết quả kỳ vọng (Expected) | Đạt |
|---:|---|---|---|---|
| 1 | Transit-A ping Transit-B DMZ IP | `ping -c 3 172.20.20.6` | `0% packet loss` | [ ] |
| 2 | Kiểm tra lộ trình vào DB bắt buộc qua Firewall-A | `traceroute -n 172.20.40.11` | Hop qua `Transit-B` → `172.20.20.1` (`Firewall-A`) → `172.20.40.11` | [ ] |
| 3 | Web-A kết nối cổng DB hợp lệ | `nc -zv 172.20.40.11 5432` (hoặc `3306`) | Thành công khi `Firewall-A` đã mở rule cho IP `Web-A` | [ ] |
| 4 | Chặn cổng không được phép vào DB (Anti-Bypass) | `nc -zv -w 3 172.20.40.11 22` | Bị chặn (`Timeout/Filtered`), tăng counter drop tại `Transit-B` / `Firewall-A` | [ ] |
| 5 | Subnet không advertise (`172.20.10.0/24`) bị cô lập | `ping -c 2 -W 2 172.20.10.1` (qua Tailscale) | Không có route qua Tailscale (`172.20.10.0/24` không được advertise) | [ ] |

---

## 4. Mẫu ghi nhận bằng chứng (Lưu vào `evidence/minh-hung/`)

Tên file chuẩn: `YYYYMMDD-minh-hung-transit-b-connectivity.md`

```text
Thời gian (ICT): YYYY-MM-DD HH:MM:SS +07:00
Máy thực hiện : transit-b (172.20.20.6)
Lệnh thực thi  : sysctl net.ipv4.ip_forward && ip route show && ping -c 3 172.20.20.5
Expected       : ip_forward=1, route .40.0/24 & .50.0/24 qua 172.20.20.1, ping 172.20.20.5 0% loss
Actual         : [Dán kết quả lệnh thực tế - đã ẩn/loại bỏ mọi thông tin nhạy cảm]
Kết luận       : PASS / FAIL
```
