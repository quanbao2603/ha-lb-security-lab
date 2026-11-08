# Kế hoạch kiểm thử — phần Quan Bảo (Site A)

Đối chiếu tiêu chí nghiệm thu trong `lab-v2.html` (mục 7). Cột "Owner" ghi rõ phần
ai phụ trách; mục nào cần firewall/DB của Minh Hùng thì đánh dấu **PENDING — chờ Hùng**,
không tự cấu hình firewall/DB.

| # | Kịch bản | Owner | Expected | Actual / trạng thái | Evidence |
|---|---|---|---|---|---|
| 1 | Route Tailscale site A: chỉ subnet khai báo được route | Bảo | Windows ping/curl tới lab qua Transit-A | PASS — ping 172.20.21.10 TTL=63, 0% loss | `evidence/quan-bao/` (route) |
| 2 | Web `/healthz` trả 200 | Bảo | 200 cả hai node | PASS | `20261108-quan-bao-web-healthz.md` |
| 3 | SSH key-only, cấm root/password | Bảo | key vào được; password bị chặn | PASS | `20261108-quan-bao-web-ssh-hardening.md` |
| 4 | VIP HTTPS + phân phối 2 node | Bảo | luân phiên Web-A/Web-B | PASS | `20261108-quan-bao-lb-https-stats-vip.md` |
| 5 | Stats nội bộ bảo vệ mật khẩu | Bảo | có mật khẩu 200, không 401 | PASS | `20261108-quan-bao-lb-https-stats-vip.md` |
| 6 | Keepalived giữ VIP | Bảo | VIP trên ens37, dịch vụ qua VIP | PASS | `20261108-quan-bao-lb-https-stats-vip.md` |
| 7 | Web failover qua VIP | Bảo | Web-A tắt → toàn bộ Web-B; khôi phục → luân phiên | PASS | `20261108-quan-bao-web-failover-vip.md` |
| 8 | HTTPS cert lab không tin cậy mặc định | Bảo | không `-k` → lỗi verify | PASS | `20261108-quan-bao-https-cert-negative.md` |
| 9 | Web bypass: WAN vào web IP trực tiếp bị chặn | Chung (firewall Hùng) | BLOCKED + log | PENDING — chờ firewall Hùng; script sẵn sàng | `scripts/quan-bao/negative_tests.sh` |
| 10 | SSH WAN tới web bị chặn | Chung (firewall Hùng) | BLOCKED + log | PENDING — chờ firewall; hiện SSH key-only | `scripts/quan-bao/negative_tests.sh` |
| 11 | DB trực tiếp từ WAN bị chặn | Hùng | BLOCKED + log | PENDING — DB + firewall Hùng | — |
| 12 | DB replication / failover | Hùng | replica nhận dữ liệu; promote được | PENDING — Hùng | — |
| 13 | Firewall failover / recovery | Hùng | chuyển/khôi phục được | PENDING — Hùng | — |
| 14 | Đối chiếu log theo timestamp | Chung | khớp firewall/HAProxy/web/DB log | PARTIAL — có log HAProxy/web; chờ log firewall/DB Hùng | — |

## Ghi chú phối hợp

- Mục 9–13 thuộc firewall/DB của Minh Hùng. Bảo chuẩn bị kịch bản + script phía
  client (`scripts/quan-bao/negative_tests.sh`) và ghi expected; chạy lại sau khi
  Hùng dựng firewall/DB. Không sửa firewall/DB trên phần của Bảo.
- File `lab/testing/acceptance-matrix.md` (chung) chỉ tạo/cập nhật sau khi hai người
  đối chiếu; hiện các dòng của Bảo nằm trong bảng này.
- Kiểm thử positive chạy trong mạng lab cô lập `172.20.21.0/24`, có sự đồng thuận nhóm.