@echo off
echo ========================================
echo BiblePulse - Flutter App Runner
echo ========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter is not installed or not in PATH!
    echo.
    echo Please follow these steps:
    echo 1. Download Flutter from: https://docs.flutter.dev/get-started/install/windows
    echo 2. Extract to C:\src\flutter
    echo 3. Add C:\src\flutter\bin to your PATH
    echo 4. Restart this script
    echo.
    pause
    exit /b 1
)

echo Flutter found! Version:
flutter --version
echo.

echo Installing dependencies...
flutter pub get
echo.

echo ========================================
echo Select how you want to run the app:
echo ========================================
echo 1. Chrome (Web) - Easiest, no Android Studio needed
echo 2. Edge (Web) - Alternative browser option
echo 3. Android - Requires Android Studio and emulator
echo 4. Windows Desktop - Native Windows app
echo 5. Show available devices
echo.
set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" (
    echo.
    echo Starting BiblePulse in Chrome...
    flutter run -d chrome
) else if "%choice%"=="2" (
    echo.
    echo Starting BiblePulse in Edge...
    flutter run -d edge
) else if "%choice%"=="3" (
    echo.
    echo Starting BiblePulse on Android...
    flutter run -d android
) else if "%choice%"=="4" (
    echo.
    echo Starting BiblePulse on Windows Desktop...
    flutter run -d windows
) else if "%choice%"=="5" (
    echo.
    echo Available devices:
    flutter devices
    echo.
    pause
) else (
    echo Invalid choice!
    pause
)

pause

