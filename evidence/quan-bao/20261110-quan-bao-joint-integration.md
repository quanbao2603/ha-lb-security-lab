# Biên bản kiểm thử tích hợp chung Site A – Site B

- **Mã biên bản:** `20261110-quan-bao-joint-integration`
- **Người thao tác:** Quan Bảo
- **Site B owner hỗ trợ:** Minh Hùng
- **Thời gian thực hiện:** 2026-11-10, khoảng 04:22–04:49 (+07:00)
- **Runbook:** `docs/quan-bao/joint-lab-test-runbook.md`
- **Raw output:** `evidence/quan-bao/logs/`
- **Images:** `evidence/quan-bao/images/`

## Tổng kết

| Mã | Nội dung | Kết quả | Evidence |
|---|---|---|---|
| C-01 | Transit-A nhận route Site B và ping DB | PASS — `ip route get` đi qua `tailscale0`, ping DB đạt 0% loss | `20261110-quan-bao-joint-transit-a-accept-routes.png` + log |
| J-01 | Windows/Site A đi qua Transit-B vào Log-Monitor | PASS — trả về `log-monitor` | PNG + log |
| J-02 | Rule tạm cho Site-A jump có log | PASS — `[FW-ALLOW-SITE-A-JUMP:]`, `SRC=172.20.20.6`, `DST=172.20.50.10` | PNG + log |
| J-03 | Route DB/MGMT trên Transit-B | PASS — route thực tế đi qua `172.20.20.1`; forwarding = `1` | PNG + log |
| J-04 | nftables deny-by-default và VIP Firewall-A | PASS — nftables active, policy drop, prefix FW đầy đủ, VIP `.1` trên FW-A. Keepalived hiện inactive; VIP đang được quản lý tĩnh | PNG + log |
| J-05 | Negative DB/MGMT/password SSH | PASS — TCP probe timeout, password SSH bị từ chối | PNG + log |
| J-06 | Firewall deny log | PASS — `FW-DEFAULT-DENY` khớp truy cập tới `172.20.40.11:5432` | PNG + log |
| J-07 | DB Primary/Replica trước failover | PASS tại thời điểm kiểm thử — Primary `f`, Replica `t`, dữ liệu giống nhau, streaming async trước khi failover | raw log + PNG render từ raw log |
| J-08 | Least privilege | PASS — INSERT/UPDATE thành công; DELETE permission denied; DROP must be owner | PNG + log |
| J-09 | DB failover | PASS có điều kiện — `.11` inactive; `.12` đã là Primary `f`; ghi dữ liệu id `75` thành công. Lệnh `pg_promote` trả recovery not in progress vì Replica đã tự ở trạng thái promoted khi lệnh được gọi | raw log + PNG render từ raw log |
| J-10 | DB-Primary cũ rejoin | PARTIAL — lần đầu pg_basebackup lỗi vì data directory chưa rỗng; lần retry thành công và `.11` có `pg_is_in_recovery() = t` | raw log + PNG render từ raw log |
| J-11 | Firewall-A → Firewall-B | PASS — FW-B nhận đủ 5 VIP `.1`, nftables active; negative DB vẫn timeout; T0→T1 khoảng 7 giây | raw log + PNG render từ raw log |
| J-12 | Firewall failback | PASS — FW-A nhận lại đủ 5 VIP `.1`, FW-B nhường VIP | raw log + PNG render từ raw log |
| J-13 | Central syslog | PASS — `/var/log/central/fw-a/kernel.log` có `FW-ALLOW-SYSLOG`, `FW-ALLOW-SITE-A-JUMP` và log firewall theo timestamp | PNG + log |

## Chi tiết đáng chú ý

### DB sau failover/rejoin

Trạng thái cuối đã kiểm tra:

- `172.20.40.12` (`db-replica`) hiện là Primary: `pg_is_in_recovery() = f`.
- `172.20.40.11` (`db-primary`) hiện chạy và là Standby: `pg_is_in_recovery() = t`.
- Tuy nhiên tại lần kiểm tra cuối, `pg_stat_replication` trên `.12` và `pg_stat_wal_receiver` trên `.11` chưa hiện session streaming. Cần Hùng kiểm tra thêm `pg_hba.conf`, `primary_conninfo`, `repl_user` và log PostgreSQL trước khi đánh dấu replication sau failover là hoàn toàn PASS.

