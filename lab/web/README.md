# Web layer — Web-A / Web-B (Site A, Quan Bảo)

Hai web node chạy Nginx trên Debian 13 minimal, làm backend cho HAProxy trên LB-A.
Mỗi node có trang nhận diện riêng để quan sát cân bằng tải và endpoint `/healthz`
phục vụ health check.

## Bảng địa chỉ

| VM | NAT (SSH quản trị) | Lab VMnet2 (ens37) | Vai trò |
|---|---|---|---|
| Web-A | 192.168.179.171 | 172.20.21.20/24 | Backend A |
| Web-B | 192.168.179.172 | 172.20.21.30/24 | Backend B |

Mạng lab dùng chung `172.20.21.0/24` (VMnet2, DHCP tắt). Cấu hình IP tĩnh lưu trong
`/etc/network/interfaces`, giữ nguyên sau reboot.

## Thành phần đã triển khai

- Nginx chạy bằng systemd, `enabled` + `active`.
- Trang nhận diện node:
  - Web-A: `/var/www/html/index.html` → `<h1>Web-A</h1>` (backend 172.20.21.20).
  - Web-B: `/var/www/html/index.html` → `<h1>Web-B</h1>` (backend 172.20.21.30).
- Health endpoint: `/var/www/html/healthz` trả `200` với nội dung `ok`.
  HAProxy dùng `option httpchk GET /healthz` (xem `lab/load-balancer/`).
- Access log mặc định của Nginx: `/var/log/nginx/access.log` và `error.log`.

## Hardening SSH

Áp dụng drop-in `/etc/ssh/sshd_config.d/99-hardening.conf` (nội dung trong
`ssh-hardening.conf`):

```text
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
```

- Chỉ cho đăng nhập bằng SSH key (ed25519 của máy quản trị Windows).
- Cấm root SSH và cấm xác thực password/keyboard-interactive.
- Đã xác nhận: đăng nhập bằng key thành công; đăng nhập password bị
  `Permission denied (publickey)`.

Quy trình nạp key an toàn: nạp public key vào `~/.ssh/authorized_keys` → xác nhận
đăng nhập key-only từ máy quản trị → mới tắt password (tránh tự khóa truy cập).

## Tệp trong thư mục này

| Tệp | Nội dung |
|---|---|
| `web-a/index.html` | Trang nhận diện triển khai trên Web-A |
| `web-b/index.html` | Trang nhận diện triển khai trên Web-B |
| `healthz` | Nội dung endpoint `/healthz` (chung cho cả hai node) |
| `ssh-hardening.conf` | Drop-in sshd hardening (chung cho cả hai node) |

## Cách kiểm chứng

Trên mỗi web node:

```bash
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1/healthz   # kỳ vọng 200
curl http://127.0.0.1/                                            # trang nhận diện node
sudo sshd -T | grep -Ei 'permitrootlogin|passwordauthentication|kbdinteractiveauthentication'
```

Từ máy quản trị Windows (key-only):

```cmd
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no quanbao2603@192.168.179.171
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no quanbao2603@192.168.179.171
```

Bằng chứng: `evidence/quan-bao/20261108-quan-bao-web-healthz.md` và
`evidence/quan-bao/20261108-quan-bao-web-ssh-hardening.md`.