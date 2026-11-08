# Load balancer — LB-A (Site A, Quan Bảo)

LB-A chạy HAProxy 3.0.11 + Keepalived trên Debian 13 minimal, cân bằng tải cho
Web-A/Web-B, kết thúc TLS bằng cert lab và giữ VIP bằng Keepalived.

## Bảng địa chỉ

| Thành phần | Địa chỉ | Ghi chú |
|---|---|---|
| LB-A NAT (SSH) | 192.168.179.170 | quản trị |
| LB-A lab (ens37) | 172.20.21.10/24 | IP thật |
| VIP dịch vụ | 172.20.21.100/24 | Keepalived giữ, client truy cập VIP |
| Backend Web-A | 172.20.21.20:80 | health check `/healthz` |
| Backend Web-B | 172.20.21.30:80 | health check `/healthz` |
| Stats nội bộ | 172.20.21.10:8404/stats | bảo vệ bằng mật khẩu |

## Thành phần đã triển khai

- HAProxy:
  - `frontend web_http` bind VIP `172.20.21.100:80`.
  - `frontend web_https` bind VIP `172.20.21.100:443 ssl crt /etc/haproxy/lab.pem`.
  - `backend web_backend` round-robin, `option httpchk GET /healthz`, expect 200.
  - `listen stats` bind IP thật `172.20.21.10:8404`, `stats auth` (mật khẩu đặt cục bộ).
- Keepalived: VRRP instance `VI_1`, state MASTER, interface `ens37`,
  `virtual_router_id 51`, priority 100, giữ VIP `172.20.21.100/24`.
- Sysctl: `net.ipv4.ip_nonlocal_bind=1` để HAProxy bind được VIP kể cả khi VIP
  chưa kịp gán (file `sysctl-nonlocal-bind.conf`).

## Giới hạn thiết kế (ghi rõ)

Site A chỉ có **một** LB-A (không có LB-B trong danh sách VM của cả hai thành viên).
Keepalived chạy một node MASTER nên VIP luôn nằm trên LB-A; **chưa demo được failover
chính LB**. Failover backend web (tắt Web-A → Web-B) đã kiểm chứng. Nếu ghép thêm LB-B
với Minh Hùng, cấu hình VRRP đối xứng (BACKUP, priority thấp hơn) sẽ cho failover LB.

## Cert lab (không commit)

Cert/key tự ký chỉ nằm trên LB-A, không đưa vào repo (`.gitignore` chặn `*.pem`,
`*.key`). Tạo lại trên LB-A khi cần:

```bash
sudo openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout /etc/haproxy/lab.key -out /etc/haproxy/lab.crt \
  -subj "/C=VN/ST=HCM/L=HCM/O=Lab/OU=Security/CN=lab.local"
sudo bash -c 'cat /etc/haproxy/lab.crt /etc/haproxy/lab.key > /etc/haproxy/lab.pem'
sudo chmod 600 /etc/haproxy/lab.pem /etc/haproxy/lab.key
```

HAProxy ghép cert+key vào `lab.pem`. Client lab dùng `curl -k` (bỏ qua xác thực cert
tự ký); đây là cert lab, không phải cert tin cậy công cộng.

## Secret đã loại bỏ khi export

- `haproxy.cfg` trong repo thay mật khẩu stats bằng `__REDACTED_SET_LOCALLY__`.
  Mật khẩu thật chỉ đặt trên LB-A. Lưu ý HAProxy: tránh ký tự `#` trong mật khẩu
  (bị hiểu là comment).

## Cách kiểm chứng

Trên LB-A:

```bash
systemctl is-active haproxy keepalived
ip -br addr show ens37                       # thấy 172.20.21.10 và 172.20.21.100
for i in 1 2 3 4; do curl -sk https://172.20.21.100; done   # luân phiên Web-A/Web-B
curl -s -o /dev/null -w '%{http_code}\n' -u 'admin:<mat-khu>' http://172.20.21.10:8404/stats  # 200
curl -s -o /dev/null -w '%{http_code}\n' http://172.20.21.10:8404/stats                        # 401
```

Bằng chứng: `evidence/quan-bao/20261108-quan-bao-lb-https-stats-vip.md`.