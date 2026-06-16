# 07 — Tích hợp với ai-simple-product-dev

Hai skill ở 2 tầng: **ai-simple-product-dev = hệ điều hành project** (docs, context routing,
enforcement, risk tier); **ui-design-logic = chuyên môn UI** chạy bên trong hệ điều hành đó.
Project nào dùng cả hai thì áp các điểm móc sau — mỗi điểm móc vào đúng 1 nguyên tắc của ai-simple.

> **App-map có thể chứa 2 spec**: `ba-spec` (do `ba-flow-logic` — oracle HÀNH VI: user/nghiệp vụ/flow/AC) và
> `design-spec` (skill này — oracle GIAO DIỆN: screen/token). Design ĐỌC ba-spec làm input (xem `01 §1`), KHÔNG
> phân tích user lại. Cả hai là canonical app-map doc riêng, đều có frontmatter coupling, đều là oracle riêng cho
> `ui-ux-triage`. Bước 0 pipeline: có ba-spec → seed từ đó; không có → tự thu brief.

## 1. DESIGN-SPEC.md là một canonical doc trong app-map (móc nguyên tắc 2 + 12 v2)

- Vị trí: `docs/app-map/0X-design-spec.md` (đánh số theo hệ app-map của project), KHÔNG để
  ở root như project trần. Một nguồn sự thật duy nhất cho design — không có bản sao thứ hai
- Frontmatter ĐẦY ĐỦ theo nguyên tắc 12 v2 — DESIGN-SPEC là doc dễ mục nhất repo (UI đổi
  liên tục), không có coupling map là nằm ngoài cả 2 cổng bảo vệ:

```markdown
> Load khi: task chạm UI/screen/component/flow/style
covers: src/app, src/components
last_verified: {{YYYY-MM-DD}}
ttl_days: 90
```

- `covers:` trỏ đúng các thư mục UI của project (app/pages/screens/components). UI churn
  cao mà thấy cổng ghi chặn phiền → dùng `gate: warn` thay vì bỏ covers

## 2. Context routing biết route task UI (móc nguyên tắc 3)

Thêm rule vào context-router: task là UI → ordered list bắt đầu bằng
`docs/app-map/0X-design-spec.md`, rồi đúng file reference của ui-design-logic theo bước pipeline
(thêm màn hình → 01; chỉnh layout/density → 02; chọn component/viết text → 03; màu/token → 04;
responsive/mobile → 05; user chê xấu → 06). Không load cả 7 file cho một task sửa button.

## 3. Sync invariant mở rộng: UI code ⇄ DESIGN-SPEC ⇄ screenshot (móc nguyên tắc 4 + 12 v2)

Code UI đổi hành vi/cấu trúc → DESIGN-SPEC cập nhật CÙNG COMMIT (screen map, trọng số,
ma trận trạng thái) — với `covers:` ở mục 1, điều này được **cổng ghi enforce bằng máy**,
không còn là kỷ luật tay. Screenshot QA loop (06) đóng vai trò "test" trong cặp doc+test
của UI: màn hình mới chưa có ảnh nghiệm thu 3 viewport = chưa xong, tương đương thiếu test.

**Verify-on-use cho DESIGN-SPEC** (cổng đọc): router gắn ⚠️ SUSPECT khi UI code đổi sau
`last_verified` → cách đối chiếu ĐÚNG CHO DOC UI chính là một vòng QA loop thu nhỏ:
so screen map với routes thật + chụp nhanh màn hình bị ảnh hưởng, khớp thì bump
`last_verified` kèm dòng `<!-- re-verified: ... -->`. Hai skill khớp răng ở đúng chỗ này —
QA loop của ui-design-logic là cơ chế verify mà cổng đọc của ai-simple yêu cầu.

## 4. Risk tier cho công việc design (móc nguyên tắc 6)

| Tier | Việc design | Hành xử |
|---|---|---|
| GREEN | Sửa trong budget + token hiện có: chỉnh component, spacing, text, màu theo 04 | Làm thẳng, không hỏi |
| YELLOW | Thêm màn hình/biến thể TRONG budget; thêm preset màu; đổi default theo thói quen | Tự làm theo phương án an toàn + ghi Assumptions cuối task |
| RED | PHÁ budget cấu trúc: tái cấu trúc nav, gộp/tách màn hình ảnh hưởng flow toàn app, đổi design token toàn cục (accent, radius, font), đổi thang user | Đúng 1 câu confirm gộp kèm phương án khuyến nghị |

Khớp với 01 §8: màn hình mới phá budget → đề xuất tái cấu trúc TRƯỚC (RED), không nhét thêm.

## 5. Enforcement hook thêm check UI (móc nguyên tắc 8)

- ~~Diff có file UI mà không kèm DESIGN-SPEC → warn~~ **ĐÃ THAY THẾ**: check này được
  covers-sync của 12 v2 làm hộ, mạnh hơn (block, có `gate: warn` knob, có fixture) — chỉ cần
  khai `covers:` đúng ở mục 1, KHÔNG viết check riêng (2 cơ chế cùng việc = drift đôi)
- Vẫn thêm 2 pattern UI-riêng vào hook của project:
  - `grep -E 'className="[^"]*\[[0-9]+px\]'` trên file staged → BLOCK: vi phạm thang spacing (04 §5)
  - Route/page mới trong code mà screen map không có dòng tương ứng → WARN (đối chiếu
    `_generated/routes.md`, xem mục 6)
- **`design-verify.sh --staged`** là cổng thứ hai, KHÁC việc với covers-sync ở trên — không drift đôi:
  covers-sync enforce *code ⇄ doc coupling* (UI đổi thì spec phải re-verify); design-verify enforce
  *spec đầy đủ* (thang user / screen map đủ cột + ≥1 dòng / ma trận trạng thái / frontmatter). Một cái
  giữ doc khỏi mục, cái kia giữ doc khỏi rỗng. Wire cả hai vào `.githooks/pre-commit`:
  `if ! sh .claude/skills/ui-design-logic/design-verify.sh --staged; then FAIL=1; fi`

## 6. Generated vs authored cho UI (móc nguyên tắc 9 + 12)

- Máy sinh `_generated/routes.md` từ router của code; screen map trong DESIGN-SPEC là authored
- doc-health-report (`--ci` mỗi PR, không phải đợi tuần) đối chiếu 2 bảng → "route có trong
  code nhưng không có trong screen map" là drift đo được
- Trong `/audit` quý: DESIGN-SPEC gần như luôn là top-hotspot (route-freq × churn UI đều cao)
  → mặc định nằm trong 3 doc được semantic verify sâu (Bước 2 của audit)

## 7. Memory as feedback cho design (móc nguyên tắc 7)

Mục "Quyết định đã chốt" + "Thói quen cần nhớ" trong DESIGN-SPEC là memory tầng project cho design.
User sửa cùng một loại quyết định design 2 lần (vd: luôn đổi drawer thành page riêng) → ghi vào
"Quyết định đã chốt", không hỏi lại lần 3.
