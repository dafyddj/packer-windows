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

$uninstallSuccess = $false
#while(!$uninstallSuccess) {
  Write-Host "Attempting to uninstall features..."
#  try {
    Get-WindowsOptionalFeature -Online | ? { $_.State -eq 'Disabled' } | Disable-WindowsOptionalFeature -Online -Remove -NoRestart -ErrorAction Stop
    Write-Host "Uninstall succeeded!"
    $uninstallSuccess = $true
#  }
#  catch {
#    Write-Host "Waiting two minutes before next attempt"
#    Start-Sleep -Seconds 120
#  }
#}
