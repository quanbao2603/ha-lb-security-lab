# Evidence — Web health endpoint `/healthz`

- Ngày: 2026-11-08 (Asia/Ho_Chi_Minh, +07)
- Người thực hiện: Quan Bảo
- Máy chạy lệnh: Web-A (192.168.179.171), Web-B (192.168.179.172)
- Phạm vi: Site A — web layer

## Mục tiêu

Xác nhận mỗi web node có endpoint `/healthz` trả HTTP 200 để HAProxy health check
(`option httpchk GET /healthz`) đánh giá backend UP.

## Lệnh thực hiện (trên mỗi web node)

```bash
echo ok | sudo tee /var/www/html/healthz
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1/healthz
```

## Expected / Actual

| Máy | Expected | Actual | Kết quả |
|---|---|---|---|
| Web-A | 200 | 200 | PASS |
| Web-B | 200 | 200 | PASS |

## Output quan sát

Web-A:

```text
ok
200
```

Web-B:

```text
ok
200
```

Ghi chú: `/healthz` là tệp tĩnh trong `/var/www/html/`, Nginx trả 200 không cần sửa
cấu hình site. HAProxy chuyển sang check `/healthz` ở mốc LB (xem evidence LB).