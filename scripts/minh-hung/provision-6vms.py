#!/usr/bin/env python3
"""Clone and configure Minh Hung's 6 Linked Clone VMs from Base-Template (day-1-clean).

ponytail: direct vmrun linked-clone + .vmx guestinfo rewrite for 6 static lab VMs;
upgrade to Packer + Terraform/Ansible when VM count > 10 or multi-host drift matters.
"""
from __future__ import annotations

import pathlib
import subprocess
import sys

VMRUN = next(
    (
        p
        for p in (
            r"C:\Program Files\VMware\VMware Workstation\vmrun.exe",
            r"C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe",
        )
        if pathlib.Path(p).exists()
    ),
    r"C:\Program Files\VMware\VMware Workstation\vmrun.exe",
)
BASE_DIR = pathlib.Path(r"D:\Lab\vms\minh-hung")
TEMPLATE_VMX = BASE_DIR / "Base-Template" / "Base-Template.vmx"
SNAPSHOT = "day-1-clean"

# Windows VMware Workstation supports VMnet0..VMnet19 (VNL_GetNumberOfVnets() == 20).
# Zone mapping:
#   WAN-LAB  (172.20.10.0/24) -> VMnet10
#   DMZ      (172.20.20.0/24) -> VMnet12
#   APP      (172.20.30.0/24) -> VMnet13
#   DATABASE (172.20.40.0/24) -> VMnet14
#   MGMT     (172.20.50.0/24) -> VMnet15 (Host adapter: 172.20.50.254/24)
VMS = [
    {
        "name": "Transit-B",
        "hostname": "transit-b",
        "vcpus": 1,
        "mem_mb": 768,
        "nics": [("custom", "VMnet12"), ("nat", "")],
        "netcfg": "eth0=172.20.20.6/24~172.20.40.0/24:172.20.20.1,172.20.50.0/24:172.20.20.1;eth1=dhcp",
        "verify_ip": "172.20.20.6",
    },
    {
        "name": "Firewall-A",
        "hostname": "fw-a",
        "vcpus": 1,
        "mem_mb": 1024,
        "nics": [
            ("custom", "VMnet10"),
            ("custom", "VMnet12"),
            ("custom", "VMnet13"),
            ("custom", "VMnet14"),
            ("custom", "VMnet15"),
        ],
        "netcfg": (
            "eth0=172.20.10.2/24,172.20.10.1/24;"
            "eth1=172.20.20.2/24,172.20.20.1/24~172.20.20.5/32:172.20.20.6,172.20.20.10/32:172.20.20.6,172.20.20.11/32:172.20.20.6,172.20.20.21/32:172.20.20.6,172.20.20.22/32:172.20.20.6,172.20.20.100/32:172.20.20.6;"
            "eth2=172.20.30.2/24,172.20.30.1/24;"
            "eth3=172.20.40.2/24,172.20.40.1/24;"
            "eth4=172.20.50.2/24,172.20.50.1/24"
        ),
        "verify_ip": "172.20.50.2",
    },
    {
        "name": "Firewall-B",
        "hostname": "fw-b",
        "vcpus": 1,
        "mem_mb": 1024,
        "nics": [
            ("custom", "VMnet10"),
            ("custom", "VMnet12"),
            ("custom", "VMnet13"),
            ("custom", "VMnet14"),
            ("custom", "VMnet15"),
        ],
        "netcfg": (
            "eth0=172.20.10.3/24;"
            "eth1=172.20.20.3/24~172.20.20.5/32:172.20.20.6,172.20.20.10/32:172.20.20.6,172.20.20.11/32:172.20.20.6,172.20.20.21/32:172.20.20.6,172.20.20.22/32:172.20.20.6,172.20.20.100/32:172.20.20.6;"
            "eth2=172.20.30.3/24;"
            "eth3=172.20.40.3/24;"
            "eth4=172.20.50.3/24"
        ),
        "verify_ip": "172.20.50.3",
    },
    {
        "name": "DB-Primary",
        "hostname": "db-primary",
        "vcpus": 2,
        "mem_mb": 1536,
        "nics": [("custom", "VMnet14")],
        "netcfg": "eth0=172.20.40.11/24@172.20.40.1",
        "verify_ip": "172.20.40.11",
    },
    {
        "name": "DB-Replica",
        "hostname": "db-replica",
        "vcpus": 2,
        "mem_mb": 1536,
        "nics": [("custom", "VMnet14")],
        "netcfg": "eth0=172.20.40.12/24@172.20.40.1",
        "verify_ip": "172.20.40.12",
    },
    {
        "name": "Log-Monitor",
        "hostname": "log-monitor",
        "vcpus": 1,
        "mem_mb": 1024,
        "nics": [("custom", "VMnet15")],
        "netcfg": "eth0=172.20.50.10/24@172.20.50.1",
        "verify_ip": "172.20.50.10",
    },
]


