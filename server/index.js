require("dotenv").config();

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const rateLimit = require("express-rate-limit");

const router = require("./routes/userRoutes");
const authRouter = require("./routes/authRoute");
const companyRouter = require("./routes/companyRoutes");
const locationRouter = require("./routes/locationRoute");
const employeeRouter = require("./routes/employeeRoute");
const attendanceRouter = require("./routes/attendanceRoutes");
const leaveRouter = require("./routes/leaveRoute");

const app = express();

const PORT = process.env.PORT || 2000;
const DB = process.env.DB;

// ── Global middleware ─────────────────────────────────────────────────────────

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiter disabled for testing
// const authLimiter = rateLimit({
//   windowMs: 15 * 60 * 1000,
//   max: 10,
//   standardHeaders: true,
//   legacyHeaders: false,
//   message: { success: false, message: "Too many requests. Try again later." },
// });
const authLimiter = (req, res, next) => next(); // passthrough

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

app.use("/api/v1/otp", authLimiter, router);
app.use("/api/v1/auth", authRouter);
app.use("/api/v1/company", authLimiter, companyRouter);
app.use("/api/v1/location", locationRouter);
app.use("/api/v1/employee", employeeRouter);
app.use("/api/v1/attendance", attendanceRouter);
app.use("/api/v1/leave", leaveRouter);

// ── Global error handler ──────────────────────────────────────────────────────

// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error("[SERVER ERROR]", err);
  res.status(500).json({ success: false, message: "Internal server error" });
});

// ── Database + listen ─────────────────────────────────────────────────────────

mongoose
  .connect(DB)
  .then(() => {
    console.log("Connected To Mongoose");
  })
  .catch((e) => {
    console.log(e);
  });

app.listen(PORT, () => {
  console.log(`Server Connected At ${PORT}`);
});
