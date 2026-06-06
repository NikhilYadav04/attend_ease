const reportModel = require("../models/attendance");

const markIn = async (req, res) => {
  try {
    const { InTime, Date } = req.body;
    const { employeeName } = req.user;

    const report = await reportModel.findOneAndUpdate(
      { employeeName },
      { $push: { attendance: { InTime, OutTime: "00:00", Date, isPresent: false } } },
      { new: true }
    );

    if (!report) {
      return res.status(404).json({ success: false, message: "Employee record not found" });
    }

    return res.status(200).json({ success: true, message: "Punched in" });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const markOut = async (req, res) => {
  try {
    const { InTime, OutTime, Date } = req.body;
    const { employeeName } = req.user;

    const report = await reportModel.findOne({ employeeName });
    if (!report) {
      return res.status(404).json({ success: false, message: "Employee record not found" });
    }

    const record = report.attendance.find((a) => a.Date === Date);
    if (record) {
      record.InTime = InTime;
      record.OutTime = OutTime;
      record.isPresent = true;
    } else {
      report.attendance.push({ InTime, OutTime, Date, isPresent: true });
    }

    report.daysPresent += 1;
    await report.save();

    return res.status(200).json({ success: true, message: "Punched out", data: { totalDays: report.daysPresent } });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const getAttend = async (req, res) => {
  try {
    const { Date } = req.body;
    const { employeeName } = req.user;

    const report = await reportModel.findOne({ employeeName });
    if (!report) {
      return res.status(400).json({ success: false, message: "Record not found" });
    }

    const attendanceRecord = report.attendance.find((a) => a.Date === Date);
    if (!attendanceRecord) {
      return res.status(400).json({ success: false, message: "No record for this date" });
    }

    return res.status(200).json({ success: true, message: "OK", data: attendanceRecord });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const getAttendDays = async (req, res) => {
  try {
    const { employeeName } = req.user;
    const report = await reportModel.findOne({ employeeName });

    if (!report) {
      return res.status(400).json({ success: false, message: "Record not found" });
    }

    return res.status(200).json({ success: true, message: "OK", data: [{ daysPresent: report.daysPresent }] });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

module.exports = { markIn, markOut, getAttend, getAttendDays };
