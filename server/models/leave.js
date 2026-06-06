const mongoose = require("mongoose");

const leaveSchema = new mongoose.Schema({
  employeeName: { type: String, required: true },
  employeeCompany: { type: String, required: true },
  leaveType: { type: String, required: true },
  fromDate: { type: String, required: true },
  toDate: { type: String, required: true },
  reason: { type: String, required: true },
  status: { type: String, default: "Pending" },
  createdAt: { type: Date, default: Date.now },
});

leaveSchema.index({ employeeCompany: 1, status: 1 });
leaveSchema.index({ employeeName: 1 });

const leaveModel = mongoose.model("leave", leaveSchema);
module.exports = leaveModel;
