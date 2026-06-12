# 08 — Automated Enforcement

> Invariant sống bằng kỷ luật tay sẽ chết khi project phình to. Biến quy tắc thành cơ chế: pre-commit hook chặn, CI lint cảnh báo, report đo doc-lag.
> *(EN: Discipline-based invariants die as the project grows. Turn rules into mechanisms: pre-commit hooks block, CI lints warn, weekly reports measure drift.)*

---

## Vấn đề / The problem

Các nguyên tắc 01–04 đều là **quy tắc tự giác**:
- Root CLAUDE.md < 6K tokens → ai đếm? Thực tế root phình dần qua từng commit, không ai để ý
- Doc + Test sync invariant → giữ được khi 1 người commit chậm; gãy khi nhiều người (hoặc nhiều AI agent) commit nhanh
- Last-updated date → có ghi nhưng không ai quét xem doc nào đã stale

Hậu quả: drift xảy ra **ngay trong project tuân thủ tốt nhất**, và chỉ phát hiện khi AI bắt đầu đề xuất sai.

*(EN: Principles 01–04 are honor-system rules. Drift happens even in the most disciplined projects, and is only noticed when the AI starts suggesting wrong things.)*

---

## Giải pháp / The solution

3 tầng enforcement, từ cứng đến mềm:

```
TẦNG 1 — pre-commit hook (BLOCK)
├── Migration đổi mà doc database không đổi → chặn commit
├── Root CLAUDE.md vượt token budget → chặn commit
└── Schema dùng chung đổi mà contract không bump version → chặn (xem nguyên tắc 10)

TẦNG 2 — CI lint (WARN)
├── App-map file thiếu "Load khi" / last-updated → warning
├── Module > 5 file chưa có CLAUDE.md → warning
└── Cross-ref tới file không tồn tại (broken link) → warning

TẦNG 3 — report định kỳ (MEASURE)
├── Doc-lag: code trong covers đổi sau last_verified (đo theo coupling, KHÔNG theo tuổi doc — xem 12 v2)
├── Doc-lag: doc SUSPECT (code trong covers đổi sau last_verified) + symbol chết — xem 12 v2
└── Token budget trend: size CLAUDE.md qua thời gian
```

Template hook sẵn dùng: `templates/pre-commit.hook.template`

---

## Quy tắc cứng / Hard rules

1. **Hook cài từ tuần đầu** — retrofit hook vào project đang chạy khó gấp 10 lần (phải sửa hết vi phạm tồn đọng trước)
2. **BLOCK chỉ dành cho invariant cốt tử** (DB doc sync, token budget, contract version) — block quá nhiều thứ → dev sẽ `--no-verify` và toàn bộ cơ chế chết
3. **Token budget đo bằng proxy ký tự** — ~4 chars/token cho tiếng Anh, ~3 chars/token cho tiếng Việt; budget 6K tokens ≈ chặn ở 20.000–24.000 chars. Không cần tiktoken chính xác, cần ngưỡng ổn định
4. **Mapping migration→doc khai báo trong hook** — mỗi project tự sửa pattern (vd `supabase/migrations/*.sql` → `docs/app-map/*database*.md`)
5. **Report tuần phải gửi đến nơi có người đọc** — Telegram/Slack, không phải file log không ai mở

---

## Đo lường tự động / Automated measurement

Nguyên tắc gốc định nghĩa 4 metric (onboard time, doc-lag, hallucination rate, wrong-commit rate) nhưng không nói cách thu thập. Cách thu:

| Metric | Cách thu tự động |
|---|---|
| **Doc-lag** (v2 — chính) | Report đếm doc SUSPECT: code trong `covers` đổi sau `last_verified` + số ngày lệch (nguyên tắc 12 v2) |
| Escaped-drift | Lỗi doc bị cổng đọc/audit bắt mà cổng ghi lẽ ra phải chặn → mỗi case = 1 pattern mới cho hook |
| Hallucination rate | Nếu có bot triage (Telegram/issue bot): đếm report gắn tag "AI chẩn đoán sai do doc cũ" |
| Token budget trend | Hook ghi size CLAUDE.md vào log mỗi commit → vẽ trend |

> v1 dùng "drift % = % commit sửa code có kèm doc" — đã bỏ: proxy đo hoạt động chứ không đo độ đúng, và gameable (Goodhart). Xem nguyên tắc 12 v2 §Đo lường.

---

## Anti-patterns

| Anti-pattern | Hậu quả |
|---|---|
| Block mọi thứ trong hook | Dev dùng `--no-verify` → cơ chế chết toàn bộ |
| Hook chỉ cài máy 1 người | Người/agent khác commit không bị chặn → drift quay lại |
| Lint mà không có owner xử lý warning | Warning chồng đống → mù cảnh báo |
| Đo metric nhưng không có ngưỡng hành động | Có số liệu, không có quyết định |
| Retrofit hook khi đã 500 commit vi phạm | Hook fail mọi commit → bị gỡ ngay tuần đầu |

---

## Checklist áp dụng / Adoption checklist

- [ ] Hook cài **versioned**: `.githooks/pre-commit` (commit vào repo) + `git config core.hooksPath .githooks` trên mỗi máy clone — KHÔNG copy vào `.git/hooks/` (chỉ 1 máy được enforce → drift quay lại, vi phạm chính rule 08)
- [ ] `sh .githooks/pre-commit --self-test` chạy OK sau khi sửa 3 biến CONFIG
- [ ] Pattern migration→doc đã sửa đúng cho project (default: Supabase)
- [ ] Token budget threshold đã set (mặc định 24.000 chars; lưu ý ratchet: chỉ check khi CLAUDE.md có trong commit — vi phạm tồn đọng được ân hạn tới lần sửa kế)
- [ ] `templates/doc-health-report.sh.template` chạy định kỳ (cron tuần), output đến kênh có người đọc (Telegram/Slack)
- [ ] Quy ước nhóm: `--no-verify` chỉ dùng khi hotfix, phải trả nợ doc trong 24h
