# App Map — {{PROJECT_NAME}}

> Load khi: cần quyết định đọc app-map file nào cho task hiện tại (đây là index/router).
> **Single source of truth** cho mọi domain của {{PROJECT_NAME}}. Mỗi file 1 chủ đề canonical, đánh số tăng dần.

---

## Load strategy

### Khi nào load tất cả
- KHÔNG BAO GIỜ — tốn token
- AI phải route qua `/fl <task>` để biết file nào cần

### Khi nào load file nào
| Task | Files cần |
|---|---|
| Hỏi tổng quan project | Root `CLAUDE.md` only |
| Sửa UI component | Root + `src/<module>/CLAUDE.md` |
| Add page mới | Root + `01-pages-and-navigation.md` + `src/<module>/CLAUDE.md` |
| Đụng DB | Root + `03-database-and-automation.md` + ADR liên quan |
| Permission change | Root + `05-permissions-and-gates.md` |
| Flow change | Root + `06-user-flows.md` |
| Sự cố hệ thống chạy nền | Root + `ops/runbook-<service>.md` TRƯỚC TIÊN |
| Decision quá khứ | Root + `decisions/NNNN-*.md` |

---

## Index

> Khung gợi ý — các file CHƯA tồn tại lúc mới init. Khi tạo file nào, đổi tên thường thành
> link markdown (invariant 3). Broken-ref check chỉ tính LINK, không tính text thường —
> nên index khung không làm fail CI oan ở repo mới.

| # | File | Mục đích |
|---|---|---|
| 01 | 01-pages-and-navigation.md | Routes + nav structure |
| 02 | 02-dialogs-and-forms.md | Modal/Sheet/Form catalog |
| 03 | 03-database-and-automation.md | Tables, RLS, triggers, cron |
| 04 | 04-edge-functions.md | Serverless function registry |
| 05 | 05-permissions-and-gates.md | Role matrix, journey gates |
| 06 | 06-user-flows.md | End-to-end flows |
| 07 | 07-auto-vs-manual.md | Auto-trigger vs user action |
| 08 | 08-app-structure-real.md | Actual folder layout |
| 09 | 09-empty-and-inline-states.md | Empty states, inline hints |
| 10 | 10-design-system.md | Colors, typo, copy tone |
| 20 | 20-recent-features.md | Buffer cho feature mới chưa stable |
| 21 | 21-feature-workflow.md | Pre-flight + plan template |
| 22 | 22-test-organization.md | Test structure + naming |

---

## Invariants (áp dụng cho mọi file)

1. **Mỗi file 1 chủ đề canonical** — không trộn
2. **Bắt đầu bằng "Load khi"** — 1 dòng nói khi nào AI nên load
3. **Cross-ref dùng full relative path** — vd tự tham chiếu: `[README](README.md)` (ví dụ dùng file có thật để broken-ref check không bắt oan)
4. **Last-updated date** ở cuối file
5. **Major change**: bump v2/v3, append history section thay vì silent overwrite

---

## Lifecycle

```
Feature mới → entry trong 20-recent-features.md (buffer)
        ↓ 2-4 tuần stable
Promote → file riêng NN-feature-name.md
        ↓ thay thế
Deprecate → đánh dấu "DEPRECATED YYYY-MM-DD — replaced by NN-other.md", giữ file
```

---

**Last updated**: {{YYYY-MM-DD}}
