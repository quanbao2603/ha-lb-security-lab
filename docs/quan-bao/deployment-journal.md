# Nhật ký triển khai — Quan Bảo (Site A)

Múi giờ: Asia/Ho_Chi_Minh (+07). Nền tảng: VMware Workstation, Debian 13 minimal.

## 2026-11-07 — Baseline + mạng lab

- Cài Transit-A (Debian 13 netinst, text-mode, không GUI, SSH server + standard utilities).
- Cài `sudo`, thêm `quanbao2603` vào nhóm sudo (cần đăng nhập lại để có hiệu lực).
- Clone full 4 VM: LB-A, Web-A, Web-B, Test-Client (MAC mới).
- Mỗi clone: hostname riêng, `/etc/machine-id` mới, tạo lại SSH host keys.
- Tạo VMnet2 host-only, tắt DHCP, subnet `172.20.21.0/24`.
- Gắn NIC2 vào các VM; đặt IP tĩnh lab và persist trong `/etc/network/interfaces`:
  Transit-A .5, LB-A .10, Web-A .20, Web-B .30, Test-Client .40. Kiểm tra giữ sau reboot.
- Transit-A: bật + persist IPv4 forwarding (`99-lab-router.conf`).
- Snapshot: `baseline-debian13-sudo`, `baseline-tailscale-online`.

## 2026-11-08 — Tailscale, web, LB, kiểm thử

- Transit-A: cài Tailscale, xác thực, online `100.99.198.105`; advertise
  `172.20.21.0/24` và approve trong Admin Console. Verify Windows ping TTL=63 + curl.
- Web-A/Web-B: Nginx + trang nhận diện node; thêm `/healthz` (200).
- Hardening web: SSH key-only (nạp key → xác nhận → tắt password), cấm root SSH.
- LB-A: HAProxy round-robin → health check `GET /healthz` → HTTPS cert lab →
  stats nội bộ có mật khẩu → Keepalived giữ VIP `172.20.21.100`, frontend bind VIP.
- Kiểm thử: failover web qua VIP (tắt Web-A → Web-B; khôi phục → luân phiên);
  HTTPS cert negative (không `-k` → lỗi verify).
- Điền repo phần Bảo: configs, lab/transit/site-a, lab/web, lab/load-balancer,
  scripts, lab/testing/quan-bao, evidence, docs.

## Vấn đề đã xử lý (root cause)

| Vấn đề | Nguyên nhân | Cách xử lý |
|---|---|---|
| `sudo: command not found` | bản minimal chưa cài sudo | `apt install sudo` + `usermod -aG sudo` |
| machine-id trùng sau clone | clone giữ ID cũ | `rm` + `systemd-machine-id-setup` |
| SSH host key trùng / cảnh báo known_hosts | clone giữ key cũ | tạo lại host keys; `ssh-keygen -R <ip>` phía Windows |
| `sudo: unable to resolve host` | `/etc/hosts` còn tên clone | sửa `127.0.1.1` đúng hostname |
| Ping gateway .1 thất bại | gateway NAT thật là .2 | dùng `192.168.179.2` |
| **VmxStats / scoreboard failed** | `.vmx` clone trỏ chung `Transit-A.scoreboard` | đổi `vmxstats.filename` riêng từng VM; dọn `.lck` khi VMware đóng hết |
| Stats 401 cả hai chiều | mật khẩu chứa `#` bị HAProxy cắt thành comment | đổi mật khẩu bỏ `#` |

## Quyết định

- Dùng một subnet lab chung `172.20.21.0/24` (đơn giản hóa, tiết kiệm RAM); phân vùng
  nhiều zone + firewall là phần Minh Hùng.
- Keepalived một node MASTER (chưa có LB-B): giữ VIP, chưa demo failover chính LB.
- Cert lab tự ký chỉ trên LB-A, không commit (`.gitignore` chặn `*.pem`/`*.key`).
- Làm việc trên `main` chung + folder ownership; không sửa đồng thời file chung.