# VM Inventory & RAM Profile — Minh Hùng (Site B)

<!-- ponytail: Quản lý cấu hình VMware thủ công qua bảng chuẩn hóa cho 6 VM; nâng cấp lên Packer/Terraform/Ansible khi số lượng VM > 10 hoặc cần rebuild tự động. -->

## 1. Danh sách 6 VM của Minh Hùng

| STT | Tên VM | Hostname | vCPU | RAM | Vùng mạng (VMnet) | Địa chỉ IP | Vai trò chính |
|---:|---|---|---:|---:|---|---|---|
| 1 | **Transit-B** | `transit-b` | 1 vCPU | 768 MB | DMZ (`VMnet12`) + NAT (`VMnet8` Tailscale WAN) | `172.20.20.6/24` (route `172.20.0.0/16` via `172.20.20.1`) | Linux Transit VM Site B, IP forwarding, Tailscale subnet router, nftables anti-bypass |
| 2 | **Firewall-A** | `fw-a` | 1 vCPU | 1 GB (1024 MB) | 5 vùng (`VMnet10/12/13/14/15`) | `.2/24` + VIP Gateway `.1/24` trên `eth0..eth4` (`172.20.10..50.0/24`) | Firewall chính (Active), NAT, deny-by-default policy, inter-zone routing, logging |
| 3 | **Firewall-B** | `fw-b` | 1 vCPU | 1 GB (1024 MB) | 5 vùng (`VMnet10/12/13/14/15`) | `.3/24` standby trên `eth0..eth4` (nhận `.1/24` khi failover/restore) | Firewall dự phòng (Standby/HA recovery), đồng bộ rule matrix từ Firewall-A |
| 4 | **DB-Primary** | `db-primary` | 2 vCPU | 1.5 GB (1536 MB) | DATABASE (`VMnet14`) | `172.20.40.11/24` (GW: `172.20.40.1`) | Database Primary, nhận kết nối từ Web/App qua Firewall và cấp luồng replication |
| 5 | **DB-Replica** | `db-replica` | 2 vCPU | 1.5 GB (1536 MB) | DATABASE (`VMnet14`) | `172.20.40.12/24` (GW: `172.20.40.1`) | Database Replica (Read-only / Standby), sẵn sàng promote thủ công khi DB-Primary lỗi |
| 6 | **Log-Monitor** | `log-monitor` | 1 vCPU | 1 GB (1024 MB) | MGMT (`VMnet15`) | `172.20.50.10/24` (GW: `172.20.50.1`) | Máy chủ thu thập Syslog tập trung (`514/UDP,TCP`) và kiểm tra sức khỏe dịch vụ nội bộ |

- **Tổng tài nguyên tối đa (nếu bật đủ 6 VM):** `8 vCPU` / `6.75 GB RAM (6,912 MB)`.
- **Hệ điều hành chuẩn:** Linux Minimal (Debian 12 / Ubuntu Server 24.04 LTS minimal, tắt GUI).

---

## 2. Mapping 5 vùng mạng (Network Zones)

Tất cả VMnet nội bộ cấu hình ở chế độ **Host-Only (tắt VMware DHCP cục bộ)** để mọi luồng định tuyến liên vùng bắt buộc đi qua `Firewall-A`/`Firewall-B`.
*(Lưu ý kỹ thuật: Driver `vmnet.sys` / `vnetlib64.dll` trên Windows giới hạn `VNL_GetNumberOfVnets() = 20` tức `VMnet0..VMnet19`, trả lỗi `87 ERROR_INVALID_PARAMETER` nếu dùng chỉ số `>= 20`; do đó 5 vùng `.10/.20/.30/.40/.50` được ánh xạ chuẩn vào `VMnet10, VMnet12, VMnet13, VMnet14, VMnet15`)*

| Vùng mạng | Dải IP (CIDR) | VMware Adapter | Gateway (Firewall-A) | VM của Minh Hùng trong vùng | Nguyên tắc bảo mật |
|---|---|---|---|---|---|
| **WAN-LAB** | `172.20.10.0/24` | `VMnet10` | `172.20.10.1` | `Firewall-A`, `Firewall-B` | Giả lập mạng ngoài; chỉ được truy cập VIP `172.20.20.100:80,443` |
| **DMZ** | `172.20.20.0/24` | `VMnet12` | `172.20.20.1` | `Transit-B` (`172.20.20.6`), `Firewall-A/B` | Chứa LB/Web/Transit; cấm kết nối thẳng vào DB không qua Firewall |
| **APP** | `172.20.30.0/24` | `VMnet13` | `172.20.30.1` | `Firewall-A`, `Firewall-B` | Vùng đệm backend; chỉ mở port DB (`5432`/`3306`) theo IP tới DATABASE |
| **DATABASE** | `172.20.40.0/24` | `VMnet14` | `172.20.40.1` | `DB-Primary` (`.11`), `DB-Replica` (`.12`), `Firewall-A/B` | Cô lập hoàn toàn khỏi WAN-LAB; chỉ nhận kết nối từ Web/App và Replication |
| **MGMT** | `172.20.50.0/24` | `VMnet15` (Host IP `.254`) | `172.20.50.1` | `Log-Monitor` (`.10`), `Firewall-A/B` | Quản trị SSH key-only (`22/TCP`) và nhận log tập trung |

