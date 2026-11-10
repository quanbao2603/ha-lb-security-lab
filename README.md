# Shared Cybersecurity High-Availability Lab

## Tổng quan

Mô hình thực hành về an ninh mạng, cân bằng tải và tính sẵn sàng cao trên VMware Workstation. Hai site kết nối qua Tailscale; firewall là điểm kiểm soát truy cập chính, còn Web và Database không cài Tailscale trực tiếp để hạn chế bypass.

## Mục tiêu

- Phân vùng mạng và kiểm soát truy cập giữa các trust boundary.
- Cân bằng tải HTTPS và web failover.
- PostgreSQL streaming replication, least privilege và database failover.
- Ghi log tập trung, negative security testing và đối chiếu bằng chứng.

## Kiến trúc

```text
Site A                                      Site B
Transit-A 172.20.21.5                      Transit-B 172.20.20.6
     |                                            |
LB-A / Web VIP 172.20.21.100             Firewall-A / Firewall-B
     |                                      /       |        \
Web-A, Web-B                         DATABASE   MANAGEMENT   DMZ
                                     .40.11/.12  .50.10      Gateway .1
```

PAL-v2 là kênh điều phối tùy chọn giữa hai máy host Windows qua LAN và Tailscale. PAL-v2 không thay thế firewall, SSH hoặc Tailscale ACL.

## Phân vùng mạng

| Vùng | Subnet | Thành phần tiêu biểu |
|---|---|---|
| WAN-LAB | `172.20.10.0/24` | Test-Client |
| DMZ / Transit-B | `172.20.20.0/24` | Transit-B `.6`, gateway `.1` |
| Site A service | `172.20.21.0/24` | Transit-A `.5`, LB/Web, VIP `.100` |
| APP | `172.20.30.0/24` | Vùng ứng dụng mở rộng |
| DATABASE | `172.20.40.0/24` | DB-Primary `.11`, DB-Replica `.12` |
| MANAGEMENT | `172.20.50.0/24` | Firewall `.2/.3`, Log-Monitor `.10` |

Transit-B quảng bá `172.20.20.0/24`, `172.20.40.0/24` và `172.20.50.0/24`. Route nội bộ thực tế trên Transit-B sử dụng:

```text
172.20.0.0/16 via 172.20.20.1
```

## Thành phần hệ thống

### Site A

- **Transit-A:** subnet router và IP forwarding cho Site A.
- **LB-A:** HAProxy/Keepalived, HTTPS termination, VIP và health check.
- **Web-A/Web-B:** `/healthz`, node identity, access log và SSH hardening.
- **Test-Client:** nguồn kiểm thử chức năng và negative security.

### Site B

- **Transit-B:** subnet router, forwarding và anti-bypass filtering.
- **Firewall-A/B:** nftables, NAT, deny-by-default, logging và gateway VIP.
- **DB-Primary/DB-Replica:** PostgreSQL 16 và streaming replication.
- **Log-Monitor:** rsyslog tập trung và điểm quản trị MANAGEMENT.

## Kiểm soát an ninh

Firewall sử dụng deny-by-default:

- WAN-LAB chỉ được truy cập dịch vụ công khai qua VIP và port được chỉ định.
- Truy cập trực tiếp Web IP, Database và Management bị chặn và ghi log.
- Web chỉ được truy cập PostgreSQL trên port `5432` tới đúng DB node.
- DB replication chỉ mở giữa Primary và Replica.
- SSH quản trị đi từ MANAGEMENT hoặc jump path được kiểm soát.
- Syslog được gửi về Log-Monitor trên port `514`.

Các log prefix chính:

```text
FW-ALLOW-WAN-VIP
FW-DENY-WAN-DIRECT
FW-ALLOW-WEB-DB
FW-ALLOW-DB-REPL
FW-ALLOW-MGMT-SSH
FW-DEFAULT-DENY
FW-DENY-INPUT-DEFAULT
```

## Phương pháp kiểm thử

### Routing và transit

- Xác minh peer, advertised routes và `ip_forward`.
- Kiểm tra route nội bộ đi qua firewall gateway.
- Kiểm tra không có đường bypass tới Database hoặc Management.

### Web và Load Balancer

- `/healthz` trả HTTP `200` trên cả hai Web node.
- HTTPS VIP phân phối request tới Web-A và Web-B.
- Khi Web-A dừng, Web-B tiếp tục phục vụ.
- Khi Web-A khôi phục, health check đưa node trở lại pool.
- Truy cập trực tiếp Web IP bị chặn.

### Database

