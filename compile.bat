@echo off
echo ===============================================
echo ESP32 LED Temperature Pressure - Compile Only
echo ===============================================
echo.
echo Compiling ESPHome configuration...
echo.

esphome compile main.yaml

echo.
echo Compile completed!
pause