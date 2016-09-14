@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Disabling Auto Logon. Please wait...

echo ==^> Disabling AutoAdminLogon

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\winlogon" /f /v AutoAdminLogon /t REG_DWORD /d 0
