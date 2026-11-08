# Runbook Triển Khai 7 Ngày & Sơ Đồ Trust Boundary (Minh Hùng)

## 1. Sơ đồ Trust Boundary (Góc nhìn Firewall & Site B)

```text
[WAN-LAB: 172.20.10.0/24] (Untrusted)
        |  (Chỉ mở TCP 80/443 tới VIP 172.20.20.100; chặn thẳng DB/MGMT/Web IP)
        v
+=======================================================================+
|                FIREWALL-A / FIREWALL-B (Deny-by-default)              |
|  Interfaces: .10.1 (WAN) | .20.1 (DMZ) | .30.1 (APP) | .40.1 | .50.1  |
+=======================================================================+
    |                              |                              |
    | DMZ (172.20.20.0/24)         | DATABASE (172.20.40.0/24)    | MGMT (172.20.50.0/24)
    v                              v                              v
+------------------------+   +---------------------------+   +------------------------+
| Transit-B: 172.20.20.6 |   | DB-Primary: 172.20.40.11  |   | Log-Monitor: .50.10    |
| (Tailscale <-> .20.5)  |   | DB-Replica: 172.20.40.12  |   | (Central Rsyslog 514)  |
+------------------------+   +---------------------------+   +------------------------+
```

> **Lưu ý về vùng `APP (172.20.30.0/24)`:** Đã khai báo trên Firewall, nhưng trong baseline tuần 1, `Web-A/Web-B (172.20.20.21/.22)` đảm nhiệm luôn vai trò application node tối giản kết nối vào DB port `5432`.

---

## 2. Lịch trình thực thi theo ngày của Minh Hùng

1. **Ngày 1 (Baseline VM):** Tạo 6 VM trong `D:\Lab\vms\minh-hung\`, cấu hình VMnet theo `configs/vmware/minh-hung/vm-inventory-and-ram-profile.md`, chụp snapshot `day-1-clean`.
2. **Ngày 2 (Transit-B & Tailscale):** Chạy `lab/transit/site-b/transit-b-setup.sh`, áp dụng `configs/tailscale/tailscale-acl.hujson`, kiểm thử theo `connectivity-checklist.md`.
3. **Ngày 3 (Firewall Policy):** Nạp `configs/firewall/nftables-firewall.conf` lên `Firewall-A`, đối chiếu `lab/firewall/firewall-rule-matrix.md`.
4. **Ngày 4 (Database & Monitoring):** Dựng PostgreSQL Primary/Replica theo `lab/database/postgresql-replication-setup.md`, chạy `init-least-privilege.sql`, bật `lab/monitoring/rsyslog-central.conf` trên `Log-Monitor`.
5. **Ngày 5 (Failover):** Thực hiện promote DB theo `lab/database/promote-and-recovery-runbook.md` và chuyển đổi Firewall theo `lab/firewall/failover-and-recovery-runbook.md`; thu thập evidence bằng `scripts/minh-hung/collect-evidence.sh`.
6. **Ngày 6 (Kiểm thử bảo mật):** Cùng Quan Bảo chạy negative test từ `Test-Client`, trích xuất log `FW-DENY-*` trên `Firewall-A` và `Log-Monitor`.
7. **Ngày 7 (Demo & Nghiệm thu):** Chạy toàn bộ `lab/testing/minh-hung/test-cases-minh-hung.md`, rà soát không lộ secret và push lên nhánh `main`.
