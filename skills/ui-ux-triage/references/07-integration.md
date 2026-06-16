# 07 — Hợp đồng composition: ui-ux-triage trong hệ 4-skill

ui-ux-triage là **pha VẬN HÀNH**. Nó không đứng một mình — nó tiêu thụ output các pha trên làm oracle, và đẩy ngược việc không-thuộc-nó sang đúng skill. File này là nguồn sự thật cho cách ghép; SKILL.md chỉ tóm tắt.

## Vị trí
```
BA ──ba-spec──> ui-design-logic ──design-spec──> build ──> [ui-ux-triage]
            tất cả trên ai-simple (rail/truth/tier/memory/verify)
```

## Móc vào ai-simple (DEFER, không tự chế)
| Nguyên tắc ai-simple | ui-ux-triage dùng |
|---|---|
| #06 risk-tier | escalation = phân loại action GREEN/YELLOW/RED; chỉ RED → 1 ASK gộp |
| #07 memory | decision-pattern (§6) ghi theo format 07 + luật ≥2x; seed RỖNG mỗi repo |
| #08 enforcement | no-DB/no-commit là gate của 08; triage không tự định nghĩa |
| #12 verify-on-use | `triage-verify.sh` = cổng; `ba-spec`/`design-spec` đọc qua coupling map; triage-log để /audit verify |
| app-map | mọi spec + triage-log sống trong app-map, không root trần |

ai-simple vắng → áp tier cục bộ, vẫn chạy.

## Móc vào BA = skill `ba-flow-logic` (oracle hành vi)
- Đọc `ba-spec` (canonical app-map doc do `ba-flow-logic` sinh): acceptance criteria (Given/When/Then), JTBD, scope, flow (Input/Output), cross-user handoff, **Rules/Invariants (§9)** (defect LOGIC = vi phạm invariant này).
- Observer bucket LOGIC/FLOW/TEXT: defect = **lệch AC** của ba-spec; journey đứt = handoff treo trong cross-user map.
- **Handoff NGƯỢC**: code KHỚP ba-spec mà vẫn sai → spec sai/nhu cầu thiếu → KHÔNG fix, đẩy về `ba-flow-logic` (xem `04-reverse-handoff-risk.md` của nó: phân loại spec-sai/thiếu/mới + risk-tier). (§5 bước 4c.)
- ba-spec `covers` UI code → khi code đổi, ba-spec SUSPECT → Observer biết oracle có thể cũ.

## Móc vào ui-design-logic (oracle giao diện)
- Đọc `design-spec` (do ui-design-logic sinh): screen map, state matrix, density budget, component decision, token.
- Observer bucket DESIGN: defect = lệch design-spec. Fallback `design-system` doc nếu chưa có design-spec.
- Screenshot QA loop của ui-design-logic = cách Observer chụp/đối chiếu — chung một cơ chế "test = ảnh nghiệm thu 3 viewport".

## Khi spec vắng (repo chưa chạy BA/design)
Degrade: oracle = design-system doc + heuristics; MỌI finding gắn `[no-oracle, confidence thấp]` để Lead biết đang đoán. Không giả vờ chắc chắn.

## Phân ranh trigger (chống đụng)
| Tín hiệu | Skill |
|---|---|
| nhu cầu/tính năng mới, "tại sao cần", "phân tích nghiệp vụ", "tối ưu flow" | BA = `ba-flow-logic` |
| thiết kế màn mới, "làm đẹp từ đầu" | ui-design-logic |
| "màn này sai/lệch", screenshot lỗi, "test+fix flow" | ui-ux-triage |
| review tĩnh 1 màn | uiux |

## Cross-repo — INSTALL = JUNCTION, không copy (chống drift)
Skill global (junction `~/.claude/skills/ui-ux-triage` → repo này). Mỗi repo cấp ngữ cảnh riêng qua `.claude/triage.config` (hoặc auto-discover). ba-spec/design-spec ở repo nào thì triage repo đó đọc của repo đó.

**Cài per-repo (nếu repo cần bản project-scoped)**: PHẢI là junction, KHÔNG copy thư mục — copy = fork → drift (vá repo-agnostic không tới tay repo thật; hook gọi script cũ hardcode).
```powershell
# từ repo root:
Remove-Item .claude\skills\ui-ux-triage -Recurse -Force   # nếu đang là dir-copy cũ
New-Item -ItemType Junction -Path .claude\skills\ui-ux-triage -Target C:\Code\ui-ux-triage
# VERIFY là junction thật (không phải dir):
Get-Item .claude\skills\ui-ux-triage | Select-Object LinkType, Target   # LinkType phải = Junction
```
Hook `triage-gate.sh` gọi `.claude/skills/ui-ux-triage/triage-verify.sh` → qua junction tự trỏ về script global mới nhất, không cần sửa hook. Muốn giữ tập read-ref cốt lõi riêng cho repo → đặt `READ_REFS` trong `.claude/triage.config`, KHÔNG fork script.
