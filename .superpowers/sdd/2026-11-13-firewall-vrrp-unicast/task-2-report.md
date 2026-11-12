# Task 2 report: install/configure Keepalived on fw-a / fw-b

Status: DONE_WITH_CONCERNS (installed, config validated, enabled, NOT started)

## Changed files
- configs/firewall/keepalived-fw-a.conf, keepalived-fw-b.conf: track script path
  `/etc/keepalived/...` -> `/usr/local/sbin/keepalived-healthcheck.sh` (matches the install target);
  removed `weight -60` (see concerns).
- evidence/minh-hung/logs/20261113-vrrp-install-and-baseline.log (full command output, including failed attempts)
- Live: /etc/keepalived/keepalived.conf, /usr/local/sbin/keepalived-healthcheck.sh (0755), keepalived pkg 1:2.2.7-1+b2,
  backups in /var/backups/firewall/vrrp-20261113-0126xx (fw-a 012651, fw-b 012700).

## Commands (per node, via ssh ops@<ip> with the existing key)
1. install -d -m0750 backup dir; `nft list ruleset` and `ip -br addr` saved; `systemctl is-active nftables` = active.
2. `apt-get update` / `apt-get install -y keepalived` FAILED on both: nodes have no default route and no DNS
   (Temporary failure resolving deb.debian.org). Workaround: downloaded keepalived + 9 missing deps on the
   admin PC from deb.debian.org, SHA256 verified against Packages index, scp to /tmp/kdeb, `dpkg -i /tmp/kdeb/*.deb`
   with a temporary policy-rc.d (exit 101, removed afterwards) so the service was not auto-started.
3. `install -m0644 keepalived-fw-X.conf /etc/keepalived/keepalived.conf`; `install -m0755 healthcheck /usr/local/sbin/...`
4. `keepalived -t -f ...`, `nft -c -f /etc/nftables.conf`, `systemctl enable keepalived`.

## Results
- keepalived -t: rc=0 on both (after fixes); nft -c: rc=0 on both; healthcheck script rc=0 on both.
- keepalived is-enabled=enabled, is-active=inactive on both; nftables active; no VIP moved (fw-a still holds .1 VIPs
  as secondary addresses on eth0-eth4, fw-b has none) - unchanged from baseline.

## Concerns
- Initial validation failed with rc=5: (a) script path in versioned configs pointed to /etc/keepalived but Task spec installs
  to /usr/local/sbin ("Disabling track script ... not found"); (b) keepalived 2.2.7 treats "tracked script with weight in a
  SYNC group" as a config error (rc=5). Fixed by path change and dropping `weight`. Consequence: in a sync group the
  script now acts as a hard fault (fall 2 => instance FAULT, whole group fails over) instead of a priority reduction.
  This is the intended semantic for an all-or-nothing firewall pair, but the Task-1 reviewers should know.
- Nodes are offline: package install is not repeatable via apt on the VMs; debs were hand-installed. fw-a has stale
  static secondary IPs (.1) on its interfaces: Task 3 must remove them before starting keepalived or VRRP will conflict /
  fw-a's keepalived will add the same addresses (check `ip -br addr` baseline).
- Line endings: configs are edited on Windows (autocrlf); the scp'd copies were stripped with `sed -i 's/\r$//'` on the VMs.
