# Runbook vận hành — LB + Web (Site A, Quan Bảo)

## Thứ tự bật VM (tiết kiệm RAM)

- Cấu hình từng máy: chỉ bật máy đó.
- Test dịch vụ/failover: bật **LB-A + Web-A + Web-B** (3 VM). Thêm Test-Client nếu
  cần góc nhìn client. Thêm Transit-A nếu truy cập từ Windows qua Tailscale.
- Không bật cả 5 VM cùng lúc nếu không cần.

## Khởi động / dừng dịch vụ

```bash
# Web node
sudo systemctl start nginx      # hoặc stop / restart
systemctl is-active nginx

# LB-A
sudo systemctl restart haproxy
sudo systemctl restart keepalived
systemctl is-active haproxy keepalived
```

## Kiểm tra nhanh

```bash
# Trên LB-A
ip -br addr show ens37                       # thấy .10 và VIP .100
for i in 1 2 3 4; do curl -sk https://172.20.21.100; done   # luân phiên A/B
curl -s -o /dev/null -w '%{http_code}\n' -u 'admin:<mat-khu>' http://172.20.21.10:8404/stats  # 200
# Hoặc dùng script
STATS_PASS='<mat-khu>' bash scripts/quan-bao/check_lb.sh
```

## Quy trình failover web (demo)

1. Baseline: `for i in 1..6; curl -sk https://172.20.21.100` → luân phiên A/B.
2. Trên Web-A: `sudo systemctl stop nginx`. Chờ ~10 giây.
3. Curl lại → toàn bộ Web-B (HAProxy loại backend DOWN qua `/healthz`).
4. Trên Web-A: `sudo systemctl start nginx`. Chờ ~10 giây.
5. Curl lại → luân phiên A/B (tự đưa backend trở lại).
6. Lưu evidence vào `evidence/quan-bao/YYYYMMDD-quan-bao-<test>.md`.

## Tạo lại cert lab (khi hết hạn / đổi)

```bash
sudo openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout /etc/haproxy/lab.key -out /etc/haproxy/lab.crt \
  -subj "/C=VN/ST=HCM/L=HCM/O=Lab/OU=Security/CN=lab.local"
sudo bash -c 'cat /etc/haproxy/lab.crt /etc/haproxy/lab.key > /etc/haproxy/lab.pem'
sudo chmod 600 /etc/haproxy/lab.pem /etc/haproxy/lab.key
sudo systemctl restart haproxy
```

## Troubleshooting

| Triệu chứng | Nguyên nhân thường gặp | Xử lý |
|---|---|---|
| `503 Service Unavailable` | backend chưa bật / Nginx dừng | bật Web-A/Web-B, `systemctl start nginx` |
| `VmxStats / scoreboard failed` khi bật VM thứ 2 | `.vmx` trỏ chung scoreboard | đổi `vmxstats.filename` riêng; đóng VMware, dọn `.lck` |
| SSH `Permission denied (publickey)` | đã tắt password, chưa có key | nạp key qua console VMware rồi SSH lại |
| Stats 401 dù đúng mật khẩu | mật khẩu chứa `#` (comment) | đổi mật khẩu bỏ ký tự đặc biệt |
| VIP không gán | Keepalived dừng | `systemctl restart keepalived`; kiểm tra `interface ens37` |

## An toàn

- Không commit mật khẩu stats, token Tailscale, private key, cert (`*.pem`/`*.key`).
- Mọi thay đổi firewall/DB thuộc Minh Hùng; không tự sửa trong phần Bảo.