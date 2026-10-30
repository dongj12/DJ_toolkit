# 템플릿

과제가 스택을 지정하지 않았고 웹 서비스가 필요할 때만 씁니다. 과제 제공 코드가 있으면 그걸 우선합니다.

| 폴더 | 내용 | 실행 |
|---|---|---|
| `fastapi/` | Python API + 정적 페이지 + pytest 4개 | `uvicorn app.main:app --host 0.0.0.0 --port 8000` |
| `express/` | Node API + 정적 페이지 + node:test 4개 | `PORT=3000 npm start` |
| `.gitignore` | 공통 제외 목록 | 작업 폴더에 복사 |
| `PLAN.template.md` | 계획 문서 뼈대 | README가 다른 이름을 지정하면 그 이름으로 |

복사할 때는 반드시 `-n`(이미 있는 파일은 건너뜀)을 붙입니다. 과제의 README.md나 기존 파일을 덮어쓰지 않습니다.

```bash
cp -Rn ~/DJ_toolkit/templates/fastapi/. ./
cp -n ~/DJ_toolkit/templates/.gitignore ./
```

두 템플릿 모두 같은 기능(목록 조회·추가, 빈 입력 400)만 있습니다. 그대로 두지 말고 과제 요구사항에 맞게 바꾸세요.
템플릿을 쓴 사실은 PLAN.md 결정 기록에 한 줄 남깁니다.

## FastAPI 실행

```bash
python3 -m venv .venv && . .venv/bin/activate
pip install -q -r requirements.txt
pytest -q                                              # 테스트
uvicorn app.main:app --host 0.0.0.0 --port 8000        # 실행 (반드시 0.0.0.0)
```
Browser 도구: PORT=8000, URL=/

`venv` 생성이 실패하면(ensurepip 없음): `pip install --user -r requirements.txt` 또는 `pip install --break-system-packages -r requirements.txt`. `uv`가 있으면 `uv venv && uv pip install -r requirements.txt`.

## Express 실행

```bash
npm install --silent
npm test                 # 테스트 (node 내장 test runner)
PORT=3000 npm start      # 실행 (0.0.0.0 바인딩)
```
Browser 도구: PORT=3000, URL=/
