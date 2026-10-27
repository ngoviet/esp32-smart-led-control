# ESP32 Smart LED Control System

<!-- readme-axi type=esp32 -->

**English** · [Tiếng Việt](README.vi.md)

A **smart LED control system with environmental sensors and Home Assistant**, built with
**ESPHome** on an **ESP32 WROOM-32**. It drives two 24 V LED strips through MOSFETs, reads a
BME280 (temperature, humidity, pressure), a rain sensor and an LD2410 mmWave motion sensor, and
switches the lights automatically by time of day and presence.

> 🇻🇳 Built and maintained by one person in Việt Nam — if it saves you time, please
> [support the project](#support-the-project).

## Contents

- [Features](#features)
- [Hardware](#hardware)
- [Quick start](#quick-start)
- [Configuration](#configuration)
- [Home Assistant](#home-assistant)
- [Project layout](#project-layout)
- [Development](#development)

## Features

- **Home Assistant integration** — remote control through HA
- **Environmental monitoring** — temperature, humidity, pressure (BME280)
- **Rain sensor** — automatic rain detection
- **Motion sensor** — LD2410 presence detection
- **Time-based automation** — active 18:00-06:00
- **Smart LED2** — manual control that automatically returns to auto mode
- **System monitoring** — RAM, CPU, WiFi, uptime
- **Modular structure** — easy to maintain and extend

## Hardware

### Components

- **ESP32 WROOM-32** (4MB Flash, 320KB RAM)
- **BME280** — temperature, humidity, pressure sensor (I2C)
- **LD2410** — motion sensor (UART)
- **Rain Sensor** — rain sensor (ADC)
- **2x LED strips** — the controlled LED lights
- **MOSFET 24V** — high-power switching

### GPIO wiring

```
GPIO21 (SDA) ➜ BME280 SDA
GPIO22 (SCL) ➜ BME280 SCL
GPIO16 (RX)  ➜ LD2410 TX
GPIO17 (TX)  ➜ LD2410 RX
GPIO36 (ADC) ➜ Rain Sensor
GPIO12       ➜ LED 1 Control
GPIO13       ➜ LED 2 Control
GPIO27       ➜ Manual Button
```

### GPIO mapping

- **GPIO12**: LED 1
- **GPIO13**: LED 2
- **GPIO14**: LED 1 button (INPUT_PULLUP)
- **GPIO16**: LD2410 RX
- **GPIO17**: LD2410 TX
- **GPIO21**: I2C SDA (BME280)
- **GPIO22**: I2C SCL (BME280)
- **GPIO27**: ~~LED 2 touch button~~ (DISABLED)
- **GPIO32**: Rain sensor (ADC)

### Sensors

- **LD2410**: mmWave motion sensor
- **BME280**: temperature, pressure, humidity (I2C 0x76)
- **Rain Sensor**: analog rain sensor

## Quick start

### 1. Prepare the environment

```bash
pip install esphome
```

### 2. Configure WiFi

```bash
cp secrets.template.yaml secrets.yaml
# Edit the WiFi details in secrets.yaml
```

### 3. Compile & Flash

```bash
# Windows
flash.bat

# Linux/MacOS
esphome run main.yaml
```

### Build with the modular config

```bash
esphome compile main.yaml
esphome upload main.yaml
```

Or use the helper script:

```cmd
build_modular.bat
```

## Configuration

To make changes:

1. **Change the WiFi configuration**: edit `components/common.yaml`
2. **Adjust the sensors**: edit `components/environment_sensors.yaml`
3. **Change GPIOs**: edit `components/led_controls.yaml`
4. **Update the motion logic**: edit `components/motion_sensor.yaml`
5. **Adjust the schedule**: edit `components/time_automation.yaml`

## Home Assistant

Create these input_datetime helpers in HA:

- `input_datetime.auto_led2_start`: auto mode start time
- `input_datetime.auto_led2_end`: auto mode end time

## Project layout

Modular architecture:

```
esp32_led_temp_pressure/
├── main.yaml                    # Main configuration file (MODULAR)
├── components/                  # Folder holding the modules
│   ├── common.yaml              # Basic configuration (Logger, API, OTA, I2C)
│   ├── motion_sensor.yaml       # LD2410 motion sensor
│   ├── led_controls.yaml        # LED and button control
│   ├── environment_sensors.yaml # Environmental sensors (BME280, rain)
│   ├── wifi_monitoring.yaml     # Basic WiFi configuration
│   ├── diagnostic.yaml          # 🆕 Combined system diagnostics
│   └── time_automation.yaml     # Time management and automation
├── backup/                      # 📁 Old files (no longer used)
│   ├── esp32_led_temp_pressure.yaml # Original monolithic file
│   ├── flash.bat                # Old flash script
│   ├── esare.bat                # Old erase script
│   ├── log.bat                  # Old log script
│   └── README_BACKUP.md         # Backup guide
├── build_modular.bat            # 🆕 New build/upload script
├── validate_modular.py          # 🆕 Validation script
├── so_do_esp32_led_24v_mosfet.pdf # Circuit diagram
└── README.md                    # This file
```

### Modules

#### 1. `common.yaml` — basic configuration

- ESP32, WiFi, Logger configuration
- API, OTA, Web Server
- I2C, restart button
- WiFi check interval

#### 2. `motion_sensor.yaml` — motion sensor

- LD2410 UART configuration
- Presence-detection binary sensor
- Logic that turns LED2 on/off automatically by time

#### 3. `led_controls.yaml` — LED control

- 2 LEDs (GPIO12, GPIO13)
- LED2 auto mode
- Physical and touch buttons
- Handling of the different button-press types

#### 4. `environment_sensors.yaml` — environmental sensors

- BME280: temperature, pressure, humidity
- Rain sensor (ADC)
- Rain-detection binary sensor with a threshold

#### 5. `wifi_monitoring.yaml` — basic WiFi configuration

- WiFi fallback and captive portal configuration
- mDNS and network discovery settings

#### 6. `diagnostic.yaml` — system diagnostics & monitoring

- **WiFi Diagnostics**: RSSI, quality %, signal bars, connection info
- **System Health**: Memory usage %, CPU load, temperature monitoring
- **Uptime Tracking**: Seconds and human-readable format
- **Alert Systems**: Low memory, high temp, poor WiFi warnings
- **Health Scoring**: Overall system health assessment

#### 7. `time_automation.yaml` — time-based automation

- Time sync with Home Assistant and SNTP
- Turns LED2 auto mode on/off automatically by time window
- Manages the global time variables

### Benefits of the modular structure

1. **Easy to maintain**: each function lives in its own file
2. **Reusable**: modules can be reused in other projects
3. **Easy to debug**: errors are easy to find and fix within each module
4. **Extensible**: new features do not affect existing code
5. **Collaboration**: several people can work on different modules
6. **Version control**: Git tracks changes per module

## Development

### Backup & Restore

- The original `esp32_led_temp_pressure.yaml` is kept as a backup
- To restore: copy the original file's content into `main.yaml`
- To go back from modular to monolithic: merge all components into one file

Restoring the old files (if needed):

```cmd
# Copy the original file from backup
copy backup\esp32_led_temp_pressure.yaml .

# Use the old scripts
backup\flash.bat
backup\log.bat
```

<!-- support:start -->
## Support the project

<p align="center">
  <img src="https://raw.githubusercontent.com/ngoviet/.github/main/assets/support/banner.svg" width="720" alt="Built and maintained by one person in Việt Nam">
</p>

<p align="center">
  <a href="https://buymeacoffee.com/ngoviet"><img src="https://raw.githubusercontent.com/ngoviet/.github/main/assets/support/btn-coffee.svg" height="56" alt="Buy me a coffee"></a>
  &nbsp;
  <a href="https://github.com/sponsors/ngoviet"><img src="https://raw.githubusercontent.com/ngoviet/.github/main/assets/support/btn-sponsors.svg" height="56" alt="GitHub Sponsors"></a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/ngoviet/.github/main/assets/support/vietqr-card.svg" width="300" alt="VietQR — MB Bank — NGO DUC VIET — 911051212">
</p>

<p align="center"><sub>🇻🇳 VietQR: scan with any Vietnamese banking app, transfer note <code>Ung ho esp32-smart-led-control</code>. Thank you for keeping this project alive!</sub></p>
<p align="center"><sub>Crypto (BEP20 network): <code>0x57f07d44fb581cddc028a0c67d63a8cc05aa6caa</code> · USDT · USDC · BNB · ETH · BTC</sub></p>
<!-- support:end -->

## License

[MIT](LICENSE) © Ngô Đức Việt.
