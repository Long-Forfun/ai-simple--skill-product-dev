---
name: ai-simple-product-dev
description: Methodology for organizing software projects to be AI-agent-friendly. Use when bootstrapping a new project, retrofitting docs for AI pair-programming, onboarding an AI agent to an existing codebase, or when the user reports symptoms like "AI hallucinates", "context too long", "docs out of sync with code", "docs drift as the project grows", "schema change broke another repo", "AI asks me to confirm every little thing", "nobody knows how to restart the bot", "docs were good once but nobody maintains them", "what should we optimize next". Provides hierarchical context, app-map pattern, context routing, doc+test sync invariant, LOGIC vs REQUEST classification, risk-tiered pre-flight, memory-as-feedback, enforcement hooks, generated-vs-authored docs split, cross-repo contracts, ops runbooks, and a self-optimization loop with quarterly /audit, plus ready-to-copy templates.
---

# AI-Simple Product Dev

## Khi nào kích hoạt

- Khởi tạo project mới → setup `CLAUDE.md` + folder structure + pre-commit hook
- User báo "AI hallucinate / context dài / doc lệch code" → diagnose + propose
- Retrofit AI-friendly layer vào project hiện có
- User hỏi "làm sao Claude/Cursor hiểu project nhanh"
- Project phình to: root CLAUDE.md vượt budget, app-map > 20 file, nhiều repo chia sẻ schema → áp dụng lớp scale & tự tối ưu (08–12)
- Project có process chạy nền (cron/agent/pipeline) hoặc "không ai biết restart bot thế nào" → ops layer (11)
- User phàn nàn "AI hỏi confirm lặt vặt / chậm vì phải duyệt từng bước" → re-calibrate risk tier (06 v3)
- "Docs từng tốt giờ mục dần / lâu rồi không ai dọn / không biết nên tối ưu cái gì trước" → self-optimization loop + `/audit` (12)

## 12 nguyên tắc cốt lõi

**Nền tảng (mọi project):**
1. **Hierarchical Context** — root `CLAUDE.md` < 6000 tokens, point sang module-level `CLAUDE.md`
2. **App-map Pattern** — `docs/app-map/01-*.md`, `02-*.md`… mỗi file 1 chủ đề canonical; > 20 file → cây 2 tầng theo domain
3. **Context Routing** — `/fl <task>` slash + `context-router` sub-agent → ordered file list + risk tier; skip cho task trivial
4. **Doc + Test Sync Invariant** — code change BẮT BUỘC pair với doc + test cùng commit
5. **LOGIC vs REQUEST** — phân loại utterance: hỏi (LOGIC) → docs/memory; yêu cầu (REQUEST) → commit
6. **Pre-flight Risk Tiers (v3)** — GREEN (reversible bằng git): đi thẳng; YELLOW (reversible có chủ đích — bảng mới, cột nullable): tự làm phương án an toàn + Assumptions cuối task, KHÔNG hỏi; RED (không thể quay đầu — DROP, RLS nới lỏng, mutate prod): đúng 1 câu confirm gộp kèm phương án khuyến nghị. Confirm là ngoại lệ đắt giá, không phải nghi thức
7. **Memory as Feedback** — persist user preferences cross-session; user trả lời cùng loại câu hỏi 2 lần → ghi memory, không hỏi lại

**Lớp scale & vận hành (v2 — bắt buộc khi phình to / có process chạy nền):**
8. **Automated Enforcement** — pre-commit hook chặn (migration↔doc sync, token budget, contract version), CI lint cảnh báo, report tuần đo drift. Invariant tự giác = invariant sẽ chết
9. **Generated vs Authored Docs** — người viết "tại sao" (decisions, invariants, flows); máy sinh "cái gì" (`_generated/schema.md`, `routes.md`, content-stats) từ source of truth thật, regenerate trong hook/CI
10. **Cross-Repo Contract** — mỗi schema/file/utility dùng chung giữa nhiều repo có 1 file `docs/contracts/<name>.contract.md` ở producer, đánh version, consumers tự đăng ký; root CLAUDE.md hai đầu có bảng SYNC; mọi repo checkout cạnh nhau dưới 1 root khai báo tường minh
11. **Ops Layer** — project có process chạy nền (cron/agent/pipeline) phải có `docs/app-map/ops/`: runbook per service (start/stop, health, log, lỗi thường gặp, escalation), state registry, schedules + external-services registry, routing "sự cố → runbook trước code"; fix sự cố → update runbook cùng commit
12. **Self-Optimization Loop** — hệ docs tự tiến hóa theo NHỊP (commit: hook / tuần: report --ci / tháng: promote buffer + root diet + consolidate memory / quý: `/audit`) và theo TÍN HIỆU (bảng tín hiệu→hành động: file >1500 dòng → tách; drift thấp 2 tuần → siết hook; doc 90 ngày không ai route → RETIRE; doc sai căn bản → REBUILD từ code, không vá). `/audit` (slash command) tự chấm 12 nguyên tắc bằng số đo + semantic verify doc-vs-code → backlog tối ưu xếp hạng, append `docs/audit-history.md` (log append-only, KHÔNG để trong `_generated/` vì không regenerate được) để theo dõi trend

## Workflow áp dụng

```
1. Đọc methodology/README.md → grasp 12 principles
2. Copy templates/ → project root, fill placeholders
3. Cài pre-commit hook NGAY từ tuần đầu (retrofit muộn khó gấp 10 lần)
4. Verify: session mới đọc CLAUDE.md có đủ ngữ cảnh để biết đọc gì tiếp?
5. Bật Doc+Test sync từ commit ĐẦU TIÊN — đừng đợi sau
6. Khi chạm trigger scale (root 6K tokens / app-map 20 file / multi-repo / process chạy nền / hệ chạy >3 tháng) → áp 08–12
```

## Tài liệu chi tiết

- `methodology/01-hierarchical-context.md` — tại sao không 1 root file + root diet
- `methodology/02-app-map-pattern.md` — đánh số + chia chủ đề + phân cấp domain khi > 20 file
- `methodology/03-context-routing.md` — slash + sub-agent
- `methodology/04-doc-test-sync.md` — invariant table
- `methodology/05-logic-vs-request.md` — classification rule
- `methodology/06-pre-flight-checklist.md` — risk tiers GREEN/YELLOW/RED + anti-petty-review rules
- `methodology/07-memory-as-feedback.md` — behavioral persistence
- `methodology/08-automated-enforcement.md` — hook + lint + measurement
- `methodology/09-generated-vs-authored-docs.md` — `_generated/` convention
- `methodology/10-cross-repo-contract.md` — contract + bảng SYNC + path convention
- `methodology/11-ops-layer.md` — runbook, state registry, incident routing
- `methodology/12-self-optimization.md` — nhịp bảo trì, tín hiệu→hành động, update/refactor/rebuild/retire, `/audit`

## Skill chuyên môn đi kèm

- Project có UI → dùng skill `ui-design-logic` làm tầng chuyên môn design. Điểm móc 2 chiều
  (DESIGN-SPEC là canonical doc trong app-map, routing task UI, sync invariant UI⇄spec⇄screenshot,
  risk tier GREEN/YELLOW/RED cho việc design, hook check UI, drift routes-vs-screen-map vào `/audit`)
  định nghĩa tại `ui-design-logic/references/07-integration-ai-simple.md` — nguồn sự thật duy nhất, không lặp ở đây

## Templates

- `templates/CLAUDE.md.template` — root project guide
- `templates/app-map-README.md.template` — app-map index
- `templates/app-map-doc.md.template` — single canonical doc
- `templates/ADR.md.template` — architecture decision record
- `templates/context-router.agent.md.template` — sub-agent definition
- `templates/fl.command.md.template` — slash command
- `templates/pre-commit.hook.template` — enforcement hook, chạy được ngay với default Supabase; cài versioned qua `.githooks/` + `core.hooksPath`; verify bằng `--self-test`
- `templates/doc-health-report.sh.template` — report tuần: drift %, stale app-map, broken cross-ref, token budget, lint Load-khi/last-updated, _generated staleness
- `templates/runbook.md.template` — runbook per service chạy nền (5 mục tối thiểu)
- `templates/state-registry.md.template` — registry canonical cho state files (1 writer/state, atomic write)
- `templates/ops-schedules.md.template` — registry mọi cron/scheduled job (cơ chế, lệnh, cách verify đã chạy)
- `templates/ops-external-services.md.template` — registry API ngoài (auth, token ở đâu, rate limit, "khi nó chết thì sao")
- `templates/audit.command.md.template` — slash `/audit`: tự chấm 12 nguyên tắc bằng số đo + semantic verify → backlog tối ưu
- `templates/contract-doc.md.template` — cross-repo contract

## Anti-patterns

- ❌ Một root `CLAUDE.md` 20K tokens chứa mọi thứ → context bloat, AI bỏ qua phần cuối
- ❌ Đọc source code trước khi đọc doc → tốn token, dễ miss invariant
- ❌ Code commit không kèm doc → doc lệch ngay từ commit thứ 2
- ❌ Để AI tự đoán file structure thay vì route qua sub-agent → hallucination
- ❌ Trộn LOGIC question và REQUEST trong cùng turn → AI commit nhầm lúc user chỉ muốn discuss
- ❌ Invariant chỉ dựa kỷ luật tay, không có hook → drift chắc chắn khi project lớn
- ❌ Viết tay bảng schema/route inventory → stale sau 1 tuần, máy phải sinh
- ❌ Schema dùng chung giữa repo không có contract → silent break, lỗi hiện ở repo B nhưng nguyên nhân ở repo A
- ❌ Hỏi confirm cho việc reversible (bảng mới, cột nullable) → user thành nút OK lặt vặt, mất tốc độ; confirm chỉ dành cho điểm không thể quay đầu
- ❌ Hệ thống chạy nền không có runbook → sự cố lúc 2h sáng = đoán mò, bus factor 1
