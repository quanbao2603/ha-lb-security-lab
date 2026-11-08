# Transit-A — Site A (Quan Bảo)

Transit-A là Linux transit VM chạy Tailscale subnet routing + IP forwarding, nối
mạng lab Site A (`172.20.21.0/24`) vào tailnet để máy quản trị truy cập từ xa mà
không cài Tailscale lên từng web/LB node (tránh bypass firewall).

## Giao diện

| Interface | Mạng | Địa chỉ |
|---|---|---|
| ens33 | NAT (VMnet8) | DHCP 192.168.179.169/24, gateway 192.168.179.2 |
| ens37 | Lab (VMnet2) | static 172.20.21.5/24 |
| tailscale0 | Tailscale | 100.99.198.105/32 |

Cấu hình IP tĩnh lưu trong `/etc/network/interfaces` (file `interfaces`), giữ sau reboot.

## IP forwarding

Bật và persist bằng `/etc/sysctl.d/99-lab-router.conf` (file `99-lab-router.conf`):

```text
net.ipv4.ip_forward=1
```

Kiểm tra: `sysctl net.ipv4.ip_forward` → `= 1`.

## Tailscale subnet route

- Cài Tailscale, xác thực qua trình duyệt; Transit-A online tại `100.99.198.105`.
- Advertise route: `sudo tailscale up --advertise-routes=172.20.21.0/24`.
- Phê duyệt route trong Tailscale Admin Console (Machines → transit-a → Edit route
  settings → bật `172.20.21.0/24` → Save). Đã approve ngày 2026-11-08.
- Chi tiết + bằng chứng: `tailscale-route.md`.

## Kiểm chứng

Từ máy quản trị Windows (Transit-A phải bật):

```cmd
ping 172.20.21.10
curl http://172.20.21.100
```

Đã verify: ping `172.20.21.10` thành công 0% loss, **TTL=63** (xác nhận đi qua Transit-A
routing); curl tới LB/ VIP trả nội dung web.

## Liên kết ownership

- ACL/route policy Tailscale thuộc Minh Hùng (`configs/tailscale/`). Transit-A chỉ
  advertise subnet Site A; không tự sửa ACL.
- Transit-B + liên lạc hai site qua Tailscale là phần Minh Hùng (`lab/transit/site-b/`).
- Cảnh báo `--accept-routes is false` trên Transit-A không ngăn máy khác truy cập lab
  qua Transit-A (chỉ ảnh hưởng chiều nhận route từ peer khác).