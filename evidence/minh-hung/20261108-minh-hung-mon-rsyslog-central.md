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
| **Mã thoát lệnh (Exit Code)** | `1` |

## 2. Lệnh thực thi (Command)

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ops@172.20.50.10 'export PATH=$PATH:/usr/sbin:/sbin; /opt/lab/monitoring/monitoring-healthcheck.sh && sudo ls -la /var/log/central/'
```

## 3. Đối chiếu Expected vs Actual

| Tiêu chí | Nội dung |
| :--- | :--- |
| **Expected (Kỳ vọng)** | rsyslog listening on 514, logrotate 14 days, central logs present for all 5 VMs |
| **Actual (Thực tế)** | Lệnh kết thúc với mã thoát `1` (xem chi tiết output và log bên dưới). |
| **Đánh giá (PASS/FAIL)** | **FAIL** |

## 4. Output thực tế (Sanitized Output)

```text
Warning: Permanently added '172.20.50.10' (ED25519) to the list of known hosts.
=== [1/3] Kiểm tra trạng thái dịch vụ rsyslog & lắng nghe cổng 514 ===
[OK] Dịch vụ rsyslog đang hoạt động (active).
[OK] Cổng 514 (UDP/TCP) đang lắng nghe.
=== [2/3] Kiểm tra dung lượng lưu trữ tại /var/log/central ===
```

## 5. Log trích xuất đối chiếu (Firewall / Syslog)

```text
Không có quyền đọc journalctl hoặc không chạy trên node Firewall.
```
