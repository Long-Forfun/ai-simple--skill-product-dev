# 11 — Ops Layer

> Docs-for-dev chưa đủ khi hệ thống *chạy thật*: cron, state file, service ngoài, sự cố lúc 2h sáng. Mỗi hệ thống chạy nền có 1 runbook; "hệ thống sập" có routing riêng.
> *(EN: Dev docs aren't enough once the system actually RUNS: cron jobs, state files, external services, 2am incidents. Every background system gets a runbook; "system is down" gets its own routing path.)*

---

## Vấn đề / The problem

App-map truyền thống tả **code lúc đứng yên**. Khi hệ thống có cron job, pipeline, agent chạy nền, state file, service ngoài (API bên thứ ba, webhook):
- AI được gọi lúc sự cố ("bot không đăng bài sáng nay") phải đoán: chạy bằng gì, log ở đâu, state nào, restart sao
- Mỗi lần đoán = grep cả codebase + hỏi user — đúng lúc user đang cuống
- Tri thức vận hành nằm trong đầu 1 người = bus factor 1

---

## Giải pháp / The solution

**1. Domain `ops/` trong app-map** (bắt buộc khi project có ≥ 1 process chạy nền):

```
docs/app-map/ops/
├── README.md                # Router: sự cố loại nào → đọc gì
├── 01-schedules.md          # Mọi cron/scheduled task: chạy gì, lúc nào, bằng cơ chế gì
├── 02-state-registry.md     # Mọi state file/bảng trạng thái: ai ghi, ai đọc, schema, reset sao
├── 03-external-services.md  # API ngoài: auth kiểu gì, rate limit, token hết hạn thì sao
└── runbook-<service>.md     # 1 runbook / process chạy nền (template sẵn)
```

**2. Runbook per service** — dùng `templates/runbook.md.template`; state registry — dùng `templates/state-registry.md.template`. Runbook tối thiểu 5 mục:
start/stop/restart · health check (lệnh + output mong đợi) · log ở đâu · 3-5 lỗi thường gặp kèm cách xử · escalation (khi nào bó tay, gọi ai/làm gì).

**3. Routing row cho sự cố** — root CLAUDE.md và `/fl` router phải có dòng:

| Task | Load |
|---|---|
| "Hệ thống X không chạy / sập / không đăng bài" | `docs/app-map/ops/runbook-X.md` TRƯỚC TIÊN, rồi mới tới code |

**4. Sự cố xong → runbook update cùng commit fix** — lỗi mới gặp lần đầu phải thành mục "lỗi thường gặp" trong runbook. Đây là Doc+Test sync (04) áp cho ops: fix mà không update runbook = lần sau lại đoán từ đầu.

---

## Quy tắc cứng / Hard rules

1. **≥ 1 process chạy nền = phải có `ops/`** — web app thuần request/response thì không cần
2. **Runbook viết cho người đang cuống** — mỗi lệnh copy-paste được ngay, không "xem thêm phần X"; output mong đợi ghi kèm để biết lệnh chạy đúng hay sai
3. **State registry là canonical** — AI không bao giờ được đoán schema state file; không có trong registry = coi như không tồn tại
4. **Lỗi gặp ≥ 2 lần phải có mục trong runbook** — gặp lại lần 3 mà vẫn diagnose từ đầu là bug quy trình
5. **Sự cố là LOGIC trước, REQUEST sau** (nguyên tắc 05): diagnose bằng runbook → báo nguyên nhân → mới fix. Không "sửa mò" trên hệ thống đang chạy

---

## Anti-patterns

| Anti-pattern | Hậu quả |
|---|---|
| Tri thức vận hành chỉ trong đầu founder | Bus factor 1; AI vô dụng lúc sự cố |
| Runbook tả kiến trúc thay vì lệnh | Lúc 2h sáng không ai cần diagram, cần lệnh restart |
| Fix sự cố không update runbook | Lần sau diagnose lại từ đầu |
| State file không có registry | AI đoán schema → sửa sai → hỏng state |
| Cron khai báo ở 3 nơi (code, OS scheduler, doc) lệch nhau | Không biết cái nào đang thật sự chạy |

---

## Checklist áp dụng / Adoption checklist

- [ ] Project có process chạy nền → folder `docs/app-map/ops/` tồn tại
- [ ] Mỗi process nền có `runbook-<service>.md` đủ 5 mục tối thiểu
- [ ] `02-state-registry.md` liệt kê đủ mọi state file (đối chiếu bằng grep pattern ghi file)
- [ ] Root CLAUDE.md + context-router có routing row "sự cố → runbook trước"
- [ ] Quy ước: fix sự cố → runbook update cùng commit
