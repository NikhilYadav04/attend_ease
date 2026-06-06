const express = require("express");
const verifyToken = require("../middleware/auth");
const { requireFields } = require("../middleware/validate");
const { markIn, markOut, getAttend, getAttendDays } = require("../controllers/attendanceController");

const attendanceRouter = express.Router();

attendanceRouter.post("/mark-in",         verifyToken, requireFields("InTime", "Date"), markIn);
attendanceRouter.post("/mark-out",        verifyToken, requireFields("InTime", "OutTime", "Date"), markOut);
attendanceRouter.post("/get-attend",      verifyToken, requireFields("Date"), getAttend);
attendanceRouter.get("/get-attend-days",  verifyToken, getAttendDays);

module.exports = attendanceRouter;
