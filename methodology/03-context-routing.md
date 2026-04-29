# 03 — Context Routing

> **VI**: Đừng để AI tự đoán file nào cần đọc. Setup 1 slash command + 1 sub-agent route task → output ordered file list. AI session mới chỉ cần gõ `/fl <task>` là biết phải load gì.
>
> **EN**: Don't let AI guess which files to read. Set up one slash command + one sub-agent that routes the task → outputs an ordered file list. A fresh AI session just types `/fl <task>` to know what to load.

---

## Vấn đề / The problem

### VI
Không có routing → AI session mới sẽ:
- Grep tùm lum, mỗi grep tốn token
- Đoán file structure → hallucinate path không tồn tại
- Đọc thừa nhiều file không liên quan
- Miss invariant quan trọng (vd DB safety rule) vì không biết phải đọc file nào

### EN
Without routing, a fresh AI session will:
- Grep everywhere, burning tokens per grep
- Guess at file structure → hallucinate paths that don't exist
- Read many irrelevant files
- Miss critical invariants (e.g. DB safety rules) because it doesn't know what to read

---

## Giải pháp / The solution

### VI: 2 thành phần
1. **Slash command** `/fl <task>` (hoặc tên gì bạn muốn) — định nghĩa trong `.claude/commands/fl.md`
2. **Sub-agent** `context-router` — định nghĩa trong `.claude/agents/context-router.md`

Workflow:
```
User: /fl thêm trang admin xem log

  ↓ (slash command spawn sub-agent)

context-router agent:
  1. Classify domain (admin / log / pages / permissions)
  2. Output ordered file list:
     - CLAUDE.md (baseline)
     - docs/app-map/01-pages-and-navigation.md
     - docs/app-map/05-permissions-and-gates.md
     - src/admin/CLAUDE.md (nếu có)
  3. Pre-flight flags:
     - DB risk? (admin có touch logs table không)
     - Permission risk? (admin only)
     - LOGIC vs REQUEST?
  4. Confirm câu cụ thể trước khi tôi đọc + code

  ↓ (return list, KHÔNG code, KHÔNG explore source)

Main agent:
  - Đọc danh sách files trên
  - Confirm với user trước khi tiếp tục
```

### EN: 2 components
1. **Slash command** `/fl <task>` (or whatever name you prefer) — defined in `.claude/commands/fl.md`
2. **Sub-agent** `context-router` — defined in `.claude/agents/context-router.md`

Workflow:
```
User: /fl add admin page to view logs

  ↓ (slash command spawns sub-agent)

context-router agent:
  1. Classify domain (admin / log / pages / permissions)
  2. Output ordered file list:
     - CLAUDE.md (baseline)
     - docs/app-map/01-pages-and-navigation.md
     - docs/app-map/05-permissions-and-gates.md
     - src/admin/CLAUDE.md (if exists)
  3. Pre-flight flags:
     - DB risk? (admin touches logs table?)
     - Permission risk? (admin only)
     - LOGIC vs REQUEST?
  4. Specific confirm question before I read + code

  ↓ (return list, NO code, NO source exploration)

Main agent:
  - Reads the listed files
  - Confirms with user before proceeding
```

---

## Tại sao tách sub-agent / Why a separate sub-agent

### VI
- Sub-agent chạy isolated context → KHÔNG bloat main session
- Sub-agent có thể có model khác (rẻ hơn) cho routing task
- Sub-agent không "thấy" code → tránh bias đọc code trước doc
- Output được structure cứng → main agent dễ parse

### EN
- Sub-agent runs in an isolated context → does NOT bloat the main session
- Sub-agent can use a cheaper model for routing
- Sub-agent doesn't "see" code → avoids the bias of reading code before docs
- Output has a hard structure → easy for the main agent to parse

---

## Quy tắc cứng / Hard rules

### VI
1. Sub-agent **CHỈ ROUTE** — không đọc source code, không edit
2. Output luôn có 4 phần: domain classify, file list (ordered), pre-flight flags, confirm question
3. Slash command name nên ngắn (3-4 ký tự) — `/fl`, `/ctx`, `/r` — vì user sẽ gõ nhiều
4. Tên sub-agent cố định — đừng đổi sau (broken bookmarks)
5. Sub-agent có model rẻ (haiku/sonnet) thay vì opus — task này không cần thinking

### EN
1. Sub-agent **ROUTES ONLY** — no source code reading, no edits
2. Output always has 4 parts: domain classify, ordered file list, pre-flight flags, confirm question
3. Slash command name should be short (3-4 chars) — `/fl`, `/ctx`, `/r` — user types it a lot
4. Sub-agent name is fixed — don't rename later (breaks bookmarks)
5. Use a cheap model (haiku/sonnet) rather than opus — routing doesn't need deep thinking

---

## Ví dụ output / Example output

```
## Task classification
Domain(s): admin, permissions, ui-pages
Type: REQUEST (build new page)

## Files cần đọc (theo thứ tự) / Files to read (in order)
1. CLAUDE.md — baseline
2. docs/app-map/01-pages-and-navigation.md — route registry
3. docs/app-map/05-permissions-and-gates.md — admin role check
4. src/admin/CLAUDE.md — admin module catalog
5. docs/app-map/03-database-and-automation.md §logs_table — chỉ section logs

## Pre-flight flags
- 🟢 LOGIC vs REQUEST: REQUEST
- 🟡 Permission: admin-only — bắt buộc check role gate
- 🔴 DB risk: nếu mutate logs → cần migration; nếu chỉ read → an toàn
- ⚪ Doc + Test sync: thêm route mới → update 01-pages + thêm e2e test

## Câu confirm trước khi code
"Page admin/logs chỉ READ logs hay có DELETE/EDIT? Layout list view hay
detail view? Có pagination/filter không?"
```

---

## Anti-patterns

| Anti-pattern | VI: Vấn đề | EN: Problem |
|---|---|---|
| Sub-agent edit code | Bypass main review | Bypasses main review |
| Output không structure | Main agent khó parse | Main agent can't parse |
| Slash name dài (`/context-please`) | Mỏi tay, ít dùng | Tedious, gets skipped |
| Không có confirm question | AI đi luôn, miss intent user | AI proceeds, misses user intent |
| Sub-agent đọc source code | Token waste, mục tiêu sai | Token waste, wrong scope |

---

## Templates sẵn có / Ready templates

- `templates/fl.command.md.template` — slash command
- `templates/context-router.agent.md.template` — sub-agent definition

---

## Checklist áp dụng / Adoption checklist

- [ ] `.claude/commands/<name>.md` tồn tại
- [ ] `.claude/agents/context-router.md` tồn tại
- [ ] Sub-agent có rule "KHÔNG đọc source code, CHỈ ROUTE"
- [ ] Sub-agent output có 4 phần structure cứng
- [ ] Test: gõ `/fl <random task>` → có output đúng format
