# Methodology — 10 nguyên tắc / 10 principles

> 10 nguyên tắc cốt lõi. Đọc tuần tự, mỗi file 5–10 phút. Nguyên tắc 01–07 cho mọi project; 08–10 là lớp scale (bắt buộc khi project/ecosystem phình to).
> *(EN: 10 core principles. 01–07 apply to every project; 08–10 are the scale layer — mandatory as the project/ecosystem grows.)*

---

## Index

| # | File | Tóm tắt |
|---|---|---|
| 01 | [hierarchical-context.md](01-hierarchical-context.md) | Root mỏng, link sang module |
| 02 | [app-map-pattern.md](02-app-map-pattern.md) | Doc đánh số, 1 chủ đề/file; > 20 file → phân cấp domain |
| 03 | [context-routing.md](03-context-routing.md) | Slash command + sub-agent |
| 04 | [doc-test-sync.md](04-doc-test-sync.md) | Code = Doc = Test (cùng commit) |
| 05 | [logic-vs-request.md](05-logic-vs-request.md) | Phân loại utterance |
| 06 | [pre-flight-checklist.md](06-pre-flight-checklist.md) | Flag risk trước khi code |
| 07 | [memory-as-feedback.md](07-memory-as-feedback.md) | Persist preference cross-session |
| 08 | [automated-enforcement.md](08-automated-enforcement.md) | **v2** — Hook chặn, lint cảnh báo, report đo drift |
| 09 | [generated-vs-authored-docs.md](09-generated-vs-authored-docs.md) | **v2** — Người viết "tại sao", máy sinh "cái gì" |
| 10 | [cross-repo-contract.md](10-cross-repo-contract.md) | **v2** — Schema dùng chung = contract đánh version |

---

## Triết lý chung

**KHÔNG** làm:
- ❌ Không ép AI thông minh hơn (model bạn dùng vẫn vậy)
- ❌ Không thay thế code review của con người
- ❌ Không loại bỏ hoàn toàn hallucination (chỉ giảm ~80%)

**CÓ** làm:
- ✅ Giảm cold-start cost session mới — onboard chỉ tốn root CLAUDE.md (≤ 6K tokens) + đúng các file được route, thay vì AI tự explore toàn codebase (thường 3–10x tốn hơn)
- ✅ Force tài liệu update đồng bộ với code (invariant cứng — và từ v2: **hook enforce, không tự giác**)
- ✅ Tách câu chuyện (LOGIC) với hành động (REQUEST) → giảm commit nhầm
- ✅ **v2**: Sống sót khi project phình to — docs máy sinh, app-map phân cấp, contract liên repo

---

## Thứ tự áp dụng đề xuất

### Project mới (greenfield)
1. Copy `templates/CLAUDE.md.template` → root, fill placeholder
2. Commit đầu: setup `docs/app-map/README.md` + 2-3 file canonical đầu (pages, db, flows)
3. Commit 5–10: bật Doc+Test sync invariant + **cài pre-commit hook ngay** (nguyên tắc 08 — retrofit hook muộn khó gấp 10 lần)
4. Khi > 5 module: setup `/fl` + `context-router` sub-agent
5. Khi user feedback lặp lại: persist vào memory (nguyên tắc 07)

### Project cũ (retrofit)
1. Đọc 10 nguyên tắc, score project hiện tại từng cái
2. Pick 2 cái yếu nhất → retrofit trước (thường 02 + 04)
3. Đừng cố retrofit hết 1 lần — chia 5 PR, mỗi PR 1 nguyên tắc

### Khi project phình to (scale-up triggers)
| Trigger | Hành động |
|---|---|
| Root CLAUDE.md chạm 6K tokens | Root diet (nguyên tắc 01 §diet) + hook chặn (08) |
| App-map > 20 file | Phân cấp domain 2 tầng (02 §scaling) |
| DB > 15 migrations / app > 50 routes / content hàng nghìn item | Tách docs máy sinh `_generated/` (09) |
| > 1 repo chia sẻ schema/file/utility | Contract + bảng SYNC (10) |
| Nhiều người/agent commit song song | Hook trên MỌI máy + CI lint (08) |

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
| Invariant chỉ dựa kỷ luật tay | Drift chắc chắn xảy ra khi scale — phải hook (08) |
| Viết tay doc inventory (schema/routes) | Stale sau 1 tuần — máy sinh (09) |
| Schema chung giữa repo không có contract | Silent break chéo repo (10) |

---

## Đo lường

Cách biết phương pháp đang work:
- Session mới onboard < 1 phút (từ "session start" đến "AI hỏi clarify đầu tiên")
- Doc lệch code < 5% (random sample 20 commit gần nhất, đếm % có doc update)
- AI hallucinate file/function < 1 lần / 10 turn
- Commit nhầm khi user chỉ discuss = 0

**v2 — thu thập tự động, không đo tay** (chi tiết: [08-automated-enforcement.md](08-automated-enforcement.md) §Đo lường):
- Drift % + staleness: script đọc git log, chạy tuần, gửi Telegram/Slack
- Token budget trend: hook ghi size CLAUDE.md mỗi commit
- Hallucination rate: bot triage đếm report "AI chẩn đoán sai do doc cũ"
