# 03 — Acceptance Criteria: oracle hành vi (B6)

AC là **đầu ra giá trị nhất** của BA: nó là *oracle* mà `ui-ux-triage` dùng để phán "đúng hành vi chưa", và là "test" trong cặp doc+test của ai-simple (#04). Flow mô tả đường đi; AC chốt **đúng-sai kiểm được**.

## Dạng chuẩn: Given / When / Then

```
### AC-N — <tên ngắn>  · Maps to flow: <NVx>
- Given <tiền đề: trạng thái + user + điều kiện>
- When  <hành động kích hoạt>
- Then  <kết quả quan sát được: trạng thái dữ liệu mới + side-effect>
```

- **Given** lấy từ Input + Start của flow (precondition).
- **When** lấy từ một Step quyết định.
- **Then** lấy từ Output + side-effect. Phải **quan sát được** (kiểm bằng dữ liệu/trạng thái, không bằng cảm giác).

## 5 tiêu chí AC chất lượng (gate ghi)
| Tiêu chí | Sai ví dụ → Đúng |
|---|---|
| **Testable** (quan sát được) | "đơn được xử lý đúng" → "đơn chuyển trạng thái 'đã duyệt' và kho giảm đúng số lượng" |
| **Atomic** (1 hành vi/AC) | gộp tạo+duyệt+xuất → tách 3 AC |
| **Map tới 1 flow** | AC không gắn flow nào = hành vi mồ côi → bỏ hoặc thêm flow |
| **Không chứa từ UI** | "bấm nút xanh Duyệt" → "chủ shop duyệt đơn" |
| **Có nhánh lỗi** | chỉ happy path → thêm AC cho từ chối/thiếu input/quá hạn |

## Anti-UI — ranh giới vàng (quan trọng nhất)
AC mô tả **HÀNH VI**, không mô tả **GIAO DIỆN**. Cấm các từ: `màu · nút · button · góc · màn hình · sidebar · popup · modal · tab · click · kéo thả`.

| Sai (HOW-nhìn — việc của design) | Đúng (WHAT — việc của BA) |
|---|---|
| "Nút Duyệt màu xanh ở góc phải" | "Chủ shop có thể duyệt đơn đang chờ" |
| "Hiện popup xác nhận trước khi xoá" | "Xoá đơn yêu cầu xác nhận; huỷ thì đơn còn nguyên" |
| "Bảng hiển thị 20 dòng/trang" | "Người dùng truy được toàn bộ đơn trong kỳ" |

> Vì sao nghiêm: nếu AC nói UI, hai chuyện hỏng — (1) lấn việc `ui-design-logic`, (2) triage không phân tách được defect hành vi vs defect giao diện (2 oracle nhập nhằng). "20 dòng/trang" là quyết định density của design; BA chỉ đảm bảo "truy được toàn bộ".

> **Cơ giới hoá**: cổng `ba-verify.sh` **BLOCK** AC chứa component UI tiếng Anh (`button/sidebar/popup/modal/dropdown…`) và **WARN** cụm UI tiếng Việt tín-hiệu-cao (`bấm nút/nhấn nút/kéo thả/màn hình/thanh cuộn/click chuột`). Dùng CỤM (không phải từ trần) để khỏi báo nhầm từ domain (`nút giao thông`, `màu sơn`, `bấm giờ` → không WARN). WARN = tín hiệu viết lại, đừng kệ; anti-UI là luật, không phải gợi ý.

## Phủ đủ — không chỉ happy path
Mỗi flow sinh tối thiểu: 1 AC happy path + AC cho mỗi **nhánh** (từ chối/lỗi/thiếu input/quá hạn) + AC cho mỗi **invariant** (§9) dễ vỡ. Domain-Specialist (02) thường chỉ ra ca thiếu.

## Mỗi AC kèm CÁCH TEST — ai-simple #04 (không test được = chưa xong)
ai-simple #04: *"Code without test = future bug. Both = task chưa xong."* "User flow mới → E2E test". Spec hành vi cũng vậy: AC vẽ ra mà không chỉ được cách kiểm = vô dụng cho triage/build. **BA không viết test code** (đó là build), nhưng **BẮT BUỘC khai test INTENT** để spec test được:

- Mỗi AC thêm `Test:` chọn loại theo bảng #04:

| AC kiểm cái gì | Test loại |
|---|---|
| Một **flow** end-to-end (user đi từ start→end) | **e2e** (Playwright/Cypress) |
| Tương tác nhiều bước / nhiều bản ghi, side-effect (kho, công nợ, notification) | **integration** |
| Một **rule/invariant** thuần logic (§9) | **unit** |
| Permission / role | e2e với role matrix |
| Thật sự không tự động được (vd phán đoán người) | **manual** — PHẢI nêu lý do; hạn chế tối đa |

- Mỗi AC thêm dòng **`Assert`**: điểm đo cụ thể build sẽ kiểm (query trạng thái/đếm/so sánh). Nếu không viết được Assert đo bằng máy → **Then đang mơ hồ**, viết lại cho tới khi đo được. Đây là cách diệt "vẽ chán chê rồi không test được".
- Liên thông triage: `ui-ux-triage` dùng AC làm oracle — `Test:e2e` thì nó chạy flow đối chiếu, `Test:integration/unit` thì nó kiểm assert dữ liệu. Khai sẵn loại test = triage biết kiểm bằng cách nào.

## Assert phải ĐỊNH LƯỢNG (chống "đúng cú pháp nhưng vẫn mơ hồ")
AC đúng G/W/T + `Test:` vẫn có thể vô dụng nếu `Assert` chung chung: `Assert: query đơn có status đúng` — "đúng" = gì? Luật:
- **Assert chứa ≥1 giá trị/ngưỡng cụ thể**: so sánh (`status=="đã duyệt"`, `stock_reserved==0`, `count>=1`, `≤60s`), hoặc trạng-thái-đặt-tên rõ. Cấm "đúng / hợp lệ / như mong đợi / chuẩn".
- `ba-verify.sh` WARN khi Assert không có dấu định lượng (`== < > [0-9] " status count trạng thái số lượng`). WARN = tín hiệu viết lại, đừng kệ.

## Output
Điền §10 (Acceptance Criteria) của ba-spec. Mỗi AC: map tới flow §5 + có `Test:` + có `Assert` định lượng. Xong → Exit gates (SKILL §8) + `bash ba-verify.sh`: 0 component UI, không AC thiếu `Test`/`Assert`.
