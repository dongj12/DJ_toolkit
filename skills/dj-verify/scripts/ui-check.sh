#!/usr/bin/env bash
# 헤드리스 브라우저로 페이지를 열어 구조(스냅샷), 콘솔 에러, 스크린샷을 확인한다.
# 산출물은 작업 폴더가 아니라 /tmp/dj-ui 에 남긴다.
# 사용법: ui-check.sh <url> [screenshot.png]   예) ui-check.sh http://127.0.0.1:8000/
set -uo pipefail

URL="${1:?사용법: ui-check.sh <url> [screenshot.png]}"
OUT="${2:-/tmp/dj-ui/shot-$(date +%H%M%S).png}"
PWCLI_PKG="${PWCLI_PKG:-@playwright/cli@0.1.22}"
WORK=/tmp/dj-ui
mkdir -p "$WORK" "$(dirname "$OUT")"
cd "$WORK" || exit 1

pw() { npx --yes --package "$PWCLI_PKG" playwright-cli "$@"; }

if ! command -v npx >/dev/null 2>&1; then
  echo "FAIL  npx가 없습니다. Node.js가 필요합니다."; exit 1
fi

OPEN_LOG=$(pw open --browser=chromium "$URL" 2>&1)
if echo "$OPEN_LOG" | grep -qiE "executable doesn't exist|is not found|install-browser|playwright install|browserType.launch"; then
  echo "INFO  브라우저가 없어 설치합니다 (1~2분)..."
  # --with-deps 는 apt 설치가 필요하므로 이미 root 일 때만 시도 (sudo 로 우회하지 않는다)
  if [ "$(id -u)" = 0 ]; then
    pw install-browser chromium --with-deps >/tmp/dj-ui/install.log 2>&1 \
      || pw install-browser chromium >>/tmp/dj-ui/install.log 2>&1
  else
    pw install-browser chromium >/tmp/dj-ui/install.log 2>&1
  fi
  OPEN_LOG=$(pw open --browser=chromium "$URL" 2>&1)
fi
if ! echo "$OPEN_LOG" | grep -q "Page URL"; then
  echo "FAIL  페이지를 열지 못했습니다:"
  echo "$OPEN_LOG" | grep -iE "missing|shared librar|not found|error:" | grep -v "^\s*at " | head -6
  echo "      시스템 라이브러리가 없으면 화면 자동 점검은 생략하고, smoke.sh(HTTP 확인)와 Browser 탭 직접 확인으로 대신하세요."
  exit 1
fi

echo "== 페이지 구조 (스냅샷)"
pw snapshot 2>&1 | sed -n '/```yaml/,/```/p' | head -80
echo "== 콘솔 메시지"
pw console 2>&1 | grep -E "^\[(ERROR|WARNING)\]|Total messages" | head -20
pw screenshot --filename="$OUT" >/dev/null 2>&1 && echo "== 스크린샷: $OUT"
pw close >/dev/null 2>&1
