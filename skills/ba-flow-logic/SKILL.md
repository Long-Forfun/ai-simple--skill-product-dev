---
name: ba-flow-logic
description: "BA hướng-người-dùng — pha PHÂN TÍCH NGHIỆP VỤ đầu pipeline BA→design→build→triage. Biến nhu cầu mơ hồ thành ba-spec (acceptance criteria = oracle hành vi) qua trục USER → nghiệp vụ → cross-user handoff → flow (Input/Output) → tối ưu flow bằng team-agent (suggest + đánh giá + chuyên gia nghiệp vụ) → AC. Kích hoạt khi: 'làm BA', 'phân tích nghiệp vụ', 'viết yêu cầu/spec', 'vẽ/tối ưu flow', nhu cầu/tính năng mới còn mơ hồ, hoặc nhận handoff ngược từ triage (spec sai/thiếu). KHÔNG kích hoạt cho thiết kế UI (→ui-design-logic), triage defect (→ui-ux-triage), đổi nhỏ đã rõ (→build). Defer ai-simple cho risk-tier/memory/coupling/verify; dừng ở WHAT+WHY, KHÔNG đụng UI/screen/code."
---

# BA Flow Logic — phân tích nghiệp vụ hướng người dùng (team-agent)

BA KHÔNG phải viết một đống yêu cầu chung chung. BA là **chuỗi quyết định đi từ NGƯỜI DÙNG xuống**: ai dùng → họ có những nghiệp vụ gì → nghiệp vụ nào bắt tay với user khác → mỗi nghiệp vụ chạy theo flow nào (vào gì / ra gì) → flow nào là **tối ưu** → nghiệm thu bằng acceptance criteria.

```
USER → nghiệp vụ của user → cross-user handoff → flow (Input→Output)
→ tối ưu flow (team-agent suggest + đánh giá) → Acceptance Criteria → ba-spec.md
```

**Spec tốt là hệ quả của tính hướng-đích.** Spec xấu — luồng treo, bỏ dở, lỗi — đến từ: viết chung chung, không định hướng, không mục tiêu, rối rắm, cross nghiệp vụ của user khác lung tung. Skill này diệt 6 bệnh đó bằng **rubric tối ưu** (§4, áp ở bước B5) và **owner-user bắt buộc cho mọi nghiệp vụ**.

---

## 0. Vị trí trong hệ 4-skill (ĐỌC TRƯỚC)

```
[ba-flow-logic] (nhu cầu→ba-spec) → ui-design-logic (→design-spec) → build → ui-ux-triage (vận hành/sửa)
        └──────────────── tất cả trên nền ai-simple (rail + truth + tier + memory + verify) ────────────┘
```

- **Skill này = pha PHÂN TÍCH.** Chưa có code; biến nhu cầu thành **oracle hành vi** (`ba-spec`).
- **Output `ba-spec` là canonical app-map doc** — sống ở `docs/app-map/*ba-spec*.md`, đủ frontmatter coupling. `ui-design-logic` đọc nó (user-ladder + flow), `ui-ux-triage` đọc AC làm oracle.
- **Defer sang ai-simple** (§Defer): risk-tier #06, memory #07, coupling/verify #12, doc+test #04 — KHÔNG tự chế lại.
- **Nhận handoff NGƯỢC từ triage** (§Reverse): "code khớp spec mà vẫn sai" = spec sai/thiếu → sửa AC, KHÔNG sửa code.
- **Độc lập được**: chạy riêng cho app chỉ cần spec hành vi. Vắng ai-simple → degrade: tier áp cục bộ, ba-spec để root tạm.

---

## 1. Trigger / non-trigger / tie-breaker

Kích hoạt khi user:
- "làm BA", "phân tích nghiệp vụ", "viết yêu cầu / spec / SRS", "vẽ flow", "tối ưu flow/quy trình"
- Mô tả một nhu cầu/tính năng MỚI còn mơ hồ ("tôi muốn làm app X", "thêm mảng Y cho hệ thống")
- "acceptance criteria", "định nghĩa đúng-sai cho tính năng"
- Nhận **handoff ngược** từ `ui-ux-triage` (code khớp spec mà vẫn sai)

