@setlocal EnableDelayedExpansion EnableExtensions
@for %%i in (%~dp0\_packer_config*.cmd) do @call "%%~i"
@if defined PACKER_DEBUG (@echo on) else (@echo off)

title Installing Git. Please wait...

if not defined GIT_URL set GIT_URL=https://github.com/git-for-windows/git/releases/download/v2.23.0.windows.1/Git-2.23.0-64-bit.exe

for %%i in (%GIT_URL%) do set GIT_EXE=%%~nxi
set GIT_DIR=%TEMP%\git
set GIT_PATH=%GIT_DIR%\%GIT_EXE%

echo ==^> Creating "%GIT_DIR%"
mkdir "%GIT_DIR%"
pushd "%GIT_DIR%"

if exist "%SystemRoot%\_download.cmd" (
  call "%SystemRoot%\_download.cmd" "%GIT_URL%" "%GIT_PATH%"
) else (
  echo ==^> Downloading "%GIT_URL%" to "%GIT_PATH%"
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%GIT_URL%', '%GIT_PATH%')" <NUL
)
if not exist "%GIT_PATH%" goto exit1

echo ==^> Installing Git
"%GIT_PATH%" /VERYSILENT /NORESTART /SP- /NOCANCEL /SUPPRESSMSGBOXES
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%GIT_PATH%" /VERYSILENT /NORESTART /SP- /NOCANCEL /SUPPRESSMSGBOXES

echo ==^> Testing Git
"%ProgramFiles%\Git\bin\git.exe" --version
@if errorlevel 1 echo ==^> WARNING: Error %ERRORLEVEL% was returned by: "%GIT_PATH%" /VERYSILENT /NORESTART /SP- /NOCANCEL /SUPPRESSMSGBOXES

echo ==^> Removing "%GIT_DIR%"
popd
rmdir /q /s "%GIT_DIR%"

:exit0

ver>nul

goto :exit

:exit1

verify other 2>nul

:exit
