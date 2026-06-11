# 10 — Cross-Repo Contract

> Khi nhiều repo chia sẻ schema/file/utility, độ phức tạp thật nằm **giữa** các repo — nơi không CLAUDE.md nào nhìn thấy. Mỗi schema dùng chung phải có 1 file contract đánh version, cả hai đầu link tới.
> *(EN: In multi-repo ecosystems the real complexity lives BETWEEN repos, where no single CLAUDE.md can see it. Every shared schema gets one versioned contract file that both sides link to.)*

---

## Vấn đề / The problem

Hệ nhiều repo (vd: agent sinh content → agent đăng bài → web hiển thị dashboard) chia sẻ:
- **File schema** — repo A ghi `plan.json`, repo B+C đọc
- **Shared utilities** — repo B import code từ repo A qua sys.path / submodule
- **State files** — `.last_health.json`, `insights.json` trao đổi qua filesystem

Đổi schema ở producer → consumer **vỡ im lặng** (silent break). Doc per-repo không cứu được vì:
- CLAUDE.md repo A không biết repo B đọc field nào
- AI sửa repo A không có lý do gì để mở repo B
- Khi vỡ, lỗi hiện ở repo B nhưng nguyên nhân ở repo A — triage chéo repo rất đắt

---

## Giải pháp / The solution

**1 schema dùng chung = 1 file contract**, sống ở repo producer:

```
repo-producer/
└── docs/contracts/
    └── plan-json.contract.md      # Single source of truth cho schema này
```

Nội dung contract (template: `templates/contract-doc.md.template`):
- **Version** — bump khi breaking change (v1 → v2)
- **Producer** — repo + file path + function ghi
- **Consumers** — danh sách repo + file path + function đọc (consumer TỰ thêm mình vào khi bắt đầu đọc)
- **Schema** — fields, types, required/optional, ví dụ
- **Compatibility rules** — thêm field optional = non-breaking; đổi/xóa field = breaking, phải bump version + sửa hết consumers cùng đợt
- **Change log** — ngày, version, gì đổi, consumer nào đã update

**Hai đầu đều link tới contract:**
- Root CLAUDE.md repo producer: bảng "Khi sửa X → BẮT BUỘC check contract Y + update consumers"
- Root CLAUDE.md mỗi consumer: "File này đọc schema theo contract Z (link), không tự suy diễn field"

**Quy ước đường dẫn liên repo / Cross-repo path convention** (phải khai báo tường minh, đừng ngầm định):
- Mọi repo của ecosystem checkout **cạnh nhau dưới 1 root chung** (vd `C:/Code/<repo-name>/`) — khai báo root này trong root CLAUDE.md từng repo
- Link consumer → contract viết theo dạng `<REPOS_ROOT>/<producer-repo>/docs/contracts/<name>.contract.md` — AI resolve được, CI trong 1 repo thì không (chấp nhận: contract check của CI chỉ chạy phía producer qua hook nguyên tắc 08)
- Repo đổi tên/di chuyển = breaking change của MỌI contract nó produce — ghi vào changelog từng contract

---

## Quy tắc cứng / Hard rules

1. **Contract sống ở producer** — producer đổi schema thì sửa contract cùng commit (enforce bằng hook, xem nguyên tắc 08)
2. **Consumer tự đăng ký** — repo nào bắt đầu đọc schema phải thêm mình vào mục Consumers cùng PR; không đăng ký = không được bảo vệ khi schema đổi
3. **Version trong cả file data lẫn contract** — schema JSON nên có field `"version"`; consumer check version, log warning khi gặp version lạ
4. **Breaking change = 1 đợt sửa nguyên tử** — bump version + sửa producer + sửa MỌI consumer trong cùng ngày; không để 2 version sống song song quá 1 sprint
5. **Shared utility = contract ngầm** — function được repo khác import: đổi signature phải xem như breaking change của contract, check hết caller bên ngoài repo

---

## Ví dụ bảng sync trong root CLAUDE.md / Example sync table

```markdown
## SYNC VỚI CONSUMERS — đọc trước khi commit

| Khi sửa ở repo này | BẮT BUỘC update |
|---|---|
| Schema `outputs/plan.json` | `docs/contracts/plan-json.contract.md` + repo-publisher `plan_reader.py` |
| Signature `utils/llm_client.py` | repo-zalo imports — bump version + sửa callers cùng đợt |
| Format `state/published.json` | contract + repo-dashboard `_build_slice()` |
```

Bảng này là **radar** cho AI: sửa file nào thì biết ngay vùng nổ ở repo nào.

---

## Anti-patterns

| Anti-pattern | Hậu quả |
|---|---|
| Schema chung không có contract | Silent break — lỗi hiện ở consumer, nguyên nhân ở producer |
| Contract copy ở cả 2 repo | Hai bản lệch nhau → còn tệ hơn không có |
| Đổi schema "thêm field thôi mà" không ghi changelog | Consumer thứ 3 (mới join) không biết field nào tin được |
| Version chỉ ghi trong contract, không có trong data | Runtime không tự phát hiện mismatch |
| Import chéo repo qua sys.path không khai báo | AI refactor producer xóa function mà không biết có người dùng |

---

## Checklist áp dụng / Adoption checklist

- [ ] Liệt kê mọi file/schema/utility được > 1 repo đụng vào
- [ ] Mỗi cái có 1 file `docs/contracts/<name>.contract.md` ở producer
- [ ] Root CLAUDE.md producer có bảng SYNC; root mỗi consumer link ngược về contract
- [ ] Schema data có field `version`; consumer log warning khi version lạ
- [ ] Hook (nguyên tắc 08): sửa file schema → contract phải đổi cùng commit
