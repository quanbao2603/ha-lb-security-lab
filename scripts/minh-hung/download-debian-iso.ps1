# Download Debian 12 minimal netinst ISO for Minh Hung's 6 VMs
$ErrorActionPreference = "Stop"
$IsoDir = "D:\Lab\isos"
New-Item -ItemType Directory -Force -Path $IsoDir | Out-Null
$Url = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-nocloud-amd64.tar.xz"
$IsoUrl = "https://cdimage.debian.org/cdimage/archive/latest-oldstable/amd64/iso-cd/debian-12.15.0-amd64-netinst.iso"
$Out = Join-Path $IsoDir "debian-12-nocloud-amd64.tar.xz"
# ponytail: prebuilt official Debian 12 nocloud image avoids manual ISO installer; use $IsoUrl only if interactive netinst is needed
Write-Host "Downloading Debian 12 nocloud image to $Out ..."
curl.exe -L -o "$Out" "$Url"
