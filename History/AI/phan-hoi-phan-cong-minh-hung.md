# Phản hồi và thống nhất phân công — Shared Cybersecurity HA Lab

## Kết luận tổng quát

Phần phân tích công việc của anh Hùng là **đúng phần lớn**, khoảng 90–95%. Các nội dung sau đã khớp với kiến trúc repository và bài lab hiện tại:

- Nền tảng VMware Workstation.
- Hai Linux Transit VM chạy Tailscale, IP forwarding và subnet routing.
- Không cài Tailscale lên Web/Database VM trong mô hình chuẩn.
- Firewall là điểm kiểm soát chính theo nguyên tắc deny-by-default.
- Phân tách WAN-LAB, DMZ, APP, DATABASE và MANAGEMENT.
- Phân chia VM giữa Quan Bảo và Minh Hùng.
- Ownership của từng người.
- Lộ trình triển khai trong 7 ngày.
- Các bài kiểm thử firewall, routing, load balancing, database replication và failover.

Có một số điểm cần điều chỉnh để hai người làm việc thống nhất.

## 1. Điều chỉnh quy tắc Git

Hai người đã thống nhất sử dụng chung branch `main`, vì vậy không cần bắt buộc dùng branch riêng hoặc pull request cho mọi thay đổi.

Quy tắc chính:

```text
Hai người dùng chung branch main.

Mỗi người chỉ sửa các thư mục thuộc ownership của mình.
Không chỉnh sửa đồng thời các file dùng chung như README.md,
lab-v2.html, lab/network/ và acceptance-matrix.md.

Nếu cần sửa file chung, người thực hiện phải báo trước cho người còn lại
và chờ người kia hoàn tất thay đổi trước khi chỉnh tiếp.
```

Không bắt buộc các quy trình sau:

- Feature branch.
- Pull request cho mọi thay đổi.
- Review qua pull request.
- Cấm sửa trực tiếp trên `main`.

Tuy nhiên, trước khi bắt đầu làm việc nên luôn cập nhật repository:

```bash
git pull origin main
```

Sau khi hoàn tất một nhóm thay đổi:

```bash
git status
git diff
git add <các-file-thuộc-phần-của-mình>
git commit -m "Mô tả ngắn thay đổi"
git push origin main
```

Nên commit nhỏ theo từng nhóm chức năng để người còn lại dễ theo dõi và tránh sửa đè.

## 2. Trạng thái hiện tại của repository

Cách mô tả chính xác hơn là:

> Repository đã có tài liệu thiết kế và khung thư mục, nhưng chưa có cấu hình triển khai thực tế, script, runbook và evidence kiểm thử.

Repository hiện đã có nội dung trong các file:

- `README.md`
- `lab-v2.html`
- `detaiLab.html`
- `lab-manifest.yml`
- `.gitignore`

Các phần chưa triển khai thực tế gồm:

- Cấu hình Transit-A/Transit-B.
- Tailscale ACL và subnet route thực tế.
- Firewall rule thật.
- HAProxy/Keepalived.
- Web server.
- Database replication.
- Monitoring.
- Script kiểm tra.
- Runbook.
- Evidence kiểm thử.

## 3. Phần việc của Minh Hùng

Phần ownership của Minh Hùng là đúng và gồm:

- Transit-B.
- Firewall-A và Firewall-B.
- DB-Primary và DB-Replica.
- Log-Monitor.
- Tailscale subnet route và ACL.
- Firewall zone, NAT và port forwarding.
- Deny-by-default và firewall rule matrix.
- Firewall logging.
- Database replication.
- Database user privilege tối thiểu.
- Backup, promote và recovery database.
- Syslog/monitoring tối giản.
- Kiểm thử firewall, routing, database replication/failover và firewall recovery.

Các thư mục chính:

```text
lab/transit/site-b/
lab/firewall/
configs/firewall/
configs/tailscale/
lab/database/
lab/monitoring/
lab/testing/minh-hung/
evidence/minh-hung/
docs/minh-hung/
configs/vmware/minh-hung/
scripts/minh-hung/
```

## 4. Phần việc của Quan Bảo

Phần ownership của Quan Bảo cũng đúng và gồm:

- Transit-A.
- LB-A.
- Web-A và Web-B.
- Test-Client.
- HAProxy.
- Keepalived.
- VIP và health check.
- HTTPS lab.
- Web hardening.
- Access log và node identity.
- Kiểm thử load balancing và web failover.
- Kiểm thử từ WAN/DMZ.
- Thu thập evidence phía client, web và load balancer.

Các thư mục chính:

```text
lab/transit/site-a/
lab/load-balancer/
lab/web/
lab/testing/quan-bao/
evidence/quan-bao/
docs/quan-bao/
configs/vmware/quan-bao/
scripts/quan-bao/
```

## 5. Quy tắc đối với vùng phối hợp chung

Hai người cần tránh sửa cùng lúc các file hoặc thư mục sau:

- `README.md`
- `lab-v2.html`
- `lab/network/`
- `diagrams/`
- `lab/testing/acceptance-matrix.md` nếu file này được tạo sau
- Bảng IP và sơ đồ kiến trúc tổng hợp

Quy tắc làm việc:

