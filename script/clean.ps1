$ProgressPreference='SilentlyContinue'

$cleanup_types = `
"Active Setup Temp Folders",`
"BranchCache",`
"Downloaded Program Files",`
"GameNewsFiles",`
"GameStatisticsFiles",`
"GameUpdateFiles",`
"Internet Cache Files",`
"Memory Dump Files",`
"Offline Pages Files",`
"Old ChkDsk Files",`
"Previous Installations",`
"Recycle Bin",`
"Service Pack Cleanup",`
"Setup Log Files",`
"System error memory dump files",`
"System error minidump files",`
"Temporary Files",`
"Temporary Setup Files",`
"Temporary Sync Files",`
"Thumbnail Cache",`
"Update Cleanup",`
"Upgrade Discarded Files",`
"User file versions",`
"Windows Defender",`
"Windows Error Reporting Archive Files",`
"Windows Error Reporting Queue Files",`
"Windows Error Reporting System Archive Files",`
"Windows Error Reporting System Queue Files",`
"Windows ESD installation files",`
"Windows Upgrade Log Files"

$regKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
$state = "StateFlags0100"

foreach ($cleanup in $cleanup_types) {
    New-ItemProperty -Path "$regKey\$cleanup" -Name $state -Value 2 -PropertyType DWord -Force | Out-Null
}

if (Test-Path "$env:SystemRoot\SYSTEM32\cleanmgr.exe") {
  Start-Process -Wait cleanmgr -ArgumentList "/sagerun:100"
}

Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
