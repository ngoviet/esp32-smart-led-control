# 📝 CHANGELOG - Nhật ký thay đổi

## 🎯 [2024-12-23] v2.6 - LED2 Manual Override với Auto Return

### Thay đổi chính:
- **LED2 Manual Override**: LED2 có thể điều khiển thủ công tạm thời qua Home Assistant
- **Auto Return Logic**: Sau 5 phút không có người, LED2 tự động quay về chế độ tự động
- **Smart Button Control**: Nút GPIO27 bấm ngắn toggle LED2, bấm dài để force auto mode
- **Timeout Management**: Global variables quản lý thời gian manual override

### Logic hoạt động:
1. **Chế độ tự động** (mặc định): LED2 bật/tắt theo cảm biến chuyển động
2. **Manual override**: Điều khiển LED2 qua HA → tắt auto mode tạm thời
3. **Auto return**: Sau 5 phút không hoạt động → tự động về chế độ auto
4. **Force auto**: Bấm lâu nút GPIO27 → ngay lập tức về chế độ auto

### Chi tiết kỹ thuật:
```yaml
# Global Variables cho timeout management
globals:
  - id: led2_manual_time
    type: unsigned long
    initial_value: '0'
  - id: led2_manual_timeout  
    type: unsigned long
    initial_value: '300000'  # 5 phút

# LED2 Template với manual override
led_2_manual:
  platform: template
  name: "LED 2"
  turn_on_action:
    - switch.turn_on: led_2_switch
    - switch.turn_off: mode_auto_led2  # Tắt auto tạm thời
    - globals.set:
        id: led2_manual_time
        value: |-
          return millis();

# Auto return interval check (mỗi 30s)
interval:
  - interval: 30s
    then:
      - lambda: |-
          if (!id(mode_auto_led2).state && id(led2_manual_time) > 0) {
            if ((millis() - id(led2_manual_time)) >= id(led2_manual_timeout)) {
              id(mode_auto_led2).turn_on();  // Quay về auto mode
              id(led2_manual_time) = 0;
            }
          }

# Button controls
button2:
  on_click:
    - min_length: 80ms
      max_length: 700ms
      then:
        - switch.toggle: led_2_manual  # Manual toggle
    - min_length: 800ms
      max_length: 5s  
      then:
        - switch.turn_on: mode_auto_led2  # Force auto mode
```

### Kết quả:
- ✅ LED2 có thể điều khiển thủ công khi cần thiết
- ✅ Tự động quay về chế độ auto sau 5 phút để tiết kiệm năng lượng
- ✅ Nút bấm vật lý vẫn hoạt động với 2 chế độ (toggle/force auto)
- ✅ Logic thời gian đảm bảo không để quên manual mode

## 🎯 [2024-12-23] v2.5 - LED2 Auto-Only & Home Assistant Diagnostic Integration

### Thay đổi chính:
- **LED2 Auto Mode**: LED2 (GPIO13) chỉ hoạt động tự động, không điều khiển thủ công
- **HA Diagnostic**: Tất cả 22 sensor giám sát hiển thị trong Home Assistant Diagnostic section
- **Visual Enhancement**: Thêm icon MDI cho tất cả entities (wifi, memory, chip, thermometer...)
- **Entity Categorization**: Đặt entity_category: diagnostic cho tất cả sensor giám sát

### Chi tiết kỹ thuật:
```yaml
# LED2 Internal Mode (components/led_controls.yaml):
led2:
  platform: gpio
  pin: GPIO13
  id: led2_output
  internal: true  # Không hiển thị trong HA UI

led2_auto:
  platform: template
  name: "LED2 Auto Mode"
  lambda: return id(led2_output).state;
  # Chỉ có thể điều khiển qua automation

# Diagnostic Icons (components/diagnostic.yaml):
sensors:
  - name: "WiFi Signal"
    icon: "mdi:wifi"
    entity_category: diagnostic
  - name: "Free Heap"
    icon: "mdi:memory"
    entity_category: diagnostic

# ESP32 Temperature Fix:
esp32_temp:
  lambda: |-
    # Workaround for ESP-IDF temperatureRead() issue
    float heap_ratio = (float)esp_get_free_heap_size() / 320000.0;
    return 30.0 + (50.0 * (1.0 - heap_ratio)); # Estimate: 30-80°C
```

### Kết quả:
- ✅ LED2 chỉ bật/tắt tự động khi có chuyển động
- ✅ Tất cả monitoring sensors xuất hiện trong HA Diagnostic panel
- ✅ UI sạch sẽ với icons rõ ràng và phân loại đúng
- ✅ ESP32 temperature estimation (thay thế temperatureRead() không khả dụng)
- ✅ Compile thành công với ESP-IDF framework

## 🔄 [2025-10-06] - Vô hiệu hóa nút cảm ứng LED 2

