# 04 — Visual Tokens: mọi con số đã được quyết sẵn

Tầng visual chỉ chạy SAU khi 01–03 xong. Token dưới đây là mặc định cho mọi project;
chỉ override khi DESIGN-SPEC ghi lý do.

## 1. Màu

**Cấu trúc bắt buộc: 1 neutral ramp + 1 accent + 4 semantic. Không thêm họ màu thứ ba.**

- Neutral: dùng ramp xám của Tailwind (slate/zinc/stone — chọn 1, ghi vào spec). Nền trang
  `*-50`, card trắng, border `*-200`, text phụ `*-500`, text chính `*-900`
- Accent: MỘT màu, dùng cho primary button, link, focus ring, trạng thái active. Accent xuất hiện
  < 10% diện tích màn hình — accent tràn lan thì không còn gì nổi bật
- Semantic cố định toàn app: success=green, warning=amber, danger=red, info=blue.
  Accent KHÔNG trùng họ với semantic (accent đỏ làm nút xoá mất nghĩa)
- Text contrast ≥ 4.5:1; text trên nền màu lấy stop đậm nhất cùng họ, không lấy đen tuyền

## 2. Hoà màu logo — quy trình 4 bước, chống "logo chỏi lỏi"

Logo chỏi vì 2 lỗi: lấy nguyên màu logo làm accent dù nó quá chói/quá bẩn,
hoặc bỏ qua logo chọn màu vô can. Quy trình:

```
B1. Lấy màu chủ đạo logo (hue H, saturation S, lightness L)
B2. Phân loại:
    a) Màu "dùng được" (S 40–90%, L 35–60%, không phải vàng neon/xanh chuối)
       → accent = chính nó, có thể chỉnh L về 45–55% cho đủ contrast với chữ trắng
    b) Màu quá chói/quá nhạt (vàng, cam neon, pastel)
       → accent = giữ HUE, kéo S xuống 50–70%, L về 40–50% (phiên bản "trầm" của màu logo)
       → màu gốc logo chỉ xuất hiện trong chính logo và các điểm nhấn nhỏ (icon trang trí)
    c) Logo đen/trắng/xám → tự do chọn accent theo ngành (tài chính: xanh dương đậm;
       nông nghiệp: xanh lá trầm; trẻ em: coral...) — ghi lý do vào spec
    d) Logo nhiều màu (cầu vồng) → coi như (c), chọn 1 màu trong logo làm accent, các màu kia bỏ
B3. Chọn neutral ramp NGHIÊNG theo accent: accent ấm (đỏ/cam) → stone; accent lạnh (xanh) → slate;
    không rõ → zinc. Đây là thứ làm cả giao diện "cùng tông" với logo một cách vô hình
B4. Logo luôn đặt trên nền neutral (trắng/xám nhạt/sidebar sẫm) với khoảng thở ≥ 1× chiều cao logo.
    KHÔNG đặt logo trên nền accent, không đổi màu logo, không thêm shadow cho logo
```

## 3. Typography

- 1 font duy nhất cho UI nghiệp vụ (sans, hỗ trợ tiếng Việt tốt): Inter, Be Vietnam Pro,
  hoặc system stack. Landing page ĐƯỢC PHÉP thêm 1 display font cho hero.
  Được phép +1 font MONO chỉ cho code, ID, phím tắt, data label kỹ thuật (10–14px; label uppercase
  thì tracking +0.3 đến +1.5px) — chuẩn ngành Linear/Vercel. Không mono cho body. Tối đa 3 font/project
- Scale: 12 (caption) / 13 (label phụ) / 14 (body UI) / 16 (body đọc dài) / 18 (section title)
  / 22 (page title) / 20–24 (metric phụ) / 32–40 (hero KPI — luôn 2–3× cỡ label) / 40+ (chỉ landing hero)
- Weight: 400 và 500–600. Không 300 cho chữ < 18px (mảnh quá), không 700+ trong UI (chỉ landing)
- Line-height: 1.5 body, 1.2–1.3 heading. Đoạn đọc dài: max-width 65–75 ký tự
- **Landing hero display**: tỷ lệ hero/body 8–12:1 (body 16 → hero 130–190px desktop);
  luôn fluid bằng `clamp()` với TRẦN px cứng (120–200px — Awwwards SOTY đo thực tế: Lando 127,
  Scout cap 160, Dropbox cap 200); line-height 0.8–1.0; letter-spacing âm −0.01 → −0.03em
  tăng dần theo cỡ, KHÔNG tracking âm cho chữ < 20px; cả landing chỉ dùng 3–4 cỡ chữ tổng cộng

## 4. Hình khối & độ nổi

- Radius thống nhất: button/input 4–8px (trung tâm ngành 4–6: Stripe 4, Linear/Ant/Primer 6;
  Polaris 8 là biên trên — không 16px+ cho control), card 8–12px, modal/sheet 12–16px, badge/pill full.
  CHỌN 1 BỘ ghi vào spec — trộn card vuông cạnh card tròn là lỗi nhận ra ngay
- Elevation 3 mức, dùng border làm chính: mức 0 nền; mức 1 card = border 1px neutral-200
  + shadow-sm; mức 2 overlay = shadow-lg. Không shadow màu, không glow
- Border phân tách dùng neutral-200; HOẶC dùng nền xám phân tách — chọn 1, không dùng cả hai chỗ này chỗ kia

## 5. Triển khai với shadcn/ui

- Theme qua CSS variables trong `globals.css` (`--primary`, `--radius`...) — KHÔNG sửa file component
- Map: accent → `--primary`; neutral ramp → `--background/--muted/--border`; radius bộ đã chọn → `--radius`
- Dark mode: shadcn có sẵn qua `.dark` — định nghĩa đủ biến dark NGAY từ đầu, vì retrofit
  dark mode đắt gấp 10. Dark ≠ đảo màu: nền `neutral-950`, card `neutral-900`,
  accent TĂNG lightness 10–15% để giữ contrast
- Spacing dùng class Tailwind chuẩn (p-2/3/4/6/8 = thang 8/12/16/24/32). Cấm arbitrary value
  `p-[13px]` — thấy `[..px]` trong code UI là vi phạm thang spacing

## 6. Motion

- Transition 150–200ms ease-out cho hover/focus; 250–300ms cho drawer/modal. KHÔNG animation > 400ms trong UI nghiệp vụ
- Animation phải có nghĩa (xuất hiện từ hướng nó trượt vào, fade khi thay nội dung) — không trang trí
- Landing được phép giàu hơn: scroll reveal, stagger — nhưng `prefers-reduced-motion` phải tắt được
