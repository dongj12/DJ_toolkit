# 템플릿

과제가 스택을 지정하지 않았고 웹 서비스가 필요할 때만 씁니다. 과제 제공 코드가 있으면 그걸 우선합니다.

| 폴더 | 내용 | 실행 |
|---|---|---|
| `fastapi/` | Python API + 정적 페이지 + pytest 4개 | `uvicorn app.main:app --host 0.0.0.0 --port 8000` |
| `express/` | Node API + 정적 페이지 + node:test 4개 | `PORT=3000 npm start` |
| `.gitignore` | 공통 제외 목록 | 작업 폴더에 복사 |
| `PLAN.template.md` | 계획 문서 뼈대 | README가 다른 이름을 지정하면 그 이름으로 |

복사 예: `cp -R ~/DJ_toolkit/templates/fastapi/. ./ && cp ~/DJ_toolkit/templates/.gitignore ./`

두 템플릿 모두 같은 기능(목록 조회·추가, 빈 입력 400)만 있습니다. 그대로 두지 말고 과제 요구사항에 맞게 바꾸세요.
