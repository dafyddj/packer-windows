$ProgressPreference='SilentlyContinue'

Write-Host "Attempting to uninstall Windows Features..."
Get-WindowsOptionalFeature -Online | ? { $_.State -eq 'Disabled' } |
  ForEach-Object {
    Write-Host "Disabling:" $_.FeatureName
    Disable-WindowsOptionalFeature -Online -Remove -NoRestart | Out-Null
  }
Write-Host "Finished uninstalling Windows Features"
