const test = require("node:test");
const assert = require("node:assert/strict");
const app = require("../server");

test("GET /health returns application health information", async (t) => {
  const server = app.listen(0);
  await new Promise((resolve) => server.once("listening", resolve));
  t.after(() => new Promise((resolve, reject) => {
    server.close((error) => error ? reject(error) : resolve());
  }));

  const address = server.address();
  const response = await fetch(`http://127.0.0.1:${address.port}/health`);
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.application, "GridPulse");
  assert.equal(body.status, "healthy");
  assert.equal(body.version, "1.0.0");
  assert.equal(body.environment, "development");
});

test("GET /version returns the application version", async (t) => {
  const server = app.listen(0);
  await new Promise((resolve) => server.once("listening", resolve));
  t.after(() => new Promise((resolve, reject) => {
    server.close((error) => error ? reject(error) : resolve());
  }));

  const address = server.address();
  const response = await fetch(`http://127.0.0.1:${address.port}/version`);
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.application, "GridPulse");
  assert.equal(body.version, "1.0.0");
});

test("unknown routes return JSON 404 responses", async (t) => {
  const server = app.listen(0);
  await new Promise((resolve) => server.once("listening", resolve));
  t.after(() => new Promise((resolve, reject) => {
    server.close((error) => error ? reject(error) : resolve());
  }));

  const address = server.address();
  const response = await fetch(`http://127.0.0.1:${address.port}/does-not-exist`);
  const body = await response.json();

  assert.equal(response.status, 404);
  assert.equal(body.error, "Not Found");
});
