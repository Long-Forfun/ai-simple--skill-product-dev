---
name: ui-design-logic
description: Top-down, user-oriented UI/UX design methodology that guarantees consistent, intelligent, beautiful interfaces. Use whenever the user asks to design or build ANY web/app UI — dashboard, landing page, admin tool, mobile screen, form, report — even if they only say "make it pretty", "build a page", or "thêm màn hình". Enforces user-ladder segmentation (public vs account vs role/tier X/Y — per level: what they want to see, what the product communicates, what nudges their next action), per-screen behavior design (entry points, user goal, desired next step, action→expectation, logged-in/out/role/empty/loading/error state matrix, habit-based defaults), information architecture budgets (how many pages/tabs/flows/buttons), screen density limits + information compaction, component decision tables (badge vs tag, modal vs drawer vs page, table vs list vs cards), title/text grammar consistency, logo color harmonization, collapse/expand rules, and platform-specific adaptation (desktop/tablet/mobile as three distinct sub-designs; iOS follows HIG, Android follows Material). Locked stack React + Tailwind + shadcn/ui, ends with a mandatory screenshot QA loop. Parameters calibrated against award-winning apps and design-system research (see research/).
---

# UI Design Logic

## Triết lý

Design KHÔNG phải trang trí. Design là **chuỗi quyết định có logic, đi từ trên xuống**:

```
Ai dùng → họ đến để làm gì → cần bao nhiêu màn hình/flow
→ mỗi màn hình chứa gì (density budget) → dùng component nào (decision table)
→ trông ra sao (tokens, hoà màu logo) → chạy trên thiết bị nào (3 design con)
→ nghiệm thu bằng mắt (screenshot QA loop)
```

Cái đẹp là **hệ quả** của tính nhất quán + mật độ đúng + quyết định có lý do.
Cái xấu "lệch lệch khó tả" đến từ quyết định tuỳ hứng: title lúc dài lúc ngắn,
badge dùng bừa, popup vô tội vạ, logo chỏi màu. Skill này diệt sự tuỳ hứng.

## Khi nào kích hoạt

- User yêu cầu build/design bất kỳ UI nào (web, app, dashboard, landing, form, report)
- User chê UI hiện tại "xấu", "rối", "không đồng nhất", "chỏi" → diagnose bằng checklist 06
- Thêm màn hình/feature vào app đã có → đọc DESIGN-SPEC.md hiện có trước, tuân theo budget
- User đưa logo/brand color → chạy quy trình hoà màu (04)

## Pipeline 7 bước — BẮT BUỘC theo thứ tự, không nhảy cóc

```
0. Brief        → ĐỌC ba-spec nếu app-map có (do ba-flow-logic sinh): user-ladder seed từ §User registry, flow/screen từ §Flows, AC làm ràng buộc hành vi → KHÔNG hỏi lại user/job. KHÔNG có ba-spec → tự thu brief: ai dùng, làm gì, platform, logo/brand
1. IA + hành vi → THANG USER (loại × 3 câu — TIẾP NỐI từ ba-spec nếu có, không dựng lại) → object model, flow map, screen map + BUDGET, entry/step-tiếp/trạng thái/action→expectation → viết DESIGN-SPEC.md
2. Layout       → grid, density budget từng màn hình, quy tắc collapse/expand
3. Components   → tra decision table: component nào, text viết sao
4. Tokens       → màu (hoà logo), font, spacing — stack khoá React+Tailwind+shadcn
5. Platforms    → desktop/tablet/mobile = 3 design con; iOS theo HIG, Android theo Material
6. QA loop      → chạy preview, screenshot từng màn hình ở 3 kích thước, check, sửa, lặp
```

**DESIGN-SPEC.md là chốt chặn**: chưa có spec (bước 1) thì CHƯA được viết code UI.
Spec nhỏ cho task nhỏ — thêm 1 màn hình thì spec là 10 dòng, nhưng phải có,
vì nó ép trả lời "màn hình này tồn tại để user làm gì" trước khi vẽ.

**Cổng máy `design-verify.sh`** (anh em với `ba-verify.sh` / `triage-verify.sh`): cơ giới hoá
"spec chưa đủ = chưa được code". BLOCK khi design-spec thiếu frontmatter coupling, thiếu thang
user, thiếu screen map (hoặc bảng 0 dòng / header thiếu cột Vào từ·Goal·Step tiếp·Primary),
hoặc thiếu ma trận trạng thái. Lint SPEC, KHÔNG lint code (check px/màu ở code thuộc pre-commit
hook, ref 07 §5 — tránh 2 cơ chế cùng việc). Dùng: `sh design-verify.sh [--staged|--self-test]`.
Wire vào `.githooks/pre-commit` của project:
`if ! sh .claude/skills/ui-design-logic/design-verify.sh --staged; then FAIL=1; fi`

**Quan hệ với ba-spec (nếu dùng `ba-flow-logic`)**: ba-spec là oracle HÀNH VI (user→nghiệp vụ→flow→AC),
design-spec là oracle GIAO DIỆN (screen→token). Design ĐỌC ba-spec, KHÔNG phân tích user lại từ đầu —
chỉ tiếp nối: nghiệp vụ/flow của ba-spec → màn hình; AC của ba-spec → ràng buộc "màn này phải làm được gì".
Hai file riêng, hai oracle riêng cho `ui-ux-triage`. Không có ba-spec (task UI thuần) → design tự thu brief như cũ.

