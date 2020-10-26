if (! (Test-Path "env:UPDATE") -or ($env:UPDATE -eq "false")) { return }

$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$PM_uri = 'https://f000.backblazeb2.com/file/techneg-repo/ms/PackageManagement_x64.msi'
$PM_msi = "PackageManagement_x64.msi"
$PM_path = "$env:TEMP\$PM_msi"

Invoke-WebRequest $PM_uri -OutFile $PM_path

& msiexec /qb /i $PM_path | Out-Null

Install-PackageProvider -Name NuGet -Force
Install-Module PSWindowsUpdate -Force

Install-WindowsUpdate -AcceptAll -IgnoreReboot
