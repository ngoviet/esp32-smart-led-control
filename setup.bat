@echo off
echo ===============================================
echo ESP32 Smart LED Control System - Setup
echo ===============================================
echo.

REM Check if ESPHome is installed
esphome version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ESPHome not found! Installing...
    pip install esphome
    if %ERRORLEVEL% NEQ 0 (
        echo Error: Failed to install ESPHome
        echo Please install Python and pip first
        pause
        exit /b 1
    )
)

echo ESPHome installed successfully!
echo.

REM Copy secrets template if not exists
if not exist secrets.yaml (
    echo Creating secrets.yaml from template...
    copy secrets.template.yaml secrets.yaml
    echo.
    echo IMPORTANT: Please edit secrets.yaml with your WiFi credentials
    echo.
) else (
    echo secrets.yaml already exists
)

echo Setup completed!
echo.
echo Next steps:
echo 1. Edit secrets.yaml with your WiFi information
echo 2. Run compile.bat to test configuration
echo 3. Run flash.bat to upload to ESP32
echo.
pause