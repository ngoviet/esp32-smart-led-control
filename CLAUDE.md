# ESP32 Smart LED Control â€” ESPHome Modular Architecture

ESPHome-based smart LED control system with Home Assistant integration. Environmental sensors (BME280), motion detection, and intelligent automation.

## Stack
- **Firmware**: ESPHome (YAML configuration)
- **Hardware**: ESP32-WROOM-32, BME280, HC-SR501 PIR, WS2812B LEDs
- **Integration**: Native Home Assistant API (no custom component needed)

## Build/Flash

```bash
# Validate YAML
esphome config esp32-smart-led.yaml

# Compile
esphome compile esp32-smart-led.yaml

# Flash via USB
esphome upload esp32-smart-led.yaml

# OTA update
esphome upload esp32-smart-led.yaml --device <ip>
```

## Architecture
- Modular YAML files: `common/` for shared config, device-specific YAML for each unit
- `secrets.yaml` for WiFi credentials and API keys (not committed)
- `secrets_example.yaml` as template for new users

## Code Conventions
- ESPHome naming: `snake_case` for entities
- Each device gets its own YAML file
- Common configurations extracted to `common/` directory
- Sensitive values in `secrets.yaml` (never committed)