- Kiểm tra `pg_is_in_recovery()` trên Primary và Replica.
- Đối chiếu dữ liệu giữa hai node.
- Xác minh `app_user` không có quyền DELETE/DROP ngoài phạm vi cấp.
- Dừng Primary, promote Replica và kiểm tra ghi dữ liệu.
- Rejoin Primary cũ bằng `pg_basebackup` theo runbook.

### Firewall và evidence

- DB port từ nguồn không được phép phải timeout hoặc bị DROP.
- SSH trực tiếp tới Firewall từ nguồn ngoài MANAGEMENT phải bị từ chối.
- Mỗi kiểm thử ghi node thực hiện, thời gian, lệnh, kết quả và log liên quan.
- Ảnh chụp dùng tên `YYYYMMDD-owner-test-name`.

## Kết quả xác minh hiện tại

| Hạng mục | Trạng thái | Ghi chú |
|---|---|---|
| PAL-v2 LAN/Tailscale | PASS | Handshake thành công, hai kênh HEALTHY |
| Transit-B routing | PASS | Route `/16` qua `172.20.20.1`, forwarding bật |
| Negative DB `5432` | PASS | `FW-DEFAULT-DENY` |
| Direct SSH tới Firewall | PASS | `FW-DENY-INPUT-DEFAULT` |
| ICMP tới DB | PASS | Được policy cho phép |
| DB replication | PASS | Primary `f`, Replica `t`, dữ liệu đồng bộ |
| Least privilege | PASS | INSERT thành công, DELETE bị từ chối |
| DB failover | PASS | Replica promote và ghi mới thành công |
| Central logging | PASS | Log được thu thập theo từng node |
| Firewall HA failover | GAP | Chưa xác minh được `keepalived.service` |

## Giới hạn hiện tại

1. Cơ chế giữ và chuyển Gateway VIP giữa Firewall-A và Firewall-B cần được xác nhận bằng bằng chứng chuyển VIP thực tế.
2. VIP thiết kế ban đầu `172.20.20.100` phải phân biệt với VIP Web thực tế Site A `172.20.21.100`.
3. Sau khi Replica được promote, Primary cũ phải rejoin bằng `pg_basebackup`; không khởi động độc lập để tránh split-brain.
4. `scripts/p2p/peer_agent.db` và `scripts/p2p/transfers/` là dữ liệu runtime cục bộ, không phải source code bắt buộc.

## Cấu trúc repository

| Đường dẫn | Nội dung |
|---|---|
| `configs/` | Cấu hình VM, Tailscale và firewall |
| `docs/` | Thiết kế, giao thức và runbook |
| `lab/network/` | Topology, IP plan và VMnet |
| `lab/transit/` | Transit-A/Transit-B và subnet routing |
| `lab/firewall/` | Rule matrix, NAT và recovery |
| `lab/load-balancer/` | HAProxy, VIP và health check |
| `lab/web/` | Web node và hardening |
| `lab/database/` | Replication, privilege và recovery |
| `lab/monitoring/` | Syslog và log tập trung |
| `lab/testing/` | Test plan và acceptance criteria |
| `scripts/` | Provisioning, verification và PAL-v2 |
| `evidence/` | Ảnh, log và biên bản kiểm thử |
| `diagrams/` | Sơ đồ kiến trúc |

## Tái lập nhanh

1. Tạo VM và VMnet theo `configs/vmware/`.
2. Cấu hình IP, hostname, SSH key-only và timezone.
3. Cấu hình Transit-A/Transit-B, Tailscale routes và ACL.
4. Nạp firewall policy, NAT và logging.
5. Cài Load Balancer, Web, PostgreSQL và Log-Monitor.
6. Chạy runbook trong `lab/` và lưu evidence theo timestamp.
7. Đối chiếu acceptance matrix trước khi nghiệm thu.

```bash
python scripts/p2p/agent_peer.py --self-test
python scripts/p2p/agent_peer.py --status
python scripts/p2p/agent_peer.py --handshake
sudo -u postgres psql -t -c "SELECT pg_is_in_recovery();"
sudo nft list ruleset
ip route
```

## Nguyên tắc an toàn

- Chỉ kiểm thử trong mạng lab cô lập và được nhóm cho phép.
- Không commit password, token, private key, file `.env`, VMware lock/state hoặc log chứa credential.
- Không chạy lệnh phá dữ liệu trên DB nếu chưa xác định đúng VM và chưa có snapshot/backup.
- Dừng Primary cũ trước khi promote Replica để tránh split-brain.
- Mọi kết luận PASS/FAIL phải có output hoặc log làm bằng chứng.