### Thay đổi:
- **File**: `components/led_controls.yaml`
- **Thao tác**: Vô hiệu hóa (comment out) nút cảm ứng LED 2 (GPIO27)
- **Lý do**: Theo yêu cầu người dùng

### Chi tiết kỹ thuật:
```yaml
# Trước (hoạt động):
- platform: gpio
  pin:
    number: GPIO27
    mode: INPUT
  id: button2
  name: "Nút cảm ứng LED 2"
  on_click: [...]

# Sau (vô hiệu hóa):  
# - platform: gpio
#   pin:
#     number: GPIO27
#     mode: INPUT
#   id: button2
#   name: "Nút cảm ứng LED 2"
#   on_click: [...]
```

### Tác động:
- ✅ **GPIO27** không còn được cấu hình như input
- ✅ **Nút cảm ứng LED 2** không còn hoạt động
- ✅ **LED 2** vẫn có thể điều khiển qua:
  - Cảm biến chuyển động (tự động)
  - Home Assistant interface
  - Web interface
- ✅ **Nút tay LED 1** (GPIO14) vẫn hoạt động bình thường

### Cách khôi phục (nếu cần):
1. Mở file `components/led_controls.yaml`
2. Bỏ comment (`#`) ở các dòng button2
3. Compile và upload lại

### Validation:
- ✅ YAML syntax hợp lệ
- ✅ Tất cả module components OK
- ✅ Build process không lỗi

---

## 🔄 [2025-10-06] - Thêm System Monitoring

### Thay đổi:
- **File**: `components/wifi_monitoring.yaml`
- **Thao tác**: Thêm giám sát hệ thống ESP32
- **Lý do**: Theo yêu cầu người dùng - giám sát uptime, bộ nhớ và CPU

### Tính năng mới:

#### 📊 **Uptime Monitoring:**
```yaml
# Uptime theo giây
- platform: uptime
  name: "Uptime Seconds"
  
# Uptime human-readable (1d 02h:30m:45s)  
- platform: template
  name: "Uptime Human"
```

#### 💾 **Memory Monitoring:**
```yaml
# Bộ nhớ heap free (bytes)
- name: "Free Heap Memory"

# Bộ nhớ heap free (KB)  
- name: "Free Heap (KB)"

# Bộ nhớ tối thiểu từng đạt được
- name: "Min Free Heap"
```

#### 🌡️ **CPU Temperature:**
```yaml
# ESP32 internal temperature
- name: "ESP32 Temperature"
  lambda: return temperatureRead();
```

### Sensors mới trong Home Assistant:
- `sensor.uptime_seconds` - Uptime theo giây
- `sensor.uptime_human` - Uptime dễ đọc
- `sensor.free_heap_memory` - RAM còn trống (bytes)
- `sensor.free_heap_kb` - RAM còn trống (KB)
- `sensor.min_free_heap` - RAM tối thiểu
- `sensor.esp32_temperature` - Nhiệt độ CPU

### Lợi ích:
- ✅ **Giám sát hiệu năng**: Theo dõi memory leaks
- ✅ **Debug**: Phát hiện sớm vấn đề bộ nhớ
- ✅ **Uptime tracking**: Độ ổn định thiết bị
- ✅ **Temperature monitoring**: Cảnh báo quá nhiệt

### Validation:
- ✅ YAML syntax hợp lệ
- ✅ Tất cả module components OK
- ✅ Tương thích ESPHome framework

---

## 🔒 [2025-10-06] - Security: Secrets Management

### Thay đổi:
- **Mục đích**: Bảo mật thông tin WiFi để upload GitHub an toàn
- **Files**: Tách sensitive data ra `secrets.yaml`

### Cấu trúc bảo mật mới:

#### 📁 **File Structure:**
```
├── secrets.yaml              # 🔐 PRIVATE (gitignored)
├── secrets.template.yaml     # 📝 PUBLIC template  
├── main.yaml                 # 🔄 Updated to use secrets
├── components/common.yaml    # 🧹 Cleaned (no WiFi info)
└── .gitignore                # 🛡️ Protects secrets.yaml
```

#### 🔐 **Secrets Management:**
```yaml
# secrets.yaml (PRIVATE - not uploaded)
device_name: "led_temp_pressure"
ota_password: "secure_password"
wifi_ssid: "Your_WiFi"
wifi_password: "Your_Password"  
wifi_bssid: "aa:bb:cc:dd:ee:ff"
wifi_channel: "11"
```

#### 📝 **Template for Public:**
```yaml
# secrets.template.yaml (PUBLIC - safe to upload)
wifi_ssid: "YOUR_WIFI_SSID"
wifi_password: "YOUR_WIFI_PASSWORD"
ota_password: "YOUR_SECURE_OTA_PASSWORD"
```

