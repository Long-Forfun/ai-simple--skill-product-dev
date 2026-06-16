#!/bin/sh
# ba-verify.sh — CỔNG MÁY cho ba-flow-logic (anh em với ui-ux-triage/triage-verify.sh).
# Cơ giới hoá luật "nghiệp vụ/AC vẽ ra mà không test được = chưa xong" (ai-simple #04 + #08).
#
# BLOCK (exit 1) khi ba-spec:
#   - thiếu frontmatter coupling: Load khi / covers / last_verified / ttl_days
#   - không có AC nào (0 acceptance criteria)
#   - một AC thiếu `Test:` trên header (e2e|integration|unit|manual)
#   - một AC thiếu dòng `Assert` (điểm đo được)
#   - AC chứa tên component UI tiếng Anh (button/sidebar/popup/modal…) — anti-UI luật vàng
# WARN (không chặn): AC chứa từ UI tiếng Việt mơ hồ (màu/tab/góc…); Assert chưa định lượng.
#
# DÙNG:
#   bash ba-verify.sh            # lint mọi ba-spec trong docs/app-map (đọc trên đĩa)
#   bash ba-verify.sh --staged   # lint NỘI DUNG ĐÃ STAGE (git show :file) — cho pre-commit
#   bash ba-verify.sh --self-test
#
# WIRE VÀO PRE-COMMIT (chặn thật) — thêm vào .githooks/pre-commit của project:
#   if ! sh .claude/skills/ba-flow-logic/ba-verify.sh --staged; then FAIL=1; fi
# (qua junction → bản global mới nhất; KHÔNG copy thư mục → tránh drift, bài học #08/#10.)

set -u
APP_MAP_DIR="${APP_MAP_DIR:-docs/app-map}"
MODE="${1:-all}"

# Component UI tiếng Anh — KHÔNG bao giờ xuất hiện hợp lệ trong AC hành vi → BLOCK
UI_BLOCK='button|sidebar|navbar|dropdown|tooltip|popup|modal|placeholder|scrollbar|checkbox|breadcrumb'
# UI tiếng Việt TÍN-HIỆU-CAO (yêu cầu cụm để tránh trùng domain: "nút giao thông", "màu sơn", "bấm giờ") → WARN
UI_WARN='màn hình|kéo thả|nút bấm|bấm nút|nhấn nút|thanh cuộn|click chuột|cửa sổ popup|góc (phải|trái|trên|dưới) màn|#[0-9a-fA-F]{3,6}'

# Vùng frontmatter = từ đầu file tới HEADING `## ` đầu tiên (max 30 dòng) — không kẹt ở head -8
frontmatter_region() { awk 'NR<=30 && /^## /{exit} NR<=30{print}' "$1"; }

