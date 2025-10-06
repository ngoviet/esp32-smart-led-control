# 💡 HƯỚNG DẪN SỬ DỤNG LED2 - MANUAL OVERRIDE VỚI AUTO RETURN

## 🎯 Tổng quan tính năng

LED2 được thiết kế với **Manual Override thông minh**: có thể điều khiển thủ công tạm thời, nhưng tự động quay về chế độ tự động để tiết kiệm năng lượng và đảm bảo hoạt động ổn định.

---

## 🔧 Chế độ hoạt động

### 1. 🤖 **Chế độ Tự động** (Mặc định)
- LED2 bật/tắt theo cảm biến chuyển động LD2410
- Hoạt động theo thời gian đã cài đặt (6:00 - 22:00)
- Tiết kiệm năng lượng tự động

### 2. 🖐️ **Chế độ Manual Override**
- Điều khiển trực tiếp qua Home Assistant
- Tạm thời vô hiệu hóa chế độ tự động
- **Tự động quay về auto sau 5 phút không hoạt động**

---

## 🕹️ Cách điều khiển

### 📱 **Qua Home Assistant**

1. **Bật/Tắt thủ công LED2:**
   - Vào Home Assistant → Thiết bị ESP32
   - Tìm switch "LED 2" 
   - Bấm ON/OFF → LED2 chuyển sang manual mode

2. **Kiểm tra trạng thái Auto Mode:**
   - Switch "LED 2 Auto Mode" hiển thị trạng thái hiện tại
   - ON = Chế độ tự động
   - OFF = Đang trong manual override

3. **Quay về chế độ tự động:**
   - Bật switch "LED 2 Auto Mode"
   - Hoặc đợi 5 phút sẽ tự động quay về

### 🔲 **Qua nút vật lý (GPIO27)**

1. **Bấm ngắn (80ms - 700ms):**
   - Toggle LED2 ON/OFF
   - Chuyển sang manual mode

2. **Bấm lâu (800ms - 5s):**
   - **Force về chế độ tự động** ngay lập tức
   - Bỏ qua timeout 5 phút

---

## ⏱️ Logic thời gian

### 🔄 **Auto Return Mechanism**
```
Manual Override → 5 phút timeout → Tự động về Auto Mode
```

### 📊 **Timeline hoạt động:**
- **0:00**: Bấm manual override → LED2 manual mode
- **4:59**: Vẫn trong manual mode
- **5:00**: ⚡ Tự động chuyển về auto mode
- **5:01+**: LED2 hoạt động theo cảm biến chuyển động

---

## 🎯 Các trường hợp sử dụng

### ✅ **Khi nào dùng Manual Override:**
- 🛠️ **Bảo trì**: Cần ánh sáng ổn định để làm việc
- 📚 **Đọc sách**: Cần đèn sáng liên tục không bị tắt
- 🎮 **Chơi game**: Tránh đèn nhấp nháy khi ngồi yên
- 🍽️ **Ăn uống**: Cần ánh sáng ổn định trong bữa ăn

### ✅ **Auto Return bảo vệ:**
- 💡 **Tiết kiệm điện**: Tránh quên tắt đèn
- 🔋 **Bảo vệ thiết bị**: Không để LED hoạt động liên tục quá lâu
- 🤖 **Tự động hóa**: Quay về chế độ thông minh khi không cần thiết

---

## 🚨 Xử lý sự cố

### ❓ **LED2 không phản hồi manual control:**
1. Kiểm tra "LED 2 Auto Mode" có đang ON không
2. Thử bấm lâu nút GPIO27 để force auto mode
3. Sau đó thử manual override lại

### ❓ **LED2 không tự động quay về:**
1. Kiểm tra log ESP32 có thông báo "Manual timeout reached"
2. Restart thiết bị qua Home Assistant
3. Kiểm tra global variables có được reset không

### ❓ **Nút vật lý không hoạt động:**
1. Kiểm tra connection GPIO27
2. Thử cả bấm ngắn và bấm lâu
3. Xem log để kiểm tra button events

---

## 🔍 Debug & Monitoring

### 📊 **Theo dõi trạng thái:**
- **LED 2**: Trạng thái hiện tại của LED (ON/OFF)
- **LED 2 Auto Mode**: Chế độ tự động có được bật không
- **System Health**: Tổng quan tình trạng hệ thống

### 📝 **Log messages để theo dõi:**
```
LED2: Manual timeout reached, returning to auto mode
```

### 🔧 **Tham số có thể điều chỉnh:**
- **Timeout**: Hiện tại 5 phút (300000ms)
- **Check interval**: 30 giây
- **Button timing**: 80ms-700ms (ngắn), 800ms-5s (dài)

---

## 💡 Mẹo sử dụng

### 🎯 **Tối ưu hóa:**
- Dùng manual override chỉ khi thực sự cần thiết
- Nhớ bấm lâu nút để về auto mode khi xong việc
- Theo dõi "LED 2 Auto Mode" để biết trạng thái

### 🔄 **Workflow khuyến nghị:**
1. Bình thường → Để auto mode
2. Cần điều khiển → Manual override via HA
3. Xong việc → Bấm lâu nút hoặc đợi 5 phút
4. Quay về → Auto mode cho hoạt động bình thường

---

## ⚖️ **So sánh với LED1**

| Tính năng | LED1 | LED2 |
|-----------|------|------|
| **Manual Control** | ✅ Luôn có sẵn | ✅ Có timeout |
| **Auto Mode** | ❌ Không có | ✅ Có |
| **Motion Detection** | ❌ Không | ✅ Có |
| **Time Control** | ❌ Không | ✅ 6:00-22:00 |
| **Button Control** | ✅ Toggle đơn giản | ✅ Multi-mode |
| **Energy Saving** | ❌ Manual only | ✅ Auto return |

---

🎉 **Tận hưởng LED2 thông minh với sự cân bằng hoàn hảo giữa điều khiển thủ công và tự động hóa!** 🎉