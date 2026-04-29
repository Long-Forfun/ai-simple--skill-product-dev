# 01 — Hierarchical Context

> **VI**: Đừng nhồi mọi thứ vào 1 file root. Phân tầng context theo độ chi tiết — root chỉ giữ business rules + pointer.
>
> **EN**: Don't cram everything into one root file. Layer your context by granularity — root keeps only business rules + pointers.

---

## Vấn đề / The problem

### VI
File `CLAUDE.md` (hoặc `.cursorrules`, …) nếu chứa mọi thứ:
- Tech stack, business rule, naming convention, quy ước commit, list folder, list hook, list page, …
- → **20K+ tokens**, AI đọc tới 60% rồi quên phần đầu
- → Mỗi session mới phải re-load 20K tokens dù chỉ làm 1 task nhỏ
- → Khi cần update 1 chỗ phải tìm trong file dài, dễ conflict merge

### EN
A `CLAUDE.md` file (or `.cursorrules`, …) that contains everything:
- Tech stack, business rules, naming conventions, commit conventions, folder lists, hook lists, page lists, …
- → **20K+ tokens**, AI reads through 60% and forgets the start
- → Every fresh session re-loads 20K tokens even for a tiny task
- → Updating one spot requires hunting through a long file, easy to merge-conflict

---

## Giải pháp / The solution

### VI: 3 tầng context
```
ROOT (CLAUDE.md)                    < 6000 tokens
├── Business rules cốt lõi
├── Tech stack tổng quan
├── Quy tắc commit + naming
├── Doc + Test sync invariant table
└── Pointers ──→ MODULE level

MODULE (src/<module>/CLAUDE.md)     < 2000 tokens / file
├── Module-specific patterns
├── File catalog (count + 1-line desc mỗi file)
├── Khi nào load module này
└── Pointers ──→ APP-MAP level

APP-MAP (docs/app-map/NN-*.md)      < 3000 tokens / file
├── Canonical spec cho 1 chủ đề
├── Diagrams, tables, edge cases
└── Cross-reference tới các app-map khác
```

### EN: 3 layers of context
```
ROOT (CLAUDE.md)                    < 6000 tokens
├── Core business rules
├── Tech stack overview
├── Commit + naming conventions
├── Doc + Test sync invariant table
└── Pointers ──→ MODULE level

MODULE (src/<module>/CLAUDE.md)     < 2000 tokens / file
├── Module-specific patterns
├── File catalog (count + 1-line desc per file)
├── When to load this module
└── Pointers ──→ APP-MAP level

APP-MAP (docs/app-map/NN-*.md)      < 3000 tokens / file
├── Canonical spec for one topic
├── Diagrams, tables, edge cases
└── Cross-references to other app-maps
```

---

## Quy tắc cứng / Hard rules

### VI
1. **Root CLAUDE.md < 6000 tokens** — vượt là phải tách ra app-map
2. **Mỗi module có 1 CLAUDE.md** khi module có > 5 file — lý do: AI cần catalog
3. **App-map mỗi file 1 chủ đề canonical** — không trộn (xem nguyên tắc 02)
4. **Pointer phải là relative path đầy đủ** — `docs/app-map/03-database.md`, không phải "xem doc database"

### EN
1. **Root CLAUDE.md < 6000 tokens** — exceed means split into app-map
2. **One CLAUDE.md per module** when the module has > 5 files — reason: AI needs the catalog
3. **One canonical topic per app-map file** — don't mix (see principle 02)
4. **Pointers must be full relative paths** — `docs/app-map/03-database.md`, not "see the database doc"

---

## Ví dụ structure / Example structure

```
my-project/
├── CLAUDE.md                        # ROOT — < 6K tokens
├── docs/
│   ├── app-map/
│   │   ├── README.md                # App-map index
│   │   ├── 01-pages.md
│   │   ├── 02-dialogs.md
│   │   ├── 03-database.md
│   │   ├── 04-edge-functions.md
│   │   ├── 05-permissions.md
│   │   └── 06-flows.md
│   └── decisions/                   # ADR
│       └── 0001-why-postgres.md
└── src/
    ├── auth/
    │   └── CLAUDE.md                # MODULE — auth-specific
    ├── billing/
    │   └── CLAUDE.md                # MODULE — billing-specific
    └── ui/
        └── CLAUDE.md                # MODULE — ui-specific
```

---

## Khi nào load tầng nào / When to load which layer

### VI
| Task | Load |
|---|---|
| User hỏi chung "project này làm gì" | Root only |
| User sửa 1 component UI | Root + `src/ui/CLAUDE.md` |
| User add 1 page mới | Root + `docs/app-map/01-pages.md` + `src/<module>/CLAUDE.md` |
| User đụng DB | Root + `docs/app-map/03-database.md` + ADR liên quan |
| User question về quyết định kiến trúc | Root + `docs/decisions/<adr>.md` |

### EN
| Task | Load |
|---|---|
| User asks "what does this project do" | Root only |
| User edits a UI component | Root + `src/ui/CLAUDE.md` |
| User adds a new page | Root + `docs/app-map/01-pages.md` + `src/<module>/CLAUDE.md` |
| User touches DB | Root + `docs/app-map/03-database.md` + relevant ADR |
| User asks about an architecture decision | Root + `docs/decisions/<adr>.md` |

---

## Anti-patterns

| Anti-pattern | VI: Vấn đề | EN: Problem |
|---|---|---|
| Root > 10K tokens | AI miss phần cuối | AI misses the tail |
| Module CLAUDE.md không có file count | AI không biết đã đọc đủ chưa | AI doesn't know if it has read enough |
| App-map trộn 3 chủ đề | Khó cross-ref, dễ stale | Hard to cross-ref, easy to go stale |
| Pointer "xem doc XYZ" không có path | AI grep mất thời gian | AI wastes time grepping |
| Module CLAUDE.md duplicate root | Update lệch | Updates drift apart |

---

## Checklist áp dụng / Adoption checklist

- [ ] Root CLAUDE.md < 6000 tokens (đếm bằng tiktoken hoặc estimate ~750 từ)
- [ ] Mỗi module > 5 file có CLAUDE.md
- [ ] Folder `docs/app-map/` tồn tại + README index
- [ ] Mọi pointer đều là relative path
- [ ] Module CLAUDE.md có file count + 1-line desc per file
