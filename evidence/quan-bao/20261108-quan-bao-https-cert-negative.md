# Evidence — HTTPS cert lab không được tin cậy mặc định (negative)

- Ngày: 2026-11-08 (Asia/Ho_Chi_Minh, +07)
- Người thực hiện: Quan Bảo
- Máy chạy: LB-A (172.20.21.10)
- Phạm vi: Site A — HTTPS lab / kiểm thử chứng chỉ

## Mục tiêu

Chứng minh frontend HTTPS dùng cert tự ký (lab): client không tin cậy mặc định,
phải dùng `-k` hoặc cài CA lab. Đây là hành vi đúng của cert lab, không phải cert
tin cậy công cộng.

## Lệnh

```bash
curl https://172.20.21.100        # không dùng -k
```

## Expected / Actual

Expected: lỗi xác thực chứng chỉ, không trả nội dung web.

Actual:

```text
curl: (60) SSL certificate problem: self-signed certificate
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it.
```

→ PASS (đúng kỳ vọng negative). Khi thêm `-k` (`curl -sk https://172.20.21.100`)
thì trả nội dung Web-A/Web-B bình thường (xem evidence failover).