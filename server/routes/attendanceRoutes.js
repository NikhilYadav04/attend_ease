require("dotenv").config();

const express = require("express");
const reportModel = require("../models/attendance");
const attendanceRouter = express.Router();
attendanceRouter.use(express.json());

// mark attendance
attendanceRouter.post("/mark", async (req, res) => {
  try {
    const { employeeName, InTime, OutTime, Date, isPresent } = req.body;

    const report = await reportModel.findOneAndUpdate(
      { employeeName },
      { $inc: { daysPresent: 1 } },
      { new: true }
    );

    let attendanceBody = {
      InTime,
      OutTime,
      Date,
      isPresent,
    };

    await report.attendance.push(attendanceBody);

    await report.save();

    return res.status(200).json({
      success: true,
      message: report.daysPresent,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

//get attendance data
attendanceRouter.post("/get-attend", async (req, res) => {
  try {
    const { employeeName, Date } = req.body;

    const report = await reportModel.findOne({ employeeName });

    if (!report) {
      return res.status(400).json({
        success: false,
        message: "Doesn't Exists",
      });
    }

    const attendanceRecord = report.attendance.find((attend) => {
      // Compare the date strings directly
      return attend.Date === Date;
    });

    if (!attendanceRecord) {
      return res.status(400).json({
        success: false,
        message: "Doesn't Exists",
      });
    }

    return res.status(200).json({
      success: false,
      message: attendanceRecord,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

//get attendance count of days
attendanceRouter.post("/get-attend-days", async (req, res) => {
  try {
    const { employeeName } = req.body;

    const report = await reportModel.findOne({ employeeName });

    if (!report) {
      return res.status(400).json({
        success: false,
        message: "Doesn't Exists",
      });
    }

    const days = report['daysPresent'];

    return res.status(200).json({
      success: true,
      message: days,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

module.exports = attendanceRouter;
