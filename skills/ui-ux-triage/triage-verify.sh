#!/usr/bin/env bash
# triage-verify.sh — cổng THẬT, REPO-AGNOSTIC, cho skill ui-ux-triage (verify-on-use, không honor-system).
# Đọc .claude/triage.config nếu có; KHÔNG có → auto-discover docs/app-map. Chạy từ repo root.
#   bash triage-verify.sh              # gate trước spawn: exit 0 mới chạy (exit 2 = sai cwd)
#   bash triage-verify.sh --lint-log <file>
#   bash triage-verify.sh --lint-patterns <file>
#   bash triage-verify.sh --self-test
set -u

# ---- config (parse an toàn KEY=value, KHÔNG source để khỏi chạy code lạ) ----
# Strip "KEY=", inline comment ( #...), rồi trim 2 đầu. KHÔNG source (chống chạy code lạ).
cfg() { [ -f .claude/triage.config ] && grep -E "^$1=" .claude/triage.config 2>/dev/null | head -1 | sed -E "s/^$1=//; s/[[:space:]]+#.*$//; s/^[[:space:]]+//; s/[[:space:]]+$//"; }
APP_MAP_DIR=$(cfg APP_MAP_DIR); APP_MAP_DIR=${APP_MAP_DIR:-docs/app-map}
TELEGRAM=$(cfg TELEGRAM); TELEGRAM=${TELEGRAM:-scripts/notify-telegram.sh}
TRIAGE_LOG=$(cfg TRIAGE_LOG); TRIAGE_LOG=${TRIAGE_LOG:-test-reports/triage/triage-log.md}
READ_REFS_CFG=$(cfg READ_REFS)   # danh sách explicit, phẩy ngăn; rỗng → auto-discover

# Repo-root thật = .claude/ CỘNG dấu hiệu repo (app-map HOẶC package.json). Repo-agnostic, không hardcode tên doc.
is_repo_root() { [ -d "$1/.claude" ] && { [ -d "$1/$APP_MAP_DIR" ] || [ -f "$1/package.json" ]; }; }

# Resolve read-refs cho 1 root: explicit từ config, hoặc auto-discover *.md trong app-map (bỏ _generated).
resolve_reads() {
  local root="$1"
  if [ -n "$READ_REFS_CFG" ]; then printf '%s\n' "$READ_REFS_CFG" | tr ',' '\n' | sed 's/^ *//; s/ *$//'
  elif [ -d "$root/$APP_MAP_DIR" ]; then ( cd "$root" && find "$APP_MAP_DIR" -maxdepth 2 -name '*.md' 2>/dev/null | grep -v '_generated/' )
  fi
}

check_reads() {
  local root="${1:-.}" rc=0 f
  local refs; refs=$(resolve_reads "$root")
  if [ -z "$refs" ]; then echo "  WARN  không tìm thấy app-map ($APP_MAP_DIR) — repo chưa có doc? (degrade, không stop)"; fi
  # while-read + here-string: chịu được tên file có dấu cách + rc propagate (KHÔNG pipe → khỏi subshell nuốt rc).
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if [ -f "$root/$f" ]; then echo "  OK   read   $f"
    else echo "  DEAD read   $f  <-- ref chết, HARD STOP"; rc=1; fi
  done <<< "$refs"
  # oracle presence (INFO, KHÔNG gate — repo chưa chạy BA/design vẫn chạy degrade [no-oracle]):
  if [ -d "$root/$APP_MAP_DIR" ]; then
    local oracle; oracle=$( cd "$root" && find "$APP_MAP_DIR" -maxdepth 2 -name '*.md' 2>/dev/null | grep -iE 'ba-spec|design-spec|design-system' | head -1 )
    [ -n "$oracle" ] && echo "  INFO oracle: '$oracle' → composition mode" || echo "  INFO oracle: chưa thấy ba-spec/design-spec → DEGRADE ([no-oracle] trên finding)"
  fi
  # config (telegram): warn-degrade
  if [ -f "$root/$TELEGRAM" ]; then echo "  OK   config $TELEGRAM"
  else echo "  WARN config $TELEGRAM thiếu → DEGRADE: ghi report ra file thay telegram (không stop)"; fi
  # E2E harness có nhưng thiếu test-data tracker/cleanup → WARN (cơ-chế-hóa luật 3; KHÔNG block, giữ degrade).
  if [ -d "$root/tests/e2e" ]; then
    local trk="" cln=""
    ( cd "$root" && grep -rq 'trackAccount' tests/e2e 2>/dev/null ) && trk=1
    ( cd "$root" && grep -q 'cleanup' package.json 2>/dev/null ) && cln=1
    if [ -n "$trk" ] && [ -n "$cln" ]; then echo "  OK   e2e-tracker + cleanup cmd"
    else echo "  WARN E2E harness có nhưng THIẾU test-data tracker/cleanup → flow-tester PHẢI degrade, CẤM chạm prod data"; fi
  fi
  # write-target: tự mkdir -p parent
  local d; d=$(dirname "$root/$TRIAGE_LOG")
  mkdir -p "$d" 2>/dev/null && echo "  OK   write   $d/ (đã đảm bảo tồn tại)" || { echo "  FAIL không tạo được $d/"; rc=1; }
  return $rc
}

# ---- lint triage-log (field non-empty; telegram ok|fail|degraded) ----
lint_log_line() {
  echo "$1" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}[^|]*\| *[^| ][^|]*\| *iter=[0-9]+ *\| *buckets=[^| ][^|]*\| *decided=[^| ][^|]*\| *verify=[^| ][^|]*\| *telegram=(ok|fail|degraded)'
}

# ---- lint feedback_triage_decisions.md (data rows sau separator phải có ×N, last <date>) ----
lint_patterns_file() {
  local f="$1" bad=0 n=0 line seen_sep=0 saw_pipe=0
  [ -f "$f" ] || { echo "lint-patterns: file chưa có (OK nếu chưa học pattern)"; return 0; }
  while IFS= read -r line; do
    case "$line" in "|"*) saw_pipe=1;; esac
    case "$line" in *"---"*) seen_sep=1; continue;; esac
    [ "$seen_sep" -eq 1 ] || continue
    case "$line" in "|"*) ;; *) continue;; esac
    n=$((n+1))
    echo "$line" | grep -qE '×[0-9]+, *[0-9]{4}-[0-9]{2}-[0-9]{2}' || { echo "PATTERN THIẾU Tần suất: $line"; bad=$((bad+1)); }
  done < "$f"
  if [ "$saw_pipe" -eq 1 ] && [ "$seen_sep" -eq 0 ]; then echo "MALFORMED: bảng thiếu separator '---'"; return 1; fi
  echo "lint-patterns: $n dòng, $bad thiếu"; [ "$bad" -eq 0 ]
}

case "${1:-}" in
  --lint-log)
    LOG="${2:?cần đường dẫn log}"; [ -f "$LOG" ] || { echo "log không tồn tại: $LOG"; exit 1; }
    n=0; bad=0
    while IFS= read -r line; do case "$line" in ""|\#*) continue;; esac
      n=$((n+1)); lint_log_line "$line" || { echo "DÒNG SAI: $line"; bad=$((bad+1)); }; done < "$LOG"
    echo "lint-log: $n dòng, $bad sai"; [ "$bad" -eq 0 ]; exit $? ;;
  --lint-patterns)
    lint_patterns_file "${2:?cần đường dẫn feedback_triage_decisions.md}"; exit $? ;;
  --self-test)
    T=$(mktemp -d); RC2=0
    mkdir -p "$T/.claude" "$T/$APP_MAP_DIR" "$T/scripts"
    echo a > "$T/$APP_MAP_DIR/01-x.md"; echo b > "$T/$APP_MAP_DIR/02-y.md"
    # 1) auto-discover + đủ ref → PASS
    if check_reads "$T" >/dev/null; then echo "PASS: auto-discover đủ ref → qua"; else echo "FAIL: chặn oan khi đủ ref"; RC2=1; fi
    # 2) thêm ref chết (config explicit trỏ file không có)? test bằng xoá 1 file đã discover:
    rm "$T/$APP_MAP_DIR/02-y.md"
    if check_reads "$T" >/dev/null; then echo "PASS: discover lại (file xoá không còn trong list) → vẫn qua"; else echo "INFO: (auto-discover tự bỏ file đã xoá — đúng)"; fi
    # 2b) ref chết THẬT qua config explicit
    printf 'READ_REFS=%s/01-x.md,%s/khong-ton-tai.md\n' "$APP_MAP_DIR" "$APP_MAP_DIR" > "$T/.claude/triage.config"
    READ_REFS_CFG="$APP_MAP_DIR/01-x.md,$APP_MAP_DIR/khong-ton-tai.md"
    if check_reads "$T" >/dev/null; then echo "FAIL: config ref chết KHÔNG bị bắt"; RC2=1; else echo "PASS: config ref chết → HARD STOP đúng"; fi
    READ_REFS_CFG=""
    # 3) lint-log
    lint_log_line '2026-06-15 | r | iter=1 | buckets=LOGIC:1 | decided=x | verify=tsc:pass | telegram=ok' && echo "PASS: log đúng" || { echo "FAIL: log đúng bị từ chối"; RC2=1; }
    lint_log_line 'rác' && { echo "FAIL: log sai lọt"; RC2=1; } || echo "PASS: log sai bị bắt"
    lint_log_line '2026-06-15 | r | iter=1 | buckets=D:1 | decided=x | verify=p | telegram=degraded' && echo "PASS: telegram=degraded hợp lệ" || { echo "FAIL: degraded bị từ chối"; RC2=1; }
    lint_log_line '2026-06-15 | r | iter=1 | buckets= | decided= | verify= | telegram=ok' && { echo "FAIL: field rỗng lọt"; RC2=1; } || echo "PASS: field rỗng bị bắt"
    # 4) lint-patterns (header+sep, prose-collision, malformed)
    PF="$T/p.md"; HDR='| Tình huống | pattern | heuristic | Tần suất |\n|---|---|---|---|\n'
    printf "$HDR"'| ok | x | y | ×2, 2026-06-15 |\n' > "$PF"
    lint_patterns_file "$PF" >/dev/null && echo "PASS: bảng thật data đủ → không false-fail header" || { echo "FAIL: false-fail header"; RC2=1; }
    printf "$HDR"'| Nói về Tần suất | x | y |\n' > "$PF"
    lint_patterns_file "$PF" >/dev/null && { echo "FAIL: data 'Tần suất' thiếu ×N lọt"; RC2=1; } || echo "PASS: prose chứa 'Tần suất' thiếu ×N → vẫn bắt"
    printf '| a | b | c | Tần suất |\n| data | x | y | ×1, 2026-06-15 |\n' > "$PF"
    lint_patterns_file "$PF" >/dev/null 2>&1 && { echo "FAIL: thiếu separator pass mù"; RC2=1; } || echo "PASS: thiếu separator → MALFORMED"
    # 5) tên file CÓ DẤU CÁCH không được false-DEAD (bug word-split unquoted refs)
    T2=$(mktemp -d); mkdir -p "$T2/.claude" "$T2/$APP_MAP_DIR" "$T2/scripts"
    echo a > "$T2/$APP_MAP_DIR/01 has space.md"; echo b > "$T2/$APP_MAP_DIR/02-y.md"
    if check_reads "$T2" >/dev/null; then echo "PASS: tên file có dấu cách → KHÔNG false-DEAD"; else echo "FAIL: tên file có dấu cách bị word-split → false HARD STOP"; RC2=1; fi
    # 6) config bẩn (trailing space + inline comment) phải parse trimmed, không degrade-blind
    printf 'APP_MAP_DIR=%s   # ghi chú inline\n' "$APP_MAP_DIR" > "$T2/.claude/triage.config"
    GOT=$(cd "$T2" && cfg APP_MAP_DIR)
    if [ "$GOT" = "$APP_MAP_DIR" ]; then echo "PASS: config bẩn (space+comment) → trim đúng '$GOT'"; else echo "FAIL: config bẩn parse sai → '$GOT'"; RC2=1; fi
    # 7) CWD-guard: dir CHỈ có .claude (không app-map, không package.json) → KHÔNG được nhận là repo root
    T3=$(mktemp -d); mkdir -p "$T3/.claude"
    if is_repo_root "$T3"; then echo "FAIL: dir chỉ-.claude bị nhận là repo root → spawn mù"; RC2=1; else echo "PASS: dir chỉ-.claude → guard từ chối (cần app-map/package.json)"; fi
    is_repo_root "$T" && echo "PASS: dir có .claude+app-map → guard nhận đúng" || { echo "FAIL: repo thật bị guard từ chối"; RC2=1; }
    # 8) E2E harness thiếu tracker/cleanup → WARN; có đủ → OK (cơ-chế-hóa luật 3)
    T4=$(mktemp -d); mkdir -p "$T4/.claude" "$T4/$APP_MAP_DIR" "$T4/tests/e2e/utils"; echo a > "$T4/$APP_MAP_DIR/01-x.md"
    check_reads "$T4" 2>&1 | grep -q 'THIẾU test-data tracker' && echo "PASS: E2E thiếu tracker → WARN" || { echo "FAIL: thiếu tracker không WARN"; RC2=1; }
    echo 'export function trackAccount(){}' > "$T4/tests/e2e/utils/account-tracker.ts"
    printf '{ "scripts": { "test:e2e:cleanup": "x" } }\n' > "$T4/package.json"
    check_reads "$T4" 2>&1 | grep -q 'e2e-tracker + cleanup' && echo "PASS: có tracker+cleanup → OK" || { echo "FAIL: có tracker+cleanup không nhận"; RC2=1; }
    rm -rf "$T" "$T2" "$T3" "$T4"
    echo "--- self-test: $([ $RC2 -eq 0 ] && echo ALL PASS || echo CÓ FAIL) ---"; exit $RC2 ;;
esac

# ---- gate mode ----
# CWD-root guard: chỉ .claude/ là chưa đủ — parent-dir tình cờ có .claude/ sẽ PASS mù trên repo rỗng.
if ! is_repo_root "."; then
  echo "FAIL: không giống repo root (cần .claude/ + $APP_MAP_DIR hoặc package.json). cwd: $(pwd)"; exit 2; fi
RC=0
echo "=== triage-verify (gate trước spawn, repo-agnostic) ==="
check_reads "." || RC=1
echo "=== $([ $RC -eq 0 ] && echo 'PASS — được spawn team' || echo 'FAIL — sửa ref chết trước khi spawn') ==="
exit $RC
