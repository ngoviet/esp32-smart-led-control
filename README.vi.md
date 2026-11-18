# ESP32 điều khiển LED thông minh

<!-- readme-axi type=esp32 -->

[English](README.md) · **Tiếng Việt**

**Hệ thống điều khiển LED thông minh với cảm biến môi trường và Home Assistant**, viết bằng
**ESPHome** trên **ESP32 WROOM-32**. Điều khiển hai dải LED 24V qua MOSFET, đọc BME280 (nhiệt độ,
độ ẩm, áp suất), cảm biến mưa và cảm biến hiện diện mmWave LD2410, tự bật/tắt một dải đèn theo
khung giờ và theo người.

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

- **Hai kênh LED 24V** — LED 1 bật/tắt tay (Home Assistant hoặc nút nhấn); LED 2 có thể theo người
- **LED 2 theo hiện diện** — cảm biến mmWave LD2410 chỉ bật LED 2 trong khung giờ hằng ngày
- **Ghi đè tay, tự về Auto** — bật/tắt LED 2 bằng tay thì tạm rời Auto 5 phút
- **Khung giờ đặt ngay trên thiết bị** — bốn ô số, không cần helper trong Home Assistant; khung giờ được phép vắt qua nửa đêm
- **Giám sát môi trường** — nhiệt độ, độ ẩm, áp suất (BME280) và cảm biến mưa có vùng trễ
- **Vẫn chạy khi mất mạng** — nút bấm và điều khiển theo người chạy ngay trên thiết bị. Mất Home Assistant không bao giờ làm nó khởi động lại; mất WiFi thì sau 10 phút mới khởi động lại
- **Cấu hình chia module** — mỗi chức năng một tệp YAML

## Phần cứng

### Linh kiện

- **ESP32 WROOM-32** (`esp32dev`, flash 4 MB)
- **BME280** — nhiệt độ, độ ẩm, áp suất (I2C, địa chỉ `0x76`)
- **LD2410** — cảm biến hiện diện mmWave (UART, 256000 baud)
- **Cảm biến mưa** — mạch analog đọc qua ADC
- **2 dải LED 24V**, mỗi dải đóng cắt bằng một **module MOSFET AOD4184**
- **Mạch hạ áp 24V → 5V** cấp nguồn cho ESP32
- **2 nút** — nút nhấn cho LED 1 và nút chạm cho LED 2

Sơ đồ mạch của một kênh LED: [`so_do_esp32_led_24v_mosfet.pdf`](so_do_esp32_led_24v_mosfet.pdf).

### Bảng chân GPIO

| GPIO | Chức năng | Ghi chú |
| --- | --- | --- |
| GPIO12 | LED 1 (cực G MOSFET) | Chân strapping: tuyệt đối không gắn điện trở kéo lên, nếu không ESP32 không khởi động |
| GPIO13 | LED 2 (cực G MOSFET) | |
| GPIO14 | Button LED 1 | Nút nhấn nối GND, dùng điện trở kéo lên bên trong |
| GPIO27 | Button LED 2 | Nút chạm, đọc mức thấp khi chạm |
| GPIO16 | UART RX ← LD2410 TX | |
| GPIO17 | UART TX → LD2410 RX | |
| GPIO21 | I2C SDA (BME280) | |
| GPIO22 | I2C SCL (BME280) | |
| GPIO32 | Cảm biến mưa (ADC) | Điện áp tụt khi mặt cảm biến ướt |

## Bắt đầu nhanh

### 1. Cài ESPHome

```bash
pip install esphome
```

Cấu hình cần ESPHome **2026.7.0 trở lên**.

### 2. Tạo tệp secrets

```bash
cp secrets.template.yaml secrets.yaml
```

Điền `wifi_ssid`, `wifi_password` và `ota_password`. `secrets.yaml` đã nằm trong `.gitignore`.

### 3. Kiểm cấu hình rồi nạp

```bash
esphome config main.yaml   # chỉ kiểm cấu hình
esphome run main.yaml      # biên dịch và nạp: lần đầu qua USB, về sau qua OTA
```

Trên Windows có sẵn các script: `setup.bat`, `compile.bat`, `flash.bat` và `logs.bat`.
`flash.bat` và `logs.bat` trỏ tới `192.168.20.161`; đổi thành địa chỉ thiết bị của bạn.

### 4. Kiểm nút bấm một lần

