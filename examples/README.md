# Ví dụ cấu hình tối giản

Các đoạn dưới đây tách từng phần của dự án để thử riêng một linh kiện. Ví dụ 1 là một tệp hoàn
chỉnh, chạy được ngay; mỗi ví dụ còn lại là một mảnh ghép, dán thêm vào ví dụ 1.

Khi ghép nhiều mảnh cùng lúc, YAML không cho một khoá xuất hiện hai lần: ví dụ 3 và 4 đều có
`binary_sensor:`, nên hãy gom các mục của chúng vào chung một khoá.

## 1. Chỉ hai công tắc LED

```yaml
# main_basic.yaml
esphome:
  name: esp32-led-basic

esp32:
  board: esp32dev
  framework:
    type: esp-idf

wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password

logger:

api:

ota:
  - platform: esphome
    password: !secret ota_password

switch:
  - platform: gpio
    pin:
      number: GPIO12
      ignore_strapping_warning: true
    name: "LED 1"

  - platform: gpio
    pin: GPIO13
    name: "LED 2"
```

## 2. Thêm cảm biến môi trường

```yaml
i2c:
  sda: GPIO21
  scl: GPIO22

sensor:
  - platform: bme280_i2c
    address: 0x76
    temperature:
      name: "Temperature"
    humidity:
      name: "Humidity"
    pressure:
      name: "Pressure"
```

## 3. Thêm cảm biến hiện diện

```yaml
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

## 4. Nút nhấn đảo trạng thái LED

Thay khối `switch` của ví dụ 1 bằng đoạn này:

```yaml
switch:
  - platform: gpio
    pin:
      number: GPIO12
      ignore_strapping_warning: true
    name: "LED 1"
    id: led_1

binary_sensor:
  - platform: gpio
    pin:
      number: GPIO14
      mode: INPUT_PULLUP
      inverted: true
    name: "Button"
    filters:
      - delayed_on_off: 30ms
    on_press:
      - switch.toggle: led_1
```
