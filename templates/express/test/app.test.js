import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { createApp } from '../app.js';

let server;
let base;

before(async () => {
  server = createApp().listen(0);
  await new Promise((r) => server.once('listening', r));
  base = `http://127.0.0.1:${server.address().port}`;
});
after(() => server.close());

test('health', async () => {
  assert.deepEqual(await (await fetch(`${base}/api/health`)).json(), { ok: true });
});

test('add and list', async () => {
  const r = await fetch(`${base}/api/items`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name: 'milk' }),
  });
  assert.equal(r.status, 201);
  assert.deepEqual(await (await fetch(`${base}/api/items`)).json(), [{ id: 1, name: 'milk' }]);
});

test('empty name rejected', async () => {
  const r = await fetch(`${base}/api/items`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name: ' ' }),
  });
  assert.equal(r.status, 400);
});

test('index served', async () => {
  const r = await fetch(`${base}/`);
  assert.equal(r.status, 200);
  assert.match(await r.text(), /<html/);
});
