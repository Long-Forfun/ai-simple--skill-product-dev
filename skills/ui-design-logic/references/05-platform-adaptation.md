# 05 — Platform Adaptation: 3 thiết bị = 3 design con, không phải 1 design bóp nhỏ

"Responsive" kiểu co giãn cho vừa là tư duy sai. Desktop, tablet, mobile khác nhau về
**công cụ trỏ (chuột vs ngón tay), khoảng cách mắt, tư thế dùng, và thời lượng phiên** —
nên cùng một screen map nhưng mỗi thiết bị là một bản thiết kế riêng, quyết định riêng.

## 1. Breakpoint & tư duy theo thiết bị

| | Mobile < 768px | Tablet 768–1024px | Desktop > 1024px |
|---|---|---|---|
| Trỏ | Ngón tay (to, không hover) | Ngón tay + đôi khi bàn phím | Chuột (chính xác, có hover) |
| Phiên dùng | Ngắn, 1 việc, 1 tay | Trung bình | Dài, đa nhiệm |
| Mật độ | Bằng 1/2 desktop | Trung gian | Cao nhất |
| Thiết kế cho | Hành động nhanh + xem | Xem + nhập vừa | Làm việc thật, nhập liệu nặng |

Khai báo trong DESIGN-SPEC app là **desktop-first** (công cụ nghiệp vụ) hay **mobile-first**
(app người dùng cuối) — thiết bị chính được thiết kế đầy đủ trước, thiết bị kia là design con
có chủ đích, không phải hệ quả của CSS.

## 2. Bảng biến đổi component giữa 3 design con

| Desktop | Tablet | Mobile |
|---|---|---|
| Sidebar đầy đủ (icon + label) | Sidebar thu rail (icon, tooltip) | Bottom tabs ≤ 5 (job chính) + tab "Menu" |
| Table đầy đủ cột | Table ẩn cột phụ (ưu tiên trong spec) | List card: mỗi hàng thành card 2–3 dòng (title + 2 thuộc tính + badge). KHÔNG scroll ngang table |
| Drawer phải 480px | Drawer phải full-height | Bottom sheet (kéo lên), không drawer ngang |
| Modal giữa màn hình | Modal | Modal nhỏ giữ nguyên; modal form → full-screen page có Back |
| Hover hiện action phụ trên hàng | Action hiện sẵn | Menu ⋯ mỗi card, hoặc swipe action |
| Metric 4 cột | 2×2 | Cuộn ngang snap HOẶC 2×2 — số 1 to nhất, không 4 cái bằng nhau |
| Form 2 cột được phép | 1 cột | LUÔN 1 cột |
| Toolbar đầy: search + filter + sort + export | Search + filter, còn lại ⋯ | Search + 1 nút filter mở bottom sheet |

## 3. Chuột vs chạm — quy tắc cứng

**Chuột (desktop):**
- Hover được dùng làm TĂNG TỐC (hiện action phụ, tooltip, preview) nhưng mọi việc hover làm được
  phải có đường khác làm được (menu, click). Hover là shortcut, không phải cửa duy nhất
- Click target tối thiểu 24×24px, hàng table cao 40–48px. Cursor pointer cho MỌI thứ bấm được
- Hỗ trợ thao tác lực: Enter submit form, Esc đóng overlay, `/` focus search (app dùng hằng ngày)

**Chạm (mobile/tablet):**
- Touch target ≥ 44×44pt (iOS) / 48×48dp (Android) — kể cả icon nhỏ: icon 20px thì vùng bấm vẫn 44px (padding)
- Khoảng cách 2 target phá huỷ ≥ 8px (nút Xoá không dính nút Lưu)
- Thumb zone: primary action và bottom tabs nằm 1/3 dưới màn hình — nơi ngón cái với tới.
  Action phá huỷ đặt NGOÀI thumb zone (góc trên) để khó bấm nhầm
- Không tooltip (không có hover) → thông tin trong tooltip phải hiện sẵn hoặc vào popover chạm
- Swipe action (xoá, archive) luôn có đường thay thế nhìn thấy được (menu ⋯)

## 4. iOS theo iOS, Android theo Android

Áp dụng khi build app native/hybrid hoặc PWA nghiêm túc. Web thuần: dùng chuẩn web nhất quán
2 nền tảng, chỉ giữ touch target + thumb zone + bottom sheet.

| Quyết định | iOS (HIG) | Android (Material 3) |
|---|---|---|
| Điều hướng về | Nút Back góc trái + swipe cạnh trái | Nút back hệ thống/gesture — KHÔNG cần vẽ nút back riêng trong header |
| Tab chính | Tab bar dưới, icon + label, không đổi vị trí | Bottom navigation, có thể kèm FAB |
| Action chính | Nút trong nav bar trên hoặc trong nội dung | FAB tròn góc phải dưới |
| Picker ngày/giờ | Wheel/sheet kiểu iOS | Dialog calendar Material |
| Confirm phá huỷ | Action sheet trượt từ dưới, nút đỏ | Dialog giữa màn hình |
| Font | SF Pro (system) | Roboto/system |
| Radius & đậm nhạt | Bo lớn, nền mờ, mỏng nhẹ | Bo lớn, màu tonal, đậm hơn |
| Settings | List group bo góc (inset) | List phẳng full-width + divider |

Cập nhật 2025–2026 (kiểm tra lại khi build native mới):
- **M3 Expressive**: navigation drawer đã bị DEPRECATED — tablet/desktop Android dùng nav rail
  collapse/expand; bottom nav bar còn 64dp
- **iOS 26 Liquid Glass**: tab bar nổi ở đáy, có thể thu nhỏ khi scroll; content tràn
  edge-to-edge chạy dưới lớp control kính mờ — thiết kế content phải chịu được việc bị che mép

Nguyên tắc: **user không nên cảm thấy app "lạc loài" trên máy của họ**. Một app Material
trên iPhone gây cảm giác rẻ; một app bắt chước iOS trên Android gây bối rối nút back.
Logic nghiệp vụ + screen map + token màu GIỮ NGUYÊN; chỉ lớp component convention đổi theo OS.

## 5. Kiểm tra 3 design con (nối với 06)

Mọi màn hình trong screen map phải được xem ở 3 viewport: **375×812 (mobile), 768×1024 (tablet),
1440×900 (desktop)**. Màn hình chỉ đẹp ở desktop = mới làm xong 1/3 việc.
