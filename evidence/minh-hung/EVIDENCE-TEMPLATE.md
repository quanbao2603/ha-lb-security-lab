# Mẫu Biên Bản Bằng Chứng Kiểm Thử (`EVIDENCE-TEMPLATE.md`)

> **Quy ước bắt buộc khi tạo bằng chứng mới trong `evidence/minh-hung/`:**
> 1. **Đặt tên file:** `YYYYMMDD-minh-hung-<test-name>.md` (ví dụ: `20261107-minh-hung-fw-02-wan-direct-deny.md`). Ảnh chụp màn hình đi kèm (nếu có) đặt cùng tiền tố `YYYYMMDD-minh-hung-<test-name>.png`.
> 2. **Tuyệt đối không lưu thông tin nhạy cảm:** Không commit Tailscale auth key (`tskey-*`), mật khẩu DB, SSH private key hoặc thông tin máy thật.
> 3. **Tạo nhanh bằng script:** Có thể chạy trực tiếp:
>    ```bash
>    ./scripts/minh-hung/collect-evidence.sh <test-name> "<lệnh-kiểm-thử>" "<kết-quả-kỳ-vọng>"
>    ```

---

# Biên Bản Bằng Chứng Kiểm Thử: `YYYYMMDD-minh-hung-<test-name>`

## 1. Thông tin thực hiện (Metadata)

| Trường thông tin | Nội dung ghi nhận |
| :--- | :--- |
| **Mã Test Case** | `TC-MH-XX-01` *(tham chiếu `lab/testing/minh-hung/test-cases-minh-hung.md`)* |
| **Tên bài kiểm thử** | `<Mô tả ngắn gọn mục tiêu kiểm thử>` |
| **Người thực hiện** | Minh Hùng |
| **Thời gian bắt đầu** | `YYYY-MM-DDTHH:MM:SS+07:00` |
| **Thời gian kết thúc** | `YYYY-MM-DDTHH:MM:SS+07:00` |
| **Máy thực hiện (Hostname & IP)** | `<ví dụ: firewall-a (172.20.50.2) / test-client (172.20.10.10)>` |
| **Phân vùng mạng (Zone)** | `<WAN-LAB | DMZ | APP | DATABASE | MANAGEMENT>` |
| **Snapshot nền trước khi chạy** | `<ví dụ: day-3-fw-baseline>` |

---

## 2. Lệnh thực hiện (Command Executed)

```bash
# Ghi chính xác câu lệnh đã chạy để người review có thể tái lập 100%
<dán câu lệnh thực tế tại đây>
```

---

## 3. Bảng đối chiếu Expected vs Actual

| Hạng mục đối chiếu | Expected (Kỳ vọng theo thiết kế) | Actual (Kết quả thực tế thu được) | Kết quả |
| :--- | :--- | :--- | :---: |
| **Hành vi kết nối / dịch vụ** | `<ví dụ: Kết nối TCP 5432 từ WAN bị chặn timeout>` | `<ví dụ: nc báo Connection timed out sau 3 giây>` | `PASS / FAIL` |
| **Trạng thái hệ thống / DB** | `<ví dụ: pg_is_in_recovery() = f sau promote>` | `<ví dụ: psql trả về f, cho phép INSERT mới>` | `PASS / FAIL` |
| **Ghi nhận Audit Log** | `<ví dụ: Xuất hiện log FW-DENY-WAN-DIRECT trên FW & Log-Monitor>` | `<ví dụ: Đã ghi nhận đúng SRC, DST, DPT cùng timestamp>` | `PASS / FAIL` |

---

## 4. Kết quả đầu ra của lệnh (Command Output)

```text
<Dán nguyên văn stdout/stderr của lệnh sau khi đã ẩn secret (nếu có)>
```

---

## 5. Log trích xuất đối chiếu theo Timestamp (Extracted Logs)

### 5.1. Log tại Node nguồn / Firewall / Database
```text
# Ví dụ trích từ: sudo journalctl -k --grep="FW-" -n 10 --no-pager
<Dán dòng log khớp với khung thời gian chạy lệnh>
```

### 5.2. Log tập trung tại `Log-Monitor` (`172.20.50.10:/var/log/central/`)
```text
# Ví dụ trích từ: sudo tail -n 10 /var/log/central/firewall-a/kernel.log
<Dán dòng log tập trung tương ứng>
```

---

## 6. Kết luận nghiệm thu

- **Đánh giá chung:** `[ ] PASS` / `[ ] FAIL`
- **Ghi chú xử lý lỗi / Độ trễ / RTO (nếu là bài test Failover):** `<Ghi rõ tổng số giây gián đoạn dịch vụ hoặc nguyên nhân nếu FAIL>`
- **Người đối chiếu chéo (Peer Reviewer):** Quan Bảo

<!-- ponytail: static Markdown template; upgrade to structured YAML frontmatter + schema linter if automated grading is introduced -->