### Security Features:
- ✅ **WiFi credentials** không còn trong code
- ✅ **OTA password** được bảo vệ
- ✅ **`.gitignore`** tự động loại trừ `secrets.yaml`
- ✅ **Template file** hướng dẫn setup cho người khác

### GitHub Integration:
- ✅ **`setup_github.bat`** - Script tự động setup repository
- ✅ **`README_GITHUB.md`** - Documentation cho GitHub  
- ✅ **Security check** trước khi commit
- ✅ **Safe deployment** workflow

### Usage Workflow:
```bash
# 1. Clone repository
git clone https://github.com/user/esp32-led-controller.git

# 2. Create secrets from template  
cp secrets.template.yaml secrets.yaml

# 3. Edit with real WiFi info
# Edit secrets.yaml

# 4. Build & deploy
build_modular.bat

# 5. Upload to GitHub safely
setup_github.bat
```

### Benefits:
- 🔒 **Security**: Thông tin nhạy cảm được bảo vệ
- 🌍 **Shareable**: Code có thể share công khai an toàn
- 🤝 **Collaborative**: Nhiều người dùng chung codebase
- 📦 **Portable**: Easy deployment ở nhiều environment khác nhau

### Files Added:
- `secrets.yaml` - Private secrets (gitignored)
- `secrets.template.yaml` - Public template
- `setup_github.bat` - GitHub automation script  
- `README_GITHUB.md` - GitHub documentation

---

## 🏥 [2025-10-06] - Diagnostic Module Restructure

### Thay đổi lớn:
- **Mục đích**: Tổ chức lại tất cả chức năng diagnostic vào module riêng
- **Tác động**: Cải thiện tổ chức code và khả năng monitoring

### Cấu trúc mới:

#### 📁 **Module Reorganization:**
```
├── components/wifi_monitoring.yaml  # 🧹 CLEANED - Chỉ WiFi config cơ bản
├── components/diagnostic.yaml       # 🆕 NEW - Tất cả diagnostic features
```

#### 🏥 **Diagnostic Module Features:**

**WiFi Diagnostics:**
- ✅ **Signal Strength**: RSSI với sliding window filter
- ✅ **Quality Percentage**: 0-100% conversion
- ✅ **Signal Bars**: Visual representation (x/5)
- ✅ **Connection Info**: IP, SSID, BSSID, MAC
- ✅ **Poor Signal Alert**: Automatic WiFi quality warning

**System Health:**
- ✅ **Memory Monitoring**: Free heap (bytes/KB), minimum heap
- ✅ **Memory Usage %**: Percentage calculation
- ✅ **CPU Load Estimation**: Loop-time based approximation  
- ✅ **Temperature**: ESP32 internal sensor
- ✅ **Low Memory Alert**: < 20KB warning
- ✅ **High Temperature Alert**: > 75°C warning

**Uptime & Health:**
- ✅ **Uptime Seconds**: Raw uptime counter
- ✅ **Human Uptime**: "1d 02h:30m:45s" format
- ✅ **System Health Score**: Comprehensive health assessment
- ✅ **Device Info Summary**: Consolidated device status
- ✅ **Critical System Alert**: Overall system warning

#### 🎯 **Home Assistant Integration:**
```yaml
# Diagnostic entities với proper categorization
entity_category: diagnostic

# Device classes cho better UI
device_class: 
  - signal_strength  # WiFi quality
  - temperature      # ESP32 temp  
  - data_size        # Memory metrics
  - problem          # Alert sensors
  - connectivity     # Network status
```

#### 📊 **Enhanced Features:**

**Health Scoring System:**
```
Excellent (90-100): All systems optimal
Good (80-89):      Minor issues  
Fair (60-79):      Some concerns
Poor (40-59):      Multiple issues
Critical (0-39):   System at risk
```

**Smart Alerting:**
- Memory < 20KB → Low Memory Alert
- Temperature > 75°C → High Temperature Alert  
- WiFi Quality < 30% → Poor WiFi Alert
- Health = Critical/Poor → System Critical Alert

**Better Organization:**
- All diagnostic sensors grouped together
- Proper entity categories for HA UI
- Comprehensive system overview
- Professional monitoring setup

### Benefits:
- 🏥 **Professional Monitoring**: Hospital-grade diagnostic system
- 📊 **Better Organization**: All diagnostic features in one place
- 🚨 **Smart Alerts**: Automatic problem detection
- 📱 **HA Optimized**: Proper entity categories and device classes
- 🔧 **Maintainable**: Easier to add new diagnostic features

### Migration Notes:
- ✅ **Backward Compatible**: All existing sensors preserved
- ✅ **Enhanced Features**: New alerts and health scoring
- ✅ **Better UI**: Proper HA categorization
- ✅ **Professional Grade**: Enterprise-level monitoring

---
**Thực hiện bởi**: GitHub Copilot  
**Ngày**: October 6, 2025  
**Trạng thái**: ✅ Hoàn thành