## Quy tắc cứng (không thương lượng — vi phạm là bug, không phải ý kiến)

**Kiến trúc & hành vi:**
- 1 màn hình = 1 nhiệm vụ chính = đúng 1 primary button
- Không design cho "user chung chung": spec khai báo **thang user** (public / mới / quen / power × role/tier), mỗi loại trả lời đủ 3 câu — *muốn thấy gì / sản phẩm truyền tải gì / thúc đẩy action tiếp theo gì*. Màn hình phục vụ ≥ 2 loại → có biến thể, cấm bản "trung bình cộng"
- Mỗi màn hình tối đa 1 nudge thăng cấp (upsell/mời đăng ký); cái USER CẦN luôn đứng trước cái SẢN PHẨM MUỐN
- Info trên màn hình được CHẤM TRỌNG SỐ 0–3 theo từng loại user (tần suất cần × ảnh hưởng quyết định) — trọng số quyết định vị trí/cỡ/bậc ẩn-hiện, không xếp theo cảm tính. Tối đa 2 item trọng số 3/màn hình; quá → màn hình đang gánh 2 nhiệm vụ, tách ra
- Mỗi màn hình khai báo trong spec: **vào từ đâu → muốn gì → step tiếp theo mong muốn** — và step tiếp theo đó phải là element nổi bật nhất màn hình
- Màn hình chưa định nghĩa đủ trạng thái (chưa login / role / trống / đang tải / lỗi / dữ liệu cực đoan) = mới design một nửa
- Mỗi hành động chính có dòng "user kỳ vọng thấy gì ngay sau đó" (action → expectation) — tạo xong phải thấy cái vừa tạo, xoá xong phải có Undo
- Nav hiển thị trên mobile bottom tabs / top nav: ≤ 5 mục (M3 hard max). Desktop sidebar: 5–7 mục cấp 1 + nhóm section collapse được — giới hạn thật là SỐ NHÓM và ĐỘ SÂU (≤ 2 cấp), không phải số link (NN/g: menu là recognition, broad-shallow thắng deep-narrow). Tab trong page: 2–6 tab, KHÔNG tab lồng tab
- Core action của app: user chạm tới trong ≤ 3 click/tap từ màn hình chính

**Nhất quán text:**
- Title cùng cấp = cùng ngữ pháp (cùng là danh từ hoặc cùng là động từ), luôn 1 dòng, không chấm câu cuối
- Sentence case mọi nơi. Badge ≤ 2 từ. Số liệu luôn format theo locale

**Mật độ & thao tác:**
- Spacing chỉ dùng thang 4/8/12/16/24/32/48/64/80/96px — số ngoài thang là bug (80/96 dành riêng cho khoảng giữa section lớn/landing)
- "Nén trong widget, thoáng giữa widget": thông tin luôn đọc cùng nhau (hiện có/tổng, số/%, giá trị/xu hướng) nằm CÙNG 1 widget; 1 câu hỏi của user không được cần 2 widget để trả lời
- 1 hàng button ≤ 3 cái; còn lại vào menu ⋯
- Hover KHÔNG BAO GIỜ là cách duy nhất làm một việc (touch không có hover)
- Touch target ≥ 44×44pt (iOS) / 48×48dp (Android); desktop được phép dày hơn mobile

**Visual:**
- 1 neutral ramp + 1 accent + 4 màu semantic. Hết. Logo xử lý theo 04, không nhét thô
- Text contrast ≥ 4.5:1. Dark mode phải được kiểm tra, không phải "để sau"

## Tài liệu chi tiết — đọc đúng file theo bước đang làm

- `references/01-information-architecture.md` — object model, flow map, budget page/tab/button, template DESIGN-SPEC
- `references/02-layout-and-density.md` — grid, density budget, thang progressive disclosure, quy tắc collapse/expand
- `references/03-component-decision-rules.md` — bảng tra: table vs list vs card vs map; badge vs tag; modal vs drawer vs page; quy tắc title/text/số
- `references/04-visual-tokens.md` — token đầy đủ, thuật toán hoà màu logo, shadcn theming
- `references/05-platform-adaptation.md` — 3 design con, biến đổi nav theo thiết bị, iOS vs Android vs desktop, chuột vs chạm
- `references/06-qa-acceptance.md` — checklist nghiệm thu, quy trình screenshot loop, phân cấp lỗi
- `references/07-integration-ai-simple.md` — ĐỌC KHI project dùng ai-simple-product-dev: DESIGN-SPEC vào app-map, routing task UI, sync invariant UI⇄spec⇄screenshot, risk tier cho design, hook check UI, drift routes vs screen map

## Stack (khoá cứng)

React + Tailwind CSS + shadcn/ui. Component chuẩn (button, card, dialog, form, table,
tabs, sheet, dropdown) BẮT BUỘC dùng shadcn — cấm tự viết lại từ đầu.
Lý do: floor quality. Component shadcn đã được con người tinh chỉnh spacing/contrast/states;
tự viết là mở cửa cho sự tuỳ hứng quay lại. Chỉ custom khi shadcn không có loại đó
(chart, map, canvas) — và khi custom thì phải tuân token 04.

Dự án không phải React (HTML tĩnh, Vue): vẫn áp dụng nguyên pipeline + token,
thay shadcn bằng component tự viết theo đúng spec trong 03/04.
