# 01 — Hierarchical Context

> Đừng nhồi mọi thứ vào 1 file root. Phân tầng context theo độ chi tiết — root chỉ giữ business rules + pointer.

---

## Vấn đề / The problem

File `CLAUDE.md` (hoặc `.cursorrules`, …) nếu chứa mọi thứ:
- Tech stack, business rule, naming convention, quy ước commit, list folder, list hook, list page, …
- → **20K+ tokens**, AI đọc tới 60% rồi quên phần đầu
- → Mỗi session mới phải re-load 20K tokens dù chỉ làm 1 task nhỏ
- → Khi cần update 1 chỗ phải tìm trong file dài, dễ conflict merge

---

## Giải pháp / The solution

3 tầng context:
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

---

## Quy tắc cứng / Hard rules

1. **Root CLAUDE.md < 6000 tokens** — vượt là phải tách ra app-map
2. **Mỗi module có 1 CLAUDE.md** khi module có > 5 file — lý do: AI cần catalog
3. **App-map mỗi file 1 chủ đề canonical** — không trộn (xem nguyên tắc 02)
4. **Pointer phải là relative path đầy đủ** — `docs/app-map/03-database.md`, không phải "xem doc database"
5. **v2 — budget phải được hook enforce, không tự giác** — root là thuế token trả MỖI session; thực tế root phình dần qua từng commit mà không ai đếm. Cài `templates/pre-commit.hook.template` chặn ở ~24.000 chars (xem nguyên tắc 08)

### Root diet — khi root đã phình quá budget

Thứ tự cắt (giữ lại ít nhất, trỏ đi nhiều nhất):
1. Bảng chi tiết (schema, route list, env vars) → chuyển sang app-map / `_generated/`
2. Hướng dẫn theo task ("khi làm X đọc Y") → giữ bảng routing 10–15 dòng, phần còn lại sang app-map README
3. Lịch sử/changelog → ADR hoặc xóa
4. Root sau diet chỉ còn: vị trí trong ecosystem, quy tắc CẤM/BẮT BUỘC, bảng sync, bảng routing, quick commands

---

## Ví dụ structure / Example structure

> Tên file trong ví dụ là minh họa rút gọn — **index trong `docs/app-map/README.md` của project bạn mới là canonical**; mọi bảng mapping/routing phải dùng đúng tên trong index đó.

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

| Task | Load |
|---|---|
| User hỏi chung "project này làm gì" | Root only |
| User sửa 1 component UI | Root + `src/ui/CLAUDE.md` |
| User add 1 page mới | Root + `docs/app-map/01-pages.md` + `src/<module>/CLAUDE.md` |
| User đụng DB | Root + `docs/app-map/03-database.md` + ADR liên quan |
| User question về quyết định kiến trúc | Root + `docs/decisions/<adr>.md` |

---

## Anti-patterns

| Anti-pattern | Vấn đề |
|---|---|
| Root > 10K tokens | AI miss phần cuối |
| Module CLAUDE.md không có file count | AI không biết đã đọc đủ chưa |
| App-map trộn 3 chủ đề | Khó cross-ref, dễ stale |
| Pointer "xem doc XYZ" không có path | AI grep mất thời gian |
| Module CLAUDE.md duplicate root | Update lệch |

---

## Checklist áp dụng / Adoption checklist

- [ ] Root CLAUDE.md < 6000 tokens (proxy nhanh: ~24.000 ký tự EN / ~20.000 ký tự tiếng Việt — hook tự đếm, xem nguyên tắc 08)
- [ ] Mỗi module > 5 file có CLAUDE.md
- [ ] Folder `docs/app-map/` tồn tại + README index
- [ ] Mọi pointer đều là relative path
- [ ] Module CLAUDE.md có file count + 1-line desc per file