KHÔNG kích hoạt (→ skill khác):
- Thiết kế màn, layout, "làm đẹp", chọn component/màu → **ui-design-logic**
- Defect trên UI đã chạy, "màn này sai", test+fix → **ui-ux-triage**
- Đổi nhỏ ĐÃ RÕ (sửa 1 rule có sẵn, đổi text) → **build thẳng**, không cần BA
- DB migration / schema → ASK + gate (ai-simple #06 RED)

Tie-breaker: cùng trigger "rà soát" → BA = phân tích nhu cầu/flow TRƯỚC khi có code; triage = sửa code ĐÃ có; ui-design-logic = quyết giao diện. Nghi ngờ "đây là WHAT hay HOW?" → WHAT (user/flow/rule) là BA, HOW (screen/pixel) là design.

---

## 2. Pipeline 7 bước — BẮT BUỘC theo thứ tự, không nhảy cóc

```
B0 Sàng        → LOGIC vs REQUEST (ai-simple #05); need mơ hồ/mới → chạy; đổi nhỏ rõ → trả về build
B1 User registry → liệt kê MỌI actor (loại user/role/tier, cả external system, cron, admin) = ĐIỂM XUẤT PHÁT
B2 User×Nghiệp vụ → mỗi user có nghiệp vụ gì; mỗi nghiệp vụ buộc đúng 1 OWNER-USER
B3 Cross-user map → nghiệp vụ dính nhiều user: ai bàn giao ai · điều kiện chuyển · KHÔNG dead-end
B4 Flow/nghiệp vụ → Input → Steps → Output; owner-user; điểm cross; START rõ + END rõ
B5 Tối ưu flow  → TEAM-AGENT: suggest biến thể → chấm rubric → flow tối ưu + lý do (+ chuyên gia nếu nghiệp vụ chuyên)
B6 AC từ flow tối ưu → Given/When/Then dựa Input/Output = ORACLE → viết ba-spec.md   ← CHỐT CHẶN
```

**`ba-spec` là chốt chặn**: chưa có ba-spec (B6) thì CHƯA chuyển sang design. Spec nhỏ cho việc nhỏ — thêm 1 nghiệp vụ thì spec ngắn, nhưng phải có, vì nó ép trả lời "nghiệp vụ này của USER nào, vào gì ra gì, đúng là gì" trước khi vẽ màn.

Template đầy đủ: `templates/ba-spec.md.template`. Chi tiết từng bước: `references/`.

---

## 3. Team-agent roster cho B5 (spawn như ui-ux-triage; TeamCreate prefix "ba-flow")

```
TeamCreate team_name=ba-flow-<n>
  BA-Orchestrator → Flow-Suggester / Flow-Optimizer / Domain-Specialist(động) / Cross-User-Integrity
```

| Agent | Vai trò | Không làm |
|---|---|---|
| **BA-Orchestrator** (điều phối) | Giữ map user×nghiệp vụ; xử user nào trước; **quyết khi nào gọi Domain-Specialist**; ráp ba-spec; áp risk-tier; gate cuối | Không tự chấm flow một mình |
| **Flow-Suggester** (fan-out) | Mỗi nghiệp vụ → ≥2 biến thể flow theo các góc: *ngắn nhất / an toàn nhất / ít cross nhất* | Không tự chốt |
| **Flow-Optimizer** (đánh giá) | Chấm biến thể theo **rubric** → chọn/ghép flow tối ưu + ghi lý do loại biến thể khác | Không nói UI |
| **Domain-Specialist** (động) | Khi nghiệp vụ CHUYÊN (kế toán/công nợ/kho/thanh toán/bảo hiểm/y tế/pháp lý/CSKH…) → đánh giá đúng & đủ theo chuẩn nghiệp vụ đó | Không generic |
| **Cross-User-Integrity** | Soi toàn map: handoff orphan/treo, cross thừa, nghiệp vụ không owner → trả danh sách điểm gãy | Không sửa, chỉ báo |

Cơ chế: team-agent (Agent/Task), **TeamDelete sau khi user confirm done**. App nhỏ/1 user/nghiệp vụ đơn giản → Orchestrator chạy tuần tự, không cần spawn (đừng over-engineer). Spawn khi: ≥3 nghiệp vụ, hoặc có nghiệp vụ chuyên, hoặc có cross-user, hoặc user yêu cầu "tối ưu flow".

**Thẩm quyền & xử mâu thuẫn (ai chốt flow cuối):** Domain-Specialist là **CỔNG HỢP-LỆ chạy TRƯỚC Optimizer** — loại biến thể sai chuẩn nghiệp vụ; **Specialist có quyền veto** (sai chuẩn = hỏng thật, thắng mọi tối ưu hình thức). Optimizer chỉ chọn **trong các biến thể đã hợp-chuẩn**. Mâu thuẫn không gỡ → **BA-Orchestrator là trọng tài cuối**, ghi conflict + quyết định vào Flow optimization log (§6 ba-spec). Flow "chốt" = qua Specialist (nếu chuyên) + Optimizer; user chỉ xác nhận ở mức ba-spec tổng, không vi mô từng flow.

---

## 4. Rubric "flow tối ưu" (Optimizer chấm — map 1-1 với 6 bệnh)

| Tiêu chí (đạt = ✓) | Diệt bệnh (1-1) |
|---|---|
| **Định hướng**: flow gắn đúng 1 nghiệp vụ + 1 owner-user + nằm trong scope IN (§7 ba-spec) | không định hướng |
| **Input đủ · Output rõ**, quan sát được (không "xử lý xong") | viết chung chung |
| **Không dead-end**: mọi nhánh có điểm kết; mọi handoff có **người nhận + điều kiện** | treo / bỏ dở |
| **Cross-user tường minh & tối thiểu**: chỉ cross khi thật cần, mỗi cross ghi rõ | cross lung tung |
| **Ít bước nhất mà vẫn đủ**: gộp bước thừa, không vòng vo | rối rắm |
| **Có success metric đo được** (outcome định lượng) | không mục tiêu |

Flow trượt ≥1 tiêu chí → Optimizer trả về Suggester sửa, KHÔNG đưa vào ba-spec. Ghi candidate bị loại + lý do vào **Flow optimization log** (mục 6 của ba-spec) — để /audit về sau truy được.

---

## 5. Quy tắc cứng (vi phạm là bug, không phải ý kiến)

**Ranh giới WHAT/HOW (luật vàng):**
- BA chỉ nói **WHAT + WHY**: user, nghiệp vụ, flow, input/output, rule, acceptance. **KHÔNG** nói HOW-nhìn (màn/layout/màu/nút → ui-design-logic) hay HOW-chạy (code → build).
- AC/flow nhắc tới `màu | nút | góc | màn hình | sidebar | button | popup` = **sai tầng**, viết lại bằng hành vi.

**User-first:**
- Không có "user chung chung": **User registry** liệt kê từng loại; mỗi nghiệp vụ buộc đúng 1 **owner-user**. Nghiệp vụ không gắn được owner = nghiệp vụ mồ côi → xoá hoặc gán lại.
- Nghiệp vụ dính nhiều user → khai **cross-user handoff** (ai→ai, điều kiện); cấm để cross ngầm.

**Flow:**
- Mỗi flow có **Input** (cần gì để bắt đầu) + **Output** (kết quả quan sát được) + **start/end rõ**. Flow kết thúc lơ lửng = chưa xong.
- Mỗi flow tối ưu phải qua **≥1 đánh giá** (Optimizer; + Domain-Specialist nếu chuyên) — không tự nhận "tối ưu".

**Acceptance Criteria — mỗi AC PHẢI test được (ai-simple #04):**
- AC dạng **Given / When / Then**, atomic, map tới đúng 1 flow.
- **Mỗi AC khai `Test:` (e2e | integration | unit | manual) + `Assert` đo được bằng máy.** Then không quan sát được → viết lại, CẤM để AC "không test được". User flow mới → mặc định E2E (#04 bảng test). BA khai test INTENT, build viết test CODE. Spec vẽ ra mà không test được = chưa xong.
- **`Assert` phải ĐỊNH LƯỢNG**: chứa ≥1 giá trị/ngưỡng cụ thể (`==`/`<=`/`>=`, count, hoặc trạng-thái-đặt-tên). "đúng / hợp lệ / như mong đợi" = chưa đo được, viết lại. (cổng `ba-verify.sh` WARN nếu Assert thiếu định lượng; BLOCK nếu thiếu hẳn.)

**Elicitation (solo+AI):**
- Hỏi **1 lượt gộp**, fail-closed: thiếu info → chọn giả định an toàn + ghi **Assumptions**, KHÔNG hỏi lặt vặt. Chỉ **RED** (sửa/xoá AC-flow mà downstream đang phụ thuộc) mới dừng hỏi đúng 1 câu gộp.

---

## 6. Defer sang ai-simple (KHÔNG tự chế lại nếu skill đó có mặt)

| Việc | Chủ sở hữu | BA làm gì |
|---|---|---|
| Risk-tier GREEN/YELLOW/RED | ai-simple #06 | Phân loại thay đổi AC/flow theo tier; chỉ RED → 1 ASK gộp |
| Memory format + luật ≥2x | ai-simple #07 | Ghi preference theo format đó (vd: user luôn muốn flow ngắn hơn an toàn) |
| Coupling `covers/last_verified/ttl`, verify-on-use, /audit | ai-simple #12 | ba-spec mang frontmatter; verify oracle trước khi triage tin |
| doc+test sync | ai-simple #04 | AC = test → ba-spec đổi CÙNG COMMIT với code |
| design-spec, screen/layout/token | ui-design-logic | Gửi user+flow làm input, KHÔNG tự định nghĩa UI |
| Triage defect, fix loop | ui-ux-triage | Nhận handoff ngược (§7), không tự triage |

---

## 7. Reverse handoff từ triage

Triage đẩy về "code KHỚP ba-spec mà vẫn sai" → BA phân loại, **sửa spec không sửa code** (định nghĩa tier: `references/04` + ai-simple #06 — KHÔNG tự chế lại):

| Tình huống | Hành động | Tier |
|---|---|---|
| **Spec sai** — AC viết sai hành vi | Sửa AC/flow | sửa AC downstream phụ thuộc = **RED** (1 ASK) |
| **Nhu cầu thiếu** — chưa có AC cho ca này | Thêm AC/flow mới | GREEN/YELLOW |
| **Nhu cầu mới** — ngoài scope gốc | Quyết scope (B3 Priority); thêm hoặc hoãn | YELLOW |

Sửa xong → bump `last_verified`, kích lại design/build nếu cần. Ghi 1 dòng vào History của ba-spec.

---

## 8. Exit gates (tự tick khi CHẠY xong, không pre-tick)
- [ ] **CỔNG MÁY**: `bash ba-verify.sh --staged` exit 0 — chặn ba-spec 0 AC / AC thiếu `Test:`/`Assert`. Wire vào pre-commit để CHẶN THẬT (không chỉ honor-system). Đây là cơ giới hoá luật "nghiệp vụ vẽ ra mà không test được = chưa xong".
- [ ] Mọi nghiệp vụ có đúng 1 owner-user; không nghiệp vụ mồ côi
- [ ] Mọi cross-user handoff có người nhận + điều kiện; Cross-User-Integrity báo 0 điểm gãy
- [ ] Mọi flow có Input/Output + start/end; không dead-end
- [ ] Mỗi flow tối ưu có ≥1 đánh giá; Flow optimization log ghi candidate bị loại + lý do
- [ ] Mọi AC dạng G/W/T, map tới 1 flow, KHÔNG chứa từ UI, **có `Test:` + `Assert` đo được** (không AC nào "không test được"; flow mới → E2E)
- [ ] `ba-spec` đủ frontmatter `covers/last_verified/ttl_days`; nằm trong app-map
- [ ] Assumptions ghi đủ; chỉ RED mới ASK
- [ ] TeamDelete sau khi user confirm done · KHÔNG viết code · KHÔNG đụng DB

---

## 9. Anti-patterns
| Anti-pattern | Đúng |
|---|---|
| Viết yêu cầu theo feature, không theo user | User-first: registry → nghiệp vụ → owner |
| Nghiệp vụ không owner, cross ngầm | Mỗi nghiệp vụ 1 owner; cross khai tường minh (§B3) |
| Flow "xử lý xong" mơ hồ | Input/Output cụ thể, quan sát được |
| Flow treo, không điểm kết | start/end rõ, no dead-end (rubric §4) |
| Tự nhận flow "tối ưu" không đánh giá | Qua Optimizer + Domain-Specialist nếu chuyên |
| AC mô tả nút/màn | AC là hành vi G/W/T, anti-UI (§5) |
| Hỏi user lặt vặt từng câu | 1 lượt gộp, fail-closed, chỉ RED mới hỏi |
| Tự chế risk-tier/memory/coupling | Defer ai-simple (§6) |
| Sửa code khi triage handoff về | Sửa SPEC, không sửa code (§7) |

---

## 10. Cross-reference
- **Nền**: `ai-simple-product-dev` (#04 sync, #05 LOGIC/REQUEST, #06 tier, #07 memory, #12 coupling) — defer.
- **Pha sau**: `ui-design-logic` đọc ba-spec (user-ladder + flow) → design-spec.
- **Pha vận hành**: `ui-ux-triage` đọc AC làm oracle; đẩy reverse handoff về đây.
- Tài liệu chi tiết: `references/01..05`. Template: `templates/ba-spec.md.template`. Eval: `evals/evals.json`. **Cổng máy: `ba-verify.sh`** (chặn ba-spec thiếu test — wire vào pre-commit).
