# Firewall VRRP Unicast Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace manual Firewall-A/Firewall-B VIP migration with automatic VRRP unicast failover while preserving the existing nftables policy.

**Architecture:** Keepalived runs active/passive on both firewalls with five VRRP instances, one per zone interface. Firewall-A is MASTER priority 150 and Firewall-B is BACKUP priority 100; each instance uses unicast peer addresses `.2`/`.3` on its own subnet. A tracked health script checks `nftables` and IPv4 forwarding, while nftables remains the unchanged policy engine.

**Tech Stack:** Debian 12, Keepalived, VRRP unicast, nftables, systemd, VMware host-only VMnets, SSH, Bash.

**Spec:** `docs/superpowers/specs/2026-11-13-firewall-vrrp-unicast-design.md`

## Global Constraints

- Do not change the existing security rules in `configs/firewall/nftables-firewall.conf`.
- Use unicast VRRP; do not depend on multicast across VMware host-only networks.
- Preserve Firewall-A addresses `.2`, Firewall-B addresses `.3`, and gateway VIPs `.1`.
- Validate configuration before enabling services.
- Back up live firewall state before every service-state change.
- Never run both firewalls as MASTER with the same VIPs.
- Keep the manual Gateway IP Migration runbook as rollback documentation.
- Do not commit secrets, private keys, passwords, or VM runtime state.

---

### Task 1: Add versioned Keepalived configuration

**Files:**
- Create: `configs/firewall/keepalived-fw-a.conf`
- Create: `configs/firewall/keepalived-fw-b.conf`
- Create: `configs/firewall/keepalived-healthcheck.sh`
- Modify: `lab/firewall/failover-and-recovery-runbook.md`

**Interfaces:**
- Keepalived consumes `/etc/keepalived/keepalived.conf` and runs `keepalived-healthcheck.sh` every 2 seconds.
- The health script exits `0` only when `nftables` is active and `net.ipv4.ip_forward=1`.
- The two config files expose the same five VIPs but different state, priority, router ID, unicast source, and peer addresses.

- [ ] Step 1: Write the health-check script with strict shell behavior and explicit checks:

```bash
#!/bin/sh
set -eu
systemctl is-active --quiet nftables
[ "$(cat /proc/sys/net/ipv4/ip_forward)" = "1" ]
exit 0
```

- [ ] Step 2: Write Firewall-A config with `global_defs`, `vrrp_script`, and five `vrrp_instance` blocks. Use `state MASTER`, `priority 150`, `virtual_router_id` values `10`, `20`, `30`, `40`, `50`, `advert_int 1`, `unicast_src_ip` equal to each `.2` address, `unicast_peer` equal to the matching Firewall-B `.3` address, and the matching `.1/24` VIP.
- [ ] Step 3: Write Firewall-B config with the same five blocks, but `state BACKUP`, `priority 100`, `unicast_src_ip` equal to each `.3` address, and peers equal to Firewall-A's matching `.2` address.
- [ ] Step 4: Add a runbook section documenting package installation, config placement, validation, service order, automatic failover, failback, and rollback. State explicitly that `keepalived` owns VIPs and nftables owns filtering.
- [ ] Step 5: Run a static configuration check locally:

```bash
bash -n configs/firewall/keepalived-healthcheck.sh
for f in configs/firewall/keepalived-fw-a.conf configs/firewall/keepalived-fw-b.conf; do
  grep -c 'vrrp_instance' "$f"
  grep -c 'virtual_ipaddress' "$f"
done
```

Expected: shell syntax passes; each config has five instances and five VIP blocks.

### Task 2: Install and configure Keepalived on both live firewalls

**Files:**
- Live VM: `fw-a` (`172.20.50.2`)
- Live VM: `fw-b` (`172.20.50.3`)
- Evidence: `evidence/minh-hung/logs/20261113-vrrp-install-and-baseline.log`

**Interfaces:**
- Copy the versioned config matching each firewall to `/etc/keepalived/keepalived.conf`.
- Copy the health script to `/usr/local/sbin/keepalived-healthcheck.sh` with mode `0755`.

- [ ] Step 1: Back up live state on both nodes before installing:

```bash
sudo install -d -m 0750 /var/backups/firewall/vrrp-$(date +%Y%m%d-%H%M%S)
sudo nft list ruleset > /var/backups/firewall/vrrp-*/nftables.conf
ip -br addr > /var/backups/firewall/vrrp-*/ip-br-addr.txt
sudo systemctl is-active nftables
```

- [ ] Step 2: Confirm package access and install Keepalived on each node:

```bash
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y keepalived
```

- [ ] Step 3: Copy the matching config and health script, then validate:

