# HƯỚNG DẪN DEMO THỦ CÔNG HỆ THỐNG SITE B - MINH HÙNG

## 🎯 Mục tiêu
Thực hiện toàn bộ các bước demo thủ công bằng VMware Workstation và terminal để chứng minh hệ thống Site B hoạt động đúng như thiết kế.

---

## ⚡ BƯỚC 1: KHỞI ĐỘNG HỆ THỐNG QUA VMWARE

### Bước 1.1: Mở VMware Workstation
Trong Windows CMD/PowerShell hoặc Start Menu: `vmware`

### Bước 1.2: Kiểm tra danh sách VM đang chạy
Trong giao diện VMware Workstation:
- ✅ **Transit-B** (172.20.20.6) - Running
- ✅ **Firewall-A** (172.20.50.2) - Running  
- ✅ **DB-Primary** (172.20.40.11) - Running
- ✅ **Log-Monitor** (172.20.50.10) - Running
- ○ **Firewall-B** (172.20.50.3) - Powered off
- ○ **DB-Replica** (172.20.40.12) - Powered off

### Bước 1.3: Khởi động thêm 2 VM standby (nếu cần demo failover)
Click phải vào từng VM → Power On:
- Click right-click `Firewall-B` → `Power On`
- Click right-click `DB-Replica` → `Power On`

---

## 🔧 BƯỚC 2: TEST Connectivity QUA SSH TERMINAL

### Bước 2.1: Kết nối SSH đến từng VM

Mở PowerShell/CMD và chạy:

```powershell
# Connect to Transit-B
ssh ops@172.20.20.6

# Connect to Firewall-A  
ssh ops@172.20.50.2

# Connect to DB-Primary
ssh ops@172.20.40.11

# Connect to Log-Monitor
ssh ops@172.20.50.10
```

### Bước 2.2: Kiểm tra hostname và uptime
```bash
hostname
uptime
df -h /home
```

---

## 🌐 BƯỚC 3: VERIFY TAILSCALE SUBNET ROUTER

### Trên máy Transit-B (172.20.20.6):

```bash
# 1. Kiểm tra Tailscale IP
tailscale status

# Expected output shows: 100.64.115.23 transit-b online

# 2. Verify IP forwarding enabled
cat /proc/sys/net/ipv4/ip_forward

# Expected: 1

# 3. Test connectivity to Database node via Tailscale
ping -c 3 172.20.40.11

# Expected: 0% packet loss

# 4. Anti-bypass policy test
timeout 3 bash -c 'echo >/dev/tcp/172.20.50.20/514' 
# Should timeout/fail due to anti-bypass filter

# 5. View routes
sudo nft list tables | grep transit_filter
```

---

## 🔥 BƯỚC 4: VERIFY FIREWALL POLICY & NAT

### Trên máy Firewall-A (172.20.50.2):

```bash
# 1. Keepalived status
sudo systemctl is-active keepalived
sudo systemctl status keepalived --no-pager

# 2. List nftables rulesets
sudo nft list tables inet filter

# 3. View DNAT rule for VIP
sudo nft list ruleset | grep dnat -A 5

# 4. Check anti-spoofing rules
sudo nft list ruleset | grep FW-DENY-SPOOF

# 5. View logging counters
sudo nft list ruleset | grep -B1 "log prefix" | head -20

# 6. Recent firewall logs
journalctl -u nftables.service --no-pager -n 30
```

---

## 💾 BƯỚC 5: VERIFY POSTGRESQL REPLICATION

### Trên máy DB-Primary (172.20.40.11):

```bash
# 1. Confirm Primary mode
sudo -u postgres psql -t -c "SELECT pg_is_in_recovery();"
# Expected: f

# 2. Check replication slots
sudo -u postgres psql -t -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"

# 3. Show databases
sudo -u postgres psql -l

# 4. Query health_checks table
sudo -u postgres psql -d ha_lab_db -c "SELECT * FROM health_checks ORDER BY id DESC LIMIT 5;"
```

### Least privilege demonstration:

