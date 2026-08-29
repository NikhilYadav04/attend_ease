const express = require("express");
const verifyToken = require("../middleware/auth");
const { requireRole, requireActiveEmployee } = require("../middleware/auth");
const { requireFields } = require("../middleware/validate");
const { markIn, markOut, getAttend, getAttendDays } = require("../controllers/attendanceController");

const attendanceRouter = express.Router();
const employeeOnly = [verifyToken, requireRole("employee"), requireActiveEmployee];

attendanceRouter.post("/mark-in",         employeeOnly, requireFields("latitude", "longitude"), markIn);
attendanceRouter.post("/mark-out",        employeeOnly, requireFields("latitude", "longitude"), markOut);
attendanceRouter.post("/get-attend",      employeeOnly, requireFields("Date"), getAttend);
attendanceRouter.get("/get-attend-days",  employeeOnly, getAttendDays);

module.exports = attendanceRouter;
