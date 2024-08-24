const mongoose = require("mongoose");

const attendanceSchema = new mongoose.Schema({
  InTime: {
    required: true,
    type: String,
  },
  OutTime: {
    required: true,
    type: String,
  },
  Date: {
    required: true,
    type: String,
  },
  isPresent: {
    required: true,
    type: Boolean,
  },
});

const reportSchema = new mongoose.Schema({
  employeeName: {
    required: true,
    type: String,
  },
  employeeCompany: {
    required: true,
    type: String,
  },
  daysPresent: {
    required: true,
    type: Number,
  },
  attendance: [attendanceSchema],
});

const reportModel = mongoose.model("Report", reportSchema);
module.exports = reportModel;
