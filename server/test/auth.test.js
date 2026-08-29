process.env.JWT_SECRET = "test-secret-for-unit-tests";

const { test } = require("node:test");
const assert = require("node:assert");
const jwt = require("jsonwebtoken");
const verifyToken = require("../middleware/auth");
const { requireRole, verifyOtpToken } = require("../middleware/auth");

const SECRET = process.env.JWT_SECRET;

function mockRes() {
  return {
    statusCode: null,
    body: null,
    status(c) {
      this.statusCode = c;
      return this;
    },
    json(b) {
      this.body = b;
      return this;
    },
  };
}

test("verifyOtpToken: accepts valid token bound to same phone", () => {
  const token = jwt.sign({ phone: "9999999999", purpose: "otp" }, SECRET, { expiresIn: "10m" });
  assert.strictEqual(verifyOtpToken(token, "9999999999"), true);
});

test("verifyOtpToken: rejects token for a different phone", () => {
  const token = jwt.sign({ phone: "9999999999", purpose: "otp" }, SECRET, { expiresIn: "10m" });
  assert.strictEqual(verifyOtpToken(token, "8888888888"), false);
});

test("verifyOtpToken: rejects auth tokens reused as OTP proof", () => {
  const token = jwt.sign({ employeeName: "X", type: "employee" }, SECRET, { expiresIn: "30d" });
  assert.strictEqual(verifyOtpToken(token, "9999999999"), false);
});

test("verifyOtpToken: rejects expired token", () => {
  const token = jwt.sign({ phone: "9999999999", purpose: "otp" }, SECRET, { expiresIn: "-1s" });
  assert.strictEqual(verifyOtpToken(token, "9999999999"), false);
});

test("verifyOtpToken: rejects token signed with wrong secret", () => {
  const token = jwt.sign({ phone: "9999999999", purpose: "otp" }, "other-secret", { expiresIn: "10m" });
  assert.strictEqual(verifyOtpToken(token, "9999999999"), false);
});

test("requireRole: allows matching role", () => {
  const res = mockRes();
  let called = false;
  requireRole("company")({ user: { type: "company" } }, res, () => (called = true));
  assert.strictEqual(called, true);
});

test("requireRole: 403 for employee hitting HR route", () => {
  const res = mockRes();
  let called = false;
  requireRole("company")({ user: { type: "employee" } }, res, () => (called = true));
  assert.strictEqual(called, false);
  assert.strictEqual(res.statusCode, 403);
});

test("requireRole: 403 when user missing", () => {
  const res = mockRes();
  let called = false;
  requireRole("employee")({}, res, () => (called = true));
  assert.strictEqual(called, false);
  assert.strictEqual(res.statusCode, 403);
});

test("verifyToken: 401 without Authorization header", () => {
  const res = mockRes();
  let called = false;
  verifyToken({ headers: {} }, res, () => (called = true));
  assert.strictEqual(called, false);
  assert.strictEqual(res.statusCode, 401);
});

test("verifyToken: decodes valid Bearer token onto req.user", () => {
  const token = jwt.sign({ companyName: "Acme", type: "company" }, SECRET, { expiresIn: "1h" });
  const req = { headers: { authorization: `Bearer ${token}` } };
  const res = mockRes();
  let called = false;
  verifyToken(req, res, () => (called = true));
  assert.strictEqual(called, true);
  assert.strictEqual(req.user.companyName, "Acme");
});
