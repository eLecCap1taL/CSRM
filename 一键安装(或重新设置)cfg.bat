@echo off
chcp 65001

if exist "%SystemRoot%\SysWOW64" path %path%;%windir%\SysNative;%SystemRoot%\SysWOW64;%~dp0

bcdedit >nul

if '%errorlevel%' NEQ '0' (goto UACPrompt) else (goto UACAdmin)

:UACPrompt
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
exit /B

:UACAdmin
cd /d "%~dp0"

REM 检查是否在CSRM文件夹中
for %%I in (.) do set CurrDirName=%%~nxI
if /I not "%CurrDirName%"=="CSRM" (
    color 0C
    echo 请把此文件放进CSRM文件夹中!!!
    echo.请把此文件放进CSRM文件夹中!!!
    echo.请把此文件放进CSRM文件夹中!!!
    echo.请确保此文件在*\Counter-Strike Global Offensive\game\csgo\cfg\CSRM目录当中
    echo.
    pause
    exit /b
)

REM 检查"完美世界竞技平台"进程是否运行
tasklist /FI "IMAGENAME eq 完美世界竞技平台.exe" 2>NUL | find /I /N "完美世界竞技平台.exe">NUL
if "%ERRORLEVEL%"=="1" (
    color 0C
    echo 请运行完美对战平台后启动此文件!!!
    echo.请运行完美对战平台后启动此文件!!!
    echo.请运行完美对战平台后启动此文件!!!
    echo.
    pause
    exit /b
)

REM 运行PowerShell脚本并在完成后退出
call powershell.exe -ExecutionPolicy Bypass -File ".\CSRM_install.ps1"