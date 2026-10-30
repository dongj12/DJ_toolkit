#!/usr/bin/env bash
# DJ_toolkit 설치: Codex 스킬과 작업 규칙(AGENTS.md)을 사용자 범위에 넣는다.
# - 작업 폴더(제출물)는 건드리지 않는다.
# - config.toml 등 플랫폼 설정은 건드리지 않는다.
# - 이미 있는 파일은 덮어쓰지 않는다 (이 툴킷이 만든 것만 갱신).
#
# 사용법:
#   bash install.sh                 # 스킬 + AGENTS.md
#   bash install.sh --browser       # + 화면 확인용 헤드리스 브라우저 미리 설치 (~100MB)
#   bash install.sh --openai-skills # + OpenAI 공개 스킬(playwright, security-best-practices)
#   bash install.sh --uninstall     # 이 툴킷이 설치한 것만 제거
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_HOME/skills"
MARK=".dj_toolkit"
PWCLI_PKG="@playwright/cli@0.1.22"

WITH_BROWSER=0; WITH_OPENAI=0; UNINSTALL=0
for a in "$@"; do
  case "$a" in
    --browser) WITH_BROWSER=1 ;;
    --openai-skills) WITH_OPENAI=1 ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
    *) echo "알 수 없는 옵션: $a"; exit 1 ;;
  esac
done

say() { printf '%s\n' "$*"; }

# ---------- 제거 ----------
if [ "$UNINSTALL" = 1 ]; then
  for d in "$SKILLS_DIR"/*/; do
    [ -f "$d$MARK" ] && rm -rf "$d" && say "제거: $d"
  done
  if [ -f "$CODEX_HOME/AGENTS.md" ] && grep -q "DJ_toolkit" "$CODEX_HOME/AGENTS.md"; then
    rm -f "$CODEX_HOME/AGENTS.md" && say "제거: $CODEX_HOME/AGENTS.md"
  fi
  exit 0
fi

mkdir -p "$SKILLS_DIR" 2>/dev/null || { say "FAIL  $SKILLS_DIR 를 만들 수 없습니다 (권한 확인)"; exit 1; }

# ---------- 1) 스킬 ----------
install_skill() {  # $1=원본 폴더  $2=이름
  local src="$1" name="$2" dst="$SKILLS_DIR/$2"
  if [ -e "$dst" ] && [ ! -f "$dst/$MARK" ]; then
    say "SKIP  스킬 $name: 같은 이름이 이미 있어 건드리지 않음 ($dst)"
    return
  fi
  rm -rf "$dst"
  cp -R "$src" "$dst"
  touch "$dst/$MARK"
  find "$dst" -name '*.sh' -exec chmod +x {} +
  say "OK    스킬 $name"
}
for s in "$ROOT"/skills/*/; do
  install_skill "${s%/}" "$(basename "$s")"
done

# ---------- 2) AGENTS.md (전역 작업 규칙) ----------
G="$CODEX_HOME/AGENTS.md"
if [ -f "$CODEX_HOME/AGENTS.override.md" ]; then
  say "WARN  $CODEX_HOME/AGENTS.override.md 가 있어 AGENTS.md 는 무시됩니다. 건드리지 않음."
  say "      대신 Codex 첫 메시지에서 '$ROOT/AGENTS.md 를 읽고 따라줘'라고 요청하세요."
elif [ ! -s "$G" ] || grep -q "DJ_toolkit" "$G"; then
  cp "$ROOT/AGENTS.md" "$G"
  say "OK    작업 규칙 → $G"
else
  say "SKIP  $G 가 이미 있어 건드리지 않음 (플랫폼 제공일 수 있음)."
  say "      대신 Codex 첫 메시지에서 '$ROOT/AGENTS.md 를 읽고 따라줘'라고 요청하세요."
fi

# ---------- 3) OpenAI 공개 스킬 (선택) ----------
if [ "$WITH_OPENAI" = 1 ]; then
  TMP="$(mktemp -d)"
  if git clone -q --depth 1 --filter=blob:none --sparse https://github.com/openai/skills.git "$TMP/skills" 2>/dev/null \
     && git -C "$TMP/skills" sparse-checkout set skills/.curated/playwright skills/.curated/security-best-practices >/dev/null 2>&1; then
    for n in playwright security-best-practices; do
      install_skill "$TMP/skills/skills/.curated/$n" "$n"
    done
  else
    say "WARN  github.com/openai/skills 를 가져오지 못했습니다 (네트워크 확인). 나머지는 정상."
  fi
  rm -rf "$TMP"
fi

# ---------- 4) 헤드리스 브라우저 (선택) ----------
if [ "$WITH_BROWSER" = 1 ]; then
  if command -v npx >/dev/null 2>&1; then
    say "INFO  브라우저 설치 중 (1~2분)..."
    mkdir -p /tmp/dj-ui && cd /tmp/dj-ui
    if [ "$(id -u)" = 0 ] || sudo -n true 2>/dev/null; then DEPS="--with-deps"; else DEPS=""; fi
    if npx --yes --package "$PWCLI_PKG" playwright-cli install-browser chromium $DEPS >/tmp/dj-ui/install.log 2>&1 \
       || npx --yes --package "$PWCLI_PKG" playwright-cli install-browser chromium >>/tmp/dj-ui/install.log 2>&1; then
      say "OK    브라우저 설치 (로그: /tmp/dj-ui/install.log)"
    else
      say "WARN  브라우저 설치 실패 — tail /tmp/dj-ui/install.log 확인. 화면 확인 없이도 나머지는 정상."
    fi
    cd - >/dev/null
  else
    say "WARN  npx 가 없어 브라우저 설치를 건너뜀"
  fi
fi

cat <<EOF

설치 완료. 다음 단계:
  1. Codex가 실행 중이면 /quit 후 다시 codex 실행 (스킬·규칙은 시작할 때 읽음)
  2. /skills 에서 dj-* 스킬이 보이는지 확인
  3. 첫 요청:  \$dj-kickoff 과제 README 분석해줘

스킬: \$dj-kickoff  \$dj-decision-log  \$dj-verify  \$dj-checkpoint  \$dj-submit-check  \$dj-explain
EOF
