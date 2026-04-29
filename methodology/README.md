# Methodology — 7 nguyên tắc / 7 principles

> **VI**: 7 nguyên tắc cốt lõi. Đọc tuần tự, mỗi file 5–10 phút.
>
> **EN**: 7 core principles. Read in order, 5–10 minutes per file.

---

## Index

| # | File | VI: Tóm tắt | EN: Summary |
|---|---|---|---|
| 01 | [hierarchical-context.md](01-hierarchical-context.md) | Root mỏng, link sang module | Thin root, link to module docs |
| 02 | [app-map-pattern.md](02-app-map-pattern.md) | Doc đánh số 1 chủ đề/file | Numbered docs, one topic per file |
| 03 | [context-routing.md](03-context-routing.md) | Slash command + sub-agent | Slash command + sub-agent |
| 04 | [doc-test-sync.md](04-doc-test-sync.md) | Code = Doc = Test (cùng commit) | Code = Doc = Test (same commit) |
| 05 | [logic-vs-request.md](05-logic-vs-request.md) | Phân loại utterance | Classify utterances |
| 06 | [pre-flight-checklist.md](06-pre-flight-checklist.md) | Flag risk trước khi code | Flag risk before coding |
| 07 | [memory-as-feedback.md](07-memory-as-feedback.md) | Persist preference cross-session | Persist preferences cross-session |

---

## Triết lý chung / Overall philosophy

### VI
3 thứ phương pháp này KHÔNG làm:
- ❌ Không cố ép AI thông minh hơn (model bạn dùng vẫn vậy)
- ❌ Không thay thế code review của con người
- ❌ Không loại bỏ hoàn toàn hallucination (chỉ giảm ~80%)

3 thứ phương pháp này LÀM:
- ✅ Giảm cold-start cost của session mới (5K → < 1K tokens cho onboard)
- ✅ Force tài liệu update đồng bộ với code (invariant cứng)
- ✅ Tách câu chuyện (LOGIC) với hành động (REQUEST) → giảm commit nhầm

### EN
3 things this methodology does NOT do:
- ❌ Doesn't make AI smarter (your model is still the same)
- ❌ Doesn't replace human code review
- ❌ Doesn't fully eliminate hallucination (cuts ~80%)

3 things this methodology DOES:
- ✅ Cuts cold-start cost for new sessions (5K → under 1K tokens for onboarding)
- ✅ Forces docs to stay in sync with code (hard invariant)
- ✅ Separates conversation (LOGIC) from action (REQUEST) → fewer accidental commits

---

## Thứ tự áp dụng đề xuất / Suggested adoption order

### VI — Project mới
1. Bắt đầu: copy `templates/CLAUDE.md.template` → root, fill placeholder
2. Commit đầu tiên: setup `docs/app-map/README.md` + 2-3 file canonical đầu (pages, db, flows)
3. Commit thứ 5–10: bật Doc+Test sync invariant (đừng đợi 50 commit mới bật)
4. Khi có > 5 module: setup `/fl` command + `context-router` sub-agent
5. Khi user feedback lặp lại: persist vào memory (nguyên tắc 07)

### VI — Project cũ (retrofit)
1. Đọc 7 nguyên tắc, score project hiện tại từng cái
2. Pick 2 cái yếu nhất → retrofit trước (thường là 02 + 04)
3. Đừng cố retrofit hết 1 lần — chia 5 PR, mỗi PR 1 nguyên tắc

### EN — Greenfield project
1. Start: copy `templates/CLAUDE.md.template` → root, fill placeholders
2. First commit: set up `docs/app-map/README.md` + 2-3 canonical docs (pages, db, flows)
3. Commits 5-10: turn on Doc+Test sync invariant (don't wait until 50 commits)
4. When > 5 modules: set up `/fl` command + `context-router` sub-agent
5. When user feedback repeats: persist to memory (principle 07)

### EN — Existing project (retrofit)
1. Read all 7 principles, score your project on each
2. Pick the 2 weakest → retrofit those first (usually 02 + 04)
3. Don't try to retrofit everything in one go — split into 5 PRs, one principle each

---

## Anti-patterns chung / Common anti-patterns

| Anti-pattern | Hậu quả / Consequence |
|---|---|
| Root CLAUDE.md > 10K tokens | AI bỏ qua phần cuối / AI skips the tail |
| Doc viết 1 lần, không update | AI đề xuất sai sau 5 commit / AI suggests wrong code after 5 commits |
| Để AI tự explore source code | Token cost ×3, hallucination ×2 / 3× token cost, 2× hallucination |
| Trộn LOGIC + REQUEST | AI commit khi user chỉ hỏi / AI commits when user only asked |
| Không có pre-flight | DB prod bị touch nhầm / Prod DB accidentally touched |
| Memory không có | User phải re-explain preference mỗi session / User re-explains preferences each session |

---

## Đo lường / Metrics

### VI — Cách biết phương pháp đang work
- Session mới onboard < 1 phút (tính từ "session start" đến "AI hỏi clarify đầu tiên")
- Doc lệch code < 5% (random sample 20 commit gần nhất, đếm % có doc update)
- AI hallucinate file/function < 1 lần / 10 turn
- Commit nhầm khi user chỉ discuss = 0

### EN — How to know it's working
- New session onboards in < 1 minute (from "session start" to "first clarifying question")
- Doc drift < 5% (random sample 20 recent commits, % with doc updates)
- AI hallucinates file/function < 1 per 10 turns
- Accidental commits when user was only discussing = 0