### Firewall failover

`keepalived` trên Firewall-A được kiểm tra là `inactive`, nên không dùng `systemctl stop keepalived` để chuyển VIP. Kịch bản thực tế đã dùng phương án manual trong `lab/firewall/failover-and-recovery-runbook.md`:

1. Thêm các gateway `.1` lên Firewall-B.
2. Gỡ các gateway `.1` khỏi Firewall-A.
3. Kiểm tra Firewall-B giữ đủ 5 VIP.
4. Thêm lại VIP trên Firewall-A.
5. Gỡ VIP khỏi Firewall-B.

Máy Firewall-B không có `arping`, nhưng việc chuyển VIP và kiểm tra địa chỉ đã hoàn tất; cần Hùng xác nhận thêm ARP convergence nếu muốn ghi RTO chuẩn production-like.

### Rule tạm

Rule `[FW-ALLOW-SITE-A-JUMP:]` đã được thêm trên Firewall-B để duy trì đường quản trị trong lúc FW-B giữ gateway. Đây là rule tạm phục vụ demo; Hùng cần review và remove trên cả Firewall-A/Firewall-B sau khi hoàn tất nghiệm thu.

## Files raw output

- `logs/20261110-joint-transit-a-accept-routes.log`
- `logs/20261110-joint-ssh-jump-log-monitor.log`
- `logs/20261110-joint-fw-allow-site-a-jump-log.log`
- `logs/20261110-joint-transit-b-routes.log`
- `logs/20261110-joint-fw-a-policy-vip.log`
- `logs/20261110-joint-negative-client.log`
- `logs/20261110-joint-fw-deny-log.log`
- `logs/20261110-joint-db-replication-sync.log`
- `logs/20261110-joint-db-least-privilege.log`
- `logs/20261110-joint-db-failover-promote.log`
- `logs/20261110-joint-db-failover-verify.log`
- `logs/20261110-joint-db-rejoin-standby.log`
- `logs/20261110-joint-fw-failover-fwb-vip.log`
- `logs/20261110-joint-fw-failover-client-negative.log`
- `logs/20261110-joint-fw-failback.log`
- `logs/20261110-joint-central-syslog.log`

## Ảnh PNG đã tạo

Đã tạo 16 ảnh PNG cho toàn bộ các bước đã ghi nhận. 9 ảnh đầu được chụp cửa sổ Notepad hiển thị raw log; 7 ảnh bổ sung được render trực tiếp từ raw log và có footer ghi rõ nguồn, không phải ảnh chụp terminal trực tiếp:

- C-01 Transit-A route
- J-01 SSH jump Log-Monitor
- J-02 jump allow log
- J-03 Transit-B routes
- J-04 Firewall-A policy/VIP
- J-05 negative client
- J-06 firewall deny log
- J-08 DB least privilege
- J-13 central syslog

Bảy ảnh J-07, J-09a, J-09b, J-10, J-11a, J-11b và J-12 được tạo từ raw `.log` đã lưu, với footer `Rendered from captured raw SSH output`. Đây là ảnh minh họa có nguồn gốc từ output thật, không phải ảnh chụp terminal trực tiếp; raw `.log` mới là bằng chứng nguyên bản.

## Việc cần làm buổi sáng

1. Mở và rà soát raw logs cùng biên bản này.
2. Nhờ Hùng kiểm tra và khôi phục streaming replication sau khi `.11` rejoin `.12`.
3. Nhờ Hùng xác nhận rule jump tạm trên cả hai firewall và remove sau nghiệm thu.
4. Nếu cần ảnh PNG cho J-07/J-09/J-10/J-11/J-12, mở các raw `.log` bằng Notepad và chụp theo bảng tên trong runbook.
5. Đối chiếu bảng này với Hùng trước khi cập nhật `lab/testing/acceptance-matrix.md`.
6. Commit/push sau khi Bảo đã review; chưa có commit nào được tạo bởi agent.
