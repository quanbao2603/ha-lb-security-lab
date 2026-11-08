# Scripts — phần Quan Bảo (Site A)

Script kiểm tra phía client/LB, không chứa secret. Chạy trong mạng lab cô lập.

| Script | Mục đích | Chạy ở đâu |
|---|---|---|
| `check_lb.sh` | Positive: `/healthz`, round-robin VIP HTTPS, stats 200/401 | LB-A hoặc Test-Client |
| `negative_tests.sh` | Negative: web bypass, HTTPS cert, SSH WAN, DB trực tiếp | Test-Client |

## Cách chạy

```bash
# Positive (truyền mật khẩu stats qua biến môi trường, không hardcode)
STATS_PASS='<mat-khu-stats>' bash check_lb.sh

# Negative
bash negative_tests.sh
```

## Lưu ý

- `negative_tests.sh` mục web bypass / SSH WAN / DB cần **firewall của Minh Hùng**
  mới chặn thật sự. Hiện lab chưa có firewall nên các mục đó ghi nhận trạng thái
  "chờ firewall"; chạy lại sau khi Hùng dựng firewall/DB.
- Không commit mật khẩu, token, private key. Mật khẩu stats truyền qua biến môi trường.