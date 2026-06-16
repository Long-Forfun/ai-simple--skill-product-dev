---
name: ui-ux-triage
description: "Team-agent UI/UX triage + fix loop — pha VẬN HÀNH của pipeline BA→design→build→triage. Đọc ba-spec (acceptance criteria = oracle hành vi) + design-spec (oracle giao diện) để phân loại defect, sửa qua cổng ai-simple, chỉ escalate RED. Repo-agnostic (auto-discover + triage.config). Kích hoạt khi: 'màn này sai/lệch', screenshot + câu than ngắn, 'test + fix flow'. KHÔNG kích hoạt cho nhu cầu mới (→BA) hay thiết kế mới (→ui-design-logic). Defer ai-simple cho risk-tier/memory/verify; không đụng DB, không auto-commit."
---

# UI/UX Triage — Team Agent (composable, repo-agnostic)

Triage UI/UX chạy qua **team agent** (không phải 1 agent đơn): test từng bước → quan sát → phân loại → fix → test lại. Không chắc → telegram user kèm ảnh. Skill này **repo-agnostic** (chạy mọi repo) và là **một mắt trong hệ 4-skill** — nó không tự quyết cái thuộc skill khác.

---

## 0. Vị trí trong hệ 4-skill (ĐỌC TRƯỚC)

```
BA (nhu cầu→ba-spec) → ui-design-logic (→design-spec) → build → [ui-ux-triage] (VẬN HÀNH/sửa)
        └──────────────── tất cả trên nền ai-simple (rail + truth + tier + memory + verify) ────────────┘
```

- **Skill này = pha VẬN HÀNH.** Code đã có, đang chạy → nó test, bắt drift, sửa.
- **Oracle của nó đến từ pha trên** (xem §3): `ba-spec` = "đúng hành vi chưa", `design-spec` = "đúng giao diện chưa".
- **Defer sang ai-simple** (§7): risk-tier 06, memory 07, verify 12, gate 08 — KHÔNG tự chế lại.
- **Handoff NGƯỢC về BA** (§5 bước 4c): nếu defect hóa ra là *nhu cầu thiếu/sai* (code khớp spec, nhưng spec sai) → đó là việc BA, không phải fix triage.

---

## 1. Trigger / non-trigger / tie-breaker

Kích hoạt khi user:
- Gửi screenshot UI + câu ngắn ("cái này sai", "ko đồng bộ", "ko đẹp", "tại sao…")
- "rà soát", "triage", "test + fix", "chạy flow"
- Flag inconsistency giữa 2 màn / flow / account state