---

## 3. Profile bật tuần tự theo RAM (Sequential Boot Profiles)

Không bật đồng thời cả 6 VM khi không cần thiết để bảo toàn RAM và tránh nghẽn I/O đĩa. Khởi động từng VM cách nhau **20–30 giây** theo đúng thứ tự phụ thuộc:

### Thứ tự bật chuẩn (Boot Sequence)
1. `Firewall-A` (1 GB) — Khởi tạo gateway cho 5 vùng và nạp rule lọc trước tiên.
2. `Log-Monitor` (1 GB) — Sẵn sàng nhận syslog ngay khi các dịch vụ khác khởi chạy.
3. `DB-Primary` (1.5 GB) — Khởi tạo dịch vụ cơ sở dữ liệu chính.
4. `DB-Replica` (1.5 GB) — Kết nối luồng replication tới `DB-Primary`.
5. `Transit-B` (768 MB) — Mở kênh Tailscale và subnet route sau khi mạng nội bộ đã ổn định.
6. `Firewall-B` (1 GB) — Chỉ bật khi diễn tập kịch bản HA/Failover của Firewall (Ngày 5).

### Các Profile vận hành theo kịch bản RAM
| Profile | Mục đích sử dụng | Các VM bật | Các VM tắt (Power Off/Suspend) | Tổng RAM |
|---|---|---|---|---:|
| **P1 — Core Routing** | Ngày 2–3: Cấu hình Transit-B, Tailscale, Firewall Zone/NAT | `Firewall-A`, `Transit-B`, `DB-Primary`, `Log-Monitor` | `Firewall-B`, `DB-Replica` | **4.25 GB** |
| **P2 — Standard Demo** | Ngày 4, 6, 7: Replication, Logging, Negative Test, Demo chính | `Firewall-A`, `Transit-B`, `DB-Primary`, `DB-Replica`, `Log-Monitor` | `Firewall-B` | **5.75 GB** |
| **P3 — FW Failover** | Ngày 5 (Ca 1): Mô phỏng lỗi `Firewall-A` chuyển sang `Firewall-B` | `Firewall-A`, `Firewall-B`, `Transit-B`, `DB-Primary`, `Log-Monitor` | `DB-Replica` | **5.25 GB** |
| **P4 — DB Failover** | Ngày 5 (Ca 2): Dừng `DB-Primary`, promote `DB-Replica` | `Firewall-A`, `Transit-B`, `DB-Primary`, `DB-Replica`, `Log-Monitor` | `Firewall-B` | **5.75 GB** |

---

## 4. Checklist tạo Snapshot `day-1-clean`

Thực hiện đầy đủ trên cả 6 VM ngay trong Ngày 1 trước khi join Tailscale hoặc cấu hình dịch vụ chuyên sâu:

- [x] **Tài nguyên & Adapter:** Đúng số vCPU, dung lượng RAM và gán đúng card `VMnet` theo Mục 1 & 2 (tắt DHCP VMware trên các VMnet).
- [x] **Hostname & Timezone:** Đặt đúng `/etc/hostname` (`transit-b`, `fw-a`, `fw-b`, `db-primary`, `db-replica`, `log-monitor`) và chạy `timedatectl set-timezone Asia/Ho_Chi_Minh`.
- [x] **IP tĩnh & Routing:** Gán IP tĩnh chuẩn theo bảng, kiểm tra `ping -c 3` thông tới gateway `.1` của vùng mạng tương ứng.
- [x] **SSH Hardening cơ bản:** Nạp SSH public key quản trị, cấu hình `PermitRootLogin no` và `PasswordAuthentication no` trong `/etc/ssh/sshd_config`.
- [x] **Tối ưu nền tảng:** Cài bản minimal không GUI, tắt dịch vụ thừa (`avahi-daemon`, `cups`, `bluetooth`).
- [x] **Vệ sinh bảo mật (Zero Secret):** Không lưu Tailscale auth key, token, mật khẩu hay private key nhạy cảm; chạy `history -c && rm -f ~/.bash_history`.
- [x] **Chụp Snapshot:** Tắt máy sạch (`sudo poweroff`), vào VMware Snapshot Manager tạo snapshot tên chính xác **`day-1-clean`** kèm mô tả ngày giờ.
