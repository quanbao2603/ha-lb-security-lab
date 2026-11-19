# Shared Cybersecurity High-Availability Lab

## Giới thiệu

Đây là mô hình thực hành về **an ninh mạng, cân bằng tải và tính sẵn sàng cao** triển khai trên VMware Workstation. Mô hình gồm hai site ảo hóa đặt trên hai máy tính khác nhau, kết nối với nhau qua overlay Tailscale. Firewall là điểm kiểm soát truy cập tập trung: mọi lưu lượng vào vùng dữ liệu và vùng quản trị đều phải đi qua firewall, các máy dịch vụ không cài agent overlay để hạn chế đường bypass.

Tài liệu chi tiết toàn bài lab (kiến trúc, cơ chế, kết quả kiểm thử, GAP, demo) nằm trong [`docs/documents-lab.md`](docs/documents-lab.md). README này chỉ đóng vai trò trang giới thiệu.

## Mục tiêu của bài lab

- Phân vùng mạng và kiểm soát truy cập theo trust boundary với chính sách deny-by-default.
- Cân bằng tải HTTPS, health check và chuyển đổi Web node khi có lỗi.
- PostgreSQL streaming replication, phân quyền tối thiểu và failover Primary/Replica.
- Ghi log tập trung, kiểm thử negative security và đối chiếu bằng chứng theo timestamp.
- Đo thời gian khôi phục (RTO) cho các kịch bản failover.

## Kiến trúc tổng thể

```text
Site A                                      Site B
Transit-A 172.20.21.5                      Transit-B 172.20.20.6
     |                                            |
LB-A / Web VIP 172.20.21.100             Firewall-A / Firewall-B
     |                                      /       |        \
Web-A, Web-B                         DATABASE   MANAGEMENT   DMZ
                                     .40.11/.12  .50.10      Gateway .1
```

| Vùng | Subnet | Thành phần chính |
|---|---|---|
| WAN-LAB | `172.20.10.0/24` | Test-Client (nguồn không tin cậy) |
| DMZ / Transit-B | `172.20.20.0/24` | Transit-B, gateway firewall `.1` |
| Site A service | `172.20.21.0/24` | Transit-A, LB-A, Web-A/B, VIP `.100` |
| DATABASE | `172.20.40.0/24` | DB-Primary `.11`, DB-Replica `.12` |
| MANAGEMENT | `172.20.50.0/24` | Firewall `.2/.3`, Log-Monitor `.10` |

## Thành phần chính

- **Transit-A / Transit-B:** subnet router Tailscale, IP forwarding, route chống bypass.
- **LB-A:** HAProxy (HTTPS, round-robin, health check `/healthz`) và Keepalived giữ VIP Site A.
- **Web-A / Web-B:** Nginx có node identity, access log, SSH key-only.
- **Firewall-A / Firewall-B:** nftables deny-by-default, NAT/DNAT vào VIP, logging theo prefix.
- **DB-Primary / DB-Replica:** PostgreSQL 16 streaming replication, promote/rejoin theo runbook.
- **Log-Monitor:** rsyslog tập trung cho toàn bộ VM.
- **Kênh điều phối:** bridge HTTP và PAL-v2 giữa hai máy host, phục vụ phối hợp kiểm thử; không thay thế cơ chế an ninh của lab.

## Nguyên tắc an ninh và an toàn

- Firewall deny-by-default; mỗi luồng cho phép có rule, log prefix và test tương ứng.
- SSH key-only, cấm root và mật khẩu trên mọi VM.
- Không commit password, token, private key, file `.env` hoặc log chứa credential.
- Chỉ kiểm thử trong mạng lab cô lập; kết luận PASS/FAIL phải kèm output hoặc log.

## Dẫn đường tài liệu

| Muốn xem | Mở |
|---|---|
| Toàn cảnh bài lab, kết quả, GAP, demo | `docs/documents-lab.md` |
| Kịch bản triển khai chung hai site | `docs/quan-bao/joint-lab-test-runbook.md` |
| Kịch bản chi tiết Site B + mốc ảnh SB | `docs/quan-bao/site-b-comprehensive-scenario.md` |
| Thiết kế firewall | `lab/firewall/` |
| Thiết kế database | `lab/database/` |
| Bằng chứng kiểm thử | `evidence/` |
