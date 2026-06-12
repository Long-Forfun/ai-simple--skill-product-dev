# AI-Augmented Product Development — A Simple Skill

**TL;DR (30 giây):**
- **Cho ai?** Dev/team dùng AI coding agent (Claude Code, Cursor, Aider) trên project ≥ 30 file có business logic thật.
- **Giải lỗi gì?** AI hallucinate tên hàm/file, đọc lan man tốn token, doc lệch code rồi AI tin doc cũ, hỏi confirm lặt vặt, không ai biết restart con bot.
- **Cài thế nào?** Copy 3 template (CLAUDE.md, app-map, hook) + `git config core.hooksPath .githooks` — 5 phút, có `--self-test` xác nhận chạy đúng.
- **Được gì?** Session AI mới onboard < 1 phút; mọi doc gắn code có trạng thái VERIFIED/SUSPECT máy tính từ git — doc sai **không lọt vào suy luận của AI mà chưa qua đối chiếu**; commit đổi code mà quên doc bị chặn tại chỗ.
- **4 lớp:** Core (context + routing + sync) → Scale (enforcement + generated docs + contract) → Ops (runbook + registry) → Optimization (coupling map + 2 cổng verify + /audit). Versions: xem [CHANGELOG.md](CHANGELOG.md).

> **VI**: Phương pháp đơn giản để tổ chức một dự án phần mềm khi đồng hành cùng AI coding agent (Claude Code, Cursor, Aider, …). Không phải framework, không phải tool — là **bộ nguyên tắc + template + script đã test** giúp AI hiểu codebase nhanh, không hallucination, không bloat context.
>
> **EN**: A simple skill for organizing a software project when pair-programming with an AI coding agent (Claude Code, Cursor, Aider, …). Not a framework, not a tool — a **set of principles + templates + tested scripts** that help the AI understand the codebase quickly, without hallucination, without context bloat.

---

## Tại sao cần / Why this exists

### VI
Khi dev với AI agent, 3 vấn đề phổ biến:
1. **Cold start tốn token** — session mới phải re-explain codebase từ đầu
2. **AI hallucinate** — đoán file/function/business rule không tồn tại
3. **Doc lệch code** — code đổi nhưng doc không đổi → AI đọc doc cũ → đề xuất sai

Phương pháp này giải 3 vấn đề trên bằng:
- **Hierarchical context** thay vì 1 file root khổng lồ
- **App-map docs** đánh số, mỗi file 1 chủ đề canonical
- **Context routing** qua slash command + sub-agent
- **Doc + Test sync invariant** — code change BẮT BUỘC pair với doc + test cùng commit
- **LOGIC vs REQUEST classification** — tách câu hỏi với câu yêu cầu

**Lớp Scale** (khi project phình to — vấn đề thứ 4: *phương pháp tự giác sẽ drift*):
- **Automated enforcement** — pre-commit hook chặn vi phạm thay vì dựa kỷ luật
- **Generated vs authored docs** — schema/route/inventory máy sinh, người chỉ viết "tại sao"
- **Cross-repo contract** — schema dùng chung giữa nhiều repo có contract đánh version

**Lớp Optimization** (vấn đề thứ 5: *hệ chỉ biết phát hiện mà không biết tự chữa thì điểm chỉ đi xuống theo thời gian*):
- **Self-optimization loop** — coupling map (`covers`/`last_verified`/`ttl_days`) + 2 cổng: cổng GHI (hook chặn code-đổi-mà-doc-không-re-verify cùng commit) và cổng ĐỌC (doc SUSPECT phải được đối chiếu với code trước khi AI tin) + doc-lag/hotspot + `/audit` neo metric → backlog tối ưu xếp hạng

### EN
When pair-programming with an AI agent, 3 common pain points:
1. **Cold start burns tokens** — every new session must re-explain the codebase
2. **AI hallucinates** — invents files/functions/business rules that don't exist
3. **Docs drift from code** — code changes, docs don't → AI reads stale docs → wrong suggestions

This methodology solves all 3 with:
- **Hierarchical context** instead of one giant root file
- **Numbered app-map docs**, each file = one canonical topic
- **Context routing** via slash command + sub-agent
- **Doc + Test sync invariant** — code changes MUST ship with doc + test in the same commit
- **LOGIC vs REQUEST classification** — separate questions from action requests

