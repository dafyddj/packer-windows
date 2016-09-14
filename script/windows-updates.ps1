if (! (Test-Path "env:UPDATE") -or ($env:UPDATE -eq "false")) { return }

$ProgressPreference = "SilentlyContinue"

$PM_uri = 'https://techneg-wpkg-repo.s3.amazonaws.com/ms/PackageManagement_x64.msi?AWSAccessKeyId=AKIAIIDOWPK4T5O4EBTQ&Expires=1505254154&Signature=wEP1yiiiG%2BirFmc%2FSHnLmisMDVA%3D'
$PM_msi = "PackageManagement_x64.msi"
$PM_path = "$env:TEMP\$PM_msi"

Invoke-WebRequest $PM_uri -OutFile $PM_path

& msiexec /qb /i $PM_path | Out-Null

Install-PackageProvider -Name NuGet -Force
Install-Module PSWindowsUpdate -Force

Get-WUInstall -AcceptAll -IgnoreReboot
