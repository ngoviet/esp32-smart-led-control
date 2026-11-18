# ESP32 Smart LED Control System

<!-- readme-axi type=esp32 -->

**English** · [Tiếng Việt](README.vi.md)

A **smart LED control system with environmental sensors and Home Assistant**, built with
**ESPHome** on an **ESP32 WROOM-32**. It drives two 24 V LED strips through MOSFETs, reads a
BME280 (temperature, humidity, pressure), a rain sensor and an LD2410 mmWave presence sensor, and
switches one of the lights automatically by time of day and presence.

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

- **Two 24 V LED channels** — LED 1 is manual (Home Assistant or a push button); LED 2 can follow presence
- **Presence-driven LED 2** — an LD2410 mmWave sensor lights LED 2 only inside a daily time window
- **Manual override with auto return** — switching LED 2 by hand suspends auto mode for 5 minutes
- **Time window set on the device** — four number entities, no Home Assistant helpers; the window may wrap past midnight
- **Environmental monitoring** — temperature, humidity and pressure (BME280), plus a rain sensor with hysteresis
- **Keeps working offline** — buttons and presence control run on the device. Losing Home Assistant never restarts it; losing WiFi restarts it only after 10 minutes
- **Modular configuration** — one YAML file per function

## Hardware

### Components

- **ESP32 WROOM-32** (`esp32dev`, 4 MB flash)
- **BME280** — temperature, humidity, pressure (I2C, address `0x76`)
- **LD2410** — mmWave presence sensor (UART, 256000 baud)
- **Rain sensor** — analog board read through the ADC
- **2 × 24 V LED strips**, each switched by an **AOD4184 MOSFET module**
- **Buck converter 24 V → 5 V** powering the ESP32
- **2 buttons** — a push button for LED 1 and a touch button for LED 2

Circuit diagram for one LED channel: [`so_do_esp32_led_24v_mosfet.pdf`](so_do_esp32_led_24v_mosfet.pdf).

### GPIO mapping

| GPIO | Function | Notes |
| --- | --- | --- |
| GPIO12 | LED 1 (MOSFET gate) | Strapping pin: never add a pull-up here or the ESP32 will not boot |
| GPIO13 | LED 2 (MOSFET gate) | |
| GPIO14 | Button LED 1 | Push button to GND, internal pull-up |
| GPIO27 | Button LED 2 | Touch button, reads low when touched |
| GPIO16 | UART RX ← LD2410 TX | |
| GPIO17 | UART TX → LD2410 RX | |
| GPIO21 | I2C SDA (BME280) | |
| GPIO22 | I2C SCL (BME280) | |
| GPIO32 | Rain sensor (ADC) | Voltage drops when the sensor is wet |

## Quick start

### 1. Install ESPHome

```bash
pip install esphome
```

The configuration needs ESPHome **2026.7.0 or newer**.

### 2. Create your secrets

```bash
cp secrets.template.yaml secrets.yaml
```

Fill in `wifi_ssid`, `wifi_password` and `ota_password`. `secrets.yaml` is gitignored.

### 3. Validate, then flash

```bash
esphome config main.yaml   # validate only
esphome run main.yaml      # compile and flash: USB the first time, OTA afterwards
```

On Windows there are helper scripts: `setup.bat`, `compile.bat`, `flash.bat` and `logs.bat`.
`flash.bat` and `logs.bat` target `192.168.20.161`; change the address to your device's.

### 4. Check the buttons once

With no button pressed, `Button LED 1` and `Button LED 2` must read **off** in Home Assistant.
If one reads **on**, set its `button1_inverted` / `button2_inverted` substitution in `main.yaml`
to `"false"` and flash again.

## Configuration

Shared parameters live in `substitutions` at the top of `main.yaml`:

| Substitution | Default | Meaning |
| --- | --- | --- |
| `led2_manual_timeout` | `5min` | How long a manual LED 2 action suspends auto mode |
| `ld2410_distance_interval` | `5s` | Shortest gap between two updates of an LD2410 distance |
| `button1_inverted`, `button2_inverted` | `"true"` | Button polarity (`"true"` = the pin reads low when pressed) |
| `rain_on_below`, `rain_off_above` | `1.8`, `2.2` | Rain thresholds in volts (the gap is the hysteresis) |
| `timezone` | `Asia/Ho_Chi_Minh` | Time zone used for the LED 2 window |

Everything else is in the module that owns it:

| To change | Edit |
| --- | --- |
| WiFi, OTA | `main.yaml` and `secrets.yaml` |
| BME280 and rain sensor | `components/environment_sensors.yaml` |
| LD2410 and its update rate | `components/motion_sensor.yaml` |
| LED pins, buttons, LED 2 logic | `components/led_controls.yaml` |
| Default time window, time sources | `components/time_automation.yaml` |
| Diagnostic entities | `components/diagnostic.yaml` |

## Home Assistant

The device uses the native ESPHome API and is discovered automatically. No helpers or
automations are required on the Home Assistant side.

