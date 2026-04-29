# 06 — Pre-Flight Checklist

> **VI**: Trước khi code, AI phải flag risk cụ thể. Như phi công check trước khi cất cánh — không tin "chắc OK".
>
> **EN**: Before coding, AI must flag specific risks. Like a pilot checking before takeoff — never trust "should be fine".

---

## Tại sao cần / Why needed

### VI
Không pre-flight → AI có thể:
- Touch DB prod nhầm (memory bị bỏ qua)
- Edit migration đã apply (gây drift schema)
- Skip permission check (user không có role mà gọi RPC sysadmin)
- Bypass invariant (commit nhầm khi user chỉ hỏi)
- Hardcode secret vào code

Pre-flight = force AI dừng 30 giây list risk → giảm 80% incident.

### EN
Without pre-flight, AI may:
- Touch production DB by mistake (memory ignored)
- Edit a migration already applied (causes schema drift)
- Skip permission checks (user without role calls a sysadmin RPC)
- Bypass invariants (commit when user only asked)
- Hardcode secrets into code

Pre-flight = forces AI to pause 30 seconds, list risks → cuts incidents by 80%.

---

## Khung pre-flight chuẩn / Standard pre-flight frame

### VI
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

### EN
6 default checkpoints, each with a flag color:

| Risk | Red flag | Yellow flag | Green flag |
|---|---|---|---|
| 🟢 LOGIC vs REQUEST | — | HYBRID | Clearly LOGIC or REQUEST |
| 🔴 DB risk | Migration / mutating RPC / drop / alter | Read prod | No DB touch |
| 🟠 Auth/permission | Bypass RLS / change role matrix | Add new role | No auth change |
| 🟡 Migration/schema | Irreversible schema change | Add nullable column | No schema change |
| 🟡 Cross-module impact | > 3 modules touched | 2 modules | 1 module |
| ⚪ Doc + Test sync | Skip both doc and test | Skip one of two | Both doc and test included |

Rule: if **≥ 1 red flag** → STOP, ask user for explicit confirmation before coding.

---

## Tuỳ biến cho domain / Domain-specific extras

### VI
Tuỳ project, thêm:
- **Mobile**: iOS/Android compatibility, permission plist, safe area
- **Realtime**: subscription cleanup, rate limit
- **Payment**: idempotency key, webhook signature
- **AI feature**: token cost, prompt injection
- **Public API**: backwards compat, versioning

Định nghĩa trong sub-agent (xem `templates/context-router.agent.md.template`).

### EN
Per project, add:
- **Mobile**: iOS/Android compat, permission plist, safe area
- **Realtime**: subscription cleanup, rate limit
- **Payment**: idempotency key, webhook signature
- **AI feature**: token cost, prompt injection
- **Public API**: backwards compat, versioning

Define inside the sub-agent (see `templates/context-router.agent.md.template`).

---

## Output template / Output template

### VI
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

### EN
Sub-agent (or main agent) always emits this block BEFORE coding:

```
## Pre-flight flags
- 🟢 LOGIC vs REQUEST: REQUEST (build new feature)
- 🔴 DB risk: HIGH — migration adds NOT NULL column → needs backfill default
- 🟠 Permission: new 'editor' role → update RLS on 4 tables
- 🟡 Migration: REVERSIBLE (down migration ready)
- 🟢 Cross-module: only 1 module touched
- 🟡 Doc + Test sync: need to update 03-database.md + e2e test, planned

## Stop?
Has ≥ 1 red flag (DB risk). Need user confirmation:
- Backfill strategy: hard-coded default or infer from existing?
- Run migration on prod first or staging first?
```

---

## Persistent safety rails / Persistent safety rails

### VI
Note vào memory file (vd `memory/feedback_db_safety.md`):
```
- KHÔNG tự ý chạy migration / drop table / alter trigger / change cron
  / delete edge fn như side-effect của bất kỳ task nào.
- Khi user nói "fix bug X" mà fix cần migration → DỪNG, đề xuất plan
  migration riêng, đợi user duyệt explicit.
- Solar + lunar / created_at + updated_at / từng cặp field phải đi
  cùng nhau (luôn travel as pair).
```

### EN
Persist to a memory file (e.g. `memory/feedback_db_safety.md`):
```
- DO NOT auto-run migrations / drop tables / alter triggers / change
  cron / delete edge fns as side-effect of any task.
- When user says "fix bug X" but the fix needs migration → STOP,
  propose a separate migration plan, wait for explicit user approval.
- Paired fields (solar + lunar, created_at + updated_at, etc.) must
  always travel as a pair.
```

---

## Anti-patterns

| Anti-pattern | VI: Hậu quả | EN: Consequence |
|---|---|---|
| Skip pre-flight cho task "nhỏ" | Task nhỏ thường chứa risk lớn | Small tasks often hide big risks |
| Pre-flight chỉ list, không stop | Mất tác dụng, AI vẫn đi luôn | Loses meaning, AI proceeds anyway |
| Cờ đỏ mà tự "tôi sẽ cẩn thận" | User không có cơ hội veto | User has no veto window |
| Pre-flight không persist | Mỗi session phải re-explain rule | Each session re-explains rules |

---

## Câu khẩu hiệu / Slogan

> **VI**: "30 giây list risk, tiết kiệm 30 phút revert."
>
> **EN**: "30 seconds listing risks saves 30 minutes reverting."
