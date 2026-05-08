# 04 — Doc + Test Sync Invariant

> Code change BẮT BUỘC pair với doc update + test cùng commit. Không thoả hiệp. Đây là invariant cứng nhất của phương pháp.

---

## Tại sao cứng / Why hard

Soft rule "nên update doc": sau 10 commit là doc lệch 30%. Sau 50 commit là doc vô dụng — AI đọc doc cũ → đề xuất sai → user mất niềm tin → không dùng AI nữa.

Hard invariant: code đổi mà không update doc/test = task chưa xong. Reviewer reject. CI fail (nếu setup được).

---

## Bảng mapping / Mapping table

Code change → doc update bắt buộc:

| Code change | Doc bắt buộc update |
|---|---|
| Thêm/xoá file trong `src/<module>/` | `src/<module>/CLAUDE.md` (count + entry) |
| Thêm route mới hoặc xoá route | `docs/app-map/01-pages.md` |
| Thêm/sửa Dialog/Sheet/Drawer | `docs/app-map/02-dialogs.md` |
| Migration (table/column/RLS) | `docs/app-map/03-database.md` + regenerate types |
| Edge function mới / xoá | `docs/app-map/04-edge-functions.md` |
| Permission / role matrix change | `docs/app-map/05-permissions.md` |
| User flow mới | `docs/app-map/06-user-flows.md` |
| Tech stack / quy ước business mới | Root `CLAUDE.md` + `docs/decisions/` (ADR) |
| Feature mới chưa stable | `docs/app-map/20-recent-features.md` (buffer) |
| Quyết định kiến trúc | ADR mới `docs/decisions/NNNN-*.md` |

---

Code change → test bắt buộc:

| Code change | Test bắt buộc |
|---|---|
| Hook logic mới/sửa | Unit test (Jest/Vitest) HOẶC cover qua E2E |
| Util function | Unit test |
| Component có user interaction | Component test (RTL/Vitest) |
| Page mới / flow mới | E2E test (Playwright/Cypress) |
| Bug fix | Regression test (`bug-fix-verify-YYYY-MM-DD.spec.ts`) |
| Permission / RLS change | E2E với role matrix |
| Migration | DB integration test + manual verify |

---

## Khi nào skip test được / When skipping tests is OK

Skip test CHỈ cho phép khi:
- Pure UI tweak (color/spacing/copy đổi 1-2 từ)
- Config-only change
- Doc-only change

Phải note rõ trong commit message: `style(ui): đổi padding card — skip test vì pure UI tweak`

---

## Verify checklist trước khi commit / Pre-commit verify checklist

```
[ ] Code change → list file đã touch
[ ] Doc updates → đã update tất cả docs trong bảng trên?
[ ] Test updates → đã thêm/sửa test tương ứng?
[ ] Count consistency → CLAUDE.md count khớp với `ls` thực tế?
[ ] Cross-refs → link tới file mới có thêm vào index không?
[ ] Lint + test pass → `npm run lint` + `npm run test`?
```

→ Miss bất kỳ checkpoint nào = task chưa xong.

---

## Cách enforce / How to enforce

1. **Pre-commit hook** (husky): grep diff, nếu có file `src/` mà không có file `docs/` thay đổi → warn (không block, vì đôi khi đúng là pure UI tweak)
2. **Pull request template**: checklist 6 ô trên, force tick
3. **AI agent rule**: rule trong `CLAUDE.md` — "Trước khi say done, verify checklist 6 ô"
4. **Code reviewer**: reject PR thiếu doc/test, không exception

---

## Anti-patterns

| Anti-pattern | Vấn đề |
|---|---|
| "Sẽ update doc sau" | Không bao giờ làm |
| Update doc sau 5 commit | Đã quên context |
| Skip test vì "khó setup" | Bug return sau 2 tuần |
| Doc + test ở 2 PR khác nhau | Race condition merge |
| Soft rule, không enforce | Mất hiệu lực sau 1 tháng |

---

## Câu khẩu hiệu / Slogan

> "Code without doc = bug. Code without test = future bug. Both = task chưa xong."
