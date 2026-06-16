# 06 — QA & Acceptance: chưa nhìn thấy bằng mắt = chưa xong

Code UI viết xong mới đi được nửa đường. Lovable đẹp ổn định vì có vòng lặp render-nhìn-sửa;
skill này bắt buộc vòng lặp đó. **Cấm tuyên bố "xong" khi chưa screenshot.**

## 1. Quy trình screenshot loop

```
1. Chạy app (dev server / preview tool có sẵn trong môi trường)
2. Với MỖI màn hình trong screen map: screenshot ở 1440×900, 768×1024, 375×812
   + dark mode ở viewport chính (nếu app có dark mode)
3. Tự chấm theo checklist mục 2 — nhìn ảnh thật, không nhìn code mà đoán
4. Có lỗi BLOCK/MAJOR → sửa → screenshot lại vùng đã sửa → chấm lại
5. Lặp đến khi hết BLOCK/MAJOR (thường 2–3 vòng). MINOR còn lại: liệt kê cho user quyết
```

Task nhỏ (sửa 1 component): chỉ cần screenshot màn hình chứa nó ở viewport chính + mobile.
Task mới cả app: đủ ma trận màn hình × viewport.

## 2. Checklist nghiệm thu

**BLOCK — phá chức năng hoặc phá tin cậy, sửa ngay:**
- [ ] Text tràn/đè lên nhau, element vỡ khỏi container ở bất kỳ viewport nào
- [ ] Contrast text < 4.5:1 (kiểm tra cả badge, placeholder, text trên ảnh)
- [ ] Touch target < 44px trên mobile cho action chính
- [ ] Dark mode: text tàng hình, nền trắng chói trong dark, border biến mất
- [ ] Hover-only action không có đường thay thế trên touch
- [ ] Primary action nằm dưới fold hoặc trong vùng collapse

**MAJOR — vi phạm spec/budget, sửa trước khi giao:**
- [ ] Màn hình vượt density budget đã khai trong DESIGN-SPEC (đếm khối, không cảm tính)
- [ ] Step tiếp theo mong muốn (theo screen map) KHÔNG phải element nổi bật nhất màn hình
- [ ] Màn hình phục vụ ≥ 2 loại user nhưng chỉ có 1 bản "trung bình cộng" (user mới và power user thấy y hệt nhau)
- [ ] Vị trí/cỡ element không khớp bảng trọng số (item W3 nằm dưới fold; item W1 chiếm chỗ to bậc 0; item W0 vẫn hiện); hoặc > 2 item W3/màn hình
- [ ] Quá 1 nudge thăng cấp/màn hình, hoặc upsell chen lên trên job chính của user
- [ ] Thiếu trạng thái: empty không CTA, không skeleton, lỗi không lối thoát, chưa-login chưa quyết định
- [ ] Sau hành động chính, màn hình hiện ra KHÔNG khớp bảng action → expectation (tạo xong không thấy cái vừa tạo)
- [ ] Demo bằng lorem ipsum/dữ liệu đẹp thay vì dữ liệu thật cực đoan (tên dài, số 0, list dài)
- [ ] Spacing ngoài thang 4/8/12/16/24/32/48/64/80/96 (grep `[..px]` arbitrary trong code Tailwind)
- [ ] Cột số trong table thiếu `tabular-nums` hoặc không căn phải; hero KPI không đạt 2–3× cỡ label
- [ ] 2 primary button trong 1 màn hình; hàng > 3 button
- [ ] Title cùng cấp lệch ngữ pháp / có cái 2 dòng / lệch casing
- [ ] Badge sai bảng màu trạng thái đã chốt, hoặc badge > 2 từ
- [ ] Card cùng hàng lệch chiều cao; cột số không căn phải; lệch trục căn trái
- [ ] Số/ngày chưa format locale hoặc format lẫn lộn 2 kiểu
- [ ] Logo vi phạm quy tắc 04 (trên nền accent, thiếu khoảng thở, bị đổi màu)
- [ ] Mobile: table scroll ngang thay vì biến thành list card; form 2 cột
- [ ] Empty state trống trơn không có hành động; ô table trống không có "—"

**MINOR — ghi nhận, sửa nếu còn thời gian:**
- [ ] Transition giật/thiếu cho overlay; focus ring thiếu trên vài element
- [ ] Tooltip thiếu cho icon-only button phụ
- [ ] Cắt chuỗi truncate chưa có tooltip full text

## 3. Diagnose UI có sẵn (user chê "xấu", "rối", "chỏi")

Chạy ngược checklist: screenshot hiện trạng → đánh dấu vi phạm theo 3 mức → báo cáo
"X BLOCK, Y MAJOR" kèm ảnh → đề xuất thứ tự sửa: BLOCK → căn hàng/spacing (mục MAJOR
hình học — rẻ mà hiệu quả nhất) → text/title → màu. Kinh nghiệm: 80% cảm giác "rối"
đến từ spacing ngoài thang + lệch trục + title lộn xộn, KHÔNG phải do màu. Đừng đổi màu trước.

## 4. Định nghĩa "xong"

1. DESIGN-SPEC.md tồn tại và khớp với cái đã build (screen map, density, quyết định đã chốt)
2. Ma trận screenshot đủ, không còn BLOCK/MAJOR
3. MINOR còn lại được liệt kê tường minh
4. Báo cáo cuối kèm screenshot before/after nếu là task sửa