- Quan Bảo có thể đề xuất sơ đồ DMZ và luồng request.
- Minh Hùng review gateway, route, zone và firewall boundary.
- Không ai tự ý đổi IP/subnet mà không báo người còn lại.
- Bảng IP cuối cùng phải được hai người cùng xác nhận.
- Nếu thay đổi IP Web/DB/Transit thì phải kiểm tra lại HAProxy, firewall rule, Tailscale route và test script.

## 6. Lưu ý về Tailscale

Cách hiểu của anh Hùng về Tailscale là đúng, nhưng cần giữ các nguyên tắc sau:

- Tailscale chạy trên `Transit-A` và `Transit-B`.
- Không cài Tailscale lên từng Web/Database VM trong mô hình chuẩn.
- Không advertise toàn bộ mạng Database cho mọi thiết bị trong tailnet.
- Chỉ advertise các subnet thật sự cần thiết.
- Tailscale ACL không thay thế firewall lab.
- Phải kiểm tra cả đường hợp lệ và đường bị chặn.
- Không dùng route từ Tailscale trên host để bypass firewall.
- Các route được quảng bá phải có tài liệu và được kiểm thử từ hai phía.

## 7. Lưu ý về APP network

Kiến trúc có thiết kế vùng `APP`, nhưng baseline tuần đầu chưa bắt buộc phải tạo một App VM riêng.

Trong giai đoạn đầu, Web-A/Web-B có thể đảm nhiệm application node tối giản. Có thể ghi rõ như sau:

```text
APP network được thiết kế trong kiến trúc nhưng chưa bắt buộc có
App VM riêng trong baseline tuần đầu. Web node có thể đóng vai trò
application node tối giản. App VM riêng là phần mở rộng sau khi baseline đạt.
```

Điều này tránh thắc mắc tại sao kiến trúc có APP subnet nhưng danh sách VM chưa có App Server riêng.

## 8. Lộ trình triển khai đã thống nhất

### Ngày 1 — Baseline và chuẩn bị VM

- Quan Bảo dựng Transit-A, LB-A, Web-A, Web-B và Test-Client.
- Minh Hùng dựng Transit-B, Firewall-A, Firewall-B, DB-Primary, DB-Replica và Log-Monitor theo khả năng RAM.
- Hai người đặt hostname, IP, timezone, VMnet và snapshot `day-1-clean`.
- Thống nhất tên VM, subnet và quy ước đặt tên file.

### Ngày 2 — Transit và phân vùng mạng

- Quan Bảo cấu hình Transit-A, IP forwarding và route cục bộ.
- Minh Hùng cấu hình Transit-B, Tailscale subnet route, ACL và quy trình approve route.
- Kiểm tra route hợp lệ và subnet không được phép truy cập.

### Ngày 3 — Firewall và dịch vụ edge

- Quan Bảo dựng HAProxy, Keepalived, VIP, health check và HTTPS lab.
- Minh Hùng dựng firewall zones, NAT, port forwarding giới hạn, deny-by-default và logging.
- Kiểm tra WAN chỉ vào VIP, không truy cập trực tiếp DB/MGMT/Web node.

### Ngày 4 — Web, database và monitoring

- Quan Bảo harden Web-A/Web-B, tạo `/healthz`, access log, node identity và script kiểm tra.
- Minh Hùng dựng database replication, user tối thiểu quyền, bind address, backup và Syslog.
- Kiểm tra request qua VIP và dữ liệu primary xuất hiện trên replica.

### Ngày 5 — Failover và recovery

- Quan Bảo dừng Web-A và chứng minh LB chuyển sang Web-B.
- Minh Hùng dừng DB-Primary, promote DB-Replica và mô phỏng Firewall-A lỗi.
- Hai người lưu evidence có timestamp, expected result và actual result.

### Ngày 6 — Kiểm thử bảo mật

- Quan Bảo chạy negative test từ Test-Client: truy cập DB trực tiếp, SSH từ WAN, Web bypass và HTTPS.
- Minh Hùng đối chiếu firewall log, Tailscale ACL, routing table, DB log và quyền user.
- Sửa lỗi trong đúng vùng ownership và chạy lại test.

### Ngày 7 — Tích hợp và demo

- Quan Bảo tổng hợp phần web/LB, sơ đồ request và demo VIP/Web failover.
- Minh Hùng tổng hợp phần firewall/DB/Tailscale, trust boundary và demo deny/log/DB recovery.
- Hai người cùng chạy acceptance checklist, kiểm tra secret và diễn tập demo.

## 9. Kết luận

Phần phân tích của anh Hùng là đúng và có thể dùng làm kế hoạch triển khai. Chỉ cần điều chỉnh ba điểm:

1. Hai người dùng chung `main`, không bắt buộc branch/PR.
2. Mô tả repository là đã có tài liệu và khung thư mục, nhưng chưa có cấu hình triển khai thực tế.
3. Ghi rõ APP network là vùng thiết kế; App VM riêng chưa bắt buộc trong baseline tuần đầu.

Sau khi điều chỉnh ba điểm trên, anh Hùng có thể bắt đầu triển khai phần Transit-B, Tailscale policy, Firewall, Database và Monitoring theo ownership đã phân công.