Lúc không nhấn nút nào, `Button LED 1` và `Button LED 2` trong Home Assistant phải là **off**.
Nếu một nút đang là **on**, đổi `button1_inverted` / `button2_inverted` tương ứng trong
`main.yaml` thành `"false"` rồi nạp lại.

## Cấu hình

Tham số dùng chung nằm ở `substitutions` đầu tệp `main.yaml`:

| Tham số | Mặc định | Ý nghĩa |
| --- | --- | --- |
| `led2_manual_timeout` | `5min` | Một thao tác tay với LED 2 tạm rời Auto trong bao lâu |
| `ld2410_distance_interval` | `5s` | Khoảng cách ngắn nhất giữa hai lần gửi một khoảng cách LD2410 |
| `button1_inverted`, `button2_inverted` | `"true"` | Cực tính nút (`"true"` = chân đọc mức thấp khi nhấn) |
| `rain_on_below`, `rain_off_above` | `1.8`, `2.2` | Ngưỡng mưa tính bằng vôn (khoảng giữa là vùng trễ) |
| `timezone` | `Asia/Ho_Chi_Minh` | Múi giờ dùng cho khung giờ LED 2 |

Phần còn lại nằm ở module tương ứng:

| Muốn đổi | Sửa tệp |
| --- | --- |
| WiFi, OTA | `main.yaml` và `secrets.yaml` |
| BME280 và cảm biến mưa | `components/environment_sensors.yaml` |
| LD2410 và tần suất gửi | `components/motion_sensor.yaml` |
| Chân LED, nút bấm, logic LED 2 | `components/led_controls.yaml` |
| Khung giờ mặc định, nguồn giờ | `components/time_automation.yaml` |
| Thực thể chẩn đoán | `components/diagnostic.yaml` |

## Home Assistant

Thiết bị dùng API gốc của ESPHome và được tự phát hiện. Không cần tạo helper hay automation
nào bên Home Assistant.

| Thực thể | Loại | Công dụng |
| --- | --- | --- |
| `LED 1` | switch | Dải LED 1 |
| `LED 2` | switch | Dải LED 2; bật/tắt ở đây là ghi đè tay |
| `LED 2 Auto Mode` | switch | Cho phép LED 2 theo người |
| `LD2410 Enable` | switch | Cho phép cảm biến hiện diện điều khiển LED 2 (tắt thì vẫn đo và báo về) |
| `Start Hour`, `Start Minute`, `End Hour`, `End Minute` | number | Khung giờ Auto hằng ngày (mặc định 05:00–23:00) |
| `Presence Detection`, `Moving Target`, `Still Target` | binary_sensor | Hiện diện từ LD2410 |
| `Moving Distance`, `Still Distance`, `Detection Distance` | sensor | Khoảng cách LD2410 (cm), gửi khi đổi, tối đa 5 giây một lần |
| `Temp`, `Pressure`, `Humidity` | sensor | BME280, mỗi 60 giây |
| `Rain Sensor Value`, `Mưa?` | sensor, binary_sensor | Điện áp cảm biến mưa và trạng thái có mưa |
| `Button LED 1`, `Button LED 2` | binary_sensor | Nút bấm vật lý |
| `WiFi RSSI`, `RAM Free (KB)`, `WiFi IP`, `WiFi SSID`, `WiFi BSSID`, `WiFi MAC` | chẩn đoán | Sức khoẻ thiết bị |
| `Restart thiết bị` | button | Khởi động lại ESP32 |

**Tên thực thể là khoá định danh.** Home Assistant nhận diện mỗi thực thể theo `name:`, nên đổi
tên trong YAML sẽ tạo thực thể mới và bỏ rơi thực thể cũ trong dashboard, automation.

### LED 2 hoạt động thế nào

- **Auto**: khi `LED 2 Auto Mode` và `LD2410 Enable` cùng bật và đang trong khung giờ, LED 2 theo
  `Presence Detection`.
- **Vào khung giờ**: Auto tự bật. Nếu đang ghi đè tay thì chờ lượt ghi đè đó chạy hết.
  **Hết khung giờ**: Auto tự tắt, và nếu LED 2 đang sáng do Auto thì được tắt theo; đèn bạn bật
  tay thì để yên.
