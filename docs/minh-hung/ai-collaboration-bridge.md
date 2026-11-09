# HƯỚNG DẪN KẾT NỐI & GIAO TIẾP VỚI AI SITE B (MINH HÙNG)

Hệ thống Site B đã khởi chạy tiến trình nền **AI Collaboration & Security Event Streamer** chạy liên tục 24/7.
Mọi tương tác từ AI của Bảo hoặc máy của Bảo sẽ được chuyển tiếp tức thời (streaming log) về console của AI Minh Hùng.

---

## 1. Giao thức HTTP API (Khuyến nghị cho AI của Bảo)

Địa chỉ Bridge: `http://100.64.115.23:8080` (hoặc qua subnet DMZ `http://172.20.20.6:8080`)

### 1.1. Gửi thông điệp / Trạng thái kiểm thử
```bash
curl -X POST http://100.64.115.23:8080/messages \
  -H "Content-Type: application/json" \
  -d '{"from": "Bao-AI", "type": "status_update", "content": "Bảo AI đã hoàn thành cấu hình Web-A/B, chuẩn bị test kết nối DB"}'
```

### 1.2. Đọc tin nhắn trao đổi
```bash
curl -s http://100.64.115.23:8080/messages | jq
```

### 1.3. Kiểm tra sức khỏe hệ thống Site B
```bash
curl -s http://100.64.115.23:8080/status | jq
```

---

## 2. Giao thức SSH CLI trực tiếp trên Transit-B

Bảo có thể gửi tin nhắn trực tiếp từ terminal Windows hoặc Transit-A bằng SSH:

```bash
# Gửi tin nhắn đến AI Minh Hùng
ssh ops@100.64.115.23 "ai-chat send 'Bảo: Bắt đầu chạy test Negative kiểm tra ranh giới Firewall-A'"

# Xem lịch sử trao đổi
ssh ops@100.64.115.23 "ai-chat list"
```

---

## 3. Tự động nhận diện qua Git

Khi AI của Bảo tạo commit và push lên nhánh `main` hoặc tạo pull request trên GitHub:
- Tiến trình nền sẽ tự động phát hiện commit mới qua `git fetch`.
- AI của Minh Hùng sẽ nhận streaming event thông báo hash, tác giả và tiêu đề commit của Bảo.

---

## 4. Tự động giám sát ranh giới bảo mật (Live Security Event)

Bất kỳ gói tin nào từ Site A vi phạm ranh giới bảo mật (quét port DB, thử SSH trái phép vào Firewall-A, bypass Transit) đều được `Firewall-A` bắt giữ và stream trực tiếp về phiên làm việc của AI Minh Hùng với mã định danh `[SECURITY-EVENT] [FW-DENY-...]`.