```bash
sudo install -d -m 0755 /etc/keepalived
sudo install -m 0644 keepalived-fw-a.conf /etc/keepalived/keepalived.conf
sudo install -m 0755 keepalived-healthcheck.sh /usr/local/sbin/keepalived-healthcheck.sh
sudo keepalived -t -f /etc/keepalived/keepalived.conf
sudo nft -c -f /etc/nftables.conf
```

Use `keepalived-fw-b.conf` on Firewall-B. Expected: both validation commands exit `0`.

- [ ] Step 4: Enable but do not start both services yet:

```bash
sudo systemctl enable keepalived
sudo systemctl is-enabled keepalived
```

Expected: `enabled` on both nodes.

### Task 3: Enable active/passive VRRP safely

**Files:**
- Evidence: `evidence/minh-hung/logs/20261113-vrrp-baseline.log`
- Evidence: `evidence/minh-hung/images/20261113-minh-hung-vrrp-baseline.png`

- [ ] Step 1: Ensure Firewall-B has no `.1` VIP before starting the service:

```bash
ip -br addr | grep -E '172\.20\.(10|20|30|40|50)\.1/' || true
```

Expected: no matching VIP line on Firewall-B.

- [ ] Step 2: Start Keepalived on Firewall-B and confirm it remains BACKUP:

```bash
sudo systemctl start keepalived
sudo systemctl is-active keepalived
sudo journalctl -u keepalived -n 20 --no-pager
```

- [ ] Step 3: Start Keepalived on Firewall-A and confirm it becomes MASTER:

```bash
sudo systemctl start keepalived
sudo systemctl is-active keepalived
ip -br addr | grep -E '172\.20\.(10|20|30|40|50)\.1/'
```

Expected: Firewall-A owns all five VIPs; Firewall-B owns none.

- [ ] Step 4: Verify policy and routing were not changed:

```bash
sudo nft -c -f /etc/nftables.conf
sysctl net.ipv4.ip_forward
```

Expected: nftables validation exits `0`; forwarding is `1`.

### Task 4: Exercise automatic failover and failback

**Files:**
- Evidence: `evidence/minh-hung/logs/20261113-vrrp-failover.log`
- Evidence: `evidence/minh-hung/images/20261113-minh-hung-vrrp-failover.png`
- Modify: `lab/testing/acceptance-matrix.md`

- [ ] Step 1: Record baseline VIP ownership and active Keepalived states on both firewalls.
- [ ] Step 2: Stop only Keepalived on Firewall-A:

```bash
T0=$(date -Is)
sudo systemctl stop keepalived
```

Do not manually add VIPs on Firewall-B; the test must prove automatic takeover.

- [ ] Step 3: Wait for VRRP convergence and verify Firewall-B owns all five VIPs:

```bash
sleep 5
T1=$(date -Is)
sudo systemctl is-active keepalived
ip -br addr | grep -E '172\.20\.(10|20|30|40|50)\.1/'
```

- [ ] Step 4: Run the existing negative probes from Transit-B and verify Firewall-B logs `FW-DEFAULT-DENY` and `FW-DENY-INPUT-DEFAULT`.
- [ ] Step 5: Start Keepalived on Firewall-A and verify it reclaims all VIPs after preemption:

```bash
sudo systemctl start keepalived
sleep 5
ip -br addr | grep -E '172\.20\.(10|20|30|40|50)\.1/'
```

- [ ] Step 6: Verify final PostgreSQL streaming and central syslog after failback.
- [ ] Step 7: Record the observed failover interval `(T1-T0)` and update the acceptance matrix, replacing the manual-only result with `PASS — VRRP unicast`, while retaining the manual process as rollback.

### Task 5: Update evidence and verify rollback path

**Files:**
- Modify: `evidence/minh-hung/20261112-minh-hung-site-b-comprehensive.md`
- Modify: `lab/firewall/failover-and-recovery-runbook.md`
- Modify: `lab/testing/acceptance-matrix.md`
- Create: `evidence/minh-hung/20261113-minh-hung-vrrp-keepalived.md`

- [ ] Step 1: Add the Keepalived package version, config validation output, baseline ownership, failover ownership, failback ownership, T0/T1, and log evidence to the new evidence report.
- [ ] Step 2: Mark SB-06 as PASS only if both services are active and both configs validate; otherwise leave it GAP with the exact failure.
- [ ] Step 3: Update the runbook so manual migration is labeled rollback, not the primary failover path.
- [ ] Step 4: Run the final validation commands:

```bash
sudo keepalived -t -f /etc/keepalived/keepalived.conf
sudo systemctl is-active keepalived nftables
ip -br addr | grep -E '172\.20\.(10|20|30|40|50)\.1/'
```

- [ ] Step 5: Review `git status` and `git diff`; do not stage or commit unrelated untracked files such as VM installers, history exports, or runtime state.
