---
name: ai-simple-product-dev
description: Methodology for organizing software projects to be AI-agent-friendly. Use when bootstrapping a new project, retrofitting docs structure for AI pair-programming, onboarding an AI agent to an existing codebase, or when the user reports symptoms like "AI hallucinates", "context too long", "docs out of sync with code", "Claude/Cursor doesn't understand my project", "docs drift as the project grows", "schema change broke another repo". Provides hierarchical context, app-map pattern (with domain-tree scaling), context routing, doc+test sync invariant, LOGIC vs REQUEST classification, pre-flight risk flags, memory-as-feedback, automated enforcement hooks, generated-vs-authored docs split, cross-repo contracts, plus ready-to-copy templates.
---

# AI-Simple Product Dev

## Khi nào kích hoạt

- Khởi tạo project mới → setup `CLAUDE.md` + folder structure + pre-commit hook
- User báo "AI hallucinate / context dài / doc lệch code" → diagnose + propose
- Retrofit AI-friendly layer vào project hiện có
- User hỏi "làm sao Claude/Cursor hiểu project nhanh"
- Project phình to: root CLAUDE.md vượt budget, app-map > 20 file, nhiều repo chia sẻ schema → áp dụng lớp scale (08–10)

## 10 nguyên tắc cốt lõi

**Nền tảng (mọi project):**
1. **Hierarchical Context** — root `CLAUDE.md` < 6000 tokens, point sang module-level `CLAUDE.md`
2. **App-map Pattern** — `docs/app-map/01-*.md`, `02-*.md`… mỗi file 1 chủ đề canonical; > 20 file → cây 2 tầng theo domain
3. **Context Routing** — `/fl <task>` slash + `context-router` sub-agent → ordered file list
4. **Doc + Test Sync Invariant** — code change BẮT BUỘC pair với doc + test cùng commit
5. **LOGIC vs REQUEST** — phân loại utterance: hỏi (LOGIC) → docs/memory; yêu cầu (REQUEST) → commit
6. **Pre-flight Checklist** — flag DB / auth / migration risk TRƯỚC khi code
7. **Memory as Feedback** — persist user preferences cross-session

**Lớp scale (v2 — bắt buộc khi phình to):**
8. **Automated Enforcement** — pre-commit hook chặn (migration↔doc sync, token budget, contract version), CI lint cảnh báo, report tuần đo drift. Invariant tự giác = invariant sẽ chết
9. **Generated vs Authored Docs** — người viết "tại sao" (decisions, invariants, flows); máy sinh "cái gì" (`_generated/schema.md`, `routes.md`, content-stats) từ source of truth thật, regenerate trong hook/CI
10. **Cross-Repo Contract** — mỗi schema/file/utility dùng chung giữa nhiều repo có 1 file `docs/contracts/<name>.contract.md` ở producer, đánh version, consumers tự đăng ký; root CLAUDE.md hai đầu có bảng SYNC

## Workflow áp dụng

```
1. Đọc methodology/README.md → grasp 10 principles
2. Copy templates/ → project root, fill placeholders
3. Cài pre-commit hook NGAY từ tuần đầu (retrofit muộn khó gấp 10 lần)
4. Verify: session mới đọc CLAUDE.md có đủ ngữ cảnh để biết đọc gì tiếp?
5. Bật Doc+Test sync từ commit ĐẦU TIÊN — đừng đợi sau
6. Khi chạm trigger scale (root 6K tokens / app-map 20 file / multi-repo) → áp 08–10
```

## Tài liệu chi tiết

- `methodology/01-hierarchical-context.md` — tại sao không 1 root file + root diet
- `methodology/02-app-map-pattern.md` — đánh số + chia chủ đề + phân cấp domain khi > 20 file
- `methodology/03-context-routing.md` — slash + sub-agent
- `methodology/04-doc-test-sync.md` — invariant table
- `methodology/05-logic-vs-request.md` — classification rule
- `methodology/06-pre-flight-checklist.md` — risk flagging
- `methodology/07-memory-as-feedback.md` — behavioral persistence
- `methodology/08-automated-enforcement.md` — hook + lint + measurement
- `methodology/09-generated-vs-authored-docs.md` — `_generated/` convention
- `methodology/10-cross-repo-contract.md` — contract + bảng SYNC

## Templates

- `templates/CLAUDE.md.template` — root project guide
- `templates/app-map-README.md.template` — app-map index
- `templates/app-map-doc.md.template` — single canonical doc
- `templates/ADR.md.template` — architecture decision record
- `templates/context-router.agent.md.template` — sub-agent definition
- `templates/fl.command.md.template` — slash command
- `templates/pre-commit.hook.template` — enforcement hook (sửa pattern theo project)
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
