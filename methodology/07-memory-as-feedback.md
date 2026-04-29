# 07 — Memory as Feedback

> **VI**: Khi user feedback lặp lại 2 lần ("đừng commit khi tôi chỉ hỏi", "không touch DB prod") → persist vào memory file, không re-explain mỗi session.
>
> **EN**: When user feedback repeats 2x ("don't commit when I'm just asking", "don't touch prod DB") → persist to a memory file, don't re-explain every session.

---

## Vấn đề / The problem

### VI
User dạy AI cùng 1 thứ ngày này qua ngày khác:
- "Tôi muốn confirm trước khi commit" — session 1
- "Đừng auto-push" — session 2
- "Không tự chạy migration" — session 3
- ...

→ User chán, mất niềm tin. AI cần **persistent memory** chứ không chỉ context window.

### EN
User teaches AI the same thing day after day:
- "I want to confirm before committing" — session 1
- "Don't auto-push" — session 2
- "Don't run migrations on your own" — session 3
- ...

→ User gets fed up, loses trust. AI needs **persistent memory**, not just context window.

---

## Giải pháp / The solution

### VI: Memory file structure
```
~/.claude/projects/<project-id>/memory/
├── MEMORY.md                          # Index — link tới các entry
├── feedback_db_safety.md              # Rule: không touch DB prod
├── feedback_commit_flow.md            # Rule: confirm trước commit
├── feedback_classify_logic_request.md # Rule: classify utterance
├── project_<domain>_<topic>.md        # Domain knowledge persist
└── ...
```

`MEMORY.md` là index — root CLAUDE.md inline content của index.

### EN: Memory file structure
```
~/.claude/projects/<project-id>/memory/
├── MEMORY.md                          # Index — links to entries
├── feedback_db_safety.md              # Rule: don't touch prod DB
├── feedback_commit_flow.md            # Rule: confirm before committing
├── feedback_classify_logic_request.md # Rule: classify utterances
├── project_<domain>_<topic>.md        # Persisted domain knowledge
└── ...
```

`MEMORY.md` is the index — root CLAUDE.md inlines the index content.

---

## Khi nào persist / When to persist

### VI
Trigger persist:
1. **User repeat 2 lần trở lên** — không phải one-off feedback
2. **Behavioral preference** — không phải technical decision (tech decision → ADR)
3. **Cross-task safety rail** — áp dụng cho mọi task, không chỉ task hiện tại
4. **User explicit request** — "ghi nhớ giúp tôi: ..."

KHÔNG persist:
- Task-specific decision ("commit này dùng feat type") — vì task đã xong
- Context của 1 session ("hôm nay debug bug X") — không cross-session
- Architectural decision → ADR thay vì memory

### EN
Triggers to persist:
1. **User repeats 2+ times** — not a one-off
2. **Behavioral preference** — not a technical decision (tech → ADR)
3. **Cross-task safety rail** — applies to every task, not just the current one
4. **Explicit user request** — "please remember: ..."

DON'T persist:
- Task-specific decision ("this commit uses feat type") — task is done
- Single-session context ("today debugging bug X") — not cross-session
- Architectural decision → ADR instead of memory

---

## Format memory entry / Memory entry format

### VI
File `feedback_*.md` thường ngắn (50-150 từ):

```markdown
# <One-line title>

**Date**: 2026-04-29
**Trigger**: User nói "..." trong session X (link nếu có)
**Repetition**: 3 lần (session X, Y, Z)

## Rule
1. ...
2. ...

## Áp dụng khi
- ...

## KHÔNG áp dụng khi
- ...

## Liên quan
- ADR: docs/decisions/NNNN-*.md (nếu có)
- Doc: docs/app-map/NN-*.md
```

### EN
A `feedback_*.md` file is usually short (50-150 words):

```markdown
# <One-line title>

**Date**: 2026-04-29
**Trigger**: User said "..." in session X (link if available)
**Repetition**: 3 times (sessions X, Y, Z)

## Rule
1. ...
2. ...

## Apply when
- ...

## Do NOT apply when
- ...

## Related
- ADR: docs/decisions/NNNN-*.md (if any)
- Doc: docs/app-map/NN-*.md
```

---

## Index pattern / Index pattern

### VI
`MEMORY.md` chỉ là 1 list link, không trùng nội dung file con:

```markdown
- [DB safety](feedback_db_safety.md) — never auto-touch prod
- [Commit flow](feedback_commit_flow.md) — confirm before commit
- [Classify utterance](feedback_classify_logic_request.md) — LOGIC vs REQUEST
- [Auth domain](project_auth_overview.md) — JWT flow + refresh token
```

Root CLAUDE.md inline list này (không inline nội dung từng file con) → AI biết file nào tồn tại + đọc khi cần.

### EN
`MEMORY.md` is just a list of links, doesn't duplicate child file content:

```markdown
- [DB safety](feedback_db_safety.md) — never auto-touch prod
- [Commit flow](feedback_commit_flow.md) — confirm before commit
- [Classify utterance](feedback_classify_logic_request.md) — LOGIC vs REQUEST
- [Auth domain](project_auth_overview.md) — JWT flow + refresh token
```

Root CLAUDE.md inlines this list (not the child file content) → AI knows what files exist + reads them on demand.

---

## Lifecycle

### VI
- **Tạo**: khi trigger persist
- **Update**: khi rule thay đổi (vd "trước đây cho commit auto, giờ không")
- **Merge**: nếu 2 entry overlap → merge thành 1, update index
- **Sunset**: rule không còn áp dụng → đánh dấu `# DEPRECATED 2026-04-29 — replaced by Y` thay vì xoá

### EN
- **Create**: when persist trigger fires
- **Update**: when rule changes (e.g. "used to allow auto-commit, now disabled")
- **Merge**: if two entries overlap → merge into one, update index
- **Sunset**: rule no longer applies → mark `# DEPRECATED 2026-04-29 — replaced by Y` instead of deleting

---

## Anti-patterns

| Anti-pattern | VI: Hậu quả | EN: Consequence |
|---|---|---|
| Persist sau 1 lần | Memory bloat, rule không stable | Memory bloat, unstable rules |
| Trùng content giữa MEMORY.md index và file con | Update lệch | Updates drift |
| Memory chứa tech decision | Lẫn với ADR, khó tìm | Conflated with ADR, hard to find |
| Xoá memory khi sunset | Mất history | Loses history |
| Memory không có date | Không biết còn fresh không | Can't tell if still fresh |

---

## Câu khẩu hiệu / Slogan

> **VI**: "Đừng dạy AI 2 lần. Lần thứ 2 là ghi vào memory."
>
> **EN**: "Don't teach AI twice. The second time, write it down."
