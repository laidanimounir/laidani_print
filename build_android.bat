@echo off
echo Building Android APK...
cd /d "%~dp0"
flutter build apk --release --split-per-abi
if %errorlevel% equ 0 (
    echo APK saved to build\app\outputs\flutter-apk\
) else (
    echo Build failed!
)
pause
