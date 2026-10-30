#!/usr/bin/env bash
# 서버 스모크 테스트: 포트 대기 → 바인딩 주소 확인 → 경로별 HTTP 응답 확인
# 사용법: smoke.sh <port> [path ...]     예) smoke.sh 8000 / /api/health
set -uo pipefail

PORT="${1:?사용법: smoke.sh <port> [path ...]}"
shift
PATHS=("$@")
[ ${#PATHS[@]} -eq 0 ] && PATHS=("/")

# 1) 포트가 열릴 때까지 최대 30초 대기
for i in $(seq 1 30); do
  if (exec 3<>"/dev/tcp/127.0.0.1/$PORT") 2>/dev/null; then break; fi
  if [ "$i" -eq 30 ]; then
    echo "FAIL  포트 $PORT 에서 응답하는 서버가 없습니다 (30초 대기)."
    echo "      서버가 실행 중인지, 실제 포트가 맞는지, 로그(/tmp/*.log)를 확인하세요."
    exit 1
  fi
  sleep 1
done
echo "OK    포트 $PORT 열림"

FAILED=0

# 2) 바인딩 주소 확인 (미리보기는 0.0.0.0 바인딩이 필요)
LISTEN=""
if command -v ss >/dev/null 2>&1; then
  LISTEN=$(ss -ltnH 2>/dev/null | awk '{print $4}' | grep -E "[:.]$PORT\$" || true)
elif command -v lsof >/dev/null 2>&1; then
  LISTEN=$(lsof -nP -iTCP:"$PORT" -sTCP:LISTEN 2>/dev/null | awk 'NR>1{print $9}' || true)
elif command -v netstat >/dev/null 2>&1; then
  LISTEN=$(netstat -ltn 2>/dev/null | awk '{print $4}' | grep -E "[:.]$PORT\$" || true)
elif [ -r /proc/net/tcp ]; then
  # 도구가 없는 리눅스: /proc/net/tcp(6)에서 LISTEN(0A) 상태인 주소를 읽는다
  HEX=$(printf '%04X' "$PORT")
  LISTEN=$(cat /proc/net/tcp /proc/net/tcp6 2>/dev/null | awk -v h="$HEX" '$4=="0A"{split($2,a,":"); if(a[2]==h) print a[1]}' \
    | sed -e 's/^00000000$/0.0.0.0/' -e 's/^0100007F$/127.0.0.1/' \
          -e 's/^00000000000000000000000000000000$/[::]/' -e 's/^00000000000000000000000001000000$/[::1]/' \
          -e 's/^0000000000000000FFFF00000100007F$/127.0.0.1/' -e 's/^0000000000000000FFFF000000000000$/0.0.0.0/')
fi
if [ -z "$LISTEN" ]; then
  echo "WARN  바인딩 주소를 확인할 도구가 없습니다 (ss/lsof/netstat). 서버 코드에서 host=0.0.0.0 인지 직접 확인하세요."
elif echo "$LISTEN" | grep -qE '^(0\.0\.0\.0|\*|\[::\]|::|\*:)'; then
  echo "OK    바인딩: $(echo $LISTEN | tr '\n' ' ')(외부 접근 가능)"
else
  echo "FAIL  바인딩: $(echo $LISTEN | tr '\n' ' ')— localhost 전용입니다. 0.0.0.0 으로 바꿔야 미리보기가 열립니다."
  FAILED=1
fi

# 3) 경로별 응답
for P in "${PATHS[@]}"; do
  BODY=$(mktemp)
  CODE=$(curl -s -o "$BODY" -w '%{http_code}' --max-time 10 "http://127.0.0.1:$PORT$P")
  SNIP=$(head -c 160 "$BODY" | tr '\n' ' ')
  rm -f "$BODY"
  if [[ "$CODE" =~ ^[23] ]]; then
    echo "OK    GET $P → $CODE  | $SNIP"
  else
    echo "FAIL  GET $P → $CODE  | $SNIP"
    FAILED=1
  fi
done
exit $FAILED
