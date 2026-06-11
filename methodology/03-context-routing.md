# 03 — Context Routing

> Đừng để AI tự đoán file nào cần đọc. Setup 1 slash command + 1 sub-agent route task → output ordered file list. AI session mới chỉ cần gõ `/fl <task>` là biết phải load gì.

---

## Vấn đề / The problem

Không có routing → AI session mới sẽ:
- Grep tùm lum, mỗi grep tốn token
- Đoán file structure → hallucinate path không tồn tại
- Đọc thừa nhiều file không liên quan
- Miss invariant quan trọng (vd DB safety rule) vì không biết phải đọc file nào

---

## Giải pháp / The solution

2 thành phần:
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
  3. Risk tier GREEN/YELLOW/RED (nguyên tắc 06)
  4. Câu confirm gộp — CHỈ khi tier RED

  ↓ (return list, KHÔNG code, KHÔNG explore source)

Main agent:
  - Đọc danh sách files trên
  - GREEN/YELLOW: code luôn (YELLOW: phương án an toàn + Assumptions cuối task)
  - RED: hỏi 1 câu gộp, đợi, rồi code
```

Chi phí routing: 1 lần spawn sub-agent ≈ 1-2K tokens (model rẻ). **Skip `/fl` cho task trivial** (1 file, đã biết đường, < 5 phút) — routing chỉ đáng giá khi task chạm nhiều domain hoặc session mới chưa có context.

---

## Tại sao tách sub-agent / Why a separate sub-agent

- Sub-agent chạy isolated context → KHÔNG bloat main session
- Sub-agent có thể có model khác (rẻ hơn) cho routing task
- Sub-agent không "thấy" code → tránh bias đọc code trước doc
- Output được structure cứng → main agent dễ parse

---

## Quy tắc cứng / Hard rules

1. Sub-agent **CHỈ ROUTE** — không đọc source code, không edit
2. Output luôn có 4 phần: domain classify, file list (ordered), risk tier, confirm (chỉ khi RED)
3. Slash command name nên ngắn (3-4 ký tự) — `/fl`, `/ctx`, `/r` — vì user sẽ gõ nhiều
4. Tên sub-agent cố định — đừng đổi sau (broken bookmarks)
5. Sub-agent có model rẻ (haiku/sonnet) thay vì opus — task này không cần thinking
6. **Confirm là ngoại lệ, không phải nghi thức** — router xuất câu confirm khi tier không phải RED là bug (user phải review lặt vặt)

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

## Risk tier (nguyên tắc 06)
Tier: YELLOW
- DB: 🟡 page chỉ READ logs table — không migration; nếu sau này cần index thì additive
- Permission: 🟡 admin-only — thêm role gate theo pattern sẵn có (an toàn mặc định)
- Doc + Test sync: update 01-pages + e2e test — đã plan

## KHÔNG đụng tới
- Không mutate logs table; không sửa RLS hiện hành

(Không có section Confirm — tier YELLOW: main agent tự code theo phương án an toàn,
layout mặc định list view + pagination, ghi vào Assumptions cuối task.)
```

---

## Anti-patterns

| Anti-pattern | Vấn đề |
|---|---|
| Sub-agent edit code | Bypass main review |
| Output không structure | Main agent khó parse |
| Slash name dài (`/context-please`) | Mỏi tay, ít dùng |
| Confirm khi tier không phải RED | User phải review lặt vặt — confirm mất giá trị khi RED thật xuất hiện |
| RED mà thiếu confirm | AI đi luôn qua điểm không thể quay đầu |
| Sub-agent đọc source code | Token waste, mục tiêu sai |
| `/fl` cho task trivial 1 file | Routing 1-2K tokens đắt hơn chính task |

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
