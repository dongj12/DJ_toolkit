# DJ_toolkit

시간 제한이 있는 해커톤에서 Codex CLI와 함께 쓰는 범용 작업 도구입니다. 과제 풀이 코드는 없고, 작업 규칙, 스킬, 검증 스크립트, 최소 템플릿만 들어 있습니다.

## 시험장에서 (1분)

```bash
git clone https://github.com/dongj12/DJ_toolkit.git ~/DJ_toolkit
bash ~/DJ_toolkit/install.sh
codex
```

- **작업 폴더 밖(`~/DJ_toolkit`)에 clone하세요.** 작업 폴더 안에 넣으면 제출물에 섞입니다.
- 설치하는 곳은 `~/.codex/skills/`(스킬)와 `~/.codex/AGENTS.md`(작업 규칙)뿐입니다. 이미 있는 파일은 덮어쓰지 않고, `config.toml`은 건드리지 않습니다.
- Codex를 켤 때 **업데이트 질문이 나오면 거절**하세요 (제공된 Codex 업데이트 금지).
- Codex에서 `/skills`를 입력해 `start`, `log`, `verify`, `commit`, `submit`, `brief`가 보이면 설치된 것입니다. 같은 이름의 스킬이 이미 있으면 설치 스크립트가 우리 것을 `dj-` 접두어 이름(예: `$dj-commit`)으로 설치하고 크게 알려줍니다.
- `/skills`에 안 보이면 이름 대신 파일을 읽게 하세요: `~/DJ_toolkit/skills/start/SKILL.md 읽고 그대로 해줘`. 규칙은 `~/DJ_toolkit/AGENTS.md 읽고 이번 작업 내내 따라줘`.

## 들어 있는 것

| 구성 | 하는 일 |
|---|---|
| `AGENTS.md` | Codex가 항상 따르는 규칙: README 우선, 0.0.0.0 바인딩, 검증 후 보고, 기록·커밋, 금지 사항 |
| `$start` | README 분석 → 요구사항 체크리스트, 실무자에게 물어볼 질문, 시간 계획, PLAN.md 뼈대 |
| `$log` | 결정을 PLAN.md에 선택/대안/이유/검증/한계 형식으로 기록 |
| `$verify` | 테스트 실행 + 서버 스모크(포트·바인딩·HTTP) + Browser 탭에서 직접 확인할 PORT·URL과 확인 항목 안내 |
| `$commit` | 기능 단위 git 커밋 (.gitignore 정리, push 안 함) |
| `$submit` | 제출 전 요구사항 대조 + 비밀 정보·임시 파일·TODO·계획 문서 점검 |
| `$brief` | 서술형 대비: 내 작업 한 장 브리핑 + 예상 질문 6개 (터미널에만 출력) |
| `templates/` | FastAPI / Express 최소 뼈대 (테스트 포함), .gitignore, PLAN 템플릿. 복사는 `cp -Rn`으로 (과제 README 보호) |
| `mcp/` | 키 없이 쓰는 공개 MCP 설정(Context7). 선택 사항 |
| `docs/codex-cheatsheet.md` | Codex 슬래시 명령과 상황별 한 줄 요청 |

## 과제 중 흐름

```
$start        → 요구사항·계획 확정 (처음 10분)
  기능 구현
  $log → 결정할 때마다
  $verify       → 기능마다
  $commit   → 기능마다
$submit   → 종료 20분 전
$brief        → 제출 직전 5분
```

## 직접 실행할 수 있는 스크립트

```bash
S=~/DJ_toolkit/skills      # clone 한 원본 경로 (설치 이름이 바뀌어도 그대로)
bash $S/verify/scripts/smoke.sh 8000 / /api/health     # 포트·바인딩·HTTP 확인
bash $S/submit/scripts/precheck.sh .              # 제출 전 점검
```

## 제거

```bash
bash ~/DJ_toolkit/install.sh --uninstall   # 이 툴킷이 설치한 것만 지움
```

## 출처
- 스킬 형식과 위치: [Codex 스킬 문서](https://learn.chatgpt.com/docs/build-skills), [AGENTS.md 문서](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
- 라이브러리 문서 MCP: [Context7](https://github.com/upstash/context7)
- `--openai-skills` 옵션은 [openai/skills](https://github.com/openai/skills)(Apache-2.0)에서 내려받아 설치합니다. 이 저장소에 복사해 두지는 않았습니다.
