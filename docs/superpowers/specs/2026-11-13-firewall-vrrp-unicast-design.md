# Firewall VRRP Unicast Design

## Goal

Replace manual Gateway IP Migration with automatic active/passive VRRP failover between Firewall-A and Firewall-B without changing the existing nftables security policy.

## Current State

- Firewall-A: `172.20.10.2`, `.20.2`, `.30.2`, `.40.2`, `.50.2`; currently owns VIP gateway `.1` on all five interfaces.
- Firewall-B: `172.20.10.3`, `.20.3`, `.30.3`, `.40.3`, `.50.3`; standby addresses only.
- VIPs: `172.20.10.1`, `172.20.20.1`, `172.20.30.1`, `172.20.40.1`, `172.20.50.1`.
- Existing ruleset: `configs/firewall/nftables-firewall.conf`; policies are deny-by-default and must remain unchanged.
- Existing gap: `keepalived` is absent; current failover is manual IP assignment plus gratuitous ARP.

## Design

Install Keepalived on both firewalls and configure five VRRP instances, one per zone interface. Use VRRP unicast peers rather than multicast because the lab runs across five VMware host-only networks on a laptop.

Firewall-A is `MASTER` with priority `150`; Firewall-B is `BACKUP` with priority `100`. Each instance owns the corresponding `.1` VIP. `advert_int 1`, `garp_master_repeat 3`, and `garp_master_delay 1` provide rapid neighbor cache convergence. Firewall-A uses `unicast_peer` pointing to Firewall-B's `.3` address for the same subnet; Firewall-B points to Firewall-A's `.2` address.

A tracked script checks `nftables` is active and that IPv4 forwarding is enabled. If the active firewall loses either condition, Keepalived lowers its effective priority and allows the peer to take all VIPs. The nftables file remains identical on both nodes; Keepalived owns only VIP state.

## Safety and Rollback

1. Back up `/etc/nftables.conf`, current addresses, routes, and Keepalived configuration before enabling the service.
2. Validate `keepalived -t -f /etc/keepalived/keepalived.conf` and `nft -c -f /etc/nftables.conf` before service start.
3. Start Firewall-B in BACKUP mode first, then Firewall-A in MASTER mode.
4. Confirm only Firewall-A owns all five VIPs before testing failure.
5. For rollback, stop and disable Keepalived on both nodes, remove the Keepalived configuration, and restore the manual VIP procedure from `lab/firewall/failover-and-recovery-runbook.md`.

## Acceptance

- Both nodes report `keepalived` active.
- Baseline: Firewall-A owns all five `.1` VIPs; Firewall-B owns none.
- Failover: stopping Keepalived on Firewall-A causes Firewall-B to own all five VIPs without manual `ip addr add` commands.
- During failover, DB/SSH negative probes remain blocked and deny logs continue on the active firewall.
- Failback: restoring Firewall-A causes it to reclaim all five VIPs.
- PostgreSQL replication and central syslog remain healthy after the firewall test.
