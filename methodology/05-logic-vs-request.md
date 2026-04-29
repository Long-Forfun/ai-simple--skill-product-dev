# 05 — LOGIC vs REQUEST Classification

> **VI**: Mỗi câu nói của user đều phải classify: hỏi (LOGIC) hay yêu cầu (REQUEST). Trộn 2 loại = AI commit code khi user chỉ đang discuss.
>
> **EN**: Every user utterance must be classified: question (LOGIC) or action (REQUEST). Mixing the two = AI commits code when user was only discussing.

---

## Vấn đề / The problem

### VI
User nói "cái notification này hơi lag" — họ đang:
- (a) Báo bug → muốn fix?
- (b) Hỏi tại sao lag → muốn hiểu trước?
- (c) Brainstorm → chưa quyết gì?

AI không classify → đoán bừa → đôi khi commit code sửa, user không muốn → revert.

### EN
User says "this notification feels laggy" — they could mean:
- (a) Reporting a bug → wants a fix?
- (b) Asking why it's laggy → wants to understand first?
- (c) Brainstorming → no decision yet?

AI doesn't classify → guesses → sometimes commits a fix the user didn't want → revert.

---

## Quy tắc phân loại / Classification rule

### VI
| Loại | Pattern | Action AI |
|---|---|---|
| **LOGIC** | Hỏi why, how, what, "có nên không" | Trả lời, KHÔNG code, KHÔNG commit. Persist insight vào docs/memory nếu cần. |
| **REQUEST** | Imperative: "thêm", "sửa", "xoá", "commit", "deploy" | Code + commit (sau khi confirm). |
| **HYBRID** | "tại sao X lag, sửa giúp" | Split: trả lời why trước, sau đó hỏi confirm fix scope, sau đó mới code. |

### EN
| Type | Pattern | AI action |
|---|---|---|
| **LOGIC** | Asks why, how, what, "should we" | Answer, NO code, NO commit. Persist insight to docs/memory if relevant. |
| **REQUEST** | Imperative: "add", "fix", "remove", "commit", "deploy" | Code + commit (after confirming). |
| **HYBRID** | "why is X laggy, fix it" | Split: answer the why first, then confirm fix scope, then code. |

---

## Ví dụ classify / Classification examples

### VI
| User utterance | Type | AI nên làm gì |
|---|---|---|
| "tại sao home page chậm" | LOGIC | Phân tích, không code |
| "fix home page chậm" | REQUEST | Confirm scope, code |
| "tại sao chậm, fix giúp" | HYBRID | Trả lời why → confirm scope → code |
| "có nên dùng React Query không" | LOGIC | Discuss, không add lib |
| "thêm React Query" | REQUEST | Add lib |
| "form validation hơi yếu" | LOGIC (báo cảm nhận) | Hỏi user muốn (a) discuss hay (b) fix |
| "form validation yếu, thêm Zod" | REQUEST | Add Zod |
| "test fail, kiểm tra" | LOGIC | Diagnose, KHÔNG fix |
| "test fail, fix giúp" | REQUEST | Fix |
| "commit và push" | REQUEST | Commit + push |

### EN
| User utterance | Type | AI should do |
|---|---|---|
| "why is the home page slow" | LOGIC | Analyze, no code |
| "fix the slow home page" | REQUEST | Confirm scope, code |
| "why slow, fix it" | HYBRID | Answer why → confirm scope → code |
| "should we use React Query" | LOGIC | Discuss, don't add lib |
| "add React Query" | REQUEST | Add lib |
| "form validation feels weak" | LOGIC (sentiment) | Ask user: (a) discuss or (b) fix |
| "form validation weak, add Zod" | REQUEST | Add Zod |
| "tests are failing, check" | LOGIC | Diagnose, NO fix |
| "tests failing, fix it" | REQUEST | Fix |
| "commit and push" | REQUEST | Commit + push |

---

## Khi không chắc / When in doubt

### VI
**MẶC ĐỊNH classify là LOGIC.** Hỏi confirm trước khi code:
> "Câu này tôi hiểu là (a) bạn muốn discuss, hay (b) bạn muốn tôi fix? Nếu (b) thì scope như nào?"

Cost của hỏi 1 câu < cost của commit nhầm rồi revert.

### EN
**DEFAULT to LOGIC.** Ask to confirm before coding:
> "I'm reading this as either (a) you want to discuss, or (b) you want me to fix it. If (b), what's the scope?"

The cost of asking one question < the cost of committing wrong then reverting.

---

## Persistent rule / Persistent rule

### VI
Note vào memory file (vd `memory/feedback_classify_logic_request.md`):
```
- Mỗi user utterance: classify LOGIC vs REQUEST
- LOGIC → docs + memory, KHÔNG commit
- REQUEST → code + commit (sau confirm)
- HYBRID → split, trả lời why trước rồi mới code
- Không chắc → default LOGIC, hỏi confirm
```

### EN
Persist to a memory file (e.g. `memory/feedback_classify_logic_request.md`):
```
- Every user utterance: classify LOGIC vs REQUEST
- LOGIC → docs + memory, NO commit
- REQUEST → code + commit (after confirm)
- HYBRID → split, answer why first then code
- When in doubt → default LOGIC, ask to confirm
```

---

## Anti-patterns

| Anti-pattern | VI: Hậu quả | EN: Consequence |
|---|---|---|
| Default REQUEST | Commit nhầm khi user chỉ hỏi | Accidental commits |
| Không hỏi confirm | Code sai scope, revert | Wrong scope, revert |
| LOGIC trả lời rồi auto code luôn | User không có cơ hội pivot | User can't pivot decision |
| HYBRID merge thành 1 commit | Discussion + code lẫn lộn, khó review | Discussion + code conflated, hard to review |

---

## Câu khẩu hiệu / Slogan

> **VI**: "Hỏi không phải lệnh. Khi không chắc — hỏi lại, đừng code."
>
> **EN**: "A question isn't a command. When in doubt — ask back, don't code."
