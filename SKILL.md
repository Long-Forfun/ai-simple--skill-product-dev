---
name: ai-simple-product-dev
description: Methodology for organizing software projects to be AI-agent-friendly. Use when bootstrapping a new project, retrofitting docs structure for AI pair-programming, onboarding an AI agent to an existing codebase, or when the user reports symptoms like "AI hallucinates", "context too long", "docs out of sync with code", "Claude/Cursor doesn't understand my project". Provides hierarchical context, app-map pattern, context routing, doc+test sync invariant, LOGIC vs REQUEST classification, pre-flight risk flags, memory-as-feedback, plus ready-to-copy templates.
---

# AI-Simple Product Dev

## Khi nào kích hoạt

- Khởi tạo project mới → setup `CLAUDE.md` + folder structure
- User báo "AI hallucinate / context dài / doc lệch code" → diagnose + propose
- Retrofit AI-friendly layer vào project hiện có
- User hỏi "làm sao Claude/Cursor hiểu project nhanh"

## 7 nguyên tắc cốt lõi

1. **Hierarchical Context** — root `CLAUDE.md` < 6000 tokens, point sang module-level `CLAUDE.md`
2. **App-map Pattern** — `docs/app-map/01-*.md`, `02-*.md`… mỗi file 1 chủ đề canonical
3. **Context Routing** — `/fl <task>` slash + `context-router` sub-agent → ordered file list
4. **Doc + Test Sync Invariant** — code change BẮT BUỘC pair với doc + test cùng commit
5. **LOGIC vs REQUEST** — phân loại utterance: hỏi (LOGIC) → docs/memory; yêu cầu (REQUEST) → commit
6. **Pre-flight Checklist** — flag DB / auth / migration risk TRƯỚC khi code
7. **Memory as Feedback** — persist user preferences cross-session

## Workflow áp dụng

```
1. Đọc methodology/README.md → grasp 7 principles
2. Copy templates/ → project root, fill placeholders
3. Verify: session mới đọc CLAUDE.md có đủ ngữ cảnh để biết đọc gì tiếp?
4. Bật Doc+Test sync từ commit ĐẦU TIÊN — đừng đợi sau
```

## Tài liệu chi tiết

- `methodology/01-hierarchical-context.md` — tại sao không 1 root file
- `methodology/02-app-map-pattern.md` — cách đánh số + chia chủ đề
- `methodology/03-context-routing.md` — slash + sub-agent
- `methodology/04-doc-test-sync.md` — invariant table
- `methodology/05-logic-vs-request.md` — classification rule
- `methodology/06-pre-flight-checklist.md` — risk flagging
- `methodology/07-memory-as-feedback.md` — behavioral persistence

## Templates

- `templates/CLAUDE.md.template` — root project guide
- `templates/app-map-README.md.template` — app-map index
- `templates/app-map-doc.md.template` — single canonical doc
- `templates/ADR.md.template` — architecture decision record
- `templates/context-router.agent.md.template` — sub-agent definition
- `templates/fl.command.md.template` — slash command

## Anti-patterns

- ❌ Một root `CLAUDE.md` 20K tokens chứa mọi thứ → context bloat, AI bỏ qua phần cuối
- ❌ Đọc source code trước khi đọc doc → tốn token, dễ miss invariant
- ❌ Code commit không kèm doc → doc lệch ngay từ commit thứ 2
- ❌ Để AI tự đoán file structure thay vì route qua sub-agent → hallucination
- ❌ Trộn LOGIC question và REQUEST trong cùng turn → AI commit nhầm lúc user chỉ muốn discuss
