# 05 — Tích hợp với ai-simple-product-dev

Hai tầng: **ai-simple = hệ điều hành project** (app-map, routing, gate, tier, memory, verify); **ba-flow-logic = chuyên môn PHÂN TÍCH** chạy bên trong. Dùng cả hai thì áp các điểm móc sau — mỗi điểm móc vào đúng 1 nguyên tắc ai-simple, KHÔNG tự chế lại.

## 1. ba-spec là canonical app-map doc (móc #02 + #12)
- Vị trí: `docs/app-map/0X-ba-spec[-<domain>].md` — KHÔNG để root. Một nguồn sự thật cho hành vi.
- Frontmatter ĐẦY ĐỦ (ba-spec là doc dễ mục: nghiệp vụ đổi theo nhu cầu):

```markdown
> Load khi: task chạm hành vi/nghiệp vụ/flow/acceptance của <domain>
covers: src/<feature thực hiện nghiệp vụ>
last_verified: {{YYYY-MM-DD}}
ttl_days: 90
```

- `covers:` trỏ code hiện thực nghiệp vụ (không phải code UI thuần — đó là việc design-spec). Code nghiệp vụ đổi → ba-spec ⚠️ SUSPECT → triage biết oracle có thể cũ.

## 2. Context routing biết route task BA (móc #03)
Thêm rule context-router: task là *nhu cầu/nghiệp vụ/flow mới* → ordered list bắt đầu bằng `docs/app-map/0X-ba-spec.md`, rồi reference theo bước (user/nghiệp vụ → 01; flow/tối ưu → 02; AC → 03; reverse → 04). Đổi nhỏ đã rõ → KHÔNG load BA, vào build.

## 3. Sync invariant: code nghiệp vụ ⇄ ba-spec ⇄ AC ⇄ test (móc #04 + #12)
Code đổi HÀNH VI nghiệp vụ → ba-spec cập nhật CÙNG COMMIT (flow, AC, invariant). Với `covers:` ở mục 1, cổng ghi enforce bằng máy. **AC đóng vai "test"** trong cặp doc+test: nghiệp vụ mới chưa có AC = chưa xong, tương đương thiếu test.

**Mỗi AC PHẢI test được (#04 mạnh):** AC khai `Test:` (e2e | integration | unit | manual) + `Assert` đo được — đây là **test INTENT** mà build dựa vào để viết test CODE. Map đúng bảng test #04: *user flow mới → E2E*. Quy tắc: nghiệp vụ/flow vẽ ra mà AC không chỉ được cách kiểm = **chưa xong**, không chỉ thiếu doc mà thiếu test. Build commit code nghiệp vụ → kèm test khớp `Test:` của AC (cổng test của #04).

**Cơ giới hoá (không để honor-system) — `ba-verify.sh`:** ai-simple #08 dạy "invariant chết nếu chỉ dựa kỷ luật". Cổng `ba-verify.sh` parse ba-spec và **exit 1 (BLOCK)** nếu: ba-spec 0 AC · AC thiếu `Test:` · AC thiếu `Assert` · thiếu frontmatter. Wire vào `.githooks/pre-commit` của project (cùng chỗ covers-sync của ai-simple) để **commit ba-spec thiếu test bị chặn thật**:
```sh
# trong .githooks/pre-commit, sau block covers-sync:
if ! sh .claude/skills/ba-flow-logic/ba-verify.sh --staged; then FAIL=1; fi
```
Junction skill → bản global mới nhất, không copy thư mục (tránh drift, bài học #08/#10). Vắng wiring → vẫn còn tầng skill-rule (exit gate §8) nhưng đó là kỷ luật AI; muốn chắc thì BẮT BUỘC wire cổng.

**Verify-on-use cho ba-spec** (cổng đọc): router gắn ⚠️ SUSPECT khi code nghiệp vụ đổi sau `last_verified` → đối chiếu AC với hành vi code thật (chạy thử/đọc logic), khớp thì bump `last_verified` kèm `<!-- re-verified: ... -->`. **TTL hết hạn** (thời gian trôi quá `ttl_days` dù code chưa đổi) cũng → SUSPECT: task mới chạm ba-spec quá hạn phải **re-verify AC với nhu cầu HIỆN TẠI** (nhu cầu có thể đã đổi dù code chưa) trước khi tin, rồi bump.

## 4. Risk tier cho công việc BA (móc #06) — chi tiết ở `04-reverse-handoff-risk.md`
GREEN: thêm AC/flow mới · YELLOW: thêm nghiệp vụ trong scope + Assumptions · RED: sửa/xoá AC downstream phụ thuộc → 1 ASK gộp.

## 5. Generated vs authored (móc #09)
- ba-spec là **authored** (con người/AI quyết "đúng là gì").
- Có thể generate phụ trợ: `_generated/flow-graph.md` từ ba-spec flows để soi dead-end bằng máy (Cross-User-Integrity tự động hoá). Không bắt buộc.

## 6. /audit (móc #12)
Flow optimization log (§6 ba-spec) + History là bằng chứng cho `/audit` quý: nghiệp vụ nào AC chưa phủ nhánh lỗi, flow nào chưa qua Optimizer, cross-user nào còn treo → backlog tối ưu.

## 7. Memory (móc #07)
Quyết định BA lặp (ưu tiên flow ngắn vs an toàn, granularity nghiệp vụ) → ghi memory feedback theo format ai-simple, ≥2x thì promote rule, không hỏi lại.

## 8. Guard KHÔNG chặn sửa flow (giải toả hiểu lầm thường gặp)
Cổng covers-sync của ai-simple **bất đối xứng**: fire lúc COMMIT, chỉ khi **code trong `covers` đổi mà doc KHÔNG đổi** → BLOCK. Suy ra:
- Sửa flow/AC trong ba-spec (chỉ doc) → cổng KHÔNG fire → **sửa thoải mái** (spec-first hợp lệ; code làm sau).
- Code đổi mà ba-spec không update → BLOCK — đó là guard đứng VỀ PHÍA BA, giữ flow không bị code bỏ rơi.
- "Cổng" thật của sửa flow = **risk-tier #06**: doc edit = GREEN (làm thẳng); chỉ sửa/xoá AC downstream phụ thuộc = RED (1 ASK). BA defer, không bị chặn oan.
- BA **không tự commit** (#08) — chỉ sửa doc; hook chạy lúc build/user commit, lúc đó ba-spec đã sẵn → qua.

**⚠️ Windows/PowerShell**: cổng encoding (hook mục 3b) BLOCK file `.md` có **BOM/mojibake**. PS 5.1 `Set-Content`/`Out-File` thêm BOM → sửa ba-spec PHẢI dùng Edit/Write tool (UTF-8 no BOM), KHÔNG dùng PS `Set-Content`.

## Degrade
Vắng ai-simple trong repo → vẫn chạy: ba-spec để root tạm, tier áp cục bộ, bỏ phần coupling/hook. Có ai-simple thì BẮT BUỘC theo mục 1–8.
