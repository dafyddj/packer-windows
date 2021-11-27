$ProgressPreference='SilentlyContinue'

# The sleeps may seem whacky because they are
# Might beable to remove after 2016 RTMs
# For now after much trial and error, this is what works
#Write-Host "Waiting 5 minutes"
#Start-Sleep -Seconds 300

Write-Host "Attempting to install further updates"

if ( (Test-Path "env:UPDATE") -and ($env:UPDATE -eq "true")) {
  Install-WindowsUpdate -AcceptAll -IgnoreReboot
}

Write-Host "Attempting to uninstall Windows Features..."
Get-WindowsOptionalFeature -Online | ? { $_.State -eq 'Disabled' } |
  ForEach-Object {
    Write-Host "Disabling:" $_.FeatureName
    Disable-WindowsOptionalFeature -Online -Remove -NoRestart | Out-Null
  }
Write-Host "Finished uninstalling Windows Features"
