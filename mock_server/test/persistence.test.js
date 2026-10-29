const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const path = require('node:path');
const app = require('../api/server');

test('prototype server reads GET data and rejects every write without changing its fixture', async () => {
  const file = path.join(__dirname, '..', 'db.json');
  const before = await fs.readFile(file, 'utf8');
  const server = await new Promise(resolve => {
    const listener = app.listen(0, '127.0.0.1', () => resolve(listener));
  });
  const base = `http://127.0.0.1:${server.address().port}`;
  try {
    for (const route of ['/items', '/api/items', '/notes?itemId=1']) {
      const response = await fetch(base + route);
      assert.equal(response.status, 200);
      assert.ok(Array.isArray(await response.json()));
    }
    // Negative security probes only; application clients expose GET exclusively.
    for (const method of ['POST', 'PUT', 'PATCH', 'DELETE']) {
      const response = await fetch(base + '/items/1', { method,
        headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ title: 'must not save' }) });
      assert.equal(response.status, 403, method);
    }
    assert.deepEqual(await (await fetch(base + '/items')).json(), JSON.parse(before).items);
    assert.equal(await fs.readFile(file, 'utf8'), before);
  } finally { await new Promise(resolve => server.close(resolve)); }
});
