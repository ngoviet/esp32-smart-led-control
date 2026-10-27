# ESP32 điều khiển LED thông minh

<!-- readme-axi type=esp32 -->

[English](README.md) · **Tiếng Việt**

**Hệ thống điều khiển LED thông minh với cảm biến môi trường và Home Assistant**, viết bằng
**ESPHome** trên **ESP32 WROOM-32**. Điều khiển hai dải LED 24V qua MOSFET, đọc BME280 (nhiệt độ,
độ ẩm, áp suất), cảm biến mưa và cảm biến chuyển động mmWave LD2410, tự bật/tắt đèn theo thời
gian và theo người.

> 🇻🇳 Dự án do một người Việt tự xây dựng và duy trì — nếu nó giúp ích cho bạn, hãy
> [ủng hộ dự án](#ủng-hộ-dự-án).

## Mục lục

- [Tính năng](#tính-năng)
- [Phần cứng](#phần-cứng)
- [Bắt đầu nhanh](#bắt-đầu-nhanh)
- [Cấu hình](#cấu-hình)
- [Home Assistant](#home-assistant)
- [Cấu trúc dự án](#cấu-trúc-dự-án)
- [Phát triển](#phát-triển)

## Tính năng

- **Tích hợp Home Assistant** - Điều khiển từ xa qua HA
- **Giám sát môi trường** - Nhiệt độ, độ ẩm, áp suất (BME280)
- **Cảm biến mưa** - Phát hiện mưa tự động
- **Cảm biến chuyển động** - LD2410 phát hiện người
- **Tự động theo thời gian** - Hoạt động 18:00-06:00
- **LED2 thông minh** - Điều khiển thủ công với tự động quay về
- **Giám sát hệ thống** - RAM, CPU, WiFi, uptime
- **Cấu trúc modular** - Dễ bảo trì và mở rộng

## Phần cứng

### Linh kiện

- **ESP32 WROOM-32** (4MB Flash, 320KB RAM)
- **BME280** - Cảm biến nhiệt độ, độ ẩm, áp suất (I2C)
- **LD2410** - Cảm biến chuyển động (UART)
- **Rain Sensor** - Cảm biến mưa (ADC)
- **2x LED strips** - Đèn LED điều khiển
- **MOSFET 24V** - Điều khiển công suất cao

### Kết nối GPIO

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

### GPIO Mapping

- **GPIO12**: LED 1
- **GPIO13**: LED 2
- **GPIO14**: Nút bấm LED 1 (INPUT_PULLUP)
- **GPIO16**: LD2410 RX
- **GPIO17**: LD2410 TX
- **GPIO21**: I2C SDA (BME280)
- **GPIO22**: I2C SCL (BME280)
- **GPIO27**: ~~Nút cảm ứng LED 2~~ (VÔ HIỆU HÓA)
- **GPIO32**: Cảm biến mưa (ADC)

### Cảm biến

- **LD2410**: Cảm biến chuyển động mmWave
- **BME280**: Nhiệt độ, áp suất, độ ẩm (I2C 0x76)
- **Rain Sensor**: Cảm biến mưa analog

## Bắt đầu nhanh

### 1. Chuẩn bị môi trường

```bash
pip install esphome
```

### 2. Cấu hình WiFi

```bash
cp secrets.template.yaml secrets.yaml
# Sửa thông tin WiFi trong secrets.yaml
```

### 3. Compile & Flash

```bash
# Windows
flash.bat

# Linux/MacOS
esphome run main.yaml
```

### Biên dịch với cấu hình modular

```bash
esphome compile main.yaml
esphome upload main.yaml
```

Hoặc dùng script tiện lợi:

```cmd
build_modular.bat
```

## Cấu hình

Để sửa đổi:

1. **Thay đổi cấu hình WiFi**: Sửa trong `components/common.yaml`
2. **Điều chỉnh cảm biến**: Sửa trong `components/environment_sensors.yaml`
3. **Thay đổi GPIO**: Sửa trong `components/led_controls.yaml`
4. **Cập nhật logic motion**: Sửa trong `components/motion_sensor.yaml`
5. **Điều chỉnh thời gian**: Sửa trong `components/time_automation.yaml`

## Home Assistant

Cần tạo các input_datetime helpers trong HA:

- `input_datetime.auto_led2_start`: Thời gian bắt đầu tự động
- `input_datetime.auto_led2_end`: Thời gian kết thúc tự động

## Cấu trúc dự án

Kiến trúc modular:

```
esp32_led_temp_pressure/
├── main.yaml                    # File cấu hình chính (MODULAR)
├── components/                  # Thư mục chứa các module
│   ├── common.yaml              # Cấu hình cơ bản (Logger, API, OTA, I2C)
│   ├── motion_sensor.yaml       # Cảm biến chuyển động LD2410
│   ├── led_controls.yaml        # Điều khiển LED và nút bấm
│   ├── environment_sensors.yaml # Cảm biến môi trường (BME280, mưa)
│   ├── wifi_monitoring.yaml     # WiFi cấu hình cơ bản
│   ├── diagnostic.yaml          # 🆕 Chẩn đoán hệ thống tổng hợp
│   └── time_automation.yaml     # Quản lý thời gian và tự động hóa
├── backup/                      # 📁 Old files (không còn dùng)
│   ├── esp32_led_temp_pressure.yaml # File gốc monolithic
│   ├── flash.bat                # Script flash cũ
│   ├── esare.bat                # Script erase cũ
│   ├── log.bat                  # Script log cũ
│   └── README_BACKUP.md         # Hướng dẫn backup
├── build_modular.bat            # 🆕 Script build/upload mới
├── validate_modular.py          # 🆕 Script validation
├── so_do_esp32_led_24v_mosfet.pdf # Sơ đồ mạch
└── README.md                    # File này
```

### Mô tả các module

#### 1. `common.yaml` - Cấu hình cơ bản

- Cấu hình ESP32, WiFi, Logger
- API, OTA, Web Server
- I2C, Button restart
- Interval kiểm tra WiFi

#### 2. `motion_sensor.yaml` - Cảm biến chuyển động

- Cấu hình LD2410 UART
- Binary sensor phát hiện người
- Logic tự động bật/tắt LED2 theo thời gian

#### 3. `led_controls.yaml` - Điều khiển LED

- 2 LED (GPIO12, GPIO13)
- Chế độ tự động LED2
- Nút bấm vật lý và cảm ứng
- Logic xử lý các loại nhấn nút

#### 4. `environment_sensors.yaml` - Cảm biến môi trường

- BME280: nhiệt độ, áp suất, độ ẩm
- Cảm biến mưa (ADC)
- Binary sensor phát hiện mưa với ngưỡng

#### 5. `wifi_monitoring.yaml` - Cấu hình WiFi cơ bản

- Cấu hình WiFi fallback và captive portal
- mDNS và network discovery settings

#### 6. `diagnostic.yaml` - Chẩn đoán & Giám sát hệ thống

- **WiFi Diagnostics**: RSSI, quality %, signal bars, connection info
- **System Health**: Memory usage %, CPU load, temperature monitoring
- **Uptime Tracking**: Seconds và human-readable format
- **Alert Systems**: Low memory, high temp, poor WiFi warnings
- **Health Scoring**: Overall system health assessment

#### 7. `time_automation.yaml` - Tự động hóa theo thời gian

- Đồng bộ thời gian với Home Assistant và SNTP
- Tự động bật/tắt chế độ auto LED2 theo khung giờ
- Quản lý các biến toàn cục thời gian

### Ưu điểm cấu trúc modular

1. **Dễ bảo trì**: Mỗi chức năng trong file riêng
2. **Tái sử dụng**: Có thể dùng lại các module cho dự án khác
3. **Debug dễ**: Dễ tìm và sửa lỗi trong từng module
4. **Mở rộng**: Thêm tính năng mới không ảnh hưởng code cũ
5. **Cộng tác**: Nhiều người có thể làm việc trên các module khác nhau
6. **Version control**: Git tracking thay đổi từng module riêng biệt

## Phát triển

### Backup & Restore

- File gốc `esp32_led_temp_pressure.yaml` được giữ lại làm backup
- Để khôi phục: copy nội dung file gốc vào `main.yaml`
- Để cập nhật từ modular về monolithic: tổng hợp tất cả components vào 1 file

Khôi phục file cũ (nếu cần):

```cmd
# Copy file gốc từ backup
copy backup\esp32_led_temp_pressure.yaml .

# Sử dụng scripts cũ
backup\flash.bat
backup\log.bat
```

<!-- support:start -->
## Ủng hộ dự án

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

<p align="center"><sub>🇻🇳 VietQR: quét bằng app ngân hàng bất kỳ, nội dung <code>Ung ho esp32-smart-led-control</code>. Cảm ơn bạn đã giúp dự án tiếp tục phát triển!</sub></p>
<p align="center"><sub>Tiền mã hoá (mạng BEP20): <code>0xcbf0402b232cb24b4d998f09a4884f87b5f74750</code> · USDT · USDC · BNB · ETH · BTC</sub></p>
<!-- support:end -->

## Giấy phép

[MIT](LICENSE) © Ngô Đức Việt.
