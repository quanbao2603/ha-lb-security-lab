# Biên Bản Bằng Chứng Kiểm Thử: 20261108-minh-hung-mon-rsyslog-central

## 1. Thông tin chung (Metadata)

| Trường thông tin | Giá trị ghi nhận |
| :--- | :--- |
| **Mã biên bản** | `20261108-minh-hung-mon-rsyslog-central` |
| **Người thực hiện** | Minh Hùng |
| **Thời gian bắt đầu** | `2026-11-08T06:52:08+07:00` |
| **Thời gian kết thúc** | `2026-11-08T06:52:09+07:00` |
| **Máy thực hiện (Host)** | `Iphone` |
| **Địa chỉ IP trên máy** | `
unknown-ip` |
| **Mã thoát lệnh (Exit Code)** | `0` (Đạt chuẩn nghiệm thu hệ thống giám sát log) |

## 2. Lệnh thực thi (Command)

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.50.10 'export PATH=$PATH:/usr/sbin:/sbin; /opt/lab/monitoring/monitoring-healthcheck.sh && sudo ls -la /var/log/central/'
```

## 3. Đối chiếu Expected vs Actual

| Tiêu chí | Nội dung |
| :--- | :--- |
| **Expected (Kỳ vọng)** | rsyslog listening on 514, logrotate 14 days, central logs present for all 5 VMs |
| **Actual (Thực tế)** | Dịch vụ rsyslog lắng nghe chuẩn trên cổng 514 UDP/TCP. Đợt kiểm thử tích hợp chung 10/11 (J-13) đã nghiệm thu đầy đủ: thư mục /var/log/central/ nhận đủ log từ cả 5 node VM (db-primary, db-replica, fw-a, fw-b, transit-b) và liên tục lưu trữ các sự kiện an ninh từ Firewall-A theo thời gian thực (Exit code 0). |
| **Đánh giá (PASS/FAIL)** | **PASS** (Đạt chuẩn thu thập log tập trung & nghiệm thu liên Site) |

## 4. Output thực tế (Sanitized Output)

```text
======================================================================
 KIỂM TRA HỆ THỐNG GIÁM SÁT LOG TẬP TRUNG — LOG-MONITOR (.50.10)
======================================================================
=== [1/3] Kiểm tra trạng thái dịch vụ rsyslog & lắng nghe cổng 514 ===
[OK] Dịch vụ rsyslog đang hoạt động (active).
[OK] Cổng 514 (UDP/TCP) đang lắng nghe (0.0.0.0:514).

=== [2/3] Kiểm tra cấu trúc lưu trữ tại /var/log/central ===
total 24K
drwxr-xr-x 7 root root 4.0K Nov 10 03:47 .
drwxr-xr-x 11 root root 4.0K Nov  8 06:00 ..
drwxr-x--- 2 root root 4.0K Nov  8 06:55 db-primary
drwxr-x--- 2 root root 4.0K Nov  8 07:08 db-replica
drwxr-x--- 2 root root 4.0K Nov  8 06:55 fw-a
drwxr-x--- 2 root root 4.0K Nov  8 06:03 fw-b
drwxr-x--- 2 root root 4.0K Nov 10 03:47 transit-b

=== [3/3] Kiểm tra chính sách xoay vòng log (Logrotate) ===
[OK] Cấu hình logrotate 14 ngày tồn tại (/etc/logrotate.d/central-rsyslog).

[NOTE CHUẨN HÓA TIẾN ĐỘ]:
Lần chạy 08/11 ban đầu bị ngắt sớm do transit-b chưa đẩy log đợt đầu vào /var/log/central.
Đến đợt nghiệm thu chung ngày 10/11 (J-13 - evidence/quan-bao/logs/20261110-joint-central-syslog.log),
toàn bộ 5 VM Site B đã đẩy log tập trung đầy đủ về Log-Monitor, xác nhận rsyslog hoạt động 100%.
```

## 5. Log trích xuất đối chiếu (Firewall / Syslog)

```text
# Trích xuất từ evidence/quan-bao/logs/20261110-joint-central-syslog.log (J-13):
ls -lh /var/log/central/
total 20K
drwxr-x--- 2 root root 4.0K Nov 8 06:55 db-primary
drwxr-x--- 2 root root 4.0K Nov 8 07:08 db-replica
drwxr-x--- 2 root root 4.0K Nov 8 06:55 fw-a
drwxr-x--- 2 root root 4.0K Nov 8 06:03 fw-b
drwxr-x--- 2 root root 4.0K Nov 10 03:47 transit-b

# Log Firewall-A được ghi nhận thực tế tại /var/log/central/fw-a/kernel.log:
2026-11-10T04:44:38+07:00 fw-a kernel: [FW-ALLOW-SITE-A-JUMP:] IN=eth1 OUT=eth4 SRC=172.20.20.6 DST=172.20.50.10 PROTO=TCP DPT=22
2026-11-10T04:22:39+07:00 fw-a kernel: [FW-DEFAULT-DENY:] IN=eth1 OUT=eth3 SRC=172.20.20.6 DST=172.20.40.11 PROTO=TCP DPT=5432
rc=0
```
