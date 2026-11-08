# Phần báo cáo — Quan Bảo (Site A)

Đây là phần đóng góp của Quan Bảo cho báo cáo chung. Việc cập nhật `lab-v2.html`
chỉ thực hiện sau khi thống nhất với Minh Hùng (file chung, không sửa đồng thời).

## Phạm vi Site A

Phụ trách: Transit-A (Tailscale subnet routing), LB-A (HAProxy + Keepalived),
Web-A/Web-B (Nginx), Test-Client, kiểm thử phía client và tài liệu/runbook phần này.

## Kiến trúc Site A đã triển khai

```
Windows (admin) -- Tailscale --> Transit-A (100.99.198.105, route 172.20.21.0/24)
                                        |
                                  lab VMnet2 172.20.21.0/24
                                        |
Test-Client (.40) --> VIP (.100) --> LB-A (HAProxy TLS + round-robin)
                                        |
                          +-------------+-------------+
                          |                           |
                       Web-A (.20)                 Web-B (.30)
                       Nginx + /healthz            Nginx + /healthz
```

- Dịch vụ truy cập qua VIP `172.20.21.100` (HTTP/HTTPS), Keepalived giữ VIP trên LB-A.
- HAProxy kết thúc TLS bằng cert lab, health check `GET /healthz`, cân bằng round-robin.
- Web node hardening SSH key-only, cấm root/password; trang nhận diện riêng từng node.
- Stats nội bộ `172.20.21.10:8404` bảo vệ bằng mật khẩu.

## Kết quả kiểm thử (phần Bảo)

| Hạng mục | Kết quả |
|---|---|
| Route Tailscale Site A (Windows ping TTL=63, curl) | PASS |
| `/healthz` 200 cả hai node | PASS |
| SSH key-only / cấm password | PASS |
| VIP HTTPS + phân phối 2 node | PASS |
| Stats 200/401 | PASS |
| Keepalived giữ VIP | PASS |
| Web failover qua VIP | PASS |
| HTTPS cert lab không tin cậy mặc định | PASS |

Chi tiết + output: `evidence/quan-bao/`. Bảng đối chiếu nghiệm thu:
`lab/testing/quan-bao/test-plan.md`.

## Giới hạn hiện tại

- **Một LB-A** (không có LB-B): Keepalived một node, chưa demo failover chính LB.
- **Chưa có firewall/DB** (phần Minh Hùng): các negative test web bypass / SSH WAN /
  DB trực tiếp đang chuẩn bị script + expected, chạy lại sau khi Hùng dựng firewall/DB.
- Lab dùng một subnet chung `172.20.21.0/24`; phân vùng nhiều zone là bước tiếp theo
  của Hùng.
- Cert lab tự ký (không phải CA tin cậy công cộng) — đúng phạm vi lab.

## Hướng mở rộng

- Ghép LB-B + Keepalived BACKUP để demo failover LB thật.
- Bổ sung firewall zone + deny-by-default (Hùng) rồi chạy lại bộ negative test.
- Dùng CA lab riêng để client tin cậy cert thay vì `-k`.
- Tập trung log (Log-Monitor của Hùng) và đối chiếu timestamp firewall/HAProxy/web.