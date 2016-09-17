$ProgressPreference='SilentlyContinue'

if ( (Test-Path "env:UPDATE") -and ($env:UPDATE -eq "true")) { 
  Get-WUInstall -AcceptAll -IgnoreReboot
}

# The sleeps may seem whacky because they are
# Might beable to remove after 2016 RTMs
# For now after much trial and error, this is what works
#Write-Host "waiting 5 minutes"
#Start-Sleep -Seconds 300

$uninstallSuccess = $false
#while(!$uninstallSuccess) {
  Write-Host "Attempting to uninstall features..."
#  try {
    Get-WindowsOptionalFeature -Online | ? { $_.State -eq 'Disabled' } | Disable-WindowsOptionalFeature -Online -Remove -ErrorAction Stop
    Write-Host "Uninstall succeeded!"
    $uninstallSuccess = $true
#  }
#  catch {
#    Write-Host "Waiting two minutes before next attempt"
#    Start-Sleep -Seconds 120
#  }
#}
