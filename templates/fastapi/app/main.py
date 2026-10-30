"""최소 FastAPI 뼈대: 상태 확인, 메모리 저장 목록 API, 정적 페이지."""
from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from pydantic import BaseModel

STATIC = Path(__file__).resolve().parent.parent / "static"

app = FastAPI()
items: list[dict] = []


class ItemIn(BaseModel):
    name: str


@app.get("/api/health")
def health():
    return {"ok": True}


@app.get("/api/items")
def list_items():
    return items


@app.post("/api/items", status_code=201)
def add_item(body: ItemIn):
    name = body.name.strip()
    if not name:
        raise HTTPException(status_code=400, detail="name is required")
    item = {"id": len(items) + 1, "name": name}
    items.append(item)
    return item


@app.get("/")
def index():
    return FileResponse(STATIC / "index.html")
