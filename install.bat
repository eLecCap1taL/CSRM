chcp 65001
@echo off


cd /d %~dp0
cd ../
cd ../


set "EXPECTED_FOLDER_NAME=csgo"

for %%F in (.) do set "CURRENT_FOLDER_NAME=%%~nxF"

echo Current folder name: %CURRENT_FOLDER_NAME%
echo Expected folder name: %EXPECTED_FOLDER_NAME%

if /I "%CURRENT_FOLDER_NAME%" neq "%EXPECTED_FOLDER_NAME%" (
    echo ERROR: The current folder is wrong!! Please check the Guide again
    echo 错误: 你的 Horizon 放置位置错误， 请重新查看教程的安装指引
    exit /b 1
)

cd ./cfg/Horizon/

cd ./script
copy /Y gamestate_integration_horizon.cfg "../../gamestate_integration_horizon.cfg"
cd ../
copy /Y Cap1taLB站独家免费.cfg "../Cap1taLB站独家免费.cfg"
cd ../
cd ../
xcopy .\cfg\Horizon\resource .\resource\ /Y /E

cd ./cfg

setlocal enabledelayedexpansion

:: 设置autoexec.cfg文件路径
set "AUTOEXEC_FILE=autoexec.cfg"

:: 检查autoexec.cfg文件是否存在
if not exist "%AUTOEXEC_FILE%" (
    echo %AUTOEXEC_FILE% does not exist. Creating it...
    echo. > "%AUTOEXEC_FILE%"
)

:: 获取文件的最后一行
set "LAST_LINE="
for /f "tokens=* delims=" %%A in ('type "%AUTOEXEC_FILE%" ^| findstr /r /n ".*"') do (
    set "LAST_LINE=%%A"
)

:: 提取文件最后一行内容
for /f "tokens=2 delims=:" %%B in ("!LAST_LINE!") do set "LAST_LINE_CONTENT=%%B"

:: 输出最后一行内容，用于调试
echo Last line content: !LAST_LINE_CONTENT!

:: 检查最后一行是否是 "exec Horizon/load"
if /i not "!LAST_LINE_CONTENT!"=="exec Horizon/load" (
    if /i not "!LAST_LINE_CONTENT!"=="exec Horizon/load " (
        echo Last line is not "exec Horizon/load". Adding it to the file...
        echo exec Horizon/load >> "%AUTOEXEC_FILE%"
    ) else (
        echo Last line is already "exec Horizon/load". No changes made.
    )
) else (
    echo Last line is already "exec Horizon/load". No changes made.
)

echo Done
echo 运行结束
echo 按任意键关闭

pause