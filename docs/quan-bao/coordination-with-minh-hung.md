# Phối hợp với Minh Hùng — phần dùng chung

Nguyên tắc: làm trên `main` chung + folder ownership. Không sửa đồng thời file chung;
không đụng thư mục của Hùng (`lab/firewall/`, `lab/database/`, `lab/monitoring/`,
`lab/transit/site-b/`, `…/minh-hung/`).

## Việc Bảo đã xong (không chờ Hùng)

Toàn bộ thư mục ownership của Bảo đã điền: `configs/vmware/quan-bao/`,
`lab/transit/site-a/`, `lab/web/`, `lab/load-balancer/`, `scripts/quan-bao/`,
`lab/testing/quan-bao/`, `evidence/quan-bao/`, `docs/quan-bao/`.

## Việc cần Hùng / cùng thống nhất

| Hạng mục | File chung | Trạng thái / việc cần làm |
|---|---|---|
| Firewall zone + deny-by-default | `lab/firewall/` (Hùng) | Hùng dựng; sau đó Bảo chạy lại `negative_tests.sh` (web bypass, SSH WAN, DB) |
| DB replication/failover | `lab/database/` (Hùng) | Hùng dựng; Bảo phối hợp test phía client |
| ACL / route policy Tailscale | `configs/tailscale/` (Hùng) | Hùng giữ policy; Bảo đã ghi route Site A + bằng chứng trong `lab/transit/site-a/` |
| Transit-B + liên lạc 2 site | `lab/transit/site-b/` (Hùng) | Hùng dựng; test cross-site sau |
| Sơ đồ mạng tổng | `lab/network/`, `diagrams/` | Bảo đề xuất `lab/network/site-a-quan-bao.md`; Hùng review route/firewall rồi merge |
| Acceptance matrix chung | `lab/testing/acceptance-matrix.md` | CHƯA tạo đơn phương; dòng của Bảo ở `lab/testing/quan-bao/test-plan.md`, đối chiếu rồi mới tạo file chung |
| README / lab-v2.html | file chung | Bảo chỉ thêm mục riêng; cập nhật HTML sau khi hai người thống nhất |
| Đối chiếu log timestamp | `lab/monitoring/` (Hùng) | Có log HAProxy/web phía Bảo; chờ log firewall/DB Hùng |

## Quy ước evidence

- Đặt tên `YYYYMMDD-quan-bao-<test>.md`, không ghi đè evidence của Hùng.
- Mỗi evidence ghi: ngày, máy chạy, lệnh, expected/actual, kết quả.

## Secret

- Không commit token Tailscale, mật khẩu, private key, cert (`*.pem`/`*.key`),
  file state VMware. Mật khẩu stats trong repo là placeholder.