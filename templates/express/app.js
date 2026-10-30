// 최소 Express 뼈대: 상태 확인, 메모리 저장 목록 API, 정적 페이지.
import express from 'express';

export function createApp() {
  const app = express();
  const items = [];

  app.use(express.json());
  app.use(express.static(new URL('./public', import.meta.url).pathname));

  app.get('/api/health', (req, res) => res.json({ ok: true }));

  app.get('/api/items', (req, res) => res.json(items));

  app.post('/api/items', (req, res) => {
    const name = String(req.body?.name ?? '').trim();
    if (!name) return res.status(400).json({ error: 'name is required' });
    const item = { id: items.length + 1, name };
    items.push(item);
    res.status(201).json(item);
  });

  return app;
}
