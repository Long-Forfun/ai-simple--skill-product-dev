# AI-Augmented Product Development — A Simple Skill

> **VI**: Phương pháp đơn giản để tổ chức một dự án phần mềm khi đồng hành cùng AI coding agent (Claude Code, Cursor, Aider, …). Không phải framework, không phải tool — là **bộ nguyên tắc + template** giúp AI hiểu codebase nhanh, không hallucination, không bloat context.
>
> **EN**: A simple skill for organizing a software project when pair-programming with an AI coding agent (Claude Code, Cursor, Aider, …). Not a framework, not a tool — a **set of principles + templates** that help the AI understand the codebase quickly, without hallucination, without context bloat.

---

## Tại sao cần / Why this exists

### VI
Khi dev với AI agent, 3 vấn đề phổ biến:
1. **Cold start tốn token** — session mới phải re-explain codebase từ đầu
2. **AI hallucinate** — đoán file/function/business rule không tồn tại
3. **Doc lệch code** — code đổi nhưng doc không đổi → AI đọc doc cũ → đề xuất sai

Phương pháp này giải 3 vấn đề trên bằng:
- **Hierarchical context** thay vì 1 file root khổng lồ
- **App-map docs** đánh số, mỗi file 1 chủ đề canonical
- **Context routing** qua slash command + sub-agent
- **Doc + Test sync invariant** — code change BẮT BUỘC pair với doc + test cùng commit
- **LOGIC vs REQUEST classification** — tách câu hỏi với câu yêu cầu

### EN
When pair-programming with an AI agent, 3 common pain points:
1. **Cold start burns tokens** — every new session must re-explain the codebase
2. **AI hallucinates** — invents files/functions/business rules that don't exist
3. **Docs drift from code** — code changes, docs don't → AI reads stale docs → wrong suggestions

This methodology solves all 3 with:
- **Hierarchical context** instead of one giant root file
- **Numbered app-map docs**, each file = one canonical topic
- **Context routing** via slash command + sub-agent
- **Doc + Test sync invariant** — code changes MUST ship with doc + test in the same commit
- **LOGIC vs REQUEST classification** — separate questions from action requests

---

## Quick start (5 phút / 5 min)

### VI
1. Copy `templates/CLAUDE.md.template` → root project, đổi thành `CLAUDE.md`
2. Tạo thư mục `docs/app-map/` + copy `templates/app-map-README.md.template` vào
3. Tạo `.claude/commands/fl.md` từ `templates/fl.command.md.template`
4. Tạo `.claude/agents/context-router.md` từ `templates/context-router.agent.md.template`
5. Đọc `methodology/README.md` để hiểu 7 nguyên tắc

### EN
1. Copy `templates/CLAUDE.md.template` → project root, rename to `CLAUDE.md`
2. Create `docs/app-map/` directory, copy `templates/app-map-README.md.template` into it
3. Create `.claude/commands/fl.md` from `templates/fl.command.md.template`
4. Create `.claude/agents/context-router.md` from `templates/context-router.agent.md.template`
5. Read `methodology/README.md` to grasp the 7 principles

---

## Cấu trúc repo / Repo structure

```
ai-simple--skill-product-dev/
├── README.md                    # This file
├── SKILL.md                     # Claude Code skill manifest (auto-discoverable)
├── methodology/                 # 7 principles, deep-dive
│   ├── README.md                # Principles index
│   ├── 01-hierarchical-context.md
│   ├── 02-app-map-pattern.md
│   ├── 03-context-routing.md
│   ├── 04-doc-test-sync.md
│   ├── 05-logic-vs-request.md
│   ├── 06-pre-flight-checklist.md
│   └── 07-memory-as-feedback.md
└── templates/                   # Drop-in files, just edit placeholders
    ├── CLAUDE.md.template
    ├── app-map-README.md.template
    ├── app-map-doc.md.template
    ├── ADR.md.template
    ├── context-router.agent.md.template
    └── fl.command.md.template
```

---

## Khi nào dùng / When to use

### VI — Phù hợp khi
- Project ≥ 30 file, có business logic phức tạp
- Có nhiều người (kể cả AI agent) cùng đụng codebase
- Có DB + auth + nhiều flow → cần tách concern
- Muốn AI session mới onboard < 1 phút

### VI — Không cần khi
- Throwaway script, prototype 1 file
- Pure library không có business rule
- Solo dev, project < 10 file

### EN — Use when
- Project ≥ 30 files, with non-trivial business logic
- Multiple contributors (humans + AI agents) touch the codebase
- DB + auth + many flows → need separation of concerns
- You want a fresh AI session to onboard in < 1 minute

### EN — Skip when
- Throwaway scripts, single-file prototypes
- Pure libraries with no business rules
- Solo dev, project under 10 files

---

## Triết lý / Philosophy

> **VI**: AI không phải là intern thông minh — AI là một **đồng nghiệp chỉ đọc tài liệu của bạn**. Tài liệu tốt = đồng nghiệp tốt. Phương pháp này không cố ép AI thông minh hơn, mà ép **bạn viết tài liệu tốt hơn**.
>
> **EN**: AI is not a smart intern — AI is **a colleague who only reads your docs**. Good docs = good colleague. This methodology doesn't try to make AI smarter; it forces **you to write better docs**.

---

## Đóng góp / Contributing

Mở issue/PR nếu có pattern hay từ project của bạn. Không cần leak code/business — chỉ cần share **pattern** đã work.

Open an issue/PR with patterns from your own project. No need to leak code/business — share **patterns** that worked.
