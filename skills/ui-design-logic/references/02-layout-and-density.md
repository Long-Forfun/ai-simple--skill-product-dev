# 02 — Layout & Density: mật độ thông tin là một quyết định, không phải tai nạn

Màn hình rối = nhồi quá density budget. Màn hình "trống hoác vô dụng" = dưới budget.
Cả hai đều là bug đo đếm được, không phải gu.

## 1. Density budget — khai báo trong DESIGN-SPEC cho từng màn hình

| Mức | Dùng cho | Giới hạn cứng trên 1 viewport (chưa scroll) |
|---|---|---|
| **L** (thoáng) | Landing, onboarding, empty state, auth | 1 thông điệp chính + 1 primary action. Hero chiếm ≥ 50% viewport |
| **M** (vừa) | Dashboard, detail, settings | ≤ 6 khối thông tin (metric card, chart, list...) + 1 primary action |
| **H** (đặc) | Table nghiệp vụ, admin, công cụ chuyên dùng hằng ngày | 1 widget chủ đạo (table/map) chiếm ≥ 60% diện tích + toolbar; KHÔNG thêm khối trang trí |

Quy tắc chọn: user dùng màn hình này **mỗi ngày nhiều giờ** → H (họ cần dữ liệu, không cần khoảng thở).
User **thỉnh thoảng ghé** → M. User **lần đầu gặp** → L.

- Trên 1 màn hình M: tối đa 4 metric card. Metric thứ 5+ → màn hình báo cáo riêng
- "Khối thông tin" đếm cả banner, tip, quảng cáo tính năng — chúng ăn budget như widget thật
- Mobile: budget giảm một nửa (M = 3 khối/viewport), vì viewport chỉ bằng 1/3
- **Kim tự tháp dashboard**: hàng 1 = 4–6 KPI; hàng 2 = 1–2 chart lớn; hàng 3 = table.
  KPI quan trọng nhất đặt GÓC TRÊN-TRÁI — 80% thời gian nhìn dồn vào nửa trái + đỉnh viewport (NN/g).
  Chart chỉ dùng bar (so độ dài) và line (vị trí) — cấm pie/gauge/3D; hue mã hoá DANH MỤC, không mã hoá độ lớn
- **Density H là enum, không phải hằng số**: table nghiệp vụ ship 3 nấc chiều cao hàng
  nén 40 / chuẩn 48 / thoáng 56px, user chuyển được và lựa chọn PHẢI được nhớ qua session
  (chuẩn ngành: Carbon 5 nấc 24–64, Airtable 4 nấc mặc định nấc ngắn nhất)

## 2. Grid & khoảng cách

- Desktop: 12 cột, gutter 24px, max-width nội dung 1200–1440px, căn giữa
- Tablet: 8 cột, gutter 16px. Mobile: 4 cột, gutter 16px, padding mép 16px
- Mọi khoảng cách lấy từ thang **4/8/12/16/24/32/48/64/80/96**:
  - 4–8: trong 1 component (icon↔label)
  - 12–16: giữa các phần tử cùng nhóm
  - 24–32: giữa các nhóm/card
  - 48–64: giữa các section trong app nghiệp vụ
  - 80–96: giữa các section landing/page lớn (Linear 80–120, Stripe 80, Awwwards SOTY 80)
- **Tỷ lệ whitespace ngoài:trong = 5–8×**: padding quanh section lớn gấp 5–8 lần padding trong
  component (≈80px ngoài vs 12–16px trong). Chính TỶ LỆ này tạo cảm giác "premium",
  không phải tổng lượng khoảng trắng
- **Khoảng cách thể hiện quan hệ**: 2 thứ liên quan đặt gần (≤16), 2 thứ khác nhóm đặt xa (≥24).
  Đều tăm tắp 20px mọi nơi = mắt không phân nhóm được = "rối" dù ít nội dung

## 3. Thang progressive disclosure — giấu thông tin theo bậc

Khi màn hình vượt density budget, KHÔNG nhồi — đẩy thông tin xuống bậc dưới:

```
Bậc 0: hiện thẳng          → thông tin user cần trong job chính của màn hình
Bậc 1: collapse/expand     → thông tin bổ trợ, 20% lần dùng mới cần (chi tiết phí, log)
Bậc 2: drawer/sheet bên    → object phụ xem nhanh rồi quay lại (preview, quick edit)
Bậc 3: page riêng          → nhiệm vụ độc lập, cần URL, cần quay lại bằng Back
```

Thông tin càng ít người cần càng xuống bậc sâu. Đẩy việc-hằng-ngày xuống bậc 2 = bắt user trả thuế click mỗi ngày.

## 4. Quy tắc collapse/expand (Bậc 1)

- **Mặc định mở** khi: ≤ 3 section VÀ nội dung thuộc job chính. **Mặc định đóng** khi: nội dung bổ trợ, hoặc > 3 section
- Primary action và thông tin quyết định (tổng tiền, trạng thái) KHÔNG BAO GIỜ nằm trong vùng collapse
- Header vùng collapse phải nói trước nội dung: "Chi tiết phí (3 khoản)" chứ không phải "Xem thêm"
- Cả header là vùng bấm (không chỉ mũi tên), có icon chevron xoay, nhớ trạng thái user đã mở trong session
- Accordion (mở cái này đóng cái kia) CHỈ dùng cho nội dung cùng loại và user chỉ cần 1 cái một lúc (FAQ). Form nhiều section: cho mở đồng thời — user cần đối chiếu
- Cấm collapse lồng collapse. Cần lồng = cấu trúc sai, quay lại screen map

