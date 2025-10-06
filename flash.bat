@echo off
echo ===============================================
echo ESP32 LED Temperature Pressure - Flash Tool
echo ===============================================
echo.
echo Flashing ESP32 via OTA to 192.168.20.161...
echo.

esphome run main.yaml --device 192.168.20.161

echo.
echo Flash completed!
pause