# Changelog

Toàn bộ lịch sử tiến hóa của phương pháp. README/methodology dùng tên LỚP (Core / Scale / Ops / Optimization); version chỉ sống ở đây.

## v1.1.0 — 2026-06-13 (npm CLI)

- **NEW: npm package `ai-simple`** — CLI zero-dependency đóng gói lớp máy: `init` (cài
  hook + doc-health + templates + workflow theo stack supabase/prisma/custom, set hooksPath,
  self-test), `doctor` (khám setup + phát hiện version drift qua marker `ai-simple-version`),
  `update` (nâng cấp giữ nguyên CONFIG người dùng, backup .bak), `doc-status`, `doc-health --ci`.
  Giải bài toán template-drift: N repo copy tay = N bản drift; CLI = 1 nguồn + 1 lệnh sync.
- Version marker trong hook + report để doctor/update so drift
- Fix tự bắt khi test CLI: `$'` trong chuỗi replacement của String.replace() nhân bản file
  (dùng replacer function); index của app-map README template đổi sang plain text (link hóa
  khi file tồn tại) + ví dụ cross-ref tự tham chiếu — repo mới init không còn fail CI oan
- LICENSE (MIT), package.json, `npm test` chạy self-test 2 template từ package

## v1.0.0 — 2026-06-13 (release đầu tiên)

Trạng thái: 12 nguyên tắc, 15 templates, 2 script tự test (report 12 fixtures + hook 6 fixtures), đạt 99/100 sau 11 vòng adversarial review + 2 vòng đối chiếu nghiên cứu khoa học.

### Optimization layer — nguyên tắc 12 v2 (các commit v4.0–v4.3)
- Coupling map: mỗi doc gắn code khai `covers:` / `last_verified:` / `ttl_days:` → trạng thái VERIFIED/SUSPECT/ORPHANED máy tính từ git
- Cổng GHI: hook chặn commit đổi code trong covers mà doc không được sửa/re-verify cùng commit
- Cổng ĐỌC: doc-status.md regenerate mỗi commit, router gắn cờ (fail-closed), marker trong chính doc, agent phải đối chiếu code trước khi tin doc SUSPECT
- Chống laundering: commit chore chạm doc không rửa được SUSPECT (attestation phải gate-1-shaped hoặc `re-verify(...)`)
- Symbol-level rot: doc nhắc hàm đã xóa → SUSPECT (tìm toàn repo, loại *.md) → CI fail
- Doc-lag + escaped-drift thay drift% (proxy gameable); hotspot = route-freq × covers-churn
- Ranh giới lời bảo đảm nêu tường minh trong 12 §gates — mọi residual có tên + audit check

### Ops layer — nguyên tắc 11 (v2.2–v3.0)
- Runbook per service, state registry, schedules + external-services registry (4/4 templates)
- Routing "sự cố → runbook trước code"; fix sự cố → update runbook cùng commit

### Scale layer — nguyên tắc 08–10 (v2–v2.1)
- Pre-commit hook versioned (.githooks + core.hooksPath), --self-test, encoding guard (BOM/mojibake)
- Generated vs authored docs (`_generated/`), cross-repo contract + bảng SYNC + path convention
- doc-health-report: --ci fail PR, --status sinh doc-status, --self-test, --fast

### Core layer — nguyên tắc 01–07 (v1–v3)
- Hierarchical context (root <6K tokens + root diet), app-map pattern (>20 file → domain hóa)
- Context routing /fl + context-router; LOGIC vs REQUEST
- Risk tiers GREEN/YELLOW/RED (06 v3): reversible tự làm + Assumptions cuối task, RED mới hỏi 1 câu gộp
- Doc+Test sync invariant; memory as feedback

### Bài học được mã hóa thành cơ chế (lịch sử lỗi → fixture)
- Hook hỏng vì `{{X|default}}` bị sh hiểu là pipe → --self-test pattern-exercise
- PowerShell 5.1 phá UTF-8 tiếng Việt (BOM khi ghi, ANSI khi đọc) 2 lần → encoding guard trong hook
- Multi-covers parser mù, same-day false SUSPECT, sibling-path overmatch → 12 fixtures
- SUSPECT laundering qua commit chore → attestation semantics + fixture
- "Doc 90 ngày không ai đọc → khai tử" bị user veto đúng → RETIRE chỉ cho doc mồ côi; doc lạnh = check router + verify, không xóa
