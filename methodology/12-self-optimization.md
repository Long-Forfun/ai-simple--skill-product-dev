# 12 — Self-Optimization Loop (v2 — evidence-based)

> Doc mục khi code đổi, không phải khi lịch đến. Xương sống của vòng tự tối ưu là **bản đồ ghép nối doc↔code** (coupling map): mỗi doc khai báo nó cover code nào + lần verify cuối → staleness thành thứ MÁY TÍNH ĐƯỢC theo từng commit, và **không doc nào được DÙNG khi đang khả nghi mà chưa verify lại** (verify-on-use gate).
> *(EN: Docs rot when code changes, not when the calendar says so. The spine is a doc↔code COUPLING MAP — each doc declares what code it covers + when it was last verified — making staleness machine-computable per commit, and enforcing that no SUSPECT doc is ever USED without re-verification.)*

**v2 — 2026-06-12**: thiết kế lại theo nghiên cứu (EMSE 2024: 28,9% repo top GitHub document thứ không còn tồn tại, trung bình sai 4,7 năm mới bị phát hiện; ICPC 2019: doc chỉ được sửa trong đúng commit đổi code, lỡ là sai mãi; STALE benchmark 2026: AI agent tuân theo tiền đề cũ ~70% số lần nếu staleness không được đánh dấu tường minh). Bản v1 dùng lịch tuần/tháng/quý làm trục chính — sai trục: lịch chỉ còn vai trò phụ.

---

## Xương sống: coupling map + freshness frontmatter

Mỗi app-map doc (trừ `_generated/`) khai báo trong 10 dòng đầu:

```markdown
# 03 — Database and automation
> Load khi: đụng schema, RLS, trigger, cron
covers: supabase/migrations, src/lib/db
last_verified: 2026-06-12
ttl_days: 180
```

- `covers:` — danh sách FILE/DIR **có thật** (phẩy ngăn cách) mà doc này mô tả; match anchored: đúng path đó hoặc mọi thứ bên dưới (`src/lib` KHÔNG khớp `src/lib-utils`). **Doc không có covers = doc không được bảo vệ.** Ngoại lệ hợp lệ (exemption list): README router của app-map, doc thuần decision/vision/ADR, `_generated/`. Tùy chọn `gate: warn` cho vùng code churn rất cao (mặc định block)
- `last_verified:` — ngày lần cuối nội dung doc được đối chiếu với code thật (không phải ngày sửa doc!). Mốc này chỉ được máy NÂNG lên khi commit chạm doc là **gate-1-shaped** (cùng chạm covers path) hoặc message bắt đầu `re-verify(` — commit chore/typo chạm doc KHÔNG rửa được trạng thái SUSPECT (chống laundering)
- Chi phí: symbol-scan (check hàm trong doc còn tồn tại) chạy ở report `--ci`/tuần; hook per-commit dùng `--status --fast` (skip symbol) để giữ commit nhanh — dead symbol hiếm khi cần phát hiện trong-phút
- `ttl_days:` — hạn tin cậy THEO LOẠI doc: quickstart/flow hay đổi 90; architecture/decision 365. KHÔNG dùng một ngưỡng 30 ngày đồng loạt — tuổi không phải là mục (doc 300 ngày trên code không đổi vẫn VERIFIED)

**3 trạng thái doc** (máy tính từ git, không đoán):
| Trạng thái | Điều kiện | Hành xử |
|---|---|---|
| ✅ VERIFIED | code trong `covers` không đổi sau `last_verified` VÀ chưa quá TTL | Dùng bình thường |
| ⚠️ SUSPECT | code trong `covers` đổi sau `last_verified`, HOẶC quá TTL | **Verify-on-use** (xem dưới) |
| ☠️ ORPHANED | path trong `covers` không còn tồn tại | RETIRE flow |

---

## Hai cổng đảm bảo / The two gates

**CỔNG GHI (per-commit, hook — đã ship trong template):** commit đổi code nằm trong `covers` của doc nào → doc đó PHẢI được sửa hoặc bump `last_verified` trong CÙNG commit (xác nhận "tôi đã check, nội dung vẫn đúng"). Đây là quy tắc same-commit mà toàn bộ bằng chứng hội tụ về — lỡ cửa sổ commit là doc sai trung bình nhiều năm.

**CỔNG ĐỌC (verify-on-use, router + main agent):** context-router đánh dấu trạng thái từng doc trong output (đọc từ `_generated/doc-status.md` — hook regenerate MỖI COMMIT nên luôn fresh; không có status file → doc có covers bị coi là SUSPECT, **fail-closed**). Doc SUSPECT → main agent **BẮT BUỘC đối chiếu các khẳng định nó sắp dựa vào với code thật trước khi dùng** (bound phạm vi: chỉ các claim sắp dùng, không cả doc), rồi bump `last_verified` ngay trong task. `--status` còn chèn marker `<!-- DOC-STATUS: SUSPECT -->` vào CHÍNH doc — đường đọc trực tiếp không qua `/fl` cũng thấy cờ.

**Ranh giới của lời bảo đảm (nói thẳng, không nói quá):** điều được đảm bảo bằng cơ chế là *sai sót không vượt qua được thời điểm sử dụng* khi: (1) doc-status fresh — hook regenerate mỗi commit, nên cửa sổ mù chỉ còn là thay đổi chưa commit; (2) agent đi qua `/fl` hoặc thấy marker trong doc; (3) agent tuân thủ lệnh verify — tầng cuối này là prompt-level, được gia cố bằng marker hiển thị tại chỗ (STALE: staleness phải machine-visible thì agent mới không tin tiền đề cũ) và bằng audit spot-check các lần bump (bump phải kèm commit message `re-verify(<doc>): <claims đã check>` — bump không có claims là red flag rubber-stamp). Đây là giảm rủi ro rất mạnh có điều kiện nêu rõ — không phải phép màu tuyệt đối, và chính vì nêu rõ điều kiện nên audit đo được từng điều kiện một.

Chi phí cổng đọc tự giảm dần: mỗi lần verify là một lần bump `last_verified` → doc nóng (được dùng nhiều) gần như luôn VERIFIED; chỉ doc lạnh quay lại sau thời gian dài mới trả phí verify — đúng lúc đáng trả nhất.

---

## Nhịp — sự kiện trước, lịch sau / Event-first cadence

| Trigger | Cơ chế | Việc |
|---|---|---|
| **Mỗi commit** (sự kiện) | hook | Cổng ghi: covers-sync, migration↔doc, token budget, contract version, encoding guard |
| **Mỗi lần dùng doc** (sự kiện) | router + main agent | Cổng đọc: SUSPECT → verify trước khi tin → bump last_verified |
| **Mỗi PR / tuần** | report `--ci` | Doc-lag (xem Đo lường), escaped-drift, broken ref, `_generated` stale, regenerate `doc-status.md` |
| **Tháng** (lịch — việc không có sự kiện trigger) | AI session, người đọc 5' | Promote buffer 20-recent → file riêng; root diet nếu ≥ 80% budget; consolidate memory |
| **Quý** (lịch) | `/audit` | CHỈ còn 3 việc lịch thật sự cần: trend report, verify doc KHÔNG có covers (vision/decision), fire-drill runbook. Mọi verify doc-có-covers đã chạy theo sự kiện |

---

## Đo lường — thay proxy bằng số đo thật / Metrics v2

- **Doc-lag** (chính): số doc SUSPECT + tuổi lệch (ngày từ khi code đổi mà doc chưa re-verify). Mục tiêu: median 0, max < 7 ngày. Thay hẳn "drift % = % commit sửa code có kèm docs" của v1 — proxy đó đo *hoạt động* chứ không đo *độ đúng*, và rule "drift thấp → siết hook" của v1 là lệnh tự tối ưu proxy (Goodhart) — **đã xóa**.
- **Escaped-drift**: lỗi doc bị cổng đọc/audit phát hiện mà lẽ ra cổng ghi phải chặn → mỗi case là 1 pattern mới cho hook (phiên bản hợp lệ của "siết hook").
- **Hotspot = tần suất được route (từ `docs/.fl-routing-log`) × tần suất code trong covers đổi**: xếp độ sâu verify và thứ tự backlog. Doc nóng code động → verify kỹ nhất; doc lạnh code tĩnh → chỉ TTL.
- **Trigger tức thời**: agent làm theo doc X mà hành động fail → verify X ngay, không đợi gì cả.

---

## Bảng tín hiệu → hành động (v2)

| Tín hiệu (máy đo) | Hành động | Loại |
|---|---|---|
| Doc SUSPECT được route tới | Verify claims vs code trước khi dùng → bump last_verified | VERIFY (cổng đọc) |
| Commit đổi code trong covers | Sửa doc hoặc bump last_verified cùng commit — hook chặn | UPDATE (cổng ghi) |
| Drift cơ học: rename/move path, đổi signature, schema regenerate | Máy/agent tự vá phần tham chiếu, không cần quyết định ngữ nghĩa | **AUTO-SYNC** |
| Escaped-drift case mới | Thêm pattern vào hook | UPDATE hook |
| Root CLAUDE.md ≥ 80% budget | Root diet (01 §diet) | UPDATE |
| App-map file > 1500 dòng HOẶC router thường trả về file mà agent chỉ cần 1 section | Tách theo đơn vị retrieval (cái agent cần đọc trọn), không chỉ theo số dòng | REFACTOR |
| App-map > 20 file phẳng | Domain hóa 2 tầng (02 §scaling) | REFACTOR |
| Semantic verify: doc sai căn bản | Viết lại từ code thật, không vá (STALE/CUPMem: hòa giải lúc GHI thắng vá lúc đọc) | REBUILD |
| ORPHANED: path trong covers không còn tồn tại | DEPRECATED + ngày, giữ 1 tháng, xóa. Chỉ khai tử khi chủ thể đã chết | RETIRE |
| Doc lạnh (vắng routing-log 90 ngày) nhưng covers còn sống | KHÔNG xóa: check keyword map router (lạnh thường là lỗi router) + ưu tiên verify kỳ tới | UPDATE router / verify |
| Sự cố cùng loại lần 2 | Mục "lỗi thường gặp" trong runbook (11 §4) | UPDATE runbook |
| User trả lời cùng câu hỏi lần 2 | Persist memory (07) | UPDATE memory |

**Update vs Refactor vs Rebuild vs Retire**: đúng nền lệch chi tiết → UPDATE (kèm bump verify); đúng nội dung sai cỡ/granularity → REFACTOR (stub `MOVED →`); sai căn bản hoặc máy sinh được → REBUILD từ source of truth; chủ thể đã xóa khỏi code → RETIRE. Tuyệt đối không retire vì lượt đọc thấp — doc sống theo code.

→ Cross-ref nguyên tắc 02 §Lifecycle: doc bị **thay thế bởi doc kế nhiệm** thì giữ file + stub `DEPRECATED — replaced by NN-x.md` (link không gãy); doc **mồ côi** (không có kế nhiệm, chủ thể biến mất) mới đi flow RETIRE xóa sau 1 tháng.

---

## Tự chấm điểm — judge phải neo vào số đo / De-noised audit

Quý 1 lần, `/audit` (slash command, read-only trừ `docs/audit-history.md`):
1. Điểm mỗi nguyên tắc phải **neo vào sub-metric deterministic có sẵn lệnh đo** (doc-lag, escaped-drift, budget, hook self-test, covers coverage %...) — LLM chỉ diễn giải và bắt vùng xám, không chấm cảm tính
2. **"Hệ đang mục" chỉ được tuyên bố khi metric deterministic cũng xấu đi** — điểm judge LLM dao động giữa các lần chạy; 2 mẫu của máy đo nhiễu không phải trend
3. Semantic verify sâu: 3 doc hotspot cao nhất (theo công thức hotspot) — claim-by-claim vs code
4. Output: backlog xếp hạng theo hotspot, mỗi mục có loại hành động + effort + deadline; append 1 dòng vào `docs/audit-history.md`

---

## Anti-patterns

| Anti-pattern | Hậu quả |
|---|---|
| Verify theo lịch thay vì theo sự kiện đổi code | Doc sai nằm chờ tới 90 ngày — với AI agent là đầu độc ngữ cảnh, không phải "tham khảo kém" (STALE: agent tin tiền đề cũ ~70% nếu không đánh dấu) |
| Doc không khai `covers` (trừ doc thuần quyết định) | Nằm ngoài mọi cổng bảo vệ — staleness quay về đoán mò |
| Bump `last_verified` mà không thật sự đối chiếu | Đầu độc chính cơ chế — tệ hơn không bump; bump = lời cam kết "tôi đã check" |
| Dùng tuổi doc làm thước mục (stale 30d đồng loạt) | Tuổi không phải mục: doc già trên code tĩnh vẫn đúng; doc mới trên code vừa viết lại là khẩn cấp. Đo doc-LAG, không đo doc-AGE |
| Đo drift bằng % commit có kèm doc | Proxy gameable — đo hoạt động không đo độ đúng (Goodhart) |
| Tin trend từ 2 lần chấm LLM | Judge nhiễu; trend phải có metric deterministic đi kèm |
| Vá doc sai nền tảng thay vì rebuild | Chăn vá — AI đọc tin nhầm phần cũ |
| Xóa doc chỉ vì lâu không ai đọc | Đốt trí nhớ module còn sống — lúc code đụng lại mất sạch ngữ cảnh |
| Giữ doc MỒ CÔI "biết đâu cần" | AI đọc tin vào feature không còn tồn tại |

---

## Checklist áp dụng / Adoption checklist

- [ ] Mọi app-map doc gắn code có `covers:` + `last_verified:` + `ttl_days:` (audit đo % coverage)
- [ ] Hook có check covers-sync (cổng ghi) — `--self-test` pass
- [ ] `_generated/doc-status.md` được regenerate (report `--status`) và router đọc nó (cổng đọc)
- [ ] `docs/.fl-routing-log` + `docs/audit-history.md` được commit (append-only)
- [ ] `/audit` kỳ đầu đã chạy: điểm neo metric, backlog có owner + deadline
- [ ] Đã xóa mọi rule "drift % thấp → siết hook" nếu retrofit từ v1
