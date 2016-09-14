@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Setting WSUS settings. Please wait...

echo ==^> Setting WSUS settings

net stop wuauserv

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /f /v UseWUServer /t REG_DWORD /d 1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f /v WUServer /t REG_SZ /d "https://wsus.techneg.it:8531" 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f /v TargetGroupEnabled /t REG_DWORD /d 1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f /v TargetGroup /t REG_SZ /d "win8-dev" 

net start wuauserv
