const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const os = require('node:os');
const path = require('node:path');
const jsonServer = require('json-server');

// Use a disposable database: never mutate the checked-in sample or a user's DB.
test('POST/PATCH, soft delete and undo survive a real json-server restart', async () => {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), 'polarsteps-'));
  const file = path.join(directory, 'db.json');
  await fs.copyFile(path.join(__dirname, '..', 'db.json'), file);
  let server;
  let base;
  async function start() {
    const app = jsonServer.create();
    app.use(jsonServer.defaults({ logger: false }));
    app.use(jsonServer.bodyParser);
    app.use(jsonServer.router(file)); // Same file-backed router as the CLI.
    server = await new Promise(resolve => {
      const listener = app.listen(0, '127.0.0.1', () => resolve(listener));
    });
    base = `http://127.0.0.1:${server.address().port}`;
  }
  async function stop() {
    if (!server) return;
    await new Promise((resolve, reject) => server.close(error => error ? reject(error) : resolve()));
    server = null;
  }
  async function request(method, route, body) {
    const response = await fetch(base + route, { method,
      headers: { 'Content-Type': 'application/json' }, body: body ? JSON.stringify(body) : undefined });
    assert.ok(response.ok, `${method} ${route}: ${response.status}`);
    return response.json();
  }
  try {
    await start();
    const created = await request('POST', '/items', { title: 'New trip', subtitle: '', image: '',
      destination: 'Seoul', countryCode: 'KR', startDate: '2026-01-01', endDate: '2026-01-03',
      favorite: false, deleted: false, tags: [] });
    assert.ok(Number.isInteger(created.id));
    const route = `/items/${created.id}`;
    await request('PATCH', route, { title: 'Edited trip', destination: 'Tokyo', countryCode: 'JP',
      startDate: '2026-02-01', endDate: '2026-02-05', favorite: true });
    await stop(); await start();
    let restored = await request('GET', route);
    assert.equal(restored.title, 'Edited trip');
    assert.equal(restored.favorite, true);
    assert.equal(restored.destination, 'Tokyo');
    assert.equal(restored.startDate, '2026-02-01');
    assert.equal(restored.endDate, '2026-02-05');
    await request('PATCH', route, { deleted: true });
    await stop(); await start();
    assert.ok(!(await request('GET', '/items?deleted_ne=true')).some(x => x.id === created.id));
    assert.equal((await request('GET', route)).deleted, true);
    await request('PATCH', route, { deleted: false });
    await stop(); await start();
    restored = (await request('GET', '/items?deleted_ne=true')).find(x => x.id === created.id);
    assert.equal(restored.favorite, true);
    assert.equal(restored.countryCode, 'JP');
    const disk = JSON.parse(await fs.readFile(file, 'utf8'));
    assert.equal(disk.items.find(x => x.id === created.id).deleted, false);
    assert.equal(disk.notes.length, 7);
  } finally {
    await stop();
    await fs.rm(directory, { recursive: true, force: true });
  }
});
