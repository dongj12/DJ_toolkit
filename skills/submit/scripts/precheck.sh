#!/usr/bin/env bash
# 제출 전 기계적 점검: 커밋 안 된 변경, 비밀 정보, 큰 파일, 임시 산출물, TODO, 계획 문서
# 사용법: precheck.sh [작업폴더] [계획문서]   예) precheck.sh . DESIGN.md
#   계획문서를 안 주면 PLAN.md → 결정 기록(### D1) 이 있는 다른 .md 순서로 찾는다.
set -uo pipefail
cd "${1:-.}" || exit 1
PLAN_ARG="${2:-}"

EXCL='--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.venv --exclude-dir=venv --exclude-dir=__pycache__ --exclude-dir=dist --exclude-dir=build'
WARN=0
warn() { echo "WARN  $*"; WARN=1; }
ok()   { echo "OK    $*"; }

# 1) git 상태
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  N=$(git status --porcelain | wc -l | tr -d ' ')
  if [ "$N" = 0 ]; then ok "커밋 안 된 변경 없음 (커밋 $(git rev-list --count HEAD 2>/dev/null || echo 0)개)"
  else warn "커밋 안 된 변경 ${N}개:"; git status --short | head -15; fi
  TRACKED_JUNK=$(git ls-files | grep -E '(^|/)(node_modules|\.venv|venv|__pycache__)/|\.env$' | head -5)
  [ -n "$TRACKED_JUNK" ] && warn "커밋되면 안 되는 파일이 추적 중:" && echo "$TRACKED_JUNK"
else
  warn "git 저장소가 아닙니다 (작업 이력이 남지 않음)"
fi

# 2) 비밀 정보 패턴
SECRETS=$(grep -rInE $EXCL \
  -e 'sk-[A-Za-z0-9_-]{20,}' -e 'AKIA[0-9A-Z]{16}' -e 'gh[pousr]_[A-Za-z0-9]{30,}' \
  -e '-----BEGIN [A-Z ]*PRIVATE KEY-----' \
  -e '(api[_-]?key|secret|token|password)["'"'"' ]*[:=][ ]*["'"'"'][^"'"'"']{12,}["'"'"']' . 2>/dev/null | head -10)
if [ -n "$SECRETS" ]; then warn "비밀 정보로 보이는 문자열:"; echo "$SECRETS" | cut -c1-160
else ok "비밀 정보 패턴 없음"; fi

# 3) 큰 파일 (5MB 이상)
BIG=$(find . -type f -size +5M -not -path './.git/*' -not -path '*/node_modules/*' -not -path '*/.venv/*' 2>/dev/null | head -10)
[ -n "$BIG" ] && warn "5MB 넘는 파일 (정말 제출물인지 확인):" && echo "$BIG" || ok "큰 파일 없음"

# 4) 임시 산출물
JUNK=$(find . -maxdepth 3 \( -name '*.log' -o -name '.DS_Store' \) -not -path './.git/*' -not -path '*/node_modules/*' 2>/dev/null | head -10)
[ -n "$JUNK" ] && warn "임시 산출물로 보이는 파일:" && echo "$JUNK" || ok "임시 산출물 없음"

# 5) TODO / FIXME
TODO=$(grep -rInE $EXCL '\b(TODO|FIXME|XXX)\b' --include='*.py' --include='*.js' --include='*.ts' --include='*.tsx' --include='*.jsx' --include='*.go' --include='*.java' . 2>/dev/null | head -10)
[ -n "$TODO" ] && warn "남은 TODO/FIXME:" && echo "$TODO" | cut -c1-140 || ok "TODO/FIXME 없음"

# 6) 계획 문서
if [ -n "$PLAN_ARG" ]; then
  PLAN=$([ -f "$PLAN_ARG" ] && echo "$PLAN_ARG")
else
  PLAN=$(ls PLAN.md plan.md docs/PLAN.md 2>/dev/null | head -1)
  [ -z "$PLAN" ] && PLAN=$(grep -rlE $EXCL --include='*.md' '^### D[0-9]+' . 2>/dev/null | head -1)
fi
if [ -n "$PLAN" ]; then
  D=$(grep -cE '^### D[0-9]+' "$PLAN" || true)
  ok "계획 문서: $PLAN (결정 기록 ${D}개)"
  grep -qE '검증' "$PLAN" || warn "$PLAN 에 검증 결과가 없습니다"
  grep -qE '한계' "$PLAN" || warn "$PLAN 에 남은 한계가 없습니다"
else
  warn "계획 문서(${PLAN_ARG:-PLAN.md})가 없습니다 (README가 지정한 이름이면: precheck.sh . <파일명>)"
fi

echo
[ "$WARN" = 0 ] && echo "결과: 기계적 점검 통과" || echo "결과: WARN 항목을 확인하세요"
exit 0
