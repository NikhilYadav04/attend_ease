require("dotenv").config();

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const prisma = require("./lib/prisma");

const router = require("./routes/userRoutes");
const authRouter = require("./routes/authRoute");
const companyRouter = require("./routes/companyRoutes");
const locationRouter = require("./routes/locationRoute");
const employeeRouter = require("./routes/employeeRoute");
const attendanceRouter = require("./routes/attendanceRoutes");
const leaveRouter = require("./routes/leaveRoute");
const correctionRouter = require("./routes/correctionRoutes");
const holidayRouter = require("./routes/holidayRoutes");
const auditRouter = require("./routes/auditRoutes");

const app = express();

const PORT = process.env.PORT || 2000;

if (!process.env.JWT_SECRET) {
  console.error("FATAL: JWT_SECRET is not set");
  process.exit(1);
}
if (!process.env.DATABASE_URL) {
  console.error("FATAL: DATABASE_URL is not set");
  process.exit(1);
}

// ── Global middleware ─────────────────────────────────────────────────────────

app.use(helmet());

const allowedOrigins = (process.env.CORS_ORIGINS || "")
  .split(",")
  .map((s) => s.trim())
  .filter(Boolean);
app.use(cors(allowedOrigins.length ? { origin: allowedOrigins } : {}));

app.use(express.json({ limit: "64kb" }));
app.use(express.urlencoded({ extended: true, limit: "64kb" }));

const isProd = process.env.NODE_ENV === "production";

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: isProd ? 10 : 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: "Too many requests. Try again later." },
});

const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: isProd ? 300 : 2000,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: "Too many requests. Try again later." },
});

// Request logger
app.use((req, res, next) => {
  const start = Date.now();
  res.on("finish", () => {
    const ms = Date.now() - start;
    const status = res.statusCode;
    const color = status >= 500 ? "\x1b[31m" : status >= 400 ? "\x1b[33m" : "\x1b[32m";
    console.log(`${color}[${status}]\x1b[0m ${req.method} ${req.originalUrl} — ${ms}ms`);
  });
  next();
});

// ── Routes (v1) ───────────────────────────────────────────────────────────────

app.get("/health", async (req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.status(200).json({ status: "ok", db: true });
  } catch (e) {
    res.status(503).json({ status: "degraded", db: false });
  }
});

app.use("/api/v1/otp", authLimiter, router);
app.use("/api/v1/auth", authLimiter, authRouter);
app.use("/api/v1/company", generalLimiter, companyRouter);
app.use("/api/v1/location", generalLimiter, locationRouter);
app.use("/api/v1/employee", generalLimiter, employeeRouter);
app.use("/api/v1/attendance", generalLimiter, attendanceRouter);
app.use("/api/v1/leave", generalLimiter, leaveRouter);
app.use("/api/v1/correction", generalLimiter, correctionRouter);
app.use("/api/v1/holiday", generalLimiter, holidayRouter);
app.use("/api/v1/audit", generalLimiter, auditRouter);

// ── Global error handler ──────────────────────────────────────────────────────

// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error("[SERVER ERROR]", err);
  res.status(500).json({ success: false, message: "Internal server error" });
});

// ── Listen ─────────────────────────────────────────────────────────────────

app.listen(PORT, () => {
  console.log(`Server Connected At ${PORT}`);
});
