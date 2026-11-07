# Shared Cybersecurity HA Lab

## Mục đích

Repository này chứa thiết kế, cấu hình, bằng chứng kiểm thử và tài liệu cho bài lab an ninh mạng dùng chung của hai thành viên: Quan Bảo và Minh Hùng. Mục tiêu là triển khai trong một tuần trên VMware Workstation, sử dụng Tailscale làm kênh liên kết giữa hai máy nhưng vẫn giữ firewall lab là điểm kiểm soát truy cập chính.

## Nguyên tắc kiến trúc

- VMware Workstation là nền tảng ảo hóa.
- Mỗi máy chạy một Linux Transit VM có Tailscale, IP forwarding và subnet routing.
- Không cài Tailscale lên từng web/database VM trong mô hình chính để tránh bypass firewall.
- Mạng WAN mô phỏng, DMZ, APP, DATABASE và MANAGEMENT được tách riêng.
- Firewall dùng nguyên tắc deny-by-default, chỉ mở đúng luồng cần thiết.
- Mọi bài kiểm thử chỉ thực hiện trong các mạng lab được cô lập và có sự đồng thuận của nhóm.

## Cấu trúc thư mục

| Thư mục | Ý nghĩa |
|---|---|
| `docs/` | Kế hoạch, quyết định kiến trúc, checklist triển khai và báo cáo nghiệm thu. |
| `lab/network/` | Sơ đồ mạng, bảng IP, thiết kế VMnet và routing. |
| `lab/transit/` | Thiết kế hai Linux Transit VM và cấu hình Tailscale/subnet route. |
| `lab/firewall/` | Rule matrix, NAT, policy, hardening và log firewall. |
| `lab/load-balancer/` | HAProxy/Keepalived và health-check. |
| `lab/web/` | Thiết kế và cấu hình hai web/app node. |
| `lab/database/` | Replication, quyền truy cập và kế hoạch failover database. |
| `lab/monitoring/` | Logging, giám sát tối giản và cảnh báo. |
| `lab/testing/` | Kịch bản kiểm thử chức năng, bảo mật, failover và khôi phục. |
| `configs/vmware/` | Thông số VM, VMnet, adapter và resource profile. |
| `configs/tailscale/` | ACL, advertised routes và hướng dẫn phê duyệt route. |
| `configs/firewall/` | Bản cấu hình/rule export của firewall, không lưu secret. |
| `scripts/` | Script cài đặt, kiểm tra kết nối và thu thập bằng chứng sau này. |
| `evidence/` | Ảnh chụp, log, output lệnh và biên bản kiểm thử. Không lưu dữ liệu nhạy cảm. |
| `diagrams/` | Sơ đồ kiến trúc và luồng dữ liệu dạng nguồn hoặc ảnh xuất. |

## Tài liệu chính

- `lab-v2.html`: bản lab thực hành mới, bao gồm mục tiêu, kiến trúc, phân chia việc, cấu hình tài nguyên, firewall policy, kế hoạch một tuần, kiểm thử và tiêu chí nghiệm thu.
- `detaiLab.html`: bản lab cũ được giữ lại để đối chiếu lịch sử.
- `lab-manifest.yml`: thông tin tổng quát và quy ước phiên bản của lab.

## Quy tắc cộng tác

1. Mỗi thay đổi phải ghi rõ mục tiêu và phạm vi trong commit/PR.
2. Không commit token Tailscale, mật khẩu, private key, file state hoặc thông tin thật.
3. Mọi thay đổi firewall phải cập nhật đồng thời rule matrix và kịch bản kiểm thử.
4. Bằng chứng kiểm thử phải ghi thời gian, máy chạy, lệnh thực hiện và kết quả.
5. Chỉ sử dụng công cụ kiểm thử trong mạng lab được cô lập.

## Phân công ownership và phạm vi chỉnh sửa

Mục tiêu của cách chia này là mỗi người có vùng làm việc riêng, hạn chế tối đa việc cùng sửa một file. Hai người không sửa trực tiếp cùng một file trên cùng branch.

### Vùng làm việc của Quan Bảo

