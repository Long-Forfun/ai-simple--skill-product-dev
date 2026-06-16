# 01 — User-first: registry → nghiệp vụ → cross-user map (B1–B3)

Mọi spec rối rắm đều bắt đầu từ việc viết theo **tính năng** thay vì theo **người dùng**. Tính năng "quản lý đơn" nghe gọn nhưng giấu mất: ai tạo, ai duyệt, ai đối soát — ba người, ba nghiệp vụ, ba flow khác nhau. Bước này ép trả lời "AI làm gì" trước khi nói "hệ thống có gì".

## B1. User registry — điểm xuất phát

Liệt kê **mọi actor**, không chỉ người:
- **Người**: theo role/tier (chủ/nhân viên/kế toán; free/pro; admin/staff/khách-portal).
- **Phi người**: external system (cổng thanh toán, sàn TMĐT), cron/scheduler (nhắc hạn, đồng bộ đêm), webhook (nhận sự kiện ngoài).

Mỗi actor ghi: **là ai · vòng đời (public/mới/quen/power) · bối cảnh-thiết bị chính**. Vòng đời + bối cảnh là cầu nối sang `ui-design-logic` (user-ladder) — khai ở đây để design KHÔNG hỏi lại.

> Không có "user chung chung". Nếu chỉ viết được 1 dòng "người dùng" → chưa phân tích, chia tiếp theo *quyền* và *việc họ đến để làm*.

## B2. User × Nghiệp vụ — mỗi nghiệp vụ đúng 1 owner-user

Với **từng user**, hỏi: user này đến hệ thống để hoàn thành những **nghiệp vụ** nào? Một nghiệp vụ = một mục tiêu công việc có điểm bắt đầu và kết thúc (Tạo đơn, Duyệt đơn, Đối soát công nợ, Xuất báo cáo).

Quy tắc:
- **Mỗi nghiệp vụ buộc đúng 1 OWNER-USER** — người chịu trách nhiệm chính & khởi xướng. Gắn không được = nghiệp vụ **mồ côi** → xoá hoặc gán lại.
- Nghiệp vụ có user khác *tham gia* (không sở hữu) → ghi vào cột "user liên quan" → sẽ thành cross-user ở B3.
- Gán **tần suất** (cao/trung/thấp) + **ưu tiên** (MoSCoW: Must/Should/Could/Won't; hoặc RICE nếu cần định lượng Reach×Impact×Confidence÷Effort).

> Đây thay cho "danh sách tính năng": một bảng user→nghiệp vụ luôn truy được "tính năng này phục vụ ai", chống bệnh *không định hướng*.

## B3. Cross-user handoff map — chống cross lung tung / treo

Nghiệp vụ dính nhiều user là nơi flow **treo, bỏ dở** nhiều nhất (A làm xong tưởng B nhận, B không biết). Khai tường minh mọi bàn giao:

| Phải có | Vì sao |
|---|---|
| **Từ user → user nhận** | biết ai chịu chặng kế |
| **Điều kiện chuyển** | khi nào thì chuyển (trạng thái/sự kiện) |
| **Điểm kết khi KHÔNG ai nhận** | chống treo: quá hạn → nhắc/cron/huỷ-tự-động |

Luật:
- Cấm **cross ngầm** (nghiệp vụ A đụng dữ liệu nghiệp vụ B của user khác mà không khai). Mọi đụng chạm cross-user phải là 1 dòng handoff.
- **Cross tối thiểu**: chỉ cross khi thật cần. Nếu một flow có **>2 cross-point (≥3 user)** → nghi ngờ đang gánh nhiều nghiệp vụ, tách ra. (cùng ngưỡng rubric §4 ở references/02.)
- Mọi handoff phải có **điểm kết khi treo** — không có cột đó = flow có thể nằm chờ vô hạn.

`Cross-User-Integrity` agent (xem references/02 §B5) soi lại toàn map tìm: handoff orphan (không người nhận), điều kiện thiếu, **vòng lặp-treo** (khác rework-loop hợp lệ — xem Edge cases), nghiệp vụ mồ côi.

## Edge cases — cấu hình owner/cross bất thường (xử rõ, KHÔNG improvise)
| Ca | Luật |
|---|---|
| **App 1 user, không cross** | §4 ba-spec (cross-user map) ghi `N/A — không cross`; KHÔNG bịa handoff giả cho đủ bảng |
| **Nghiệp vụ tự động hoàn toàn** (cron/webhook, không người khởi xướng) | owner = **system-actor** đó; "owner" = "ai chịu trách nhiệm KHI NÓ HỎNG" (thường admin) — KHÔNG xoá vì tưởng "mồ côi" |
| **Nghiệp vụ luân ca / đồng sở hữu** (ai online thì nhận) | owner = **role** (vd "trực ca"), vẫn "1 owner-role"; cá nhân hoá ở runtime, không ở spec |
| **Rework-loop** (sửa → duyệt lại → sửa) | vòng lặp **có điều kiện thoát** = HỢP LỆ, không phải dead-end; chỉ vòng **không điều kiện thoát** mới là treo (rubric §4) |
| **Nghiệp vụ phụ thuộc nghiệp vụ** (NV2 cần NV1 xong, có thể cùng user) | khai cột **Phụ thuộc NV** (depends-on) ở §3 ba-spec → thành precondition (Given) của AC; KHÁC cross-user (cross = chuyển giữa user; depends = thứ tự giữa nghiệp vụ) |

## Output
Điền §2, §3 (kèm cột Phụ thuộc NV), §4 của `templates/ba-spec.md.template`. Xong B3 mới sang B4 (flow) — vì flow phải biết nó thuộc nghiệp vụ nào, của user nào, cross ở đâu, phụ thuộc gì.
