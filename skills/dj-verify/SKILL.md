---
name: dj-verify
description: 만든 기능이 실제로 동작하는지 검증한다 — 테스트 실행, 서버 스모크 테스트(포트·0.0.0.0 바인딩·HTTP 응답), 헤드리스 브라우저로 화면 확인. 기능을 하나 끝냈을 때, "확인해줘", "테스트해줘", "화면 봐줘", 미리보기가 안 열릴 때 사용한다.
---

# 검증

스크립트 위치: 이 SKILL.md와 같은 폴더의 `scripts/`. 아래에서 `$S`는 그 절대 경로다.

## 1. 자동 테스트
- 프로젝트의 테스트 명령을 찾아 실행한다 (`pytest -q`, `npm test`, `node --test` 등).
- 테스트가 없고 로직이 있으면, 핵심 동작 3~5개에 대한 최소 테스트를 먼저 만든다.
- 결과는 "N개 통과 / M개 실패"로 보고하고, 실패는 원인을 한 줄씩 적는다.

## 2. 서버 스모크 테스트
서버를 백그라운드로 띄운 뒤:

```bash
nohup <서버 실행 명령> > /tmp/server.log 2>&1 &
bash "$S/smoke.sh" <port> / /api/...      # 확인할 경로 나열
```

- `FAIL 바인딩 ... localhost 전용`이 나오면 host를 `0.0.0.0`으로 고친다.
- 포트가 안 열리면 `tail -30 /tmp/server.log`로 원인을 본다.
- 통과하면 사용자에게 "Browser 도구에서 PORT=<port>, URL=<path> 로 확인하세요"라고 알려준다.
- 화면의 최종 확인은 사용자가 Browser 탭에서 직접 한다.

## 3. 화면 확인 (헤드리스 브라우저, 사용자가 요청할 때만)
사용자가 "화면 자동 점검"을 요청했을 때만 한다. 토큰과 메모리를 쓰고, 사람이 Browser로 확인하는 것을 대신하지 않는다.

한 번에 확인:

```bash
bash "$S/ui-check.sh" http://127.0.0.1:<port>/<path>
```

스냅샷(요소 구조), 콘솔 에러, `/tmp/dj-ui/` 아래 스크린샷 경로가 나온다. 스크린샷은 이미지로 열어 직접 확인한다.

클릭·입력까지 확인해야 하면 Playwright CLI를 직접 쓴다. 반드시 `/tmp/dj-ui`에서 실행해 작업 폴더를 더럽히지 않는다.

```bash
cd /tmp/dj-ui
pw() { npx --yes --package @playwright/cli@0.1.22 playwright-cli "$@"; }
pw open --browser=chromium http://127.0.0.1:<port>/   # 리눅스는 --browser=chromium 필수
pw snapshot            # 요소 ref(e1, e2...) 확인
pw fill e3 "테스트 입력"
pw click e4
pw snapshot            # 결과 확인 (화면이 바뀌면 ref를 다시 받는다)
pw console             # 콘솔 에러
pw screenshot --filename=/tmp/dj-ui/after.png
pw close
```

브라우저 설치가 필요하면 `ui-check.sh`가 자동으로 설치한다(약 100MB). 메모리가 부족해 보이면 화면 확인은 생략하고 HTTP 확인으로 대신한다.

## 보고 형식
```
검증 결과
- 테스트: 12개 통과 / 0개 실패
- 스모크: GET / 200, GET /api/items 200, 바인딩 0.0.0.0 OK
- 화면: 목록 3개 표시, "추가" 클릭 후 4개로 증가, 콘솔 에러 없음
- 미확인: <못 해본 것>
```
검증 결과는 `$dj-decision-log`나 PLAN.md "검증 결과" 섹션에도 남긴다.