| Đường dẫn | Nội dung Quan Bảo phụ trách |
|---|---|
| `lab/transit/site-a/` | Transit-A, IP forwarding, route phía máy Quan Bảo và checklist kết nối. |
| `lab/load-balancer/` | HAProxy, Keepalived, VIP, health check, stats nội bộ. |
| `lab/web/` | Web-A/Web-B, trang nhận diện node, `/healthz`, hardening web và access log. |
| `lab/testing/quan-bao/` | Test từ WAN/DMZ, test load balancing, web failover, expected/actual. |
| `evidence/quan-bao/` | Ảnh chụp và log do Quan Bảo thu thập. |
| `docs/quan-bao/` | Nhật ký triển khai, runbook LB/web và phần báo cáo được giao. |
| `configs/vmware/quan-bao/` | Thông số VMnet/VM của các máy Quan Bảo chạy. |
| `scripts/quan-bao/` | Script kiểm tra web, VIP, health check và thu thập log phía client. |

### Vùng làm việc của Minh Hùng

| Đường dẫn | Nội dung Minh Hùng phụ trách |
|---|---|
| `lab/transit/site-b/` | Transit-B, IP forwarding, route phía máy Minh Hùng và checklist kết nối. |
| `lab/firewall/` | Zone, NAT, deny-by-default, rule matrix, logging, backup/restore policy. |
| `lab/database/` | DB-Primary/Replica, replication, user privilege, promote và recovery. |
| `lab/monitoring/` | Syslog, health check, log retention và dashboard tối giản. |
| `lab/testing/minh-hung/` | Test firewall, routing, DB replication/failover và firewall recovery. |
| `evidence/minh-hung/` | Ảnh chụp và log do Minh Hùng thu thập. |
| `docs/minh-hung/` | Nhật ký triển khai, runbook firewall/database và phần báo cáo được giao. |
| `configs/vmware/minh-hung/` | Thông số VMnet/VM của các máy Minh Hùng chạy. |
| `scripts/minh-hung/` | Script kiểm tra route, port policy, DB replication và log. |

### Vùng dùng chung — phải review trước khi sửa

| Đường dẫn/file | Quy tắc |
|---|---|
| `README.md` | Mỗi người chỉ thêm phần thuộc ownership; thay đổi cấu trúc phải báo người còn lại. |
| `lab-v2.html` | Chỉ cập nhật sau khi hai người thống nhất nội dung; không sửa đồng thời. |
| `lab/network/` | Quan Bảo đề xuất sơ đồ DMZ, Minh Hùng review đường route/firewall; merge sau khi cả hai đồng ý. |
| `configs/tailscale/` | Minh Hùng giữ ACL/route policy, Quan Bảo kiểm thử route từ site A; mọi thay đổi phải ghi lý do. |
| `diagrams/` | Có thể tạo file mới theo tên người tạo; file tổng hợp chỉ sửa qua PR. |
| `lab/testing/` | Mỗi người viết test trong thư mục riêng; file `acceptance-matrix.md` là file chung, chỉ cập nhật khi đã đối chiếu. |
| `evidence/` | Không ghi đè evidence của nhau; đặt tên `YYYYMMDD-owner-test-name`. |

## Phân công chi tiết trong 7 ngày

### Ngày 1 — Baseline và chuẩn bị VM

**Quan Bảo:** tạo Transit-A, LB-A, Web-A, Web-B và Test-Client; đặt hostname, snapshot `day-1-clean`; ghi cấu hình VM vào `configs/vmware/quan-bao/`; tạo trang web nhận diện riêng cho Web-A/Web-B.

**Minh Hùng:** tạo Transit-B, Firewall-A, Firewall-B, DB-Primary, DB-Replica và Log-Monitor theo profile bật tuần tự; ghi cấu hình vào `configs/vmware/minh-hung/`; tạo snapshot baseline và bảng resource.

**Đầu ra:** cả hai thống nhất tên VM, subnet, hostname, timezone, snapshot và quy ước đặt tên file.

### Ngày 2 — Transit và phân vùng mạng

**Quan Bảo:** cấu hình adapter/VMnet phía site A, IP Transit-A, bật IP forwarding, kiểm tra route cục bộ; ghi kết quả vào `lab/transit/site-a/`.

**Minh Hùng:** cấu hình Transit-B, Tailscale subnet route phía site B, firewall transit tối thiểu và quy trình approve route; ghi vào `lab/transit/site-b/` và `configs/tailscale/`.

**Đầu ra:** ping/route giữa hai transit hoạt động; các subnet chưa được advertise không truy cập được; có ảnh/log chứng minh.

### Ngày 3 — Firewall và dịch vụ edge

