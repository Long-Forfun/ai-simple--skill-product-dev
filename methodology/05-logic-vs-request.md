# 05 — LOGIC vs REQUEST Classification

> Mỗi câu nói của user đều phải classify: hỏi (LOGIC) hay yêu cầu (REQUEST). Trộn 2 loại = AI commit code khi user chỉ đang discuss.

---

## Vấn đề / The problem

User nói "cái notification này hơi lag" — họ đang:
- (a) Báo bug → muốn fix?
- (b) Hỏi tại sao lag → muốn hiểu trước?
- (c) Brainstorm → chưa quyết gì?

AI không classify → đoán bừa → đôi khi commit code sửa, user không muốn → revert.

---

## Quy tắc phân loại / Classification rule

| Loại | Pattern | Action AI |
|---|---|---|
| **LOGIC** | Hỏi why, how, what, "có nên không" | Trả lời, KHÔNG code, KHÔNG commit. Persist insight vào docs/memory nếu cần. |
| **REQUEST** | Imperative: "thêm", "sửa", "xoá", "commit", "deploy" | Code luôn theo risk tier 06: GREEN/YELLOW đi thẳng (Assumptions cuối task), RED mới hỏi 1 câu gộp. |
| **HYBRID** | "tại sao X lag, sửa giúp" | Split: trả lời why trước, rồi code phần fix theo tier 06 (chỉ dừng hỏi nếu RED). |

---

## Ví dụ classify / Classification examples

| User utterance | Type | AI nên làm gì |
|---|---|---|
| "tại sao home page chậm" | LOGIC | Phân tích, không code |
| "fix home page chậm" | REQUEST | Code luôn (GREEN) — scope tự chọn hợp lý, ghi Assumptions |
| "tại sao chậm, fix giúp" | HYBRID | Trả lời why → code theo tier 06 |
| "có nên dùng React Query không" | LOGIC | Discuss, không add lib |
| "thêm React Query" | REQUEST | Add lib |
| "form validation hơi yếu" | LOGIC (báo cảm nhận) | Hỏi user muốn (a) discuss hay (b) fix |
| "form validation yếu, thêm Zod" | REQUEST | Add Zod |
| "test fail, kiểm tra" | LOGIC | Diagnose, KHÔNG fix |
| "test fail, fix giúp" | REQUEST | Fix |
| "commit và push" | REQUEST | Commit + push |

---

## Khi không chắc / When in doubt

**MẶC ĐỊNH classify là LOGIC.** Hỏi confirm trước khi code:
> "Câu này tôi hiểu là (a) bạn muốn discuss, hay (b) bạn muốn tôi fix? Nếu (b) thì scope như nào?"

Cost của hỏi 1 câu < cost của commit nhầm rồi revert.

---

## Persistent rule

Note vào memory file (vd `memory/feedback_classify_logic_request.md`):
```
- Mỗi user utterance: classify LOGIC vs REQUEST
- LOGIC → docs + memory, KHÔNG commit
- REQUEST → code luôn theo risk tier 06 (GREEN/YELLOW đi thẳng, RED 1 câu confirm gộp)
- HYBRID → split, trả lời why trước rồi mới code
- Không chắc LOGIC hay REQUEST → default LOGIC, hỏi 1 câu phân loại
```

---

## Anti-patterns

| Anti-pattern | Hậu quả |
|---|---|
| Default REQUEST | Commit nhầm khi user chỉ hỏi |
| Không hỏi confirm | Code sai scope, revert |
| LOGIC trả lời rồi auto code luôn | User không có cơ hội pivot |
| HYBRID merge thành 1 commit | Discussion + code lẫn lộn, khó review |

---

## Câu khẩu hiệu / Slogan

> "Hỏi không phải lệnh. Khi không chắc — hỏi lại, đừng code."
