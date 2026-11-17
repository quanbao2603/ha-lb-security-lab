# Kế Hoạch & Phân Công Công Việc (Đã Thống Nhất): `ha-lb-security-lab`

> **Nguồn đối chiếu:** `README.md`, `lab-manifest.yml` và phản hồi thống nhất `phan-hoi-phan-cong-minh-hung.md`.
> **Trạng thái hiện tại của repository:** Repository **đã có tài liệu thiết kế** (`README.md`, `lab-v2.html`, `detaiLab.html`, `lab-manifest.yml`, `.gitignore`) và **khung thư mục**, nhưng **chưa có cấu hình triển khai thực tế, script, runbook và evidence kiểm thử**.

---

## 1. Nguyên tắc kiến trúc & Lưu ý kỹ thuật quan trọng

1. **Nền tảng ảo hóa:** VMware Workstation (bật VM tuần tự theo khả năng RAM).
2. ** phân vùng mạng (5 vùng):** `WAN-LAB`, `DMZ`, `APP`, `DATABASE`, `MANAGEMENT`.
   - **Lưu ý về vùng `APP`:** `APP network` được thiết kế trong kiến trúc nhưng **chưa bắt buộc có App VM riêng trong baseline tuần đầu**. `Web-A`/`Web-B` đóng vai trò application node tối giản; App VM riêng là phần mở rộng sau khi đạt baseline.
3. **Nguyên tắc Tailscale & Transit:**
   - Tailscale chỉ chạy trên `Transit-A` và `Transit-B` (kèm `IP forwarding` + `subnet routing`).
   - **Không** cài Tailscale lên từng Web/Database VM trong mô hình chuẩn.
   - **Không** advertise toàn bộ mạng Database cho mọi thiết bị trong tailnet; chỉ advertise các subnet thật sự cần thiết.
   - Tailscale ACL **không thay thế** firewall lab; không dùng route từ Tailscale trên host để bypass firewall.
   - Mọi route quảng bá phải có tài liệu và kiểm thử cả đường hợp lệ lẫn đường bị chặn từ hai phía.
4. **Firewall là điểm kiểm soát chính:** `Deny-by-default`, chỉ mở đúng luồng cần thiết và phải ghi log đầy đủ.
5. **Bảo mật kho code:** Không commit token Tailscale, mật khẩu, private key, file `.env`, hoặc VMware state/lock.

---

## 2. Phần việc trọng tâm của bạn — **Minh Hùng** (Site B, Firewall, DB, Monitoring, Tailscale)

### A. Danh sách VM cần dựng & quản lý (theo khả năng RAM)
- `Transit-B` (Linux Transit VM phía máy Minh Hùng)
- `Firewall-A`, `Firewall-B` (Cụm Firewall kiểm soát các zone)
- `DB-Primary`, `DB-Replica` (Cụm Database Primary/Replica)
- `Log-Monitor` (Syslog & monitoring tối giản)

### B. Các thư mục thuộc Ownership của Minh Hùng (toàn quyền chỉnh sửa)

