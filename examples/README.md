# ESP32 LED Control Examples

## 1. Cấu hình cơ bản (Chỉ LED đơn giản)

```yaml
# main_basic.yaml - Cấu hình tối giản
esphome:
  name: esp32_led_basic
  
esp32:
  board: esp32dev
  framework:
    type: esp-idf

wifi:
  ssid: "YourWiFi"
  password: "YourPassword"

api:
ota:

switch:
  - platform: gpio
    pin: GPIO12
    name: "LED 1"
    
  - platform: gpio
    pin: GPIO13
    name: "LED 2"
```

## 2. Chỉ cảm biến môi trường

```yaml
# environment_only.yaml
sensor:
  - platform: bme280_i2c
    address: 0x76
    temperature:
      name: "Temperature"
    humidity:
      name: "Humidity"
    pressure:
      name: "Pressure"

i2c:
  sda: GPIO21
  scl: GPIO22
```

## 3. Chỉ cảm biến chuyển động

```yaml 
# motion_only.yaml
uart:
  id: ld2410_uart
  tx_pin: GPIO17
  rx_pin: GPIO16
  baud_rate: 256000
  parity: NONE
  stop_bits: 1

ld2410:
  uart_id: ld2410_uart

binary_sensor:
  - platform: ld2410
    has_target:
      name: "Presence"
```

## 4. Automation đơn giản

```yaml
# simple_automation.yaml
binary_sensor:
  - platform: gpio
    pin: GPIO27
    name: "Button"
    on_press:
      - switch.toggle: led_1

switch:
  - platform: gpio
    pin: GPIO12
    name: "LED 1"
    id: led_1
```