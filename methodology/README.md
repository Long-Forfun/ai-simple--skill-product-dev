# Methodology — 7 nguyên tắc / 7 principles

> 7 nguyên tắc cốt lõi. Đọc tuần tự, mỗi file 5–10 phút.
> *(EN: 7 core principles. Read in order, 5–10 min each.)*

---

## Index

| # | File | Tóm tắt |
|---|---|---|
| 01 | [hierarchical-context.md](01-hierarchical-context.md) | Root mỏng, link sang module |
| 02 | [app-map-pattern.md](02-app-map-pattern.md) | Doc đánh số, 1 chủ đề/file |
| 03 | [context-routing.md](03-context-routing.md) | Slash command + sub-agent |
| 04 | [doc-test-sync.md](04-doc-test-sync.md) | Code = Doc = Test (cùng commit) |
| 05 | [logic-vs-request.md](05-logic-vs-request.md) | Phân loại utterance |
| 06 | [pre-flight-checklist.md](06-pre-flight-checklist.md) | Flag risk trước khi code |
| 07 | [memory-as-feedback.md](07-memory-as-feedback.md) | Persist preference cross-session |

---

## Triết lý chung

**KHÔNG** làm:
- ❌ Không ép AI thông minh hơn (model bạn dùng vẫn vậy)
- ❌ Không thay thế code review của con người
- ❌ Không loại bỏ hoàn toàn hallucination (chỉ giảm ~80%)

**CÓ** làm:
- ✅ Giảm cold-start cost session mới (5K → < 1K tokens onboard)
- ✅ Force tài liệu update đồng bộ với code (invariant cứng)
- ✅ Tách câu chuyện (LOGIC) với hành động (REQUEST) → giảm commit nhầm

---

## Thứ tự áp dụng đề xuất

### Project mới (greenfield)
1. Copy `templates/CLAUDE.md.template` → root, fill placeholder
2. Commit đầu: setup `docs/app-map/README.md` + 2-3 file canonical đầu (pages, db, flows)
3. Commit 5–10: bật Doc+Test sync invariant (đừng đợi 50 commit)
4. Khi > 5 module: setup `/fl` + `context-router` sub-agent
5. Khi user feedback lặp lại: persist vào memory (nguyên tắc 07)

### Project cũ (retrofit)
1. Đọc 7 nguyên tắc, score project hiện tại từng cái
2. Pick 2 cái yếu nhất → retrofit trước (thường 02 + 04)
3. Đừng cố retrofit hết 1 lần — chia 5 PR, mỗi PR 1 nguyên tắc

---

## Anti-patterns chung

| Anti-pattern | Hậu quả |
|---|---|
| Root CLAUDE.md > 10K tokens | AI bỏ qua phần cuối |
| Doc viết 1 lần, không update | AI đề xuất sai sau 5 commit |
| Để AI tự explore source code | Token cost ×3, hallucination ×2 |
| Trộn LOGIC + REQUEST | AI commit khi user chỉ hỏi |
| Không có pre-flight | DB prod bị touch nhầm |
| Không có memory | User phải re-explain preference mỗi session |

---

## Đo lường

Cách biết phương pháp đang work:
- Session mới onboard < 1 phút (từ "session start" đến "AI hỏi clarify đầu tiên")
- Doc lệch code < 5% (random sample 20 commit gần nhất, đếm % có doc update)
- AI hallucinate file/function < 1 lần / 10 turn
- Commit nhầm khi user chỉ discuss = 0
