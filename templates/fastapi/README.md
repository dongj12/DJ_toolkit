# FastAPI 뼈대

```bash
python3 -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt
pytest -q                                              # 테스트
uvicorn app.main:app --host 0.0.0.0 --port 8000        # 실행 (반드시 0.0.0.0)
```
Browser 도구: PORT=8000, URL=/

`venv` 생성이 실패하면(ensurepip 없음): `pip install --user -r requirements.txt` 또는 `pip install --break-system-packages -r requirements.txt`. `uv`가 있으면 `uv venv && uv pip install -r requirements.txt`.
