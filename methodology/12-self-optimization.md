# 12 — Self-Optimization Loop

> Hệ docs không phải tượng đài — nó là sinh vật phải tự tiến hóa. Nguyên tắc này định nghĩa NHỊP (khi nào), TÍN HIỆU (cái gì kích hoạt), và HÀNH ĐỘNG (update / refactor / làm lại / khai tử) — để hệ tự tối ưu theo lịch và theo sự kiện, không chờ ai nhớ ra.
> *(EN: The docs system is not a monument — it's an organism that must evolve itself. This principle defines CADENCE (when), SIGNALS (what triggers), and ACTIONS (update / refactor / rebuild / retire) so the system optimizes itself on schedule and on signal, without relying on anyone remembering.)*

---

## Vấn đề / The problem

Nguyên tắc 01–11 cho hệ thống **đúng tại thời điểm setup**. Nhưng project sống tiếp:
- Doc tốt hôm nay → 6 tháng sau mô tả một app không còn tồn tại
- Hook/report phát hiện vấn đề → nhưng "ai sửa, sửa đến đâu, khi nào làm lại từ đầu" không ai định nghĩa
- Phương pháp chỉ biết **phát hiện** (detect) mà không biết **tự chữa** (heal) thì điểm số chỉ đi xuống theo thời gian

---

## Nhịp bảo trì / Maintenance cadence

4 tầng nhịp — 2 tầng đầu máy chạy, 2 tầng sau AI chạy với chi phí người ≤ 15 phút:

| Nhịp | Cơ chế | Việc | Đã ship ở |
|---|---|---|---|
| **Mỗi commit** | pre-commit hook (tự động) | Chặn: migration↔doc sync, token budget, contract version | 08 |
| **Mỗi tuần / mỗi PR** | doc-health-report `--ci` (tự động) | Đo: drift %, stale, broken ref, `_generated` cũ | 08, 09 |
| **Mỗi tháng** | AI session 1 lần, người đọc 5 phút | Promote buffer `20-recent-features.md` → file riêng cho feature đã stable; root diet nếu ≥ 80% budget; consolidate memory (07); xử lý backlog WARN của report | 12 (this) |
| **Mỗi quý** | `/audit` agent (template sẵn) | Tự chấm 12 nguyên tắc → backlog tối ưu có ưu tiên; semantic verify doc vs code; review contract consumers; fire-drill runbook (chạy thử các lệnh health) | 12 (this) |

---

## Bảng tín hiệu → hành động / Signal → action table

Tối ưu **theo sự kiện**, không chỉ theo lịch. Tín hiệu nào bắn, làm đúng việc đó:

| Tín hiệu (đo được) | Hành động | Loại |
|---|---|---|
| Root CLAUDE.md ≥ 80% budget | Root diet (01 §diet) ngay — đừng đợi hook chặn | UPDATE |
| App-map file > 1500 dòng | Tách file (02) | REFACTOR |
| App-map > 20 file phẳng | Domain hóa 2 tầng (02 §scaling) | REFACTOR |
| Drift % < ngưỡng 2 tuần liên tiếp | Thêm pattern vào hook (cặp code→doc bị lọt) — siết máy, đừng nhắc người | UPDATE hook |
| `/fl` route sai cùng 1 kiểu ≥ 2 lần | Update keyword map trong context-router agent | UPDATE router |
| Sự cố cùng loại lần 2 | Thêm mục "lỗi thường gặp" vào runbook (11 §4) | UPDATE runbook |
| User trả lời cùng câu hỏi lần 2 | Persist memory (07), không hỏi lại | UPDATE memory |
| **Doc mồ côi**: chủ thể không còn trong code — module/route/bảng/feature đã xóa hoặc bị thay thế (đo: doc tham chiếu entity không còn tồn tại — semantic verify của audit bắt được) | Đánh dấu DEPRECATED + ngày, giữ 1 tháng, xóa. CHỈ khai tử khi chủ thể đã chết — doc sống theo code, không sống theo lượt đọc | RETIRE |
| Doc lạnh: không xuất hiện trong `docs/.fl-routing-log` 90 ngày NHƯNG chủ thể vẫn còn trong code | **KHÔNG xóa.** (a) Check keyword map của context-router — doc không được route nhiều khi là lỗi router thiếu keyword, không phải lỗi doc; (b) đưa vào danh sách verify của audit quý (lâu không ai đọc = lâu không ai bắt lỗi stale). Doc về module ổn định ít đụng chính là doc quý nhất lúc quay lại | UPDATE router / verify |
| Semantic audit: doc mô tả sai căn bản so với code | **LÀM LẠI** file đó từ code thật — sửa vá doc sai nền tảng tốn hơn viết lại | REBUILD |
| `08-app-structure-real.md` lệch folder thật | Regenerate từ filesystem (09) — đây là doc "cái gì", máy sinh | REBUILD (máy) |
| Schema contract bump major version | Đợt sửa nguyên tử: producer + mọi consumer + contract changelog cùng ngày (10) | UPDATE đồng bộ |

---

## Update vs Refactor vs Làm lại vs Khai tử — quy tắc chọn

- **UPDATE**: nội dung đúng nền, lệch chi tiết → thêm/sửa entry, bump `v2 — date` history
- **REFACTOR**: nội dung đúng nhưng cấu trúc sai cỡ (file quá to, cây quá phẳng) → tách/gộp, giữ nội dung, để stub `MOVED →`
- **REBUILD**: nội dung sai căn bản hoặc là doc "cái gì" có thể máy sinh → viết lại từ source of truth, không vá
- **RETIRE**: chủ thể của doc đã bị xóa khỏi code (mồ côi) → DEPRECATED + ngày, giữ 1 tháng, xóa. **Tuyệt đối không retire vì "lâu không ai đọc"** — doc tồn tại theo code, không theo lượt đọc; xóa doc của module còn sống = lúc code đụng lại mất sạch ngữ cảnh
- Mẹo: đọc 5 phút mà sửa được → UPDATE. Sửa 1 giờ không xong → REBUILD rẻ hơn. Chủ thể đã biến mất khỏi codebase → RETIRE. Lạnh nhưng chủ thể còn sống → verify rồi để yên.

---

## Tự chấm điểm / Self-audit

Quý 1 lần, chạy `/audit` (slash command, template: `templates/audit.command.md.template`) — phiên audit read-only:
1. Chấm 12 nguyên tắc 0–10 kèm bằng chứng đo được (size, count, git log) — không chấm cảm tính
2. Semantic verify: chọn 3 doc authored rủi ro nhất, diff **khẳng định trong doc** với `_generated/` + code thật → liệt kê khẳng định sai
3. Đối chiếu bảng tín hiệu trên: tín hiệu nào đang bắn mà chưa xử lý
4. Output: **backlog tối ưu xếp hạng** (việc, loại U/R/R/R, effort, deadline đề xuất) — đây chính là câu trả lời "đến thời điểm này cần tối ưu cái gì"

Điểm audit append vào `docs/audit-history.md` — **log append-only, KHÔNG nằm trong `_generated/`** (nguyên tắc 09 định nghĩa `_generated/` là "regenerate được từ source bất kỳ lúc nào"; lịch sử audit không regenerate được, để trong đó sẽ bị `rm -rf _generated && gen-docs` xóa mất trend). Trend đi xuống 2 quý liên tiếp = hệ đang mục, ưu tiên backlog lên đầu sprint.

---

## Anti-patterns

| Anti-pattern | Hậu quả |
|---|---|
| Chỉ detect không heal (có report, không có owner + deadline) | Cảnh báo chồng đống → mù cảnh báo, hệ mục dần |
| Vá doc sai nền tảng thay vì rebuild | Doc thành chăn vá — AI đọc tin nhầm phần cũ |
| Tối ưu theo cảm hứng ("dạo này rảnh dọn docs") | Lúc bận nhất là lúc drift nặng nhất — phải theo nhịp + tín hiệu |
| Giữ doc MỒ CÔI (chủ thể đã xóa khỏi code) "biết đâu cần" | Token tax + AI đọc tin vào feature không còn tồn tại |
| Xóa doc chỉ vì lâu không ai đọc | Đốt trí nhớ của module còn sống — lúc code đụng lại mất sạch ngữ cảnh, phải reverse-engineer từ đầu |
| Audit bằng cảm tính không kèm số đo | Điểm đẹp, hệ vẫn mục — bằng chứng đo được hoặc không tính |

---

## Checklist áp dụng / Adoption checklist

- [ ] `.claude/commands/audit.md` tồn tại (copy từ template)
- [ ] Lịch tháng/quý có trong root CLAUDE.md §Bảo trì định kỳ (template đã có sẵn mục này)
- [ ] Bảng tín hiệu→hành động được root CLAUDE.md link tới (file này)
- [ ] `docs/audit-history.md` có ≥ 1 entry sau quý đầu; `docs/.fl-routing-log` đang được append (tín hiệu RETIRE đo được)
- [ ] Mỗi mục backlog audit có owner + deadline — không có thì chưa gọi là loop
