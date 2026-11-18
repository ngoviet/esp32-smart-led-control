# Hướng dẫn LED 2: chế độ Auto và ghi đè tay

LED 2 bình thường tự bật/tắt theo người. Bạn vẫn bật/tắt bằng tay được bất cứ lúc nào; khi đó
đèn tạm rời chế độ Auto rồi tự quay về, để không ai phải nhớ trả lại.

## Ba thứ quyết định LED 2

| Thực thể | Vai trò |
| --- | --- |
| `LED 2 Auto Mode` | Bật: đèn theo cảm biến hiện diện. Tắt: cảm biến không đổi đèn nữa; đèn đang sáng do Auto vẫn được tắt khi hết khung giờ. |
| `LD2410 Enable` | Bật: cảm biến LD2410 được phép điều khiển đèn. Tắt: cảm biến vẫn đo và báo về Home Assistant nhưng không đụng tới đèn. |
| `Start Hour`, `Start Minute`, `End Hour`, `End Minute` | Khung giờ Auto hằng ngày, mặc định 05:00–23:00. End nhỏ hơn Start nghĩa là khung giờ vắt qua nửa đêm (ví dụ 18:00–06:00). |

LED 2 chỉ tự chạy theo người khi **cả ba cùng thuận**: Auto bật, LD2410 bật và đang trong khung giờ.

## Một ngày của LED 2

| Lúc | Điều xảy ra |
| --- | --- |
| Vào khung giờ (05:00) | `LED 2 Auto Mode` tự bật, đèn đặt lại theo cảm biến. Nếu bạn vừa bật/tắt tay chưa đủ 5 phút, việc này chờ hết 5 phút đó. |
| Trong khung giờ | Có người thì sáng, hết người thì tắt. |
| Hết khung giờ (23:00) | `LED 2 Auto Mode` tự tắt. Đèn đang sáng do Auto thì được tắt theo; đèn bạn bật tay thì để yên. |
| Ngoài khung giờ | Cảm biến không điều khiển đèn. Bạn vẫn bật/tắt tay được. |

## Ghi đè tay

Bật hoặc tắt `LED 2` bằng một trong hai cách:

- **Home Assistant**: gạt công tắc `LED 2`.
- **Nút chạm (GPIO27)**: chạm ngắn (dưới 0,8 giây).

Ngay lúc đó `LED 2 Auto Mode` tắt và bắt đầu đếm 5 phút. Mỗi lần bạn bật/tắt tay nữa, đồng hồ đếm
lại từ đầu. Hết 5 phút, Auto tự bật lại và đèn được đặt lại theo cảm biến.

Muốn về Auto ngay, không chờ 5 phút:

- bật `LED 2 Auto Mode` trong Home Assistant, hoặc
- giữ nút chạm 0,8–5 giây.

Muốn tắt hẳn việc đèn theo người (ví dụ khi có khách ngủ lại): tắt `LD2410 Enable`. Công tắc này
không tự bật lại.

## Vài tình huống hay gặp

**Bật tay ngoài khung giờ rồi quên.** Sau 5 phút `LED 2 Auto Mode` bật lại nhưng vì đang ngoài
khung giờ nên đèn vẫn sáng cho tới khi bạn tắt, hoặc tới giờ Start kế tiếp: lúc đó đèn được đặt
lại theo cảm biến. Đây là chủ ý: ban đêm không tự tắt đèn bạn vừa bật.

**Tắt `LD2410 Enable` khi đèn đang sáng.** Đèn giữ nguyên. Nếu đèn đó do Auto bật thì đến giờ End
nó vẫn được tắt; nếu bạn bật tay thì nó sáng tới khi bạn tắt.

**Mất WiFi lâu.** Mất Home Assistant không ảnh hưởng gì tới đèn. Mất WiFi liên tục 10 phút thì
thiết bị tự khởi động lại, và cả hai đèn trở về trạng thái tắt.

**Đèn không sáng dù có người.** Kiểm lần lượt: `LED 2 Auto Mode` có bật không, `LD2410 Enable` có
bật không, giờ hiện tại có nằm trong khung Start–End không, `Presence Detection` có báo `on` không.

**Chạm nút không ăn.** Xem thực thể `Button LED 2` trong Home Assistant: lúc không chạm phải là
`off`, lúc chạm phải lên `on`. Nếu ngược lại, đổi `button2_inverted` trong `main.yaml` thành
`"false"` rồi nạp lại.

**Thiết bị vừa khởi động lại.** Nếu đang trong khung giờ, Auto được bật lại ngay khi thiết bị lấy
được giờ (từ Home Assistant hoặc SNTP). Khi chưa có giờ, cảm biến chưa điều khiển đèn.

## Thông số chỉnh được

| Thông số | Ở đâu | Mặc định |
| --- | --- | --- |
| Thời gian ghi đè tay | `led2_manual_timeout` trong `main.yaml` | `5min` |
| Khung giờ Auto | bốn ô số trong Home Assistant (lưu trên thiết bị) | 05:00–23:00 |
| Độ dài chạm ngắn / giữ lâu | `on_click` của `button2` trong `components/led_controls.yaml` | 80–799 ms / 0,8–5 s |
| Nhịp gửi khoảng cách LD2410 (thưa nhất) | `ld2410_distance_interval` trong `main.yaml` | `5s` |

## So với LED 1

| | LED 1 | LED 2 |
| --- | --- | --- |
| Bật/tắt tay | Luôn được, giữ nguyên trạng thái | Được, tự về Auto sau 5 phút |
| Theo người | Không | Có, trong khung giờ |
| Nút vật lý | Nhấn là đảo trạng thái | Chạm ngắn đảo trạng thái, giữ lâu về Auto |
