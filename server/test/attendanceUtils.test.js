const { test } = require("node:test");
const assert = require("node:assert");
const { serverNow, distanceMeters } = require("../utils/attendanceUtils");

test("distanceMeters: zero for identical points", () => {
  assert.strictEqual(distanceMeters(19.076, 72.8777, 19.076, 72.8777), 0);
});

test("distanceMeters: known distance Mumbai to Delhi ~1150km", () => {
  const d = distanceMeters(19.076, 72.8777, 28.7041, 77.1025);
  assert.ok(d > 1_100_000 && d < 1_200_000, `got ${d}`);
});

test("distanceMeters: ~111m for 0.001 deg latitude", () => {
  const d = distanceMeters(19.0, 72.0, 19.001, 72.0);
  assert.ok(d > 105 && d < 118, `got ${d}`);
});

test("distanceMeters: 60m offset is inside a 100m radius", () => {
  const d = distanceMeters(19.076, 72.8777, 19.07654, 72.8777);
  assert.ok(d < 100, `got ${d}`);
});

test("serverNow: returns HH:mm and dd/MM/yy shapes", () => {
  const { time, date } = serverNow("Asia/Kolkata");
  assert.match(time, /^([01]\d|2[0-3]):[0-5]\d$/);
  assert.match(date, /^\d{2}\/\d{2}\/\d{2}$/);
});

test("serverNow: never emits hour 24", () => {
  const { time } = serverNow("Asia/Kolkata");
  assert.ok(!time.startsWith("24"), `got ${time}`);
});