def render_vmx(existing_text: str, spec: dict) -> str:
    drop_prefixes = (
        "memsize",
        "numvcpus",
        "cpuid.coresPerSocket",
        "displayName",
        "sata0.pciSlotNumber",
        "pciBridge",
        "ethernet",
        "guestinfo.hostname",
        "guestinfo.netcfg",
    )
    kept = [
        line
        for line in existing_text.splitlines()
        if line.strip() and not line.strip().startswith(drop_prefixes)
    ]
    kept.extend(
        [
            f'displayName = "{spec["name"]}"',
            f'numvcpus = "{spec["vcpus"]}"',
            f'memsize = "{spec["mem_mb"]}"',
            'sata0.pciSlotNumber = "16"',
            'pciBridge0.present = "TRUE"',
            'pciBridge0.pciSlotNumber = "17"',
            f'guestinfo.hostname = "{spec["hostname"]}"',
            f'guestinfo.netcfg = "{spec["netcfg"]}"',
        ]
    )
    for idx, (conn_type, vnet) in enumerate(spec["nics"]):
        slot = 32 + idx
        kept.extend(
            [
                f'ethernet{idx}.present = "TRUE"',
                f'ethernet{idx}.connectionType = "{conn_type}"',
                f'ethernet{idx}.virtualDev = "e1000"',
                f'ethernet{idx}.addressType = "generated"',
                f'ethernet{idx}.pciSlotNumber = "{slot}"',
            ]
        )
        if conn_type == "custom":
            kept.append(f'ethernet{idx}.vnet = "{vnet}"')
    return "\n".join(kept) + "\n"


def self_check() -> None:
    assert len(VMS) == 6, "Expected 6 VMs"
    assert sum(v["vcpus"] for v in VMS) == 8, "Total vCPUs must equal 8"
    assert sum(v["mem_mb"] for v in VMS) == 6912, "Total RAM must equal 6912 MB"
    for vm in VMS:
        for _, vnet in vm["nics"]:
            if vnet:
                num = int(vnet.replace("VMnet", ""))
                assert 0 <= num < 20, f"Invalid Windows VMnet index: {vnet}"
        rendered = render_vmx('.encoding = "UTF-8"\nsata0.present = "TRUE"\n', vm)
        assert f'guestinfo.hostname = "{vm["hostname"]}"' in rendered
        assert 'ethernet0.pciSlotNumber = "32"' in rendered
    print("[PASS] provision-6vms.py self-check OK (6 VMs, 8 vCPUs, 6912 MB RAM, VMnet indices < 20)")


def clone_all() -> None:
    self_check()
    for vm in VMS:
        target_dir = BASE_DIR / vm["name"]
        target_vmx = target_dir / f'{vm["name"]}.vmx'
        if not target_vmx.exists():
            target_dir.parent.mkdir(parents=True, exist_ok=True)
            cmd = [
                VMRUN,
                "-T",
                "ws",
                "clone",
                str(TEMPLATE_VMX),
                str(target_vmx),
                "linked",
                f"-snapshot={SNAPSHOT}",
                f'-cloneName={vm["name"]}',
            ]
            print(f"[CLONE] {vm['name']} -> {target_vmx}")
            subprocess.run(cmd, check=True, timeout=60)
        patched = render_vmx(target_vmx.read_text(encoding="utf-8"), vm)
        target_vmx.write_text(patched, encoding="utf-8")
        print(f"[PATCH] {vm['name']} ({vm['vcpus']} vCPU, {vm['mem_mb']} MB, {len(vm['nics'])} NICs)")


if __name__ == "__main__":
    if "--self-check" in sys.argv:
        self_check()
    else:
        clone_all()