KHÔNG kích hoạt (→ skill khác):
- Nhu cầu/tính năng mới, "tại sao user cần…" → **BA**
- Thiết kế màn mới, "build trang", "làm đẹp từ đầu" → **ui-design-logic**
- Review tĩnh 1 màn không cần flow+fix loop → **uiux**
- DB migration / schema → ASK + gate (ai-simple #06 RED + memory db-safety)

Tie-breaker đầy đủ: §11.

---

## 2. Repo-agnostic setup — KHÔNG hardcode (chạy mọi repo)

Trước khi spawn team, Lead chạy **gate THẬT**:
```
bash <skill-dir>/triage-verify.sh        # exit 0 mới spawn
```
Gate đọc `./.claude/triage.config` nếu có; KHÔNG có → **auto-discover** mặc định:
- App-map: `docs/app-map/` (mọi `*.md` = read-ref cần resolve)
- Memory: thư mục memory của Claude Code (harness)
- ba-spec / design-spec: glob trong app-map (xem §3); thiếu → degrade
- Test cmd: từ `package.json` scripts (typecheck/test/e2e) nếu có
- **E2E harness** (nếu repo có `tests/e2e/` + helpers): account-matrix theo VAI TRÒ, helper auth/create-family/add-member/join/approve/link, dual-context multi-user, **test-data tracker** (log entity tạo ra, vd JSONL) + **cleanup cmd** (vd `test:e2e:cleanup`). → Flow-tester TÁI DÙNG (§4.2), KHÔNG tự clicking ad-hoc. Thiếu → degrade flow thủ công.
- Telegram: `scripts/notify-telegram.sh` nếu có; thiếu → degrade ghi file

→ Cùng một skill global chạy đúng ở *từng* repo vì ref được **khám phá**, không **đóng cứng**. (Bài học ai-simple #08 CONFIG-per-repo, #09 generic-vs-project.)

Copy `triage.config.template` → `.claude/triage.config` ở repo nào cần chỉ định rõ (vd test cmd khác chuẩn, spec ở chỗ lạ).

---

## 3. ORACLE — trái tim của composition

Observer phân loại defect bằng cách **đối chiếu với oracle**, KHÔNG phán "xấu/đẹp" cảm tính. Thứ tự ưu tiên oracle:

| Bucket | Oracle (cao→thấp) | "Defect" = |
|---|---|---|
| **LOGIC** / **FLOW** | `ba-spec` (acceptance criteria, JTBD) → app-map flows | lệch AC / vi phạm invariant / journey đứt |
| **DESIGN** | `design-spec` (ui-design-logic) → design-system doc | lệch screen map / state matrix / token |
| **TEXT** | ba-spec copy + i18n contract | sai/ lẫn ngôn ngữ, copy không khớp intent |

- **Có ba-spec/design-spec** → diff thực-tế-vs-spec. Đây là chế độ mạnh nhất (composition đủ).
- **Thiếu spec** (repo chưa chạy BA/design) → fallback design-system + heuristics, NHƯNG gắn cờ `[no-oracle, confidence thấp]` trong mọi finding để Lead biết đang đoán.
- **Defect mà code KHỚP spec** → không phải bug triage. Code đúng spec mà vẫn sai = **spec sai** → §5 bước 4c handoff về BA.

---

## 4. Team structure

```
TeamCreate team_name=ui-triage-<n>      (tên BẮT BUỘC prefix "ui-triage" — hook/gate nhận diện)
  team-lead → flow-tester / observer / fixer / advisor
```

### 4.1 team-lead (general-purpose)
Parse feedback → test plan; giao Tester; nhận Observer → giao Fixer; không chắc → Advisor → vẫn không chắc → telegram (§8). Không tự code.

### 4.2 flow-tester — test NHƯ USER THẬT, tái dùng harness repo (KHÔNG clicking ad-hoc)
**Bước 0 — tái dùng harness**: repo có E2E harness (§2) → DÙNG LẠI helper sẵn (login, account-matrix theo vai, create-family/add-member/join/approve/link, dual-context) để dựng user + chạy hành trình; KHÔNG tự viết selector rời. Đây là cách đi đúng "đường người dùng thật" mà E2E chính thức đã đi → bắt được lỗi mà 1-session-1-user bỏ sót.

**Luật nền (BẤT BIẾN — vi phạm = test vô nghĩa):**
1. **UI-driven thật, CẤM seed DB tắt.** Toàn hành trình từ ĐĂNG KÝ → thao tác phải bấm qua UI thật như user (Playwright/preview). KHÔNG insert thẳng DB / gọi API tắt để "có sẵn user/data" — seed DB thì KHÔNG biết button có tác dụng không, flow/UI có chạy không (đó mới là thứ cần kiểm). Seed CHỈ được phép khi cả 2: (a) tiền-điều-kiện đó **KHÔNG có helper UI** trong harness, VÀ (b) **không phải** thứ feedback đang nhắm. Có helper UI cho việc đó → BẮT BUỘC đi UI, CẤM seed (ranh giới là "có helper hay không" — kiểm được, không để agent tự phán "trong/ngoài phạm vi").
2. **Sát thiết bị user.** Dùng viewport/profile đúng thiết bị thật: app mobile → mobile-first (profile iOS/Android), app web → desktop+responsive. Không chỉ 1 viewport desktop.
3. **Test-data CÓ SỔ + clear được.** MỌI user/family/record tạo ra trong test → ghi vào test-data tracker của repo (§2) để **clear sạch trước khi lên production**. Không tạo data mồ côi. Ưu tiên env/DB test cô lập; chạm data thật → bắt buộc có đường cleanup đã verify. (KHÔNG skip tracking để "chạy nhanh".)

**Test plan PHẢI phủ (theo phạm vi feedback):**
- **Theo VAI TRÒ**: chạy lại flow trên từng role của account-matrix (owner/admin/member/guest/banned…) — defect hay chỉ hiện ở 1 role.
- **Hành trình đầy đủ**: entry → mục tiêu user → bước kế; KHÔNG test 1 màn cô lập nếu lỗi nằm trong flow.
- **Cross-user / multi-context**: flow cần ≥2 user (join family, link/duyệt member, chat/call) → **dual-context** (2 browser context đồng thời), KHÔNG giả lập 1 user.
- **Đổi vai giữa chừng**: hành trình đổi quyền (member→admin, transfer owner) → test cả TRƯỚC và SAU khi đổi.

Chụp **MỌI bước** vào `test-reports/triage/<iter>/`. **Allowlist** reversible (navigate, mở/đóng modal, toggle, nhập-không-submit); irreversible (submit xoá/gửi/thanh toán/destructive) → STOP chờ Lead. (Denylist chuỗi cố định bỏ sót action không khớp tên.)

**Repo KHÔNG có harness** → degrade: flow thủ công + flag `[no-harness]`; đề xuất tạo helper tối thiểu theo pattern E2E của repo (đừng bịa đường đi user).

### 4.3 observer (read-only)
Pre-load `triage-log` nếu có (skip nếu run đầu) → ưu tiên bucket hay tái diễn. Đối chiếu oracle (§3). Output mỗi defect: `[bucket] mô tả | screenshot | suspected file:line | severity P0/P1/P2 | oracle vi phạm (spec:dòng) | suggested fix`.

### 4.4 fixer
ĐỌC file trước khi sửa. Minimal diff. Preserve i18n keys / data-testid / data-hint-key. Verify sau fix (test cmd từ §2). Verify fail → revert + báo Lead. **KHÔNG git commit** (ai-simple #08).

### 4.5 advisor (read-only)
Tư vấn khi nhiều option/risk. Dựa decision-pattern §6 (đọc bản mới nhất). Format: Options A/B + risk + recommend + red flags. Không tự apply.

---

## 5. Loop iteration (max 3 tự động)

```
iter N:
 1. LEAD parse feedback → test plan: liệt kê user-journey × VAI TRÒ × cross-user cần phủ (§4.2), không chỉ vài click rời
 2. TESTER chạy + chụp mọi step.
      → 1 BƯỚC HÀNH TRÌNH HỎNG (nút không tác dụng, đăng ký không xong, flow đứt) = defect → Fixer sửa → Tester **làm lại TỪ bước đó** tới khi qua (không bỏ qua bước, không giả lập đường vòng). User sinh ra qua mỗi lần retry đều ghi sổ test-data (§4.2 luật 3).
 3. OBSERVER classify theo oracle (§3)
 4. LEAD review:
      - clear → 5
      - ambiguous → ADVISOR → vẫn ambiguous → gộp 1 TELEGRAM ASK (§8) + pause
      - stale-pause >24h không hồi → nhắc 1 lần → TeamDelete (không giữ team zombie)
 4b. CAPTURE (đóng vòng học): user trả lời ASK → ghi [date] tình-huống→quyết-định→heuristic vào §6 +
      memory feedback_triage_decisions.md; mâu thuẫn heuristic cũ → [stale]; ≥2x → promote rule (ai-simple #07)
 4c. HANDOFF→BA: nếu code KHỚP spec mà vẫn sai → KHÔNG fix; ghi "nhu cầu mới/spec sai" → đẩy về BA, exit
 5. LEAD brief FIXER (request cụ thể)
 6. FIXER apply + verify; không rõ → hỏi Lead; verify fail → revert + escalate
 7. TESTER rerun từ step 1 (regression) — tái dùng pattern bug-fix-verify spec của repo nếu có
 8. hết defect:
      - tóm tắt + TELEGRAM done (§8)
      - update doc/memory nếu có LOGIC mới
      - append 1 dòng STRUCTURED vào triage-log:
        `<ISO> | <repo> | iter=N | buckets=LOGIC:a,TEXT:b,DESIGN:c,FLOW:d | decided=<1 dòng> | verify=tsc:pass,... | telegram=ok|fail|degraded`
      - exit
 9. còn defect + iter<3 → về 1 (scope hẹp hơn)
10. iter≥3 → TELEGRAM xin hướng
```

---

## 6. Decision patterns học từ user (seed RỖNG mỗi repo, LIVE-UPDATED)

> Repo mới: bảng này bắt đầu **trống** — mỗi repo tự học pattern riêng qua §4b (KHÔNG bê pattern lunar sang repo khác).
> Cột **Tần suất** `(×N, last <date>)`: tăng N mỗi lần lặp. Heuristic bị user mâu thuẫn → `[stale]` (giữ history). Advisor đọc bản mới nhất.

| Tình huống | User's pattern | Heuristic | Tần suất |
|---|---|---|---|
| (trống — điền khi học) | | | |

---

## 7. Defer sang ai-simple (KHÔNG tự chế lại nếu skill đó có mặt)

| Việc | Chủ sở hữu | Triage làm gì |
|---|---|---|
| Escalation GREEN/YELLOW/RED | ai-simple #06 | Phân loại action theo tier; chỉ RED → 1 ASK gộp (no-petty-confirms) |
| no-DB / no-commit | ai-simple #08 + memory | Là GATE của nó, không tự định nghĩa |
| Memory format + luật ≥2x | ai-simple #07 | Ghi pattern theo format đó |
| Coupling/verify-on-use, /audit | ai-simple #12 | Gate §2 + triage-log để /audit verify |
| ba-spec (AC), design-spec | BA / ui-design-logic | Đọc làm ORACLE (§3), không tự định nghĩa "đúng là gì" |
| E2E harness (helper, account-matrix, dual-context) | repo's tests (ai-simple #04 doc+test-sync) | TÁI DÙNG để test như user thật (§4.2), KHÔNG dựng lại đường đi user |

ai-simple/BA/ui-design-logic **vắng** trong repo → degrade: tier áp cục bộ, oracle fallback design-system, vẫn chạy.

---

## 8. Telegram + degrade
3 template ASK/DONE/STUCK. ≤2 ảnh, text thuần. **Redaction trước --photo**: che SĐT/email/token/PII member khác. **DEGRADE**: thiếu telegram script → ghi `test-reports/triage/report-<date>.txt`, KHÔNG crash; log `telegram=degraded` (cấm ghi `ok` khi thật ra fail/degrade).

---

## 9. Exit gates (verify-on-use, có bằng chứng — tự tick khi CHẠY xong, không pre-tick)
- [ ] `triage-verify.sh` exit 0
- [ ] Loop ≥1 iter end-to-end; mọi defect fix hoặc escalate
- [ ] Verify pass (capture exit code, không "chắc pass")
- [ ] Decision-pattern §6 updated nếu user dạy khác (§4b)
- [ ] triage-log dòng mới qua `triage-verify.sh --lint-log`
- [ ] Telegram exit 0 HOẶC degrade-ghi-file
- [ ] Test-data tạo ra đã ghi sổ tracker + biết đường clear trước production (§4.2 luật 3)
- [ ] TeamDelete sau khi user confirm done · KHÔNG auto-commit · KHÔNG đụng DB production

---

## 10. Anti-patterns
| Anti-pattern | Đúng |
|---|---|
| Lead tự code | Strict role separation |
| Tester skip step | Chụp MỌI bước |
| Test 1 màn cô lập / 1 user khi lỗi nằm trong flow hoặc cross-user | Journey đầy đủ, đa-vai, dual-context (§4.2) |
| Tự viết selector rời khi repo đã có E2E helper | Tái dùng harness repo (§4.2) |
| Seed DB/gọi API tắt để "có sẵn user" rồi test | Bấm UI thật từ đăng ký — mới biết button/flow chạy (§4.2 luật 1) |
| Test 1 viewport desktop cho app mobile | Sát thiết bị: mobile-first, profile iOS/Android (§4.2 luật 2) |
| Bước hỏng thì đi đường vòng / bỏ qua | Fix rồi làm lại TỪ bước đó tới khi qua (§5.2) |
| Tạo test-data rồi để đó (rác vào production) | Ghi sổ tracker + clear trước production (§4.2 luật 3) |
| Observer phán cảm tính, không oracle | Diff vs ba-spec/design-spec (§3) |
| Fix khi code KHỚP spec | Đó là spec sai → handoff BA (§4c) |
| §6 không update sau ASK | §4b CAPTURE bắt buộc |
| Bê pattern lunar sang repo khác | Seed §6 rỗng mỗi repo |
| Hardcode ref repo cụ thể | Auto-discover / triage.config (§2) |
| Log telegram=ok khi fail/degrade | Ghi đúng trạng thái |
| Tự chế escalation/no-commit | Defer ai-simple (§7) |

---

## 11. Cross-reference + tie-breaker
- **Skill nền**: `ai-simple-product-dev` (#06 tier, #07 memory, #08 gate, #12 verify) — defer, không tự chế.
- **Pha trên (oracle)**: `BA` → ba-spec (AC); `ui-design-logic` → design-spec.
- **Tie-breaker** (cùng trigger "rà soát UI"): triage = multi-step flow+fix loop; `uiux` = review tĩnh 1 màn; `test-runner` = jest/playwright only; `code-review` = static, no UI.
- Chi tiết hợp đồng composition: `references/07-integration.md`.

---

## 12. Giới hạn đã biết
1. **Đúng-ngữ-nghĩa phân loại Observer** = phán đoán LLM; chỉ chạy-thật tích lũy chứng minh (evidence over time).
2. **Agent CHỊU chạy gate §2** vẫn honor-system ở tầng skill; cơ chế hóa nốt = PreToolUse hook chặn TeamCreate đến khi `triage-verify.sh` exit 0 (per-repo, cần user đồng ý — không tự thêm).
3. Self-test chỉ phủ cấu trúc, không phủ chất lượng fix.
