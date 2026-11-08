# IP plan thực tế — Site A (Quan Bảo)

## Subnet đang dùng

Lab Site A dùng **một subnet chung** `172.20.21.0/24` trên VMnet2 (host-only, DHCP tắt).
Đây là lựa chọn đơn giản hóa cho mô hình shared-single-lab và giới hạn RAM; phân vùng
nhiều zone (WAN/DMZ/APP/DATABASE/MGMT) và firewall deny-by-default là phần Minh Hùng
triển khai sau (xem `lab-v2.html` mục 3 và `lab/firewall/`).

| Mạng | Dải | Ghi chú |
|---|---|---|
| NAT quản trị (VMnet8) | 192.168.179.0/24 | DHCP VMware, gateway 192.168.179.2; chỉ SSH/Internet |
| Lab (VMnet2) | 172.20.21.0/24 | DHCP tắt, IP tĩnh; đường dịch vụ + kiểm thử |
| Tailscale | 100.99.198.105/32 | Transit-A subnet router, advertise 172.20.21.0/24 |

## Bảng địa chỉ lab

| Thiết bị | IP lab | Vai trò |
|---|---|---|
| Transit-A | 172.20.21.5 | subnet router, IP forwarding |
| LB-A | 172.20.21.10 | HAProxy + Keepalived (IP thật) |
| VIP dịch vụ | 172.20.21.100 | Keepalived giữ; client truy cập VIP 80/443 |
| Web-A | 172.20.21.20 | backend Nginx |
| Web-B | 172.20.21.30 | backend Nginx |
| Test-Client | 172.20.21.40 | client kiểm thử |

## Đường truy cập dịch vụ

- Trong lab: Test-Client → VIP `172.20.21.100` (HTTP/HTTPS) → HAProxy → Web-A/Web-B.
- Từ máy quản trị Windows qua Tailscale: Windows → Transit-A (`100.99.198.105`,
  subnet route `172.20.21.0/24`) → VIP/LB-A → backend. Đã verify ping TTL=63 và curl.
- Stats nội bộ: `172.20.21.10:8404/stats` (có mật khẩu), không public WAN.

## Liên kết ownership

- Route/ACL Tailscale: policy thuộc `configs/tailscale/` (Minh Hùng); Bảo ghi route
  đã advertise + bằng chứng approve trong `lab/transit/site-a/`.
- Phân vùng + firewall: `lab/firewall/` (Minh Hùng). IP plan này là đầu vào để Hùng
  áp zone/rule sau.