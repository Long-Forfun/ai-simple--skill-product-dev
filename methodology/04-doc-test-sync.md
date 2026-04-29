# 04 — Doc + Test Sync Invariant

> **VI**: Code change BẮT BUỘC pair với doc update + test cùng commit. Không thoả hiệp. Đây là invariant cứng nhất của phương pháp.
>
> **EN**: A code change MUST be paired with doc updates + tests in the same commit. No compromise. This is the hardest invariant of the methodology.

---

## Tại sao cứng / Why hard

### VI
Soft rule "nên update doc": sau 10 commit là doc lệch 30%. Sau 50 commit là doc vô dụng — AI đọc doc cũ → đề xuất sai → user mất niềm tin → không dùng AI nữa.

Hard invariant: code đổi mà không update doc/test = task chưa xong. Reviewer reject. CI fail (nếu setup được).

### EN
Soft rule "you should update docs": after 10 commits, docs drift 30%. After 50 commits, docs are useless — AI reads stale docs → suggests wrong code → user loses trust → stops using AI.

Hard invariant: code change without doc/test = task not done. Reviewer rejects. CI fails (if you can set it up).

---

## Bảng mapping / Mapping table

### VI — Code change → doc update bắt buộc

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

### EN — Code change → required doc update

| Code change | Required doc update |
|---|---|
| Add/remove file in `src/<module>/` | `src/<module>/CLAUDE.md` (count + entry) |
| Add/remove route | `docs/app-map/01-pages.md` |
| Add/edit Dialog/Sheet/Drawer | `docs/app-map/02-dialogs.md` |
| Migration (table/column/RLS) | `docs/app-map/03-database.md` + regenerate types |
| New/removed edge function | `docs/app-map/04-edge-functions.md` |
| Permission / role matrix change | `docs/app-map/05-permissions.md` |
| New user flow | `docs/app-map/06-user-flows.md` |
| New tech stack / business rule | Root `CLAUDE.md` + `docs/decisions/` (ADR) |
| New feature, not yet stable | `docs/app-map/20-recent-features.md` (buffer) |
| Architectural decision | New ADR `docs/decisions/NNNN-*.md` |

---

### VI — Code change → test bắt buộc

| Code change | Test bắt buộc |
|---|---|
| Hook logic mới/sửa | Unit test (Jest/Vitest) HOẶC cover qua E2E |
| Util function | Unit test |
| Component có user interaction | Component test (RTL/Vitest) |
| Page mới / flow mới | E2E test (Playwright/Cypress) |
| Bug fix | Regression test (`bug-fix-verify-YYYY-MM-DD.spec.ts`) |
| Permission / RLS change | E2E với role matrix |
| Migration | DB integration test + manual verify |

### EN — Code change → required test

| Code change | Required test |
|---|---|
| New/edited hook logic | Unit test (Jest/Vitest) OR cover via E2E |
| Util function | Unit test |
| Component with user interaction | Component test (RTL/Vitest) |
| New page / new flow | E2E test (Playwright/Cypress) |
| Bug fix | Regression test (`bug-fix-verify-YYYY-MM-DD.spec.ts`) |
| Permission / RLS change | E2E with role matrix |
| Migration | DB integration test + manual verify |

---

## Khi nào skip test được / When skipping tests is OK

### VI
Skip test CHỈ cho phép khi:
- Pure UI tweak (color/spacing/copy đổi 1-2 từ)
- Config-only change
- Doc-only change

Phải note rõ trong commit message: `style(ui): đổi padding card — skip test vì pure UI tweak`

### EN
Skip tests ONLY when:
- Pure UI tweak (color/spacing/copy, 1-2 word changes)
- Config-only change
- Doc-only change

Must note explicitly in commit message: `style(ui): tweak card padding — skip test, pure UI tweak`

---

## Verify checklist trước khi commit / Pre-commit verify checklist

### VI
```
[ ] Code change → list file đã touch
[ ] Doc updates → đã update tất cả docs trong bảng trên?
[ ] Test updates → đã thêm/sửa test tương ứng?
[ ] Count consistency → CLAUDE.md count khớp với `ls` thực tế?
[ ] Cross-refs → link tới file mới có thêm vào index không?
[ ] Lint + test pass → `npm run lint` + `npm run test`?
```

→ Miss bất kỳ checkpoint nào = task chưa xong.

### EN
```
[ ] Code change → list of touched files
[ ] Doc updates → all docs in the table above updated?
[ ] Test updates → corresponding test added/edited?
[ ] Count consistency → CLAUDE.md counts match actual `ls`?
[ ] Cross-refs → links to new files added to the index?
[ ] Lint + test pass → `npm run lint` + `npm run test`?
```

→ Miss any checkpoint = task not done.

---

## Cách enforce / How to enforce

### VI
1. **Pre-commit hook** (husky): grep diff, nếu có file `src/` mà không có file `docs/` thay đổi → warn (không block, vì đôi khi đúng là pure UI tweak)
2. **Pull request template**: checklist 6 ô trên, force tick
3. **AI agent rule**: rule trong `CLAUDE.md` — "Trước khi say done, verify checklist 6 ô"
4. **Code reviewer**: reject PR thiếu doc/test, không exception

### EN
1. **Pre-commit hook** (husky): grep diff; if `src/` files changed but no `docs/` files → warn (don't block, sometimes truly a pure UI tweak)
2. **Pull request template**: 6-checkbox checklist, force-tick
3. **AI agent rule**: in `CLAUDE.md` — "Before saying done, verify the 6-checkbox checklist"
4. **Code reviewer**: reject PRs missing doc/test, no exceptions

---

## Anti-patterns

| Anti-pattern | VI: Vấn đề | EN: Problem |
|---|---|---|
| "Sẽ update doc sau" | Không bao giờ làm | Never happens |
| Update doc sau 5 commit | Đã quên context | Lost the context |
| Skip test vì "khó setup" | Bug return sau 2 tuần | Bug returns in 2 weeks |
| Doc + test ở 2 PR khác nhau | Race condition merge | Merge race condition |
| Soft rule, không enforce | Mất hiệu lực sau 1 tháng | Loses force in a month |

---

## Câu khẩu hiệu / Slogan

> **VI**: "Code without doc = bug. Code without test = future bug. Both = task chưa xong."
>
> **EN**: "Code without doc = bug. Code without test = future bug. Both missing = task not done."
