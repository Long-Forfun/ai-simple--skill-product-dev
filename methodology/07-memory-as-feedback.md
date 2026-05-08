# 07 — Memory as Feedback

> Khi user feedback lặp lại 2 lần ("đừng commit khi tôi chỉ hỏi", "không touch DB prod") → persist vào memory file, không re-explain mỗi session.

---

## Vấn đề / The problem

User dạy AI cùng 1 thứ ngày này qua ngày khác:
- "Tôi muốn confirm trước khi commit" — session 1
- "Đừng auto-push" — session 2
- "Không tự chạy migration" — session 3
- ...

→ User chán, mất niềm tin. AI cần **persistent memory** chứ không chỉ context window.

---

## Giải pháp / The solution

Memory file structure:
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

---

## Khi nào persist / When to persist

Trigger persist:
1. **User repeat 2 lần trở lên** — không phải one-off feedback
2. **Behavioral preference** — không phải technical decision (tech decision → ADR)
3. **Cross-task safety rail** — áp dụng cho mọi task, không chỉ task hiện tại
4. **User explicit request** — "ghi nhớ giúp tôi: ..."

KHÔNG persist:
- Task-specific decision ("commit này dùng feat type") — vì task đã xong
- Context của 1 session ("hôm nay debug bug X") — không cross-session
- Architectural decision → ADR thay vì memory

---

## Format memory entry / Memory entry format

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

---

## Index pattern

`MEMORY.md` chỉ là 1 list link, không trùng nội dung file con:

```markdown
- [DB safety](feedback_db_safety.md) — never auto-touch prod
- [Commit flow](feedback_commit_flow.md) — confirm before commit
- [Classify utterance](feedback_classify_logic_request.md) — LOGIC vs REQUEST
- [Auth domain](project_auth_overview.md) — JWT flow + refresh token
```

Root CLAUDE.md inline list này (không inline nội dung từng file con) → AI biết file nào tồn tại + đọc khi cần.

---

## Lifecycle

- **Tạo**: khi trigger persist
- **Update**: khi rule thay đổi (vd "trước đây cho commit auto, giờ không")
- **Merge**: nếu 2 entry overlap → merge thành 1, update index
- **Sunset**: rule không còn áp dụng → đánh dấu `# DEPRECATED 2026-04-29 — replaced by Y` thay vì xoá

---

## Anti-patterns

| Anti-pattern | Hậu quả |
|---|---|
| Persist sau 1 lần | Memory bloat, rule không stable |
| Trùng content giữa MEMORY.md index và file con | Update lệch |
| Memory chứa tech decision | Lẫn với ADR, khó tìm |
| Xoá memory khi sunset | Mất history |
| Memory không có date | Không biết còn fresh không |

---

## Câu khẩu hiệu / Slogan

> "Đừng dạy AI 2 lần. Lần thứ 2 là ghi vào memory."