- **Ghi đè tay**: bật/tắt `LED 2` (từ Home Assistant hoặc chạm ngắn nút 2) làm Auto tắt 5 phút
  rồi tự bật lại. Giữ nút 0,8–5 giây để về Auto ngay.
- **Sau khi khởi động lại** trong khung giờ, Auto được bật lại ngay khi thiết bị có giờ. Khi chưa
  có giờ, cảm biến chưa điều khiển đèn.
- **Mất WiFi 10 phút** thì thiết bị khởi động lại, và cả hai đèn trở về trạng thái tắt.

Chi tiết hơn: [`docs/LED2_MANUAL_OVERRIDE_GUIDE.md`](docs/LED2_MANUAL_OVERRIDE_GUIDE.md).

## Cấu trúc dự án

```
esp32_led_temp_pressure/
├── main.yaml                      # Tham số chung, WiFi, OTA, danh sách module
├── components/
│   ├── common.yaml                # Bo mạch, logger, API, I2C, nút restart
│   ├── environment_sensors.yaml   # BME280, cảm biến mưa
│   ├── motion_sensor.yaml         # LD2410 và công tắc "LD2410 Enable"
│   ├── led_controls.yaml          # Công tắc LED, nút bấm, logic LED 2
│   ├── time_automation.yaml       # Nguồn giờ, khung giờ Auto
│   └── diagnostic.yaml            # Chẩn đoán WiFi và bộ nhớ
├── secrets.template.yaml          # Chép thành secrets.yaml rồi điền
├── docs/LED2_MANUAL_OVERRIDE_GUIDE.md
├── examples/README.md             # Vài đoạn cấu hình tối giản, chạy độc lập
├── setup.bat, compile.bat, flash.bat, logs.bat
├── so_do_esp32_led_24v_mosfet.pdf # Sơ đồ mạch
└── CHANGELOG.md
```

## Phát triển

- **Kiểm trước khi nạp**: `esphome config main.yaml`. CI chạy đúng lệnh này ở mỗi lần push, dùng
  `secrets.template.yaml` thay cho secrets thật.
- **Đọc log**: `esphome logs main.yaml --device <ip>`. Logger chạy ở mức `INFO`; đổi thành
  `DEBUG` trong `components/common.yaml` để xem cấu hình từng linh kiện lúc khởi động.
- **Tuỳ chọn khởi động, bật khi cần**: `components/common.yaml` có sẵn hai tuỳ chọn `esp32` đang
  để dạng chú thích (`minimum_chip_revision`, `sram1_as_iram`) do chính thiết bị gợi ý trong log
  khởi động. Chúng thay đổi cách firmware khởi động, nên chỉ bật khi đang cầm bo mạch và có cáp USB.
- **Biên dịch trên Windows**: ESPHome từ 2026.10 biên dịch bằng bộ công cụ ESP-IDF riêng. Bộ này
  cần Windows bật long path, hoặc đặt `ESPHOME_ESP_IDF_PREFIX` tới một thư mục ngắn như
  `C:\ESPHome\idf`, và trình cài của nó từ chối chạy trong Git Bash; hãy dùng `cmd.exe` hoặc
  PowerShell (các script `.bat` vốn đã chạy như vậy). `esphome config` không bị ảnh hưởng.
- **Lịch sử thay đổi**: xem [`CHANGELOG.md`](CHANGELOG.md).

<!-- support:start -->
## Ủng hộ dự án

<p align="center">
  <img src="https://raw.githubusercontent.com/ngoviet/.github/main/assets/support/banner-v2.svg" width="560" alt="Built and maintained by one person in Việt Nam">
</p>

<p align="center">Một người Việt tự xây dựng và duy trì, miễn phí và mã nguồn mở. Sự ủng hộ của bạn giúp hỗ trợ thêm thiết bị, sửa lỗi nhanh hơn và ra bản mới đều đặn.</p>

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

<p align="center"><b>Ví tiền mã hoá, chỉ gửi qua mạng BNB Smart Chain (BEP20):</b><br><code>0xcbf0402b232cb24b4d998f09a4884f87b5f74750</code></p>

<p align="center">🇻🇳 VietQR: quét bằng app ngân hàng bất kỳ, nội dung <code>Ung ho esp32-smart-led-control</code>. Cảm ơn bạn đã giúp dự án tiếp tục phát triển!</p>
<!-- support:end -->

## Giấy phép

[MIT](LICENSE) © Ngô Đức Việt.
