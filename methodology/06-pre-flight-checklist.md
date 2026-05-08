# 06 — Pre-Flight Checklist

> Trước khi code, AI phải flag risk cụ thể. Như phi công check trước khi cất cánh — không tin "chắc OK".

---

## Tại sao cần / Why needed

Không pre-flight → AI có thể:
- Touch DB prod nhầm (memory bị bỏ qua)
- Edit migration đã apply (gây drift schema)
- Skip permission check (user không có role mà gọi RPC sysadmin)
- Bypass invariant (commit nhầm khi user chỉ hỏi)
- Hardcode secret vào code

Pre-flight = force AI dừng 30 giây list risk → giảm 80% incident.

---

## Khung pre-flight chuẩn / Standard pre-flight frame

6 ô kiểm tra mặc định, mỗi ô màu cờ:

| Risk | Khi flag đỏ | Khi flag vàng | Khi flag xanh |
|---|---|---|---|
| 🟢 LOGIC vs REQUEST | — | HYBRID | LOGIC hoặc REQUEST rõ |
| 🔴 DB risk | Migration / RPC mutate / drop / alter | Read prod | Không touch DB |
| 🟠 Auth/permission | Bypass RLS / change role matrix | Add new role | No auth change |
| 🟡 Migration/schema | Schema change irreversible | Add column nullable | No schema change |
| 🟡 Cross-module impact | > 3 module touched | 2 module | 1 module |
| ⚪ Doc + Test sync | Skip cả doc + test | Skip 1 trong 2 | Có cả doc + test |

Quy tắc: nếu có **≥ 1 cờ đỏ** → STOP, hỏi user confirm explicit trước khi code.

---

## Tuỳ biến cho domain / Domain-specific extras

Tuỳ project, thêm:
- **Mobile**: iOS/Android compatibility, permission plist, safe area
- **Realtime**: subscription cleanup, rate limit
- **Payment**: idempotency key, webhook signature
- **AI feature**: token cost, prompt injection
- **Public API**: backwards compat, versioning

Định nghĩa trong sub-agent (xem `templates/context-router.agent.md.template`).

---

## Output template

Sub-agent (hoặc main agent) luôn xuất block này TRƯỚC khi code:

```
## Pre-flight flags
- 🟢 LOGIC vs REQUEST: REQUEST (build feature mới)
- 🔴 DB risk: HIGH — migration thêm cột NOT NULL → cần backfill default
- 🟠 Permission: thêm role 'editor' → cập nhật RLS 4 table
- 🟡 Migration: REVERSIBLE (down migration sẵn)
- 🟢 Cross-module: chỉ 1 module touched
- 🟡 Doc + Test sync: cần update 03-database.md + e2e test, đã plan

## Stop?
Có ≥ 1 cờ đỏ (DB risk). Cần user confirm:
- Backfill chiến lược nào: hard-coded default hay infer từ existing?
- Migration chạy trên prod hay staging trước?
```

---

## Persistent safety rails

Note vào memory file (vd `memory/feedback_db_safety.md`):
```
- KHÔNG tự ý chạy migration / drop table / alter trigger / change cron
  / delete edge fn như side-effect của bất kỳ task nào.
- Khi user nói "fix bug X" mà fix cần migration → DỪNG, đề xuất plan
  migration riêng, đợi user duyệt explicit.
- Các cặp field (vd `start_date + end_date`, `created_at + updated_at`)
  phải luôn đi cùng nhau (travel as pair).
```

---

## Anti-patterns

| Anti-pattern | Hậu quả |
|---|---|
| Skip pre-flight cho task "nhỏ" | Task nhỏ thường chứa risk lớn |
| Pre-flight chỉ list, không stop | Mất tác dụng, AI vẫn đi luôn |
| Cờ đỏ mà tự "tôi sẽ cẩn thận" | User không có cơ hội veto |
| Pre-flight không persist | Mỗi session phải re-explain rule |

---

## Câu khẩu hiệu / Slogan

> "30 giây list risk, tiết kiệm 30 phút revert."