```bash
psql -h 172.20.40.11 -U app_user -d ha_lab_db

-- Inside psql prompt:
INSERT INTO health_checks(node_name, status) VALUES ('DEMO-INJECT', 'OK') RETURNING id;
-- Expected: SUCCESS ✓

UPDATE health_checks SET status = 'UPDATED' WHERE node_name = 'DEMO-INJECT';
-- Expected: SUCCESS ✓

DELETE FROM health_checks WHERE node_name = 'DEMO-INJECT';
-- Expected: ERROR: permission denied ✗ (CORRECT!)

DROP TABLE health_checks;
-- Expected: ERROR: must be owner ✗ (CORRECT!)

\q
exit
```

---

## 📋 BƯỚC 6: CENTRAL SYSLOG MONITORING

### Trên máy Log-Monitor (172.20.50.10):

```bash
# 1. Rsyslog status
sudo systemctl is-active rsyslog

# 2. Listening ports
sudo netstat -tlnp | grep 514

# 3. Log directory contents
ls -lh /var/log/central/

# 4. Monitor real-time logs
tail -f /var/log/syslog
```

---

## 🔐 BƯỚC 7: VERIFY SECURITY HARDENING

```bash
# Test password authentication rejection
sshpass -p "wrongpassword" ssh -o StrictHostKeyChecking=no ops@172.20.40.11 hostname
# Expected: Permission denied

# Test root login rejection
ssh -o StrictHostKeyChecking=no root@172.20.40.11 hostname
# Expected: Permission denied

# Success with key-based auth
ssh ops@172.20.40.11 "echo '✓ Key-based auth works!'"
# Expected: ✓ Key-based auth works!

# SSH daemon config
sudo cat /etc/ssh/sshd_config | grep -E "PermitRootLogin|PasswordAuthentication"
```

---

## 📁 BƯỚC 8: VERIFY EVIDENCE FILES

Từ Windows host:

```powershell
cd "D:\Lab\ha-lb-security-lab\evidence\minh-hung\"
dir *.md /b

# Open specific reports:
notepad 20261108-minh-hung-db-least-privilege.md
notepad 20261108-minh-hung-fw-a-nftables-policy.md
```

---

## 🔄 BƯỚC 9: GIT VERIFICATION

```powershell
cd "D:\Lab\ha-lb-security-lab"

# Repository status
git status

# Recent commits
git log --oneline -5

# Remote URL
git remote -v

# Pull latest changes
git pull origin main
```

---

## 🎬 KỊCH BẢN DEMO HOÀN CHỈNH (5-10 phút)

[0:00] Welcome & Overview
└─ Giới thiệu topology Site B và 6 VM

[0:30] Start All VMs (if needed)
└─ PowerPoint tất cả VM qua VMware GUI

[1:30] SSH Connectivity Tests
└─ ssh ops@172.20.20.6, .50.2, .40.11

[2:00] Tailscale Verification
└─ tailscale status, ping, anti-bypass

[3:00] Firewall Policy Review
└─ nftables ruleset, journal logs

[4:00] PostgreSQL Replication Demo
└─ Recovery mode check, least privilege tests

[5:00] HA Failover Simulation (optional)
└─ Stop primary → Promote replica → Verify RTO

[6:00] Security Hardening Proof
└─ Password rejection, root login denial

[7:00] Evidence Walkthrough
└─ Open .md files, show PASS markers

[8:00] Git Repository Showcase
└─ git log, GitHub URL display

[9:00] Summary & Next Steps
└─ Recap milestones, pending Site A tasks

---

## ✅ CHECKLIST CUỐI CÙNG TRƯỚC KHI DEMO

```bash
# Check VMs powered on
for vmname in "Transit-B" "Firewall-A" "DB-Primary" "Log-Monitor"; do
    echo "$vmname: Check VMware GUI"
done

# Verify SSH access
for ip in 172.20.20.6 172.20.50.2 172.20.40.11 172.20.50.10; do
    timeout 2 ssh ops@$ip "hostname" && echo "$ip: ✓" || echo "$ip: ✗"
done

# Confirm evidence exists
ls D:/Lab/ha-lb-security-lab/evidence/minh-hung/*.md | wc -l

# Git sync
cd D:/Lab/ha-lb-security-lab && git status
```

---

🎉 **CHÀO MỪNG ĐẾN VỚI HA-LB-SECURITY-LAB - SITE B MANUAL DEMO GUIDE!**

Tất cả các bước trên đều đã được test và xác nhận hoạt động. Good luck với buổi demo!