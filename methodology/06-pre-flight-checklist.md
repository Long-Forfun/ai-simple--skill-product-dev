# 06 — Pre-Flight Checklist (risk-tiered)

> Flag risk trước khi code — nhưng **tự chạy với mặc định an toàn**, chỉ dừng hỏi tại điểm không thể quay đầu. Confirm là ngoại lệ đắt giá, không phải nghi thức.
> *(EN: Flag risks before coding — but auto-proceed with safe defaults; stop to ask only at the point of no return. Confirmation is an expensive exception, not a ritual.)*

**v3 — 2026-06-11**: bỏ quy tắc "≥1 cờ đỏ → STOP hỏi user" của bản cũ. Thực tế vận hành cho thấy nó biến user thành nút bấm OK lặt vặt và giảm tốc độ code mà không tăng an toàn — vì 90% "cờ đỏ DB" là thao tác additive đảo ngược được.

---

## Tại sao cần / Why needed

Không pre-flight → AI có thể touch DB prod nhầm, edit migration đã apply, bypass permission, hardcode secret. Nhưng pre-flight **kiểu cũ** (mọi thứ đụng DB đều chờ duyệt) tạo vấn đề ngược: user phải review lặt vặt, AI mất khả năng tự hành, tốc độ giảm — và user mệt quá sẽ OK bừa, còn nguy hiểm hơn.

Giải pháp: phân tầng theo **khả năng đảo ngược**, không phải theo "có đụng DB hay không".

---

## 3 tầng rủi ro / 3 risk tiers

| Tầng | Tiêu chí | Hành vi AI |
|---|---|---|
| 🟢 **GREEN** | Đảo ngược bằng git: code, UI, doc, test, file mới, read-only query | **Đi thẳng**, không hỏi, không cần liệt kê |
| 🟡 **YELLOW** | Đảo ngược có chủ đích: bảng mới, cột nullable mới, index, RLS **siết chặt thêm**, role mới chưa gắn user, 2-3 module, cron/job mới chưa bật | **Tự làm theo phương án an toàn nhất** + bắt buộc reversible (down migration / feature flag) + ghi vào mục **Assumptions** của báo cáo cuối. KHÔNG hỏi trước |
| 🔴 **RED** | Không thể quay đầu hoặc nổ ở prod: DROP/ALTER mất data, RLS **nới lỏng**, đổi role matrix đang dùng, mutate data prod, xóa/sửa cron-edge fn **đang chạy**, breaking change schema liên repo (nguyên tắc 10) | **Dừng, hỏi đúng 1 câu gộp** kèm phương án đề xuất, đợi trả lời |

Mẹo phân tầng nhanh: tự hỏi *"nếu sai, undo mất bao lâu?"* — vài giây (git revert) = GREEN; một lệnh có chuẩn bị sẵn (down migration) = YELLOW; phải restore backup hoặc không undo được = RED.

---

## Quy tắc confirm — chống review lặt vặt / Anti-petty-review rules

1. **Tối đa 1 câu confirm cho cả task** — gom mọi điều cần hỏi vào MỘT message, mỗi điều kèm phương án đề xuất đánh dấu *(khuyến nghị)*. Không hỏi rải rác từng bước.
2. **Chỉ hỏi khi câu trả lời đổi cách làm** — nếu mọi đáp án đều dẫn về cùng implementation, tự chọn và ghi assumption.
3. **YELLOW dùng format "default-unless"**: *"Tôi làm X (an toàn, có down migration). Muốn khác thì nói."* — rồi **đi tiếp luôn, không đợi**. User veto sau vẫn kịp vì mọi thứ reversible.
4. **Assumptions tập trung ở cuối**: mọi quyết định tự chọn liệt kê trong mục `## Assumptions` của báo cáo hoàn thành — user review 1 lần/task, không phê duyệt từng bước.
5. **Trả lời lặp lại → memory**: user đã trả lời cùng loại câu hỏi 2 lần → persist vào memory (nguyên tắc 07) và không bao giờ hỏi lại. Confirm bị lặp = bug của quy trình.

---

## Khung pre-flight chuẩn / Standard pre-flight frame

Vẫn quét 6 ô như cũ, nhưng output gọn và chỉ hiện khi có YELLOW/RED:

```
## Pre-flight
- DB: 🟡 thêm bảng `hp_rewards` + cột nullable — additive, có down migration → tự làm
- Auth: 🟢 không đổi
- Cross-module: 🟡 2 module (shop, scoring) → tự làm
- Doc+Test: update 03-database.md + unit test scoring — đã plan
→ Tier: YELLOW → ĐI TIẾP, assumptions báo cuối task.
```

Khi RED:

```
→ Tier: RED — cần xóa cột `legacy_score` (mất data không khôi phục được).
## Confirm (1 câu duy nhất)
"Xóa hẳn cột legacy_score (mất data cũ) hay (khuyến nghị) rename thành legacy_score_deprecated
giữ 30 ngày rồi xóa? Trả lời 1/2 — mọi phần khác của task tôi đã tự xử lý theo assumptions."
```

---

## Persistent safety rails

Note vào memory (vd `feedback_db_safety.md`) — bản v3 đã nới đúng chỗ:
```
- Migration ADDITIVE (bảng mới, cột nullable, index) + có down migration → tự làm, báo sau.
- DROP / ALTER mất data / RLS nới lỏng / mutate data prod → RED, 1 câu confirm gộp, đợi.
- Các cặp field (start_date + end_date, …) luôn đi cùng nhau (travel as pair).
- Mỗi loại câu hỏi user đã trả lời 2 lần → ghi memory, không hỏi lại.
```

---

## Anti-patterns

| Anti-pattern | Hậu quả |
|---|---|
| Hỏi confirm cho việc reversible | User thành nút OK lặt vặt, mất tốc độ, mất niềm tin vào confirm thật |
| Hỏi rải rác nhiều câu trong 1 task | Mỗi câu là 1 lần ngắt context của user |
| Cờ đỏ mà tự "tôi sẽ cẩn thận" rồi làm | RED là RED — không thể quay đầu thì phải đợi |
| Confirm không kèm phương án đề xuất | Đẩy việc nghĩ sang user — câu hỏi tốt là câu chỉ cần trả lời "1" |
| YELLOW mà không làm reversible | Mất quyền tự hành — không có down migration thì nó là RED |
| Hỏi lại câu user đã từng trả lời | Memory (07) tồn tại để làm gì |

---

## Câu khẩu hiệu / Slogan

> "Reversible thì cứ làm — irreversible thì hỏi MỘT câu cho đáng."