**Scale layer** (for when the project grows — pain point #4: *honor-system methodology drifts*):
- **Automated enforcement** — pre-commit hooks block violations instead of relying on discipline
- **Generated vs authored docs** — schemas/routes/inventories are machine-generated; humans only write the "why"
- **Cross-repo contract** — schemas shared across repos get a versioned contract file

**Optimization layer** (pain point #5: *a system that only detects but never heals itself trends downward*):
- **Self-optimization loop** — a doc↔code coupling map (`covers`/`last_verified`/`ttl_days`) + two gates: WRITE (hook blocks code-changed-without-doc-reverify in the same commit) and READ (SUSPECT docs must be checked against real code before the AI relies on them) + doc-lag/hotspot metrics + a metric-anchored `/audit` → ranked optimization backlog

**Roadmap** (đang cân nhắc / under consideration): `npx ai-simple init|doctor|audit` CLI đóng gói toàn bộ template+script; `examples/` repo before/after (Next.js+Supabase, Python agent) với số đo onboard-time và doc-lag thật.

---

## Quick start (5 phút / 5 min)

### VI
1. Copy `templates/CLAUDE.md.template` → root project, đổi thành `CLAUDE.md`
2. Tạo thư mục `docs/app-map/` + copy `templates/app-map-README.md.template` vào
3. Tạo `.claude/commands/fl.md` từ `templates/fl.command.md.template`
4. Tạo `.claude/agents/context-router.md` từ `templates/context-router.agent.md.template`
5. Cài hook versioned: `mkdir .githooks` → copy `templates/pre-commit.hook.template` vào `.githooks/pre-commit` → `git config core.hooksPath .githooks` → commit folder `.githooks` (sửa 3 biến CONFIG nếu không phải Supabase; verify: `sh .githooks/pre-commit --self-test`)
6. Đọc `methodology/README.md` để hiểu 12 nguyên tắc

### EN
1. Copy `templates/CLAUDE.md.template` → project root, rename to `CLAUDE.md`
2. Create `docs/app-map/` directory, copy `templates/app-map-README.md.template` into it
3. Create `.claude/commands/fl.md` from `templates/fl.command.md.template`
4. Create `.claude/agents/context-router.md` from `templates/context-router.agent.md.template`
5. Install the versioned hook: `mkdir .githooks` → copy `templates/pre-commit.hook.template` to `.githooks/pre-commit` → `git config core.hooksPath .githooks` → commit `.githooks` (edit the 3 CONFIG vars if not Supabase; verify: `sh .githooks/pre-commit --self-test`)
6. Read `methodology/README.md` to grasp the 12 principles

---

## Cấu trúc repo / Repo structure

```
ai-simple--skill-product-dev/
├── README.md                    # This file
├── CHANGELOG.md                 # Lịch sử version (README chỉ dùng tên lớp)
├── SKILL.md                     # Claude Code skill manifest (auto-discoverable)
├── methodology/                 # 12 principles, deep-dive
│   ├── README.md                # Principles index
│   ├── 01-hierarchical-context.md
│   ├── 02-app-map-pattern.md
│   ├── 03-context-routing.md
│   ├── 04-doc-test-sync.md
│   ├── 05-logic-vs-request.md
│   ├── 06-pre-flight-checklist.md       # v3 — risk tier: tự chạy default an toàn, confirm chỉ khi RED
│   ├── 07-memory-as-feedback.md
│   ├── 08-automated-enforcement.md      # v2 — hook chặn, lint, report drift
│   ├── 09-generated-vs-authored-docs.md # v2 — máy sinh "cái gì", người viết "tại sao"
│   ├── 10-cross-repo-contract.md        # v2 — schema chung = contract đánh version
│   ├── 11-ops-layer.md                  # v2.2 — runbook, state registry, routing sự cố
│   └── 12-self-optimization.md          # v2(4.x) — coupling map covers/last_verified, 2 cổng verify, doc-lag, /audit
└── templates/                   # Drop-in files. Quy ước placeholder: {{TÊN_HOA}} = trường BẮT BUỘC
                                 # điền khi copy; <chữ-thường> = ví dụ minh họa hoặc biến — thay bằng
                                 # nội dung thật khi viết, giữ nguyên nếu là pattern runtime (src/<module>/).
    ├── CLAUDE.md.template
    ├── app-map-README.md.template
    ├── app-map-doc.md.template
    ├── ADR.md.template
    ├── context-router.agent.md.template
    ├── fl.command.md.template
    ├── pre-commit.hook.template         # v2 — enforcement hook (chạy được ngay với default Supabase)
    ├── doc-health-report.sh.template    # v4 — doc-lag, symbol chết, broken links, lint, --status, --self-test
    ├── runbook.md.template              # v2.2 — runbook per service chạy nền
    ├── state-registry.md.template       # v2.2 — registry canonical cho state files
    ├── ops-schedules.md.template        # v3.0 — registry mọi cron/scheduled job
    ├── ops-external-services.md.template# v3.0 — registry API ngoài (token, rate limit, khi chết)
    ├── audit.command.md.template        # /audit: tự chấm 12 nguyên tắc → backlog tối ưu
    ├── doc-health.workflow.yml.template # GitHub Actions: self-test + --status + --ci gate + artifact
    └── contract-doc.md.template         # cross-repo contract
```

---

## Khi nào dùng / When to use

### VI — Phù hợp khi
- Project ≥ 30 file, có business logic phức tạp
- Có nhiều người (kể cả AI agent) cùng đụng codebase
- Có DB + auth + nhiều flow → cần tách concern
- Muốn AI session mới onboard < 1 phút

### VI — Không cần khi
- Throwaway script, prototype 1 file
- Pure library không có business rule
- Solo dev, project < 10 file

### EN — Use when
- Project ≥ 30 files, with non-trivial business logic
- Multiple contributors (humans + AI agents) touch the codebase
- DB + auth + many flows → need separation of concerns
- You want a fresh AI session to onboard in < 1 minute

### EN — Skip when
- Throwaway scripts, single-file prototypes
- Pure libraries with no business rules
- Solo dev, project under 10 files

---

## Triết lý / Philosophy

> **VI**: AI không phải là intern thông minh — AI là một **đồng nghiệp chỉ đọc tài liệu của bạn**. Tài liệu tốt = đồng nghiệp tốt. Phương pháp này không cố ép AI thông minh hơn, mà ép **bạn viết tài liệu tốt hơn**.
>
> **EN**: AI is not a smart intern — AI is **a colleague who only reads your docs**. Good docs = good colleague. This methodology doesn't try to make AI smarter; it forces **you to write better docs**.

---

## Đóng góp / Contributing

Mở issue/PR nếu có **pattern** hay từ project của bạn — chỉ cần phương pháp đã work, không cần kèm code thực tế.

Open an issue/PR with **patterns** from your own project — only the approach that worked, no real code needed.
