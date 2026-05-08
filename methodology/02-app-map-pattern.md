# 02 — App-Map Pattern

> Mỗi chủ đề canonical có 1 file `docs/app-map/NN-topic.md`. Đánh số tăng dần. Mỗi file là **single source of truth** cho topic đó.

---

## Tại sao app-map / Why app-map

- Tài liệu rải rác → AI phải grep nhiều file → tốn token + miss invariant
- Mỗi chủ đề có **1 file canonical** → AI biết đọc gì khi gặp domain đó
- Đánh số → có thứ tự load (ví dụ pages trước flows trước permissions)
- File cố định → cross-ref ổn định, không bị broken link khi rename

---

## Cấu trúc đề xuất / Suggested structure

Khung 10 chủ đề phổ biến:
```
docs/app-map/
├── README.md                       # Index + load strategy
├── 01-pages-and-navigation.md      # Routes, nav structure
├── 02-dialogs-and-forms.md         # Modal, sheet, form catalog
├── 03-database-and-automation.md   # Tables, RLS, triggers, cron
├── 04-edge-functions.md            # Serverless functions
├── 05-permissions-and-gates.md     # Roles, journey gates
├── 06-user-flows.md                # End-to-end flows
├── 07-auto-vs-manual.md            # Auto-trigger vs user action
├── 08-app-structure-real.md        # Actual folder layout
├── 09-empty-and-inline-states.md   # Empty states, inline hints
└── 10-design-system.md             # Colors, typo, copy tone
```

Tuỳ project có thể có thêm 11+, gap số OK (vd 11 đã merge vào 03).

---

## Quy tắc viết app-map / App-map writing rules

1. **1 file = 1 chủ đề** — không trộn pages với dialogs
2. **Bắt đầu bằng "Load khi"** — 1 dòng nói khi nào AI nên đọc file này
3. **Có table of contents** ở đầu nếu file > 200 dòng
4. **Code block + diagram** thay vì văn xuôi dài
5. **Cross-reference** dùng full relative path: `[03-database](03-database.md)`
6. **Last-updated date** ở cuối file
7. **Khi update**: viết "v2 — 2026-04-29: thêm RLS table X" thay vì silently overwrite

---

## Anti-patterns

| Anti-pattern | Vấn đề |
|---|---|
| Tên file không có số | Khó load theo thứ tự |
| 1 file > 1500 dòng | Tách ra (vd 03 → 03a-tables, 03b-triggers) |
| Trộn topic | "pages-and-database.md" — không cross-ref được |
| Không có "Load khi" | AI đoán bừa khi nào load |
| Không có last-updated | Không biết doc còn fresh không |
| Doc nói chung chung "xem code" | Vô dụng cho AI mới onboard |

---

## Template app-map file / App-map file template

Xem `templates/app-map-doc.md.template` cho khung chuẩn.

---

## Lifecycle của app-map / App-map lifecycle

```
1. Feature mới → tạo entry trong docs/app-map/20-recent-features.md (buffer)
2. Stable sau 2-4 tuần → promote ra file riêng NN-feature-name.md
3. Deprecate → đánh dấu "DEPRECATED 2026-04-29 — replaced by NN-other.md", giữ file
4. Major change → bump v2/v3, append history section ở cuối
```

---

## Checklist áp dụng / Adoption checklist

- [ ] `docs/app-map/README.md` tồn tại + có index table
- [ ] Mỗi file có "Load khi" / "Load when" ở đầu
- [ ] Mỗi file có last-updated date ở cuối
- [ ] Cross-ref dùng relative path
- [ ] Không có file > 1500 dòng (nếu có → tách)
- [ ] Có file `20-recent-features.md` làm buffer cho feature mới