| Thư mục đích | Công việc cụ thể Minh Hùng cần làm |
|---|---|
| `configs/vmware/minh-hung/` | Ghi thông số VM, VMnet, adapter, bảng resource theo profile bật tuần tự và snapshot `day-1-clean`. |
| `lab/transit/site-b/` | Cấu hình `Transit-B`, IP forwarding, Tailscale subnet route phía Site B, firewall transit tối thiểu và checklist kết nối. |
| `configs/tailscale/` | Cấu hình Tailscale ACL, danh sách advertised routes (chỉ mở subnet cần thiết, không mở toàn bộ DB) và hướng dẫn approve route. |
| `lab/firewall/` & `configs/firewall/` | Cấu hình Zone, NAT, Port-forwarding giới hạn (WAN chỉ vào VIP), `deny-by-default`, **Firewall Rule Matrix**, firewall logging, quy trình backup/restore và bản export cấu hình đã loại secret. |
| `lab/database/` | Cấu hình replication `DB-Primary` -> `DB-Replica`, user privilege tối thiểu (tách user replication & app), giới hạn `bind-address`, backup, promote replica và recovery. |
| `lab/monitoring/` | Cấu hình Syslog tập trung tối giản, health check, log retention và dashboard cơ bản. |
| `scripts/minh-hung/` | Viết script kiểm tra bảng định tuyến (route), kiểm tra port policy, trạng thái DB replication và thu thập log. |
| `lab/testing/minh-hung/` | Kịch bản & kết quả kiểm thử firewall, routing, DB replication/failover và firewall recovery. |
| `evidence/minh-hung/` | Lưu ảnh chụp, log, output lệnh theo chuẩn `YYYYMMDD-minh-hung-<test-name>` (ghi rõ timestamp, expected/actual, downtime). |
| `docs/minh-hung/` | Nhật ký triển khai, Runbook Firewall/DB, sơ đồ trust boundary và kịch bản demo deny/log/DB recovery. |

---

## 3. Phần việc đối ứng của **Quan Bảo** (Site A, LB, Web, Test-Client)

- **VM phụ trách:** `Transit-A`, `LB-A`, `Web-A`, `Web-B`, `Test-Client`.
- **Thư mục phụ trách:** `lab/transit/site-a/`, `lab/load-balancer/`, `lab/web/`, `lab/testing/quan-bao/`, `evidence/quan-bao/`, `docs/quan-bao/`, `configs/vmware/quan-bao/`, `scripts/quan-bao/`.
- **Nội dung chính:** Dựng HAProxy + Keepalived + VIP + health check + HTTPS lab; harden Web-A/Web-B (`/healthz`, access log, node identity, SSH key-only); chạy kiểm thử load balancing, web failover và negative test từ WAN/DMZ (`Test-Client`).

---

## 4. Quy tắc vùng phối hợp chung & Quy hoạch IP

Các file/thư mục dùng chung **không được sửa đồng thời**:
- `README.md`
- `lab-v2.html`
- `lab/network/` (bảng IP, sơ đồ mạng tổng hợp)
- `diagrams/`
- `lab/testing/acceptance-matrix.md` (nếu tạo sau)

**Nguyên tắc phối hợp:**
- Quan Bảo đề xuất sơ đồ DMZ và luồng request; **Minh Hùng review gateway, route, zone và firewall boundary**.
- Bảng IP cuối cùng phải được cả hai cùng xác nhận; không ai tự ý đổi IP/subnet mà không báo trước.
- Nếu đổi IP của Web/DB/Transit, bắt buộc rà soát lại: HAProxy, Firewall rule, Tailscale route và test script.

---

## 5. Lộ trình triển khai 7 ngày (Đã thống nhất)

- [ ] **Ngày 1 — Baseline & chuẩn bị VM:**
  - **Minh Hùng:** Dựng `Transit-B`, `Firewall-A`, `Firewall-B`, `DB-Primary`, `DB-Replica`, `Log-Monitor` theo khả năng RAM; đặt hostname, IP, timezone, VMnet, chụp snapshot `day-1-clean`; ghi vào `configs/vmware/minh-hung/`.
  - **Quan Bảo:** Dựng `Transit-A`, `LB-A`, `Web-A`, `Web-B`, `Test-Client`; tạo trang nhận diện Web-A/B.
  - **Chung:** Thống nhất tên VM, bảng subnet/IP và quy ước đặt tên file.
- [ ] **Ngày 2 — Transit & phân vùng mạng:**
  - **Minh Hùng:** Cấu hình `Transit-B`, Tailscale subnet route, ACL và quy trình approve route (`lab/transit/site-b/`, `configs/tailscale/`).
  - **Quan Bảo:** Cấu hình `Transit-A`, IP forwarding và route cục bộ (`lab/transit/site-a/`).
  - **Kiểm tra:** Route hợp lệ thông suốt; các subnet không được phép truy cập bị chặn hoàn toàn.
