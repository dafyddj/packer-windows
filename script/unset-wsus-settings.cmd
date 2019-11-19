@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Unsetting WSUS settings. Please wait...

echo ==^> Unsetting WSUS settings

net stop wuauserv

reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /f /v UseWUServer
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f /v WUServer
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f /v TargetGroupEnabled
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f /v TargetGroup

net start wuauserv
