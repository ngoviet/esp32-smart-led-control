# ESP32 Smart LED Control — ESPHome Modular Configuration

ESPHome configuration for one ESP32 that switches two 24 V LED strips and reports environment and
presence to Home Assistant. Device name `led_temp_pressure`, address `192.168.20.161`.

## Stack
- **Firmware**: ESPHome 2026.7.0 or newer (YAML, ESP-IDF framework)
- **Hardware**: ESP32-WROOM-32, BME280 (I2C `0x76`), LD2410 mmWave (UART), analog rain sensor,
  two AOD4184 MOSFET modules driving 24 V LED strips, two buttons
- **Integration**: native Home Assistant API (no custom component, no HA helpers)

## Build/Flash

```bash
esphome config main.yaml                          # validate
esphome compile main.yaml                         # compile only
esphome run main.yaml                             # flash over USB
esphome run main.yaml --device 192.168.20.161     # flash over OTA (same as flash.bat)
esphome logs main.yaml --device 192.168.20.161    # same as logs.bat
```

## Architecture
- `main.yaml`: `substitutions`, WiFi, OTA and the `packages:` list.
- `components/*.yaml`: one module per function. IDs are shared across modules once packages are
  merged: `led2_sync` and `led_2_switch` live in `led_controls.yaml`, `presence_sensor` and
  `ld2410_enable` in `motion_sensor.yaml`, `led2_window_state` in `time_automation.yaml`.
- `secrets.yaml` (gitignored) is created from `secrets.template.yaml`.

## Rules that are easy to break
- **Entity `name:` values are identifiers.** Home Assistant keys entities on the name, and the
  owner's HA-Config repo references the resulting `*.tang_3_led_temp_pressure_*` entity IDs.
  Renaming, adding or dropping an entity is a Home Assistant change, not a refactor.
- **The repo must match the device.** The firmware that ran until November 2026 was built from a
  config that was never committed and was later lost. Commit before flashing, never after.
- **Only `components/led_controls.yaml` drives the LED 2 pin.** `led_2_switch` is switched by the
  `LED 2` template switch and by the scripts `led2_sync` and `led2_auto_release`, which keep the
  `led2_auto_lit` flag (who lit the light) correct. From any other file, call those scripts.
- **Template switches run their action at boot** unless `restore_mode: DISABLED`. `LED 2` needs
  it: its action counts as a manual override. And nothing in `led2_window_check` runs before
  `on_boot` priority -100, because numbers and switches restore one by one.
- **An LD2410 distance only publishes when it changes**, so a `throttle` filter must be paired
  with `timeout: {value: last}` or the last value is lost and Home Assistant keeps a stale one.
- **Validate with the template secrets in a scratch copy.** Never overwrite the real
  `secrets.yaml`; CI does `cp secrets.template.yaml secrets.yaml` on a fresh checkout.
- **Flashing is the owner's call.** It needs the OTA password of the running firmware, and the
  buttons must be checked on the hardware afterwards (see README, "Check the buttons once").

## Building on Windows
ESPHome 2026.10 builds with its own ESP-IDF toolchain. On the owner's PC (checked 2026-11-18) it
fails in two ways unless worked around:
- Windows long paths are off, and the toolchain needs a root of about 15 characters or fewer.
  Set `ESPHOME_ESP_IDF_PREFIX` to a short folder (the test build used `D:\eidf\t`), or enable
  long paths. The default root under `%LOCALAPPDATA%` is too long.
- The ESP-IDF installer refuses to run under Git Bash (it sees `MSYSTEM`), and `env -u MSYSTEM`
  does not remove it for child processes. Run `esphome compile` from `cmd.exe` or PowerShell;
  from Git Bash, call a `.cmd` file that does `set MSYSTEM=` first.

`esphome config` is unaffected by both.

## Code Conventions
- IDs in `snake_case`; entity names stay exactly as they are (see above).
- Comments in Vietnamese, explaining why rather than what.
- Sensitive values only through `!secret`.
- Tunable values go in `substitutions` in `main.yaml`, not inline in a module.
