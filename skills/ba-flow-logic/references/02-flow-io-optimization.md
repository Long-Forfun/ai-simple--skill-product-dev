# 02 — Flow I/O + tối ưu bằng team-agent (B4–B5)

Nghiệp vụ trừu tượng ("quản lý đơn") không kiểm thử được. **Flow** cụ thể hoá nó thành đường đi có **Input** (cần gì để chạy) và **Output** (ra cái gì quan sát được) — đó là thứ design vẽ thành màn và triage diff làm oracle.

## B4. Flow per nghiệp vụ — Input → Steps → Output

Mỗi nghiệp vụ → ≥1 flow. Mỗi flow khai:
- **Start**: trạng thái/điều kiện để flow bắt đầu (ai, ở đâu trong hành trình).
- **Input**: dữ liệu/điều kiện cần có. Thiếu input nào → flow không chạy được (đó là precondition của AC).
- **Steps**: chuỗi hành động, mỗi bước là 1 việc của owner-user. Bước chạm user khác = điểm **cross** (trỏ về handoff B3).
- **Output**: kết quả **quan sát được** — trạng thái dữ liệu mới + side-effect (kho trừ, thông báo gửi). Cấm "xử lý xong".
- **End**: điểm kết rõ. Mỗi **nhánh** (thành công / từ chối / lỗi) đều phải có end riêng — không nhánh nào treo.

> Test nhanh: đọc Output có hình dung được "nhìn vào đâu biết flow chạy đúng" không? Không → viết lại cụ thể.

## B5. Tối ưu flow — team-agent

Một nghiệp vụ thường có nhiều cách chạy. Đừng chốt cách đầu tiên nghĩ ra. Quy trình:

```
Orchestrator: với mỗi nghiệp vụ →
  1. Flow-Suggester  → đề ≥2 biến thể (góc: ngắn nhất / an toàn nhất / ít cross nhất)
  2. Domain-Specialist (nếu nghiệp vụ CHUYÊN) → đánh giá đúng-đủ theo chuẩn nghiệp vụ
  3. Flow-Optimizer  → chấm mọi biến thể theo RUBRIC → chọn/ghép flow tối ưu + lý do loại biến thể khác
  4. Cross-User-Integrity (sau khi gom hết flow) → soi handoff treo/orphan/cross thừa toàn map
→ ghi Flow optimization log (§6 ba-spec)
```

### Khi nào spawn team (đừng over-engineer)
- App nhỏ, 1 user, nghiệp vụ tuyến tính → Orchestrator chạy tuần tự, không spawn.
- **Spawn khi**: ≥3 nghiệp vụ · có nghiệp vụ chuyên · có cross-user · user yêu cầu "tối ưu flow".
- `TeamCreate team_name=ba-flow-<n>`; **TeamDelete sau khi user confirm done**.

### Khi nào gọi Domain-Specialist (động theo domain)
Nghiệp vụ chạm lĩnh vực có **chuẩn/luật riêng** mà sai là hỏng thật:
| Domain | Specialist soi gì |
|---|---|
| Kế toán / công nợ | bút toán cân, không trừ/cộng 2 lần, kỳ chốt sổ |
| Kho / tồn | không âm kho, giữ-tạm vs trừ-thật, FIFO/FEFO |
| Thanh toán | idempotency, hoàn tiền, đối soát cổng |
| Bảo hiểm / y tế / pháp lý | điều kiện hợp lệ, thời hiệu, tuân thủ |
| CSKH / SLA | thời hạn phản hồi, leo thang |

Orchestrator phát hiện domain qua từ khoá nghiệp vụ → spawn 1 Specialist cho domain đó. Specialist trả: nghiệp vụ **đủ chưa** (thiếu ca nào), **đúng chưa** (vi phạm chuẩn nào) → thành Rules/Invariants (§9 ba-spec).

> Bảng trên là **ví dụ, KHÔNG phải whitelist**: nghiệp vụ nào có **chuẩn/luật/công thức mà sai là hỏng-thật** (vd định tuyến logistics, tính lương, thuế, chấm công, định giá) → vẫn spawn Specialist domain đó dù không có trong bảng.

**Thẩm quyền:** Domain-Specialist chạy ở bước 2 (TRƯỚC Optimizer bước 3) = **cổng hợp-lệ, có quyền veto** biến thể sai chuẩn. Optimizer chỉ chấm trong các biến thể đã hợp-chuẩn. Mâu thuẫn không gỡ → BA-Orchestrator trọng tài, ghi vào Flow optimization log. (xem SKILL §3.)

## Rubric "flow tối ưu" (Optimizer chấm — ✓ tất mới nhận)

| # | Tiêu chí | Diệt bệnh (1-1) | Cách kiểm |
|---|---|---|---|
| 1 | Định hướng: gắn đúng 1 nghiệp vụ + 1 owner-user + trong scope IN | không định hướng | gắn được vào §3 User×Nghiệp vụ + §7 scope |
| 2 | Input đủ · Output quan sát được | chung chung | Output trỏ được trạng thái dữ liệu mới |
| 3 | Không dead-end; handoff có người nhận + điều kiện | treo / bỏ dở | mọi nhánh có end; mọi cross có B3 |
| 4 | Cross-user tường minh & tối thiểu | cross lung tung | đếm cross-point; >2/flow (≥3 user) → soi tách |
| 5 | Ít bước nhất mà vẫn đủ | rối rắm | có bước nào gộp/bỏ được không |
| 6 | Có success metric đo được (định lượng) | không mục tiêu | điền được §8 ba-spec |

Trượt ≥1 → trả Suggester sửa. Ghi mọi candidate bị loại + lý do vào **Flow optimization log** — bằng chứng cho /audit, và để reverse-handoff sau này biết "đã cân nhắc gì rồi".

## Output
Điền §5 (Flows) + §6 (optimization log) + bổ sung §9 (Rules từ Specialist) của ba-spec. Xong B5 → B6 (AC).
