@echo off
echo Building Windows EXE...
cd /d "%~dp0"
flutter build windows --release
if %errorlevel% equ 0 (
    echo EXE saved to build\windows\runner\Release\
) else (
    echo Build failed!
)
pause
