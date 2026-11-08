# Host Environment Verification for Minh Hung (ha-lb-security-lab)
$ErrorActionPreference = "Stop"
Write-Host "=== [1] Checking VMware Services ==="
Get-Service VMnetDHCP, "VMware NAT Service", VMUSBArbService, Tailscale | Select-Object Name, Status
Write-Host "=== [2] Checking VMnet & Tailscale IPv4 ==="
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -match "VMnet|Tailscale" } | Select-Object InterfaceAlias, IPAddress, PrefixLength
Write-Host "=== [3] Checking VM Directories ==="
Get-ChildItem "D:\Lab\vms\minh-hung" | Select-Object Name
Write-Host "=== [4] Disk Free Space (D:) ==="
Get-PSDrive D | Select-Object Name, @{N="FreeGB";E={[math]::Round($_.Free/1GB,2)}}
# ponytail: read-only PowerShell host probe; upgrade to automated vmrun start/snapshot script once Guest OS ISOs are installed