- [ ] **Ngày 3 — Firewall & dịch vụ Edge:**
  - **Minh Hùng:** Dựng firewall zones, NAT, port forwarding giới hạn, `deny-by-default`, rule matrix và logging (`lab/firewall/`, `configs/firewall/`).
  - **Quan Bảo:** Dựng HAProxy, Keepalived, VIP, health check và HTTPS lab (`lab/load-balancer/`).
  - **Kiểm tra:** WAN chỉ vào được VIP; chặn truy cập trực tiếp vào DB/MGMT/Web node.
- [ ] **Ngày 4 — Web, Database & Monitoring:**
  - **Minh Hùng:** Dựng DB replication (`DB-Primary` -> `DB-Replica`), user tối thiểu quyền, bind-address, backup và Syslog (`lab/database/`, `lab/monitoring/`).
  - **Quan Bảo:** Harden `Web-A`/`Web-B`, tạo `/healthz`, access log, node identity và script kiểm tra.
  - **Kiểm tra:** Request đi qua VIP tới Web và dữ liệu ghi trên Primary xuất hiện trên Replica.
- [ ] **Ngày 5 — Failover & Recovery:**
  - **Minh Hùng:** Dừng `DB-Primary`, promote `DB-Replica` theo runbook; mô phỏng `Firewall-A` lỗi và khôi phục; lưu evidence vào `evidence/minh-hung/`.
  - **Quan Bảo:** Dừng `Web-A`, chứng minh LB tự chuyển sang `Web-B`; lưu evidence vào `evidence/quan-bao/`.
- [ ] **Ngày 6 — Kiểm thử bảo mật (Negative Test) & Tinh chỉnh:**
  - **Quan Bảo:** Từ `Test-Client` test truy cập DB trực tiếp, SSH từ WAN, Web bypass và HTTPS.
  - **Minh Hùng:** Đối chiếu firewall log, Tailscale ACL, routing table, DB log và quyền user; sửa lỗi trong vùng ownership của mình rồi báo Quan Bảo chạy lại test.
- [ ] **Ngày 7 — Tích hợp & Demo:**
  - **Minh Hùng:** Tổng hợp phần Firewall/DB/Tailscale, sơ đồ trust boundary và kịch bản demo deny/log/DB recovery.
  - **Quan Bảo:** Tổng hợp phần Web/LB, sơ đồ luồng request và demo VIP/Web failover.
  - **Chung:** Chạy acceptance checklist, kiểm tra không lộ secret và diễn tập demo.

---

## 6. Quy trình Git (Làm việc trực tiếp trên nhánh `main`)

Hai thành viên đã thống nhất **dùng chung branch `main`** (không bắt buộc tạo feature branch hay Pull Request).

```bash
# 1. Luôn cập nhật code mới nhất trước khi bắt đầu làm việc
git pull origin main

# 2. Chỉ chỉnh sửa các file trong thư mục thuộc ownership của Minh Hùng
# (Nếu cần sửa file chung như README.md, lab-v2.html, lab/network/ -> Báo trước cho Quan Bảo)

# 3. Kiểm tra kỹ thay đổi (đảm bảo không dính secret/password/token) và chỉ stage phần của mình
git status
git diff
git add lab/transit/site-b/ lab/firewall/ configs/firewall/ configs/tailscale/ lab/database/ lab/monitoring/ lab/testing/minh-hung/ evidence/minh-hung/ docs/minh-hung/ configs/vmware/minh-hung/ scripts/minh-hung/

# 4. Commit nhỏ theo từng nhóm chức năng và đẩy thẳng lên main
git commit -m "Mô tả ngắn gọn thay đổi"
git push origin main
```

<!-- ponytail: single-file markdown plan on main; split into per-day runbooks under docs/minh-hung/ as each day completes -->