| Entity | Type | Purpose |
| --- | --- | --- |
| `LED 1` | switch | LED strip 1 |
| `LED 2` | switch | LED strip 2; using it is a manual override |
| `LED 2 Auto Mode` | switch | Lets presence control LED 2 |
| `LD2410 Enable` | switch | Lets the presence sensor drive LED 2 (it keeps reporting when off) |
| `Start Hour`, `Start Minute`, `End Hour`, `End Minute` | number | Daily auto window (default 05:00–23:00) |
| `Presence Detection`, `Moving Target`, `Still Target` | binary_sensor | LD2410 presence |
| `Moving Distance`, `Still Distance`, `Detection Distance` | sensor | LD2410 distances in cm, sent when they change, at most once every 5 s |
| `Temp`, `Pressure`, `Humidity` | sensor | BME280, every 60 s |
| `Rain Sensor Value`, `Mưa?` | sensor, binary_sensor | Rain sensor voltage and rain detected |
| `Button LED 1`, `Button LED 2` | binary_sensor | Physical buttons |
| `WiFi RSSI`, `RAM Free (KB)`, `WiFi IP`, `WiFi SSID`, `WiFi BSSID`, `WiFi MAC` | diagnostic | Device health |
| `Restart thiết bị` | button | Restart the ESP32 |

**Entity names are identifiers.** Home Assistant keys each entity on its `name:`, so renaming one
in YAML creates a new entity and orphans the old one in dashboards and automations.

### How LED 2 behaves

- **Auto**: while `LED 2 Auto Mode` and `LD2410 Enable` are on and the time is inside the window,
  LED 2 follows `Presence Detection`.
- **Window start**: auto mode turns on. A manual override that is still running finishes first.
  **Window end**: auto mode turns off, and an LED 2 that auto mode had lit is switched off; a
  light you switched on by hand is left alone.
- **Manual override**: switching `LED 2` (from Home Assistant or a short tap on button 2) turns
  auto mode off for 5 minutes, then back on. A long press (0.8–5 s) returns to auto at once.
- **After a restart** inside the window, auto mode is turned back on as soon as the clock is set.
  Until the clock is set, presence does not control the light.
- **Without WiFi for 10 minutes** the device restarts, and both LEDs come back off.

More detail: [`docs/LED2_MANUAL_OVERRIDE_GUIDE.md`](docs/LED2_MANUAL_OVERRIDE_GUIDE.md).

## Project layout

```
esp32_led_temp_pressure/
├── main.yaml                      # Substitutions, WiFi, OTA, module list
├── components/
│   ├── common.yaml                # Board, logger, API, I2C, restart button
│   ├── environment_sensors.yaml   # BME280, rain sensor
│   ├── motion_sensor.yaml         # LD2410 and the "LD2410 Enable" switch
│   ├── led_controls.yaml          # LED switches, buttons, LED 2 logic
│   ├── time_automation.yaml       # Time sources, auto window
│   └── diagnostic.yaml            # WiFi and memory diagnostics
├── secrets.template.yaml          # Copy to secrets.yaml and fill in
├── docs/LED2_MANUAL_OVERRIDE_GUIDE.md
├── examples/README.md             # Minimal standalone snippets
├── setup.bat, compile.bat, flash.bat, logs.bat
├── so_do_esp32_led_24v_mosfet.pdf # Circuit diagram
└── CHANGELOG.md
```

## Development

- **Validate before flashing**: `esphome config main.yaml`. CI runs the same check on every push
  with `secrets.template.yaml` standing in for the real secrets.
- **Read the logs**: `esphome logs main.yaml --device <ip>`. The logger runs at `INFO`; switch it
  to `DEBUG` in `components/common.yaml` to see each component's configuration at boot.
- **Opt-in boot options**: `components/common.yaml` holds two commented-out `esp32` options
  (`minimum_chip_revision`, `sram1_as_iram`) that the device suggests in its boot log. They change
  how the firmware boots, so enable them only with the board and a USB cable at hand.
- **Building on Windows**: ESPHome 2026.10 and newer build with their own ESP-IDF toolchain. It
  needs Windows long paths enabled, or `ESPHOME_ESP_IDF_PREFIX` pointing at a short folder such as
  `C:\ESPHome\idf`, and its installer refuses to run under Git Bash; use `cmd.exe` or PowerShell
  (the `.bat` scripts already do). `esphome config` is not affected.
- **History**: see [`CHANGELOG.md`](CHANGELOG.md).

<!-- support:start -->
## Support the project

<p align="center">
  <img src="https://raw.githubusercontent.com/ngoviet/.github/main/assets/support/banner-v2.svg" width="560" alt="Built and maintained by one person in Việt Nam">
</p>

<p align="center">Free and open source. Your support pays for new device support, faster fixes and every release.</p>

<p align="center">
  <a href="https://buymeacoffee.com/ngoviet"><img src="https://raw.githubusercontent.com/ngoviet/.github/main/assets/support/btn-coffee.svg" height="56" alt="Buy me a coffee"></a>
  &nbsp;
  <a href="https://github.com/sponsors/ngoviet"><img src="https://raw.githubusercontent.com/ngoviet/.github/main/assets/support/btn-sponsors.svg" height="56" alt="GitHub Sponsors"></a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/ngoviet/.github/main/assets/support/vietqr-card.svg" width="300" alt="VietQR — MB Bank — NGO DUC VIET — 911051212">
  &nbsp;
  <img src="https://raw.githubusercontent.com/ngoviet/.github/main/assets/support/crypto-card.svg" width="300" alt="Crypto — BNB Smart Chain (BEP20) — 0xcbf0402b232cb24b4d998f09a4884f87b5f74750">
</p>

<p align="center"><b>Crypto wallet, BNB Smart Chain (BEP20) only:</b><br><code>0xcbf0402b232cb24b4d998f09a4884f87b5f74750</code></p>

<p align="center">🇻🇳 VietQR: scan with any Vietnamese banking app, transfer note <code>Ung ho esp32-smart-led-control</code>. Thank you for keeping this project alive!</p>
<!-- support:end -->

## License

[MIT](LICENSE) © Ngô Đức Việt.
