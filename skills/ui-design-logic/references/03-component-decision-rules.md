# 03 — Component Decision Rules: tra bảng, đừng tuỳ hứng

Mỗi loại nội dung có đúng một component phù hợp. Chọn sai không "xấu ngay"
nhưng tích tụ thành cảm giác "app này rối". Tra bảng trước khi đặt component.

## 1. Hiển thị tập hợp dữ liệu: table / list / card / map

| Dữ liệu | Component | Vì sao |
|---|---|---|
| Nhiều bản ghi, nhiều thuộc tính cần SO SÁNH/quét (đơn hàng, giao dịch) | **Table** | Mắt so sánh theo cột. Desktop ≥ 5 cột ok; mobile table → biến thành list card (xem 05) |
| Nhiều bản ghi, mỗi cái chỉ cần 2–3 thuộc tính, đọc tuần tự (thông báo, tin) | **List** | Nhẹ hơn table, không cần header |
| Ít bản ghi (≤ 12/trang), hình ảnh là thông tin chính (sản phẩm, dự án) | **Card grid** | Ảnh cần diện tích; > 20 card chữ là table trá hình — đổi sang table |
| Thuộc tính quan trọng nhất là VỊ TRÍ địa lý | **Map** + list đồng bộ | Map luôn kèm list/panel — map một mình không quét nhanh được |
| 2–5 con số tổng quan | **Metric card** | 1 số chính + ngữ cảnh của chính nó (`/tổng`, `%`, delta ▲▼) — nén theo khe chuẩn ở 02 mục 5. Hai chỉ số KHÔNG liên quan thì tách card |

## 2. Cửa sổ con: modal / drawer / popover / page — cây quyết định

```
Nội dung là nhiệm vụ độc lập, cần URL/share/Back?            → PAGE riêng
Form/detail liên quan ngữ cảnh hiện tại, cần đối chiếu nền? → DRAWER (sheet trượt phải; mobile: bottom sheet)
Bắt user QUYẾT ĐỊNH trước khi tiếp tục (xác nhận xoá)?       → MODAL/DIALOG, ≤ 2 nút
Thông tin phụ gắn 1 phần tử (giải thích, mini menu)?         → POPOVER/TOOLTIP
Báo kết quả hành động, không cần phản hồi?                   → TOAST, tự tắt 4s
```

Quy tắc cứng cho mọi loại:
- Modal CHỈ cho quyết định chặn (blocking). Form sửa dữ liệu → drawer (modal che mất ngữ cảnh user đang cần đối chiếu)
- Modal: 1 câu hỏi rõ, nút hành động đặt tên theo hành động ("Xoá đơn hàng" không phải "OK"), nút huỷ luôn bên trái nút hành động
- KHÔNG modal đè modal, không drawer đè drawer. Cần tầng 2 = nội dung đó đáng là page
- Mọi overlay đóng được bằng: nút X + Esc + click nền (trừ form dở dang → hỏi "Huỷ thay đổi?")
- Hành động phá huỷ (xoá, rời trang mất dữ liệu) bắt buộc confirm; hành động thuận nghịch KHÔNG confirm — dùng toast + Undo

## 3. Nhãn nhỏ: badge / tag / pill / dot

| Component | Dùng cho | Quy tắc |
|---|---|---|
| **Badge** (nền màu semantic) | TRẠNG THÁI hệ thống: Đang xử lý, Hoàn thành, Lỗi | ≤ 2 từ. Cùng 1 object: tập trạng thái cố định, mỗi trạng thái 1 màu cố định toàn app. Tối đa 1 badge trạng thái/hàng |
| **Tag** (nền neutral nhạt) | PHÂN LOẠI gắn nhiều cái: chủ đề, kỹ năng | Hiện ≤ 3, còn lại "+N" |
| **Dot** (chấm 8px + text) | Trạng thái trong ngữ cảnh chật (table dày, sidebar) | Thay badge khi badge làm hàng cao lên |
| **Count badge** (số trên icon) | Số việc chờ xử lý | > 99 hiện "99+". Số 0 thì ẨN badge |

Badge KHÔNG dùng để: nhấn mạnh text thường, làm button (badge không bấm được), chứa câu.
Quá 30% số hàng có badge đỏ/vàng = badge mất nghĩa cảnh báo → xét lại ngưỡng.

## 4. Text & title — nguồn "lệch lệch khó tả" số một

**Title (mọi cấp):**
- Cùng cấp = cùng dạng ngữ pháp. Menu toàn danh từ ("Đơn hàng, Khách, Báo cáo") hoặc page action toàn động từ — KHÔNG trộn "Đơn hàng / Quản lý khách / Xem báo cáo"
- Luôn 1 dòng. Dài quá → truncate "..." + tooltip full text, KHÔNG xuống dòng (1 title 2 dòng phá nhịp cả list)
- **Từ khoá phân biệt đứng ĐẦU** title/link/label — mắt user chỉ fixate ~2 từ đầu (11 ký tự đầu
  mang gần hết information scent — NN/g). "Báo cáo doanh thu Q2" chứ không "Q2 — bản báo cáo về doanh thu"
- Kỷ luật truncate: cắt SAU từ khoá phân biệt (model, cỡ, biến thể) — truncate mà mất từ phân biệt
  giữa các item trong list thì tệ ngang không có title (Baymard: 55% site cắt sai). Tag: max-width 200px rồi ellipsis
- Page title ≤ 35 ký tự; card/section title ≤ 25; menu item ≤ 15
- Sentence case ("Báo cáo doanh thu"). Không Title Case, không VIẾT HOA (trừ viết tắt: SKU, VAT)
- Không chấm câu cuối title. Title không chứa giá trị động (đưa số vào metric, đừng vào title)

**Body & label:**
- Label form: danh từ ngắn, không dấu hai chấm, không "Vui lòng nhập..."
- Placeholder là VÍ DỤ ("vd: 0901 234 567"), không lặp lại label, không chứa hướng dẫn quan trọng (gõ là mất)
- Lỗi validate: nói cách sửa ("Số điện thoại cần 10 chữ số") không nói lỗi suông ("Không hợp lệ")
- Empty state: 1 dòng lý do + 1 nút hành động. Không chỉ "Không có dữ liệu"

**Số & ký tự:**
- Format locale nhất quán toàn app: vi-VN "2.450.000 ₫", ngày "11/06/2026" hoặc tương đối "3 giờ trước" — chọn 1 kiểu/ngữ cảnh, dùng mọi nơi
- Số lớn trong metric: rút gọn "2,4M" kèm tooltip số đầy đủ. Trong table: số đầy đủ căn phải
- Dùng "–" (en dash) cho khoảng, "—" cho trống dữ liệu trong table (không để ô trắng — user không biết là rỗng hay lỗi load)

## 5. Button

- 1 màn hình 1 primary (filled accent). Hành động phụ: outline. Hành động nguy hiểm: đỏ + confirm. Còn lại: ghost/menu
- Tên button = động từ + đối tượng ("Tạo đơn", "Xuất Excel"). Cấm "Submit", "OK", "Có/Không"
- Icon-only button bắt buộc tooltip. 1 hàng ≤ 3 button, thứ 4+ vào ⋯
- Trạng thái loading: spinner TRONG button + disable, giữ nguyên width (đừng cho button nhảy size)