lint_one() {
  f="$1"; label="${2:-$1}"; [ -f "$f" ] || return 0
  echo "── lint $label"
  rc=0
  FM=$(frontmatter_region "$f")
  echo "$FM" | grep -qiE 'load (khi|when)' || { echo "  BLOCK: thieu 'Load khi/Load when'"; rc=1; }
  echo "$FM" | grep -qiE '^covers:'        || { echo "  BLOCK: thieu 'covers:'"; rc=1; }
  echo "$FM" | grep -qiE '^last_verified:' || { echo "  BLOCK: thieu 'last_verified:'"; rc=1; }
  echo "$FM" | grep -qiE '^ttl_days:'      || { echo "  BLOCK: thieu 'ttl_days:'"; rc=1; }

  NAC=$(grep -cE '^###[ \t]*AC' "$f" 2>/dev/null); NAC=${NAC:-0}
  if ! [ "$NAC" -gt 0 ] 2>/dev/null; then
    echo "  BLOCK: ba-spec khong co AC nao (0 acceptance criteria) -> nghiep vu chua test duoc"; rc=1
  fi

  # mỗi AC: header có Test: (cho phép khoảng trắng trước :) + có dòng-Assert (neo đầu dòng)
  OUT=$(awk '
    function flush() {
      if (name=="") return
      if (hdr !~ /[Tt]est[ \t]*:/) print "  BLOCK: " name " -> thieu Test: tren header (e2e|integration|unit|manual)"
      if (!asrt)                   print "  BLOCK: " name " -> thieu dong Assert (diem do duoc bang may)"
      else if (aval==0)            print "  WARN: " name " -> Assert co the chua dinh luong (them == / <= / >= / count / trang-thai-dat-ten)"
    }
    /^###[ \t]*AC/ { flush(); name=$0; hdr=$0; asrt=0; aval=0; next }
    /^#/           { flush(); name=""; next }
    {
      if (name=="") next
      if ($0 ~ /^[-*> \t]*\**[Aa]ssert\**/) {
        asrt=1
        if ($0 ~ /(==|<=|>=|<|>|[0-9]|"|status|count|trạng thái|số lượng)/) aval=1
      }
    }
    END { flush() }
  ' "$f")
  [ -n "$OUT" ] && echo "$OUT"
  echo "$OUT" | grep -q BLOCK && rc=1

  # vùng AC: heading "Acceptance" HOẶC "Nghiệm thu"; không thấy → quét mọi block ### AC
  ACSEC=$(awk '/^##[^#].*([Aa]cceptance|[Nn]ghiệm thu)/{p=1;next} /^##[^#]/{p=0} p' "$f")
  [ -z "$ACSEC" ] && ACSEC=$(awk '/^###[ \t]*AC/{p=1} /^##[^#]/{p=0} p' "$f")
  ACSCAN=$(echo "$ACSEC" | grep -vE '^[[:space:]]*>')   # bỏ dòng blockquote (meta-note giải thích, không phải AC)
  HITB=$(echo "$ACSCAN" | grep -niE "$UI_BLOCK" || true)
  if [ -n "$HITB" ]; then echo "$HITB" | sed 's/^/  BLOCK: AC chua component UI (anti-UI) -> /'; rc=1; fi
  echo "$ACSCAN" | grep -niE "$UI_WARN" 2>/dev/null | sed 's/^/  WARN: AC co the chua tu UI -> /' || true

  return $rc
}

if [ "$MODE" = "--self-test" ]; then
  RC=0; T=$(mktemp -d)
  FM='> Load khi: t\ncovers: src/x\nlast_verified: 2026-01-01\nttl_days: 90\n'
  printf "# x\n${FM}## 10. Acceptance\n### AC-1 a\n- Given x\n- Then y\n" > "$T/a.md"
  R=$(lint_one "$T/a.md")
  echo "$R" | grep -q 'thieu Test:'       && echo "PASS: bat AC thieu Test:"   || { echo "FAIL: thieu Test:"; RC=1; }
  echo "$R" | grep -q 'thieu dong Assert' && echo "PASS: bat AC thieu Assert"  || { echo "FAIL: thieu Assert"; RC=1; }
  printf "# x\n${FM}## 10. Acceptance\nproza khong co AC heading\n" > "$T/b.md"
  R=$(lint_one "$T/b.md"); echo "$R" | grep -q '0 acceptance' && echo "PASS: bat 0-AC" || { echo "FAIL: 0-AC LOT"; RC=1; }
  printf "# x\n> Load khi: t\nlast_verified: 2026-01-01\nttl_days: 90\n## 10. Acceptance\n### AC-1 a · Test: e2e\n- **Assert** status==\"x\"\n" > "$T/c.md"
  R=$(lint_one "$T/c.md"); echo "$R" | grep -q "thieu 'covers:'" && echo "PASS: bat thieu covers" || { echo "FAIL: thieu covers LOT"; RC=1; }
  printf "# x\n${FM}> Muc dich: ...\n\n## 1. JTBD\nx\n## 10. Acceptance\n### AC-1 a · Test : e2e\n- Given x\n- Then y\n- **Assert** status==\"da duyet\"\n" > "$T/d.md"
  R=$(lint_one "$T/d.md"); echo "$R" | grep -q BLOCK && { echo "FAIL: spec hop le bi BLOCK oan:"; echo "$R"; RC=1; } || echo "PASS: spec hop le qua (Test co space, frontmatter co preamble, Assert dinh luong)"
  printf "# x\n${FM}## 10. Acceptance\n### AC-1 a · Test: e2e\n- Then he thong se assert quyen nguoi dung\n" > "$T/e.md"
  R=$(lint_one "$T/e.md"); echo "$R" | grep -q 'thieu dong Assert' && echo "PASS: khong nham 'assert' trong Then" || { echo "FAIL: nham assert trong Then -> false-pass"; RC=1; }
  printf "# x\n${FM}## 10. Acceptance\n### AC-1 a · Test: e2e\n- Then mo popup va bam nut Duyet\n- **Assert** status==1\n" > "$T/g.md"
  R=$(lint_one "$T/g.md"); echo "$R" | grep -q 'component UI' && echo "PASS: BLOCK component UI tieng Anh (popup)" || { echo "FAIL: UI tieng Anh LOT"; RC=1; }
  rm -rf "$T"
  [ "$RC" -eq 0 ] && echo "ba-verify self-test: ALL PASS" || echo "ba-verify self-test: CO FAIL"
  exit $RC
fi

if [ "$MODE" = "--staged" ]; then
  FILES=$(git diff --cached --name-only 2>/dev/null | grep -iE 'ba-spec.*\.md$' || true)
  [ -z "$FILES" ] && { echo "ba-verify: khong co ba-spec staged -> skip (exit 0)"; exit 0; }
  FAIL=0; TMP=$(mktemp)
  for f in $FILES; do
    git show ":$f" > "$TMP" 2>/dev/null || continue   # lint NỘI DUNG ĐÃ STAGE, không phải worktree
    lint_one "$TMP" "$f" || FAIL=1
  done
  rm -f "$TMP"
  [ "$FAIL" -eq 1 ] && { echo "ba-verify: FAIL -> ba-spec staged thieu test/frontmatter, KHONG cho commit"; exit 1; }
  echo "ba-verify: PASS"; exit 0
fi

FILES=$(find "$APP_MAP_DIR" -maxdepth 2 -name '*.md' 2>/dev/null | grep -iE 'ba-spec' || true)
[ -z "$FILES" ] && { echo "ba-verify: khong thay ba-spec (mode=$MODE) -> skip (exit 0)"; exit 0; }
FAIL=0
for f in $FILES; do lint_one "$f" || FAIL=1; done
[ "$FAIL" -eq 1 ] && { echo "ba-verify: FAIL -> nghiep vu/AC thieu test, KHONG cho qua"; exit 1; }
echo "ba-verify: PASS"
exit 0
