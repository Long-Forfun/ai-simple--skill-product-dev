# BÁO CÁO HIỆU CHUẨN — skill `ui-design-logic` vs corpus nghiên cứu (06/2026)

Đã đọc toàn bộ: `C:\Code\ui-design-logic\SKILL.md` + `references\01` → `06`.

---

## 1. XÁC NHẬN — giữ nguyên, evidence ủng hộ mạnh

- **1 màn hình = 1 primary button** (SKILL.md, 01§3) — M3 "1 FAB/screen"; Polaris "1 primary + max 2 secondary"; winners Timeleft/Partiful/Focus Friend đều 1 action thống trị.
- **Touch target 44pt/48dp, desktop click min 24px** (05§3) — HIG 44pt, M3 48dp, WCAG 2.2 AA 24px, NN/g 1cm. Khớp tuyệt đối.
- **Bottom tabs mobile ≤ 5** (05§2) — M3 hard max 5; HIG "five or fewer, tránh tab More"; ADA winners dùng 3–5; Partiful chỉ 3.
- **Body UI 14px / đọc dài 16px** (04§3) — Carbon body-01 14/20, Atlassian body 14/20, Ant seed 14, Stripe/Notion 16.
- **Line-height 1.5 body / 1.2–1.3 heading** (04§3) — đúng nguyên văn quy tắc Atlassian (heading ×1.2, body ×1.5).
- **Spacing base 4px + cấm arbitrary value** (SKILL.md, 04§5) — cả 5 design system (Polaris, Carbon, Atlassian, Ant, Primer) đều atomic 4px.
- **12 cột, max-width 1200–1440px** (02§2) — Linear/Stripe 1200, Scout 1270–1440, Lando 1248–1440, Datadog 12-col.
- **Đoạn đọc dài 65–75 ký tự** (04§3) — Bringhurst 45–75, optimum 66 CPL.
- **Elevation border-first, shadow chỉ cho overlay** (04§4) — Linear gần phẳng + 1px border; Geist dành 3/10 step mỗi scale cho border; Figma UI3 chủ động THÊM border.
- **Modal chỉ cho quyết định chặn; form sửa → drawer/inline** (03§2) — NN/g modal minimalism + HIG sheet rules trùng khớp cây quyết định của skill.
- **Density M ≤ 6 khối, ≤ 4 metric card** (02§1) — Miller 5–9 widgets, 4–6 hero KPI/hàng, >12 KPI = −40% engagement.
- **"Nén trong widget, thoáng giữa widget" + test gộp** (02§5) — trùng triết lý KPI-card anatomy (Kuznetsova) và Gentler Streak "interpretation over raw numbers".
- **≤ 3 button/hàng** (SKILL.md) — Polaris 1 primary + 2 secondary.
- **Collapse: chevron, header nói trước nội dung, accordion chỉ cho nội dung cùng loại** (02§4) — NN/g: caret là icon duy nhất user hiểu; accordion anti-pattern khi đa số cần đa số nội dung.
- **Hover không bao giờ là đường duy nhất** (SKILL.md, 05§3) — NN/g + bản chất touch.
- **Mobile 4 tabs + tab "Menu"** (01§4, 05§2) — NN/g combo nav 86% usage vs 57% hidden-only.
- **Weight 400/500–600, cấm 300 dưới 18px** (04§3) — các hệ thống cluster 400/500/600; light 300 chỉ xuất hiện ở display ≥ 32px (Carbon, Primer, Linear).
- **Density theo tần suất dùng (hằng ngày nhiều giờ → H)** (02§1) — Think Design: phiên >30 phút mới đáng density cao, <2 phút thì tối giản.
- **Mobile: table → list card, cấm scroll ngang** (05§2) — pattern hàng 2 tầng của enterprise tables.

---

## 2. ĐIỀU CHỈNH — số liệu nên đổi (≥ 2 nguồn độc lập)