## 5. Nén thông tin — "nén trong widget, thoáng giữa widget"

Density budget (mục 1) giới hạn SỐ KHỐI trên màn hình. Mặt còn lại: mỗi khối phải
**khai thác hết khe thông tin của nó**. Lỗi phổ biến nhất của dashboard AI sinh ra:
6 card mỗi card đúng 1 con số mỏng dính — vừa vượt budget khối, vừa nghèo thông tin,
vừa cắt rời các số liên quan. Đó là "trải đều" — kẻ thù của design thông minh.

**Thước đo: 1 widget trả lời được bao nhiêu câu hỏi của user trên cùng diện tích?**

```
Nghèo:  ┌─────────────┐   Trả lời 1 câu: "có bao nhiêu ao khoẻ?"
        │ Ao khoẻ     │
        │ 120         │
        └─────────────┘

Nén:    ┌──────────────────────┐   Trả lời 4 câu: bao nhiêu? trên tổng nào?
        │ Ao khoẻ              │   tỷ lệ? đang tốt lên hay xấu đi?
        │ 120/450  (27%)       │
        │ ▲ +5 so với hôm qua  │
        └──────────────────────┘
```

**Khe thông tin chuẩn của metric card** — 5 khe, điền từ trên xuống, dừng khi hết dữ liệu có nghĩa.
Thứ tự đọc: Label → Value → Delta → Timeframe (Kuznetsova, KPI card anatomy):
0. Mốc thời gian dữ liệu ("30 ngày qua") — 12px, góc trên phải hoặc cạnh label
1. Label (13px, neutral-500)
2. Số chính + đơn vị — **hero KPI 32–40px, metric phụ 20–24px; luôn 2–3× cỡ label** —
   và NGAY CẠNH nó: `/tổng` hoặc `(%)` nếu số chỉ có nghĩa khi so với tổng
3. Delta: DẤU + mũi tên + mốc so sánh tường minh (`▲ +12,5% so với tháng trước`) — số tuyệt đối
   không có mốc so sánh là số mồ côi. Màu: green/red theo nghĩa tốt/xấu; delta trung tính hướng
   (không tốt không xấu, vd số lượng đơn nháp) dùng xanh dương/cam, đừng ép green/red
4. (tuỳ chọn) Sparkline — quy tắc riêng:
   - 8–12 kỳ dữ liệu, KHÔNG trục/không nhãn — chỉ hình dạng xu hướng
   - Chỉ thêm khi xu hướng thực sự là câu hỏi của user; không bao giờ đứng một mình ngoài card
   - Khi chật: vẽ sparkline làm NỀN mờ sau số chính (cùng pixel, 2 tầng thông tin — Grafana Stat);
     card quá nhỏ thì ẨN sparkline thay vì để nó vô đọc

**Quy tắc liên kết (linkage):**
- 2 thông tin user luôn đọc CÙNG NHAU phải nằm cùng 1 component, cách nhau ≤ 8px — hiện-có với tổng, số với %, giá trị với xu hướng. Tách chúng ra 2 widget = bắt mắt user nhảy qua lại làm phép tính
- **Test gộp**: để trả lời 1 câu hỏi ("còn bao nhiêu chỗ trống?") user phải nhìn 2 widget → gộp thành 1. Chạy test này trên mọi cặp widget cạnh nhau trước khi chốt layout
- Table cũng nén được: hàng 2 tầng (title + dòng meta 13px) thay vì đẻ thêm cột; số kèm progress bar mini trong cùng ô khi giá trị có ngưỡng

**Giới hạn nén — nén không phải nhồi:**
- 1 card chỉ 1 SỐ CHÍNH (size to). Số phụ nhỏ hơn rõ rệt (13px) và phải là ngữ cảnh của chính số đó — 2 chỉ số không liên quan trong 1 card là nhồi, tách ra
- Tối đa 2 dòng phụ dưới số chính. Không hạ font < 12px để nhét thêm
- Nén làm GIẢM số khối trên màn hình (3 card nén thay 6 card mỏng) — nếu nén xong số khối không giảm thì đang nhồi chứ không nén

## 6. Hai mươi phần trăm khó nhất: căn thẳng hàng

- Mọi thứ căn theo MỘT trục trái của grid. Mắt người quét theo đường thẳng đứng — 1 phần tử lệch 4px phá cả trang
- Card cùng hàng: cùng chiều cao. Nội dung ngắn thì giãn phần thân, không để card so le răng cưa
- Số trong table: căn phải, cùng số chữ số thập phân. Text: căn trái. KHÔNG căn giữa nội dung table (trừ icon/status)
- **Tabular figures bắt buộc cho mọi cột số**: `font-variant-numeric: tabular-nums`
  (Tailwind: class `tabular-nums`) — chữ số đều khổ xếp thành cột dọc, chênh lệch tự lộ ra khi quét.
  Cấm font condensed cho số liệu (Bloomberg đặt riêng font có glyph phân biệt 1/l và 0/O cho đúng việc này)
- Label và giá trị thẳng hàng dọc qua mọi hàng (definition list 2 cột, không phải "Label: value" trôi nổi)
