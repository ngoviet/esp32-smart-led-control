@echo off
echo ===============================================
echo ESP32 LED Temperature Pressure - Log Viewer
echo ===============================================
echo.
echo Connecting to ESP32 logs at 192.168.20.161...
echo Press Ctrl+C to exit
echo.

esphome logs main.yaml --device 192.168.20.161