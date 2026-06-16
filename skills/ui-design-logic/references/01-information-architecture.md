# 01 — Information Architecture: kiến trúc trước, pixel sau

Mọi UI xấu về cấu trúc đều xấu từ trước khi chọn màu. Bước này quyết định
**bao nhiêu page, bao nhiêu tab, bao nhiêu flow, mỗi màn hình chứa gì** —
và ghi thành DESIGN-SPEC.md để mọi session sau tuân theo.

## 1. Thang người dùng — không tồn tại "user chung chung"

> **Nguồn**: nếu app-map có `ba-spec` (do `ba-flow-logic` sinh) → thang user TIẾP NỐI từ `ba-spec §2 User registry` (đã có loại user + vòng đời + bối cảnh) và `§5 Flows`, KHÔNG dựng lại từ đầu. Việc ở đây là *bổ sung 3 câu design* (muốn thấy gì / truyền tải gì / thúc đẩy gì) lên trên các loại user ba-spec đã liệt kê. Không có ba-spec → tự dựng như dưới.

Mọi quyết định design phía sau đều phục vụ MỘT loại user cụ thể đang ở MỘT bậc cụ thể.
Phân loại theo 2 trục, và với TỪNG loại trả lời đủ 3 câu — đây là triết lý gốc:

1. **Họ MUỐN nhìn thấy gì?** (nhu cầu của họ)
2. **Sản phẩm MUỐN truyền tải gì tới họ?** (thông điệp của mình)
3. **Đưa cái gì để THÚC ĐẨY action tiếp theo?** (cây cầu sang bậc kế)

**Trục dọc — vòng đời:**

| Bậc | Họ muốn thấy | Sản phẩm truyền tải | Thúc đẩy action tiếp |
|---|---|---|---|
| **Public** (chưa account) | Giá trị trong 5 giây: app này giải quyết gì cho TÔI + bằng chứng (demo, số liệu, preview thật) | "Đây là thứ bạn cần, và dùng được ngay" | 1 CTA đăng ký duy nhất. Cho nếm giá trị TRƯỚC khi xin account nếu được (preview/read-only/dùng thử không login) |
| **Mới** (có account, chưa dữ liệu) | Đường NGẮN NHẤT tới giá trị đầu tiên (aha moment) | "Bắt đầu dễ lắm, 1 bước nữa thôi" | Empty state = onboarding: 1 CTA tạo dữ liệu đầu tiên, checklist 2–3 bước, sample data nếu giúp hình dung |
| **Quen** (dùng đều) | Dữ liệu CỦA HỌ + lối tắt vào việc hằng ngày | "Mọi thứ trong tầm kiểm soát" | Mở tính năng sâu theo ngữ cảnh — đúng lúc user vừa chạm tình huống cần nó, không phải tour 10 bước ngày đầu |
| **Power / chạm trần gói** | Hiệu suất tối đa: phím tắt, bulk action, density H | "Tôn trọng thời gian của bạn" | Mời nâng cấp khi CHẠM TRẦN thật (dùng 95% quota, cần feature bị khoá) — đúng lúc đau, không rao trước |

**Trục ngang — loại account (role/tier): account loại X, loại Y...**
Mỗi role một dòng cùng 3 câu trên, ghi vào DESIGN-SPEC. Gợi ý điểm nhìn: admin muốn TOÀN CẢNH
+ kiểm soát; staff muốn việc CỦA MÌNH hôm nay; kế toán muốn số khớp và xuất được;
khách-của-khách (portal) muốn tiến độ + minh bạch, không muốn thấy nội bộ.

**Quy tắc cứng của thang:**
- Mỗi bậc có đúng 1 "hành động thăng cấp"; mỗi màn hình hiện TỐI ĐA 1 lời mời thăng cấp (nudge).
  Nudge ăn density budget như widget thật — spam upsell là cách nhanh nhất giết trust
- Màn hình phục vụ ≥ 2 loại user → khai báo BIẾN THỂ trong screen map (dashboard user mới
  = onboarding checklist; dashboard user quen = số liệu của họ). Cấm design "trung bình cộng" — nó không phục vụ ai
- Thứ tự ưu tiên trên màn hình: cái USER CẦN đứng trước, cái SẢN PHẨM MUỐN đứng sau.
  Đảo ngược (nhét upsell trên job chính) là dark pattern, phá vỡ câu 1 để ép câu 3

### 1b. Trọng số thông tin theo loại user — từ cảm tính sang số đếm được

Cùng 1 mẩu thông tin, giá trị khác nhau hoàn toàn theo người nhìn. Với mỗi màn hình,
liệt kê các info item rồi CHẤM TRỌNG SỐ 0–3 cho TỪNG loại user:

| Trọng số | Nghĩa | Suy ra vị trí + cỡ + bậc disclosure (02 §3) |
|---|---|---|
| **3** — sống còn | Thiếu nó user không làm được job, hoặc là lý do họ mở màn hình | Above the fold, góc trên-trái, cỡ lớn nhất (hero KPI 32–40px), bậc 0 |
| **2** — cần | Đọc trong đa số phiên dùng | Hiện thẳng bậc 0, cỡ chuẩn, dưới các item W3 |
| **1** — thỉnh thoảng | <20% phiên dùng mới cần | Bậc 1–2: collapse, tab phụ, drawer |
| **0** — vô nghĩa/không quyền | Loại user này không cần hoặc không được thấy | ẨN hẳn với loại user này |

Cách chấm: trọng số = **tần suất cần × mức ảnh hưởng quyết định**. Không chấm theo
"thông tin này hay" — chấm theo "user loại này có DÙNG nó để quyết định gì không".

Ví dụ màn hình "Chi tiết ao nuôi":

| Info item | Chủ trại (mobile, ngoài ao) | Kỹ thuật viên | Kế toán | Public (demo) |
|---|---|---|---|---|
| Cảnh báo thông số vượt ngưỡng | **3** | **3** | 0 | 2 (mồi giá trị) |
| pH/oxy/nhiệt độ hiện tại | **3** | **3** | 0 | 2 |
| Lịch cho ăn hôm nay | 2 | **3** | 0 | 1 |
| Chi phí thức ăn luỹ kế | 1 | 0 | **3** | 0 |
| Lịch sử thông số 30 ngày | 1 | 2 | 1 | 0 |

→ Cùng màn hình nhưng layout chủ trại ≠ kỹ thuật viên ≠ kế toán: chính bảng trọng số
này là CÔNG THỨC sinh ra các biến thể, không phải cảm hứng.

**Quy tắc phân phối — chống lạm phát trọng số:**
- Tối đa **2 item W3/màn hình/loại user**. Mọi thứ đều W3 = không có gì W3 — nếu đếm ra 4 item W3,
  nghĩa là màn hình đang gánh 2 nhiệm vụ → tách màn hình (quay lại screen map)
- Tổng item W2+W3 phải nằm trong density budget của màn hình (02 §1) — trọng số là cách
  PHÂN PHỐI budget, không phải cách vượt budget
- Item W0 với mọi loại user → xoá khỏi spec, đừng giữ "cho đủ"
- Xung đột giữa 2 loại user dùng chung màn hình (item W3 của kế toán là W0 của kỹ thuật viên)
  → đó là tín hiệu TÁCH BIẾN THỂ, không phải tín hiệu thoả hiệp đặt nó ở giữa

## 2. Object model — app này nói về cái gì

Liệt kê 3–7 danh từ cốt lõi của domain (Đơn hàng, Khách, Sản phẩm, Báo cáo...).
Mỗi danh từ tự hỏi: user cần **xem danh sách** nó không? **xem chi tiết** không?
**tạo/sửa** không? Câu trả lời sinh ra số màn hình một cách logic:

| Object cần | Sinh ra màn hình |
|---|---|
| Xem nhiều + so sánh | 1 list/table screen |
| Xem sâu 1 cái | 1 detail screen |
| Tạo/sửa phức tạp (> 5 field) | 1 form screen riêng |
| Tạo/sửa đơn giản (≤ 5 field) | KHÔNG sinh màn hình — dùng drawer/dialog trong list |

> Nếu app có > 7 object cốt lõi → khả năng cao đang gộp 2 sản phẩm vào 1. Tách hoặc nhóm lại trước.

## 3. Flow map — user đi đường nào

Mỗi job-to-be-done chính = 1 flow. Vẽ dạng text:

```
Flow: Tạo đơn hàng mới
Dashboard → [+ Đơn hàng] → Form (3 bước: khách → sản phẩm → xác nhận) → Detail đơn vừa tạo
Số bước: 3 click + 1 form   ✓ (budget: ≤ 3 click tới core action)
```

**Budget flow:**
- Core flow (việc user làm hằng ngày): ≤ 3 click/tap từ màn hình chính
- Flow phụ (settings, export): ≤ 5 click, được phép giấu trong menu
- Mỗi flow kết thúc ở một trạng thái RÕ RÀNG: detail vừa tạo / toast xác nhận / màn hình kết quả. Không bao giờ kết thúc lơ lửng
- Flow > 5 bước nhập liệu → bắt buộc chia step (wizard) có progress, mỗi step ≤ 5 field

## 4. Hành vi người dùng — mỗi màn hình là một điểm GIỮA của hành trình, không phải ốc đảo

Màn hình không tồn tại độc lập. Trước khi layout, trả lời 4 câu cho TỪNG màn hình
(ghi vào screen map):

1. **Vào từ đâu?** — nav chính / click từ list / deep link từ notification / link share / search.
   Màn hình có entry từ notification/share → phải TỰ ĐỦ ngữ cảnh: header nói rõ đang xem gì,
   không giả định user vừa từ list bước sang
2. **User muốn gì ở đây?** — 1 câu (đã có trong screen map)
3. **Step tiếp theo mong muốn là gì?** — đạt mục đích xong, 80% user làm gì tiếp? CHÍNH NÓ phải là
   element nổi bật nhất màn hình. Ví dụ: duyệt viên xem chi tiết đơn → step tiếp là Duyệt/Từ chối
   → 2 nút đó đứng đầu, không phải nút Sửa; đọc xong bài → step tiếp là bài liên quan → list bài
   liên quan ngay cuối, không phải footer chết
4. **Hành động → kỳ vọng** — với mỗi hành động chính, user kỳ vọng THẤY gì ngay sau đó?
   Tạo xong đơn → kỳ vọng thấy đơn vừa tạo (đi tới detail + toast), KHÔNG quay về list bắt tự tìm.
   Xoá xong item → kỳ vọng thấy list không còn nó + Undo. Lưu nháp → kỳ vọng ở lại form + báo đã lưu

**Ma trận trạng thái — màn hình chưa định nghĩa đủ trạng thái là màn hình mới design một nửa:**

| Trạng thái | Phải quyết định |
|---|---|
| Chưa đăng nhập | Thấy gì: redirect login, hay bản public/preview + CTA đăng ký? Nội dung nào là mồi, nội dung nào khoá? |
| Đã đăng nhập, role khác nhau | Admin thấy gì hơn staff? Không có quyền → ẨN hành động (đừng disable, trừ khi cần cho user biết tính năng tồn tại để nâng cấp) |
| Lần đầu, chưa có dữ liệu | Empty state = 1 dòng lý do + 1 CTA tạo dữ liệu đầu tiên (kết nối 03 §4) |
| Đang tải | Skeleton đúng HÌNH DẠNG nội dung sắp hiện — không spinner toàn trang |
| Lỗi / mất mạng | Nói cách khắc phục + nút thử lại; dữ liệu đã nhập không được mất |
| Dữ liệu cực đoan | Tên 60 ký tự, số 0, list 10.000 dòng — thiết kế bằng dữ liệu THẬT xấu xí, không phải lorem ipsum đẹp |

**Thiết kế theo thói quen & tần suất (data-driven defaults):**
- Hành động chiếm 80% lần dùng → gần nhất, ít click nhất (đo bằng flow budget mục 3)
- App NHỚ lựa chọn lặp lại: filter lần trước, tab đang mở, density đã chọn, kho/chi nhánh hay thao tác —
  default thông minh là default HỌC từ hành vi, không phải default của dev
- Thứ tự dữ liệu theo hành vi: recent/frequent lên đầu — không sort alphabet vô hồn khi user có lịch sử dùng

## 5. Screen map + budget — bảng trung tâm của DESIGN-SPEC

| Budget | Giới hạn | Lý do |
|---|---|---|
| Mục nav mobile / top nav | ≤ 5 | M3 hard max 5 bottom tabs; HIG "five or fewer". Mục thứ 6+ → tab "Menu" hoặc xét lại object model |
| Mục nav desktop sidebar | 5–7 cấp 1 + nhóm section | NN/g: menu là recognition không phải recall — giới hạn thật là số NHÓM + độ sâu, không phải số link (Stripe ship 5 primary + 2 nhóm collapse ≈ 9–11 link) |
| Độ sâu nav | ≤ 2 cấp | Cấp 3 là nơi feature chết. Cần cấp 3 → biến cấp 2 thành tab |
| Tab trong 1 page | 2–6 | 1 tab là vô nghĩa, 7+ là nav chính trá hình. KHÔNG tab lồng tab |
| Primary button / màn hình | đúng 1 | 2 primary = không có primary. Màn hình không có hành động chính → nó là màn hình đọc, dùng link |
| Button / 1 hàng | ≤ 3 | Từ cái thứ 4 → dropdown ⋯ |
| Field / 1 step form | 2–5 | Wizard 2–4 field/step thắng 1 trang dày (Baymard) |
| Tổng field / 1 flow nhập liệu | ≤ 8 | Baymard checkout benchmark: trung bình ngành 11,3 field nhưng lý tưởng là 8; 17% abandon vì form dài. Field optional (địa chỉ dòng 2, mã giảm giá) mặc định collapse sau 1 text link. Tên người: 1 field "Họ tên" duy nhất — 42% user gõ full name vào ô First name khi tách đôi |

## 6. Chọn navigation model theo số lượng

| Số mục nav chính | Desktop | Mobile |
|---|---|---|
| 2–3 | Top nav | Bottom tabs |
| 4–5 | Sidebar (hoặc top nav nếu app nông) | Bottom tabs |
| 5 + nhiều mục phụ | Sidebar nhóm section | Bottom tabs 4 + tab "Menu" chứa phần còn lại |

Đừng chọn nav theo thẩm mỹ. Chọn theo số đếm, rồi mới làm đẹp cái đã chọn.

## 7. Template DESIGN-SPEC.md (copy vào root project)

```markdown
# DESIGN-SPEC — <tên app>

## Người dùng & nhiệm vụ
- User chính: <ai>  |  Job hằng ngày: <1 câu>
- Platform: <desktop-first / mobile-first / cả hai>  |  Logo/brand: <link hoặc "không">

## Thang người dùng (3 câu cho từng loại)
| Loại user | Muốn thấy gì | Sản phẩm truyền tải gì | Thúc đẩy action tiếp theo |
|---|---|---|---|
| Public chưa account | demo + bằng chứng giá trị | "giải quyết đúng việc của bạn" | Đăng ký (CTA duy nhất) |
| Mới, chưa dữ liệu | đường ngắn nhất tới giá trị đầu | "1 bước nữa thôi" | Tạo <object> đầu tiên |
| Staff (loại X) | việc CỦA MÌNH hôm nay | "không sót việc" | Xử lý item chờ lâu nhất |
| Admin (loại Y) | toàn cảnh + bất thường | "trong tầm kiểm soát" | Xem drill-down chỗ lệch |

## Object model
<Object>: list? detail? form? → màn hình sinh ra

## Nav model
<sidebar 5 mục: ...> | mobile: <bottom tabs: ...>

## Screen map
| # | Màn hình | Vào từ | User đến để làm gì (1 câu) | Step tiếp theo mong muốn | Primary action | Widget chính | Density |
|---|---|---|---|---|---|---|---|
| 1 | Dashboard | login, bottom tab | Nắm tình hình hôm nay trong 5 giây | xử lý cảnh báo nóng nhất | + Tạo đơn | 4 metric + 1 chart + 1 list 5 dòng | M |
| 2 | Chi tiết đơn | list, noti, link share | Quyết định duyệt/từ chối | duyệt → đơn kế tiếp | Duyệt | header trạng thái + bảng item + timeline | M |

Màn hình phục vụ ≥ 2 loại user → mỗi biến thể 1 dòng (vd: `1a Dashboard (mới)` = onboarding checklist, `1b Dashboard (quen)` = metric của họ).

## Trọng số info (màn hình nhiều loại user — xem 1b)
| Màn hình: Chi tiết đơn | Staff | Admin | Kế toán |
|---|---|---|---|
| Trạng thái + nút Duyệt | 3 | 2 | 0 |
| Giá trị đơn + công nợ | 1 | 2 | 3 |

## Ma trận trạng thái
| Màn hình | Chưa login | Trống | Lỗi | Role |
|---|---|---|---|---|
| Chi tiết đơn | redirect login, giữ deep link | — | retry + cache bản cũ | staff không thấy nút Duyệt |

## Action → Expectation
| Hành động | User kỳ vọng thấy ngay sau đó |
|---|---|
| Tạo đơn xong | detail đơn vừa tạo + toast |
| Xoá item | list không còn nó + Undo 5s |

## Flows
<flow map như mục 3>

## Thói quen cần nhớ (data-driven defaults)
- <ví dụ: nhớ filter + chi nhánh lần trước; list đơn sort theo recent>

## Quyết định đã chốt (không hỏi lại)
- <ví dụ: tạo/sửa khách dùng drawer, không page riêng>
```

Cột "User đến để làm gì" bắt buộc điền được bằng 1 câu. Không điền được = màn hình
không có lý do tồn tại = xoá hoặc gộp.

## 8. Thêm màn hình vào app đã có

1. Đọc DESIGN-SPEC.md hiện có. Không có → tạo (reverse-engineer từ code, 15 phút đáng giá)
2. Màn hình mới có phá budget không (nav 6 mục? tab thứ 7?) → nếu phá, đề xuất tái cấu trúc TRƯỚC, không nhét thêm
3. Thêm dòng vào screen map → rồi mới code