**Quan Bảo:** cài HAProxy/Keepalived trên LB-A, cấu hình VIP, backend Web-A/Web-B, health check và HTTPS lab; viết runbook LB.

**Minh Hùng:** cấu hình zone, NAT, port-forward giới hạn, deny-by-default, logging và rule chống truy cập trực tiếp DB/MGMT; lập firewall rule matrix.

**Đầu ra:** WAN-LAB chỉ vào VIP; Web IP trực tiếp, DB và SSH trái phép bị chặn; tất cả có log.

### Ngày 4 — Web, database và logging

**Quan Bảo:** harden Web-A/Web-B, tắt dịch vụ thừa, cấu hình SSH key-only, access log, `/healthz`, node identity; viết script kiểm tra VIP và health check.

**Minh Hùng:** cấu hình DB replication, user riêng cho replication/app, bind address, quyền tối thiểu, backup và kiểm tra replica; nhận log tập trung tối giản.

**Đầu ra:** request qua VIP tới cả hai web node; dữ liệu primary xuất hiện trên replica; app chỉ mở DB port cần thiết.

### Ngày 5 — Failover và recovery

**Quan Bảo:** dừng Web-A, chứng minh LB loại node lỗi; kiểm tra Keepalived/VIP theo profile; lưu evidence vào `evidence/quan-bao/`.

**Minh Hùng:** dừng DB-Primary, promote replica theo runbook; mô phỏng Firewall-A lỗi và chạy quy trình khôi phục/đổi node; lưu evidence vào `evidence/minh-hung/`.

**Đầu ra:** dịch vụ tiếp tục hoạt động theo phạm vi thiết kế; có thời gian bắt đầu/kết thúc và giới hạn downtime.

### Ngày 6 — Kiểm thử bảo mật và sửa lỗi

**Quan Bảo:** chạy test negative từ Test-Client: DB trực tiếp, SSH WAN, Web bypass, HTTPS certificate và load distribution; không tự sửa firewall của Minh Hùng trên branch của mình.

**Minh Hùng:** đối chiếu firewall log, Tailscale ACL, route table, DB log và quyền user; sửa policy trong vùng ownership và thông báo thay đổi cho Quan Bảo.

**Đầu ra:** ma trận expected/actual, danh sách lỗi, cách khắc phục và test chạy lại sau sửa.

### Ngày 7 — Tích hợp, review và demo

**Quan Bảo:** tổng hợp phần web/LB, sơ đồ luồng request và kịch bản demo VIP/web failover; cập nhật phần được giao trong `lab-v2.html` sau khi Minh Hùng review.

**Minh Hùng:** tổng hợp firewall/DB/Tailscale, sơ đồ trust boundary và kịch bản demo deny/log/DB recovery; review toàn bộ cấu hình không chứa secret.

**Cả hai:** chạy acceptance matrix, kiểm tra link/tên file, tạo backup cấu hình đã loại secret và diễn tập demo theo đúng thứ tự.

## Quy tắc GitHub để tránh xung đột

1. Không làm việc trực tiếp trên `main`. Dùng branch `feature/quan-bao-*` hoặc `feature/minh-hung-*`.
2. Mỗi branch chỉ sửa vùng ownership của mình. Nếu cần sửa file chung, mở issue/trao đổi trước và ghi rõ phần dòng nào sẽ thay đổi.
3. Mỗi commit chỉ chứa một nhóm thay đổi liên quan, ví dụ `add web health checks` hoặc `harden firewall rules`; không trộn evidence với cấu hình không liên quan.
4. Trước khi push: `git pull --rebase origin main`, kiểm tra `git diff`, kiểm tra không có secret rồi mới push.
5. Mỗi PR phải có người còn lại review. Không tự merge PR của chính mình.
6. Nếu cần chỉnh `README.md` hoặc `lab-v2.html`, người thực hiện thông báo trước; người còn lại không sửa file đó cho tới khi PR được merge.
7. Không commit file `.env`, token Tailscale, private key, password, VMware lock/state hoặc log chứa credential.
8. Evidence không ghi đè: dùng tên `YYYYMMDD-owner-test-name` và ghi metadata trong file `.md` đi kèm.

## Trạng thái

Repository đang ở giai đoạn khung kiến trúc và kế hoạch. Code triển khai, automation và export cấu hình sẽ được bổ sung theo các ownership ở trên; mọi thay đổi firewall và routing phải đi kèm test/evidence tương ứng.