**2.1. Cỡ số chính của metric card**
- File: `references/02-layout-and-density.md` §5 (khe 2: "24–32px") + `references/03` §1 + `references/04` §3 ("28–32 metric")
- Hiện tại: số chính metric 24–32px
- Đề xuất: **hero KPI 32–40px; metric phụ 20–24px; số chính luôn 2–3× cỡ label**
- Evidence: Dashboard Design Visual Guide 2025 (primary 32–40, secondary 20–24, ratio 2–3×); Paul Wallas "Designing for Data Density"; NN/g glanceable typography (chữ to hơn cho đọc liếc); Grafana Stat auto-size value lớn nhất panel.

**2.2. Thang spacing thiếu nấc section lớn**
- File: `SKILL.md` (quy tắc cứng) + `references/02` §2 + `references/06` (checklist grep)
- Hiện tại: thang 4/8/12/16/24/32/48/64
- Đề xuất: **thêm 80 và 96 (px) cho khoảng cách giữa section/page lớn** → 4/8/12/16/24/32/48/64/80/96
- Evidence: Polaris token tới 128, Carbon tới 160, Linear scale tới 128, Atlassian tới 80; section gap thực tế Linear 80–120px, Stripe 80px, Scout (Awwwards SOTY) padding section 80px. 64px là trần quá thấp cho landing/section — chính skill cho phép landing L "hero ≥ 50% viewport" nhưng thang không có số đủ lớn để giãn section.

**2.3. Nav ≤ 5 đang áp dụng quá rộng**
- File: `SKILL.md` (quy tắc cứng) + `references/01` §3
- Hiện tại: "Nav chính ≤ 5 mục" áp cho mọi nền tảng
- Đề xuất: **giữ ≤ 5 cho mobile bottom tabs và top nav hiển thị; desktop sidebar cho phép 5–7 mục cấp 1 + các nhóm section collapse được (ghi rõ: giới hạn đúng là SỐ NHÓM và ĐỘ SÂU, không phải số link)**
- Evidence: NN/g video "How Many Items in a Navigation Menu?" phủ nhận thẳng magic number 7±2 (menu là recognition, không phải recall; broad-shallow thắng deep-narrow); Stripe Dashboard ship 5 primary + 2 nhóm collapse ≈ 9–11 mục hiển thị; SaaS sidebar chuẩn 5–7 top-level + section. Cap 5 vẫn đúng tuyệt đối cho mobile (M3 hard max).

**2.4. Radius button/input**
- File: `references/04` §4
- Hiện tại: button/input 6–8px
- Đề xuất: **4–8px** (mở biên dưới)
- Evidence: Stripe đồng nhất 4px, Ant seed 6 (SM 4), Primer medium 6 (small 3), Linear 6 — trung tâm ngành là 4–6; 8 là biên trên (Polaris). Đồng thời giữ nguyên cảnh báo "không 16px+ cho control" — evidence xác nhận "nobody uses 16px+ on controls".

---

## 3. BỔ SUNG — skill đang THIẾU hẳn

**3.1. Tabular figures cho cột số** → `references/02` §6 (căn thẳng hàng) hoặc `references/03` §4
> "Mọi cột số trong table/metric dùng chữ số đều khổ: `font-variant-numeric: tabular-nums` (Tailwind `tabular-nums`) + căn phải — để các chữ số xếp thành cột dọc, chênh lệch tự lộ ra. Cấm font condensed cho số liệu."
- Evidence: A List Apart "Web Typography: Tables"; Pencil & Paper enterprise tables; Datawrapper font guide; Bloomberg đặt riêng font có glyph 1/64 cho đúng việc này.

**3.2. Hoàn thiện giải phẫu metric card: 5 khe + format delta chuẩn** → `references/02` §5
> "Khe chuẩn đủ 5: (0) mốc thời gian ('30 ngày qua'), (1) label, (2) số chính, (3) delta có DẤU + mũi tên + mốc so sánh tường minh ('▲ +12,5% so với tháng trước') — delta trung tính hướng (không tốt không xấu) dùng xanh dương/cam thay green/red, (4) sparkline. Thứ tự đọc: Label → Value → Delta → Timeframe."
- Evidence: Kuznetsova "Anatomy of the KPI Card"; Dashboard Design Visual Guide; Grafana percent-change toggle.

**3.3. Quy tắc sparkline** → `references/02` §5
> "Sparkline: 8–12 kỳ dữ liệu, KHÔNG trục/không nhãn, chỉ hình dạng; chỉ thêm khi xu hướng thực sự là câu hỏi của user; không bao giờ đứng một mình ngoài card. Khi chật, vẽ sparkline làm NỀN sau số chính (cùng pixel, 2 tầng thông tin); panel quá nhỏ thì ẩn sparkline thay vì để nó vô đọc."
- Evidence: Grafana Stat docs (background sparkline + auto-hide); Datadog Query Value; DataCamp dashboard tutorial; Robinhood spark library.

**3.4. Density mode là enum rời rạc do user chọn** → `references/02` §1 + `references/05` §2
> "Table nghiệp vụ (density H) ship 3 nấc chiều cao hàng: nén 40 / chuẩn 48 / thoáng 56px (hoặc theo Carbon: 24/32/40/48/64), user chuyển được và lựa chọn PHẢI được nhớ qua session. Density không phải hằng số một chiều — là enum + preference."
- Evidence: Pencil & Paper (40/48/56 + persist); Carbon data-table 5 nấc 24–64px; Airtable 4 nấc, mặc định nấc ngắn nhất; Datadog high-density 2×12 tự bật trên màn lớn + opt-out.

**3.5. Front-load từ khoá + kỷ luật truncate** → `references/03` §4
> "Từ khoá phân biệt đứng ĐẦU title/link/label — user chỉ fixate 2 từ đầu (~11 ký tự đầu mang gần hết information scent). Khi buộc truncate, cắt SAU từ khoá phân biệt (model, cỡ, biến thể), không cắt giữa; truncate title trong list mà mất từ phân biệt thì tệ ngang không có title. Tag/lozenge: max-width 200px rồi ellipsis."
- Evidence: NN/g "Writing Hyperlinks" + "Better Link Labels"; Baymard cross-sell title study (55% site truncate sai); Atlassian Lozenge/Tag 200px.

**3.6. Budget tổng field của form, không chỉ per-step** → `references/01` §2–3
> "Tổng field hiển thị của 1 flow nhập liệu ≤ 8 (checkout chuẩn Baymard); wizard 2–4 field/step thắng 1 trang dày. Field optional (Địa chỉ dòng 2, mã giảm giá) mặc định collapse sau 1 text link. Tên người: 1 field 'Họ tên' duy nhất (42% user gõ full name vào ô First Name khi tách đôi)."
- Evidence: Baymard checkout benchmark 06/2024 (11,3 field trung bình vs 8 lý tưởng; 17% abandon vì dài); NN/g form top-10 (1 cột, label trên field).

**3.7. Font mono thứ ba cho dữ liệu kỹ thuật** → `references/04` §3
> "Được phép +1 font mono (tổng 3) CHỈ cho: code, ID, phím tắt, data label kỹ thuật — cỡ 10–14px; nếu là label uppercase thì tracking +0.3 đến +1.5px. Không dùng mono cho body."
- Evidence: Linear (Berkeley Mono 12–14px cho ID/shortcut); Vercel Geist Mono; 3/7 site Awwwards (IBM Plex Mono 10–12px ở Scout, Geist Mono 11–12px ở Terminal) — đã thành chuẩn ngành.

**3.8. Typography display cho landing hero** → `references/04` §3 (mở rộng dòng "40+ chỉ landing hero")
> "Landing hero: tỷ lệ hero/body 8–12:1 (vd body 16 → hero 130–190px desktop); luôn fluid bằng `clamp()` có TRẦN px cứng (120–200px); line-height display 0.8–1.0; letter-spacing âm −1 đến −4px (hoặc −0.01 → −0.03em tăng theo cỡ, không âm dưới 20px); landing chỉ dùng 3–4 cỡ chữ tổng cộng."
- Evidence: 7 site Awwwards/CSSDA SOTY 2024–2025 (Lando 127px, Scout 160 cap, Dropbox 200 cap, đo trực tiếp từ CSS production); Linear/Stripe tracking âm theo cỡ (−0.022em@72px, −0.030em@56px).

**3.9. Vị trí + loại chart trên dashboard** → `references/02` §1
> "KPI quan trọng nhất đặt GÓC TRÊN-TRÁI (80% thời gian nhìn dồn vào nửa trái + đỉnh viewport). Chart chỉ dùng bar (độ dài) và line (vị trí 2D) — cấm pie/gauge/3D. Hue mã hoá DANH MỤC, không mã hoá độ lớn (4,5% dân số mù màu); dashboard ≤ 3–4 màu semantic. Kim tự tháp màn hình: hàng 1 = 4–6 KPI, hàng 2 = 1–2 chart lớn, hàng 3 = table."
- Evidence: NN/g "Dashboards: Preattentive" + "Horizontal Attention Leans Left"; Dashboard Design Visual Guide; Robinhood 4 màu (ADA 2015).

**3.10. Tỷ lệ whitespace ngoài:trong** → `references/02` §2
> "Padding quanh section lớn gấp 5–8× padding trong component (≈80px ngoài vs 12–16px trong) — chính tỷ lệ này tạo cảm giác 'premium', không phải tổng lượng trắng."
- Evidence: Scout Motors CSS (5rem section vs .75–1rem component); pattern hội tụ trên cả 7 winner; Primer/Polaris token cũng phân tầng tương tự.

**3.11. Ghi chú HIG/M3 mới cho `references/05` §4**
> "M3 Expressive 2025: navigation drawer bị deprecated — tablet/desktop Android dùng nav rail collapse/expand; nav bar còn 64dp. iOS 26 Liquid Glass: tab bar nổi đáy, có thể thu nhỏ khi scroll; content tràn edge-to-edge dưới lớp control mờ."
- Evidence: 9to5google 14/05/2025; material-components-android BottomNavigation.md; Apple HIG Tab Bars bản hiện hành.

---

## 4. NGUỒN ĐÁNG GIÁ

1. **Apple HIG — Typography / Layout / Tab Bars / Accessibility** — https://developer.apple.com/design/human-interface-guidelines/ (type ramp 11–34pt, target 44pt, tab ≤5, bản Liquid Glass hiện hành)
2. **Material 3 + M3 Expressive** — https://m3.material.io/ (48dp, type scale sp, 8dp grid; nền tảng 46 study / 18.000 người)
3. **Shopify Polaris tokens** — https://polaris-react.shopify.com/tokens/space (thang spacing/font/radius tham chiếu tốt nhất để đối chiếu token)
4. **Carbon data table** — https://carbondesignsystem.com/components/data-table/usage/ (5 density mode 24–64px — chuẩn vàng cho enterprise table)
5. **Vercel Geist colors** — https://vercel.com/geist/colors (role-mapping 10 step: 1–3 bg, 4–6 border, 7–8 solid, 9–10 text)
6. **Linear redesign blog** — https://linear.app/now/how-we-redesigned-the-linear-ui (theme từ 3 biến LCH; density + hierarchy của SaaS hàng đầu)
7. **NN/g — Hamburger Menus study** — https://www.nngroup.com/articles/hamburger-menus/ (số liệu định lượng hiếm: hidden nav giảm nửa discoverability) + https://www.nngroup.com/articles/glanceable-fonts/ + https://www.nngroup.com/articles/modal-nonmodal-dialog/
8. **Baymard checkout benchmark** — https://baymard.com/blog/checkout-flow-average-form-fields (8 field lý tưởng, friction từng field)
9. **Datadog effective-dashboards** — https://github.com/DataDog/effective-dashboards (guideline dashboard dạng repo, có số tối thiểu cột widget)
10. **Matt Ström-Awn — "UI Density"** — https://mattstromawn.com/writing/ui-density/ (khung lý thuyết hay nhất về density: value density, temporal density, Bloomberg case) + **KPI Card anatomy** — https://nastengraph.substack.com/p/anatomy-of-the-kpi-card