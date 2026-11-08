# Evidence — Web failover qua HTTPS/VIP

- Ngày: 2026-11-08 (Asia/Ho_Chi_Minh, +07)
- Người thực hiện: Quan Bảo
- Máy chạy lệnh curl: LB-A (172.20.21.10); máy bị dừng: Web-A (172.20.21.20)
- VM bật: LB-A, Web-A, Web-B (3 VM)
- Phạm vi: Site A — nghiệm thu #4 (web lỗi vẫn phục vụ qua VIP)

## Kịch bản

Truy cập dịch vụ qua VIP `172.20.21.100` (HTTPS), dừng Nginx trên Web-A, quan sát
HAProxy loại backend lỗi và chuyển toàn bộ sang Web-B; khôi phục Web-A và quan sát
cân bằng tải trở lại.

## Lệnh

Trên LB-A (mỗi giai đoạn):

```bash
for i in 1 2 3 4 5 6; do curl -sk https://172.20.21.100; done
```

Trên Web-A:

```bash
sudo systemctl stop nginx     # giai đoạn 2
sudo systemctl start nginx    # giai đoạn 3
```

Chờ ~10 giây sau mỗi lần stop/start để health check (`GET /healthz`) cập nhật trạng thái.

## Expected / Actual

| Giai đoạn | Expected | Actual | Kết quả |
|---|---|---|---|
| 1. Baseline | Luân phiên Web-A/Web-B | A,B,A,B,A,B | PASS |
| 2. Web-A tắt | Toàn bộ Web-B | B,B,B,B,B,B | PASS |
| 3. Khôi phục | Luân phiên trở lại | B,A,B,A,B,A | PASS |

Ghi chú: giai đoạn 3 bắt đầu bằng Web-B do con trỏ round-robin tiếp tục; vẫn luân
phiên đều hai node. Dịch vụ không gián đoạn khi một backend lỗi.