---
name: ai-simple-product-dev
description: Methodology for organizing a software project to be AI-agent-friendly. Use when starting a new project, refactoring docs structure for AI pair-programming, or onboarding an AI agent to an existing codebase. Provides hierarchical context pattern, app-map docs, context routing, doc+test sync invariant, and templates.
---

# AI-Simple Product Dev — Skill

## Khi nào dùng / When to invoke

### VI
- User đang khởi tạo project mới → setup CLAUDE.md + folder structure
- User nói "AI cứ hallucinate / context dài quá / doc lệch code" → diagnose + propose
- User muốn add AI-friendly layer vào project hiện có
- User hỏi "làm sao để Claude/Cursor hiểu project nhanh"

### EN
- User is bootstrapping a new project → set up CLAUDE.md + folder structure
- User reports "AI keeps hallucinating / context too long / docs out of sync" → diagnose + propose
- User wants to retrofit AI-friendly layer onto an existing project
- User asks "how do I make Claude/Cursor understand my project fast"

## 7 nguyên tắc cốt lõi / 7 core principles

1. **Hierarchical Context** — root `CLAUDE.md` < 6000 tokens, point to module-level `CLAUDE.md`
2. **App-map Pattern** — `docs/app-map/01-*.md`, `02-*.md`… mỗi file 1 chủ đề canonical
3. **Context Routing** — `/fl <task>` slash command + `context-router` sub-agent → output ordered file list
4. **Doc + Test Sync Invariant** — code change BẮT BUỘC pair với doc + test cùng commit
5. **LOGIC vs REQUEST** — phân loại utterance: hỏi (LOGIC) → docs/memory; yêu cầu (REQUEST) → commit
6. **Pre-flight Checklist** — DB risk / auth risk / migration risk flag TRƯỚC khi code
7. **Memory as Feedback** — persist user preferences (commit flow, safety rails) cross-session

## Workflow áp dụng / Application workflow

```
1. Đọc README.md repo này → hiểu pitch
2. Đọc methodology/README.md → grasp 7 principles
3. Copy templates/ → project root, edit placeholders
4. Verify với check: AI session mới đọc CLAUDE.md có đủ ngữ cảnh để biết phải đọc gì tiếp?
5. Áp dụng Doc+Test sync từ commit ĐẦU TIÊN — đừng đợi sau
```

## Tài liệu chi tiết / Detailed docs

- `methodology/01-hierarchical-context.md` — tại sao không dùng 1 root file
- `methodology/02-app-map-pattern.md` — cách đánh số + chia chủ đề
- `methodology/03-context-routing.md` — slash command + sub-agent
- `methodology/04-doc-test-sync.md` — invariant table (code → doc → test)
- `methodology/05-logic-vs-request.md` — classification rule
- `methodology/06-pre-flight-checklist.md` — risk flagging
- `methodology/07-memory-as-feedback.md` — behavioral persistence

## Templates sẵn sàng dùng / Ready-to-use templates

- `templates/CLAUDE.md.template` — root project guide
- `templates/app-map-README.md.template` — app-map index
- `templates/app-map-doc.md.template` — single canonical doc
- `templates/ADR.md.template` — architecture decision record
- `templates/context-router.agent.md.template` — sub-agent definition
- `templates/fl.command.md.template` — slash command

## Anti-patterns

- ❌ Một root `CLAUDE.md` 20K tokens chứa mọi thứ → context bloat, AI bỏ qua phần cuối
- ❌ Đọc source code trước khi đọc doc → AI tốn token, dễ miss invariant
- ❌ Code commit không kèm doc → doc lệch ngay từ commit thứ 2
- ❌ Để AI tự đoán file structure thay vì route qua sub-agent → hallucination
- ❌ Trộn LOGIC question và REQUEST trong cùng turn → AI commit nhầm lúc user chỉ muốn discuss
