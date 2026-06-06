const leaveModel = require("../models/leave");

const requestLeave = async (req, res) => {
  try {
    const { leaveType, fromDate, toDate, reason } = req.body;
    const { employeeName, employeeCompany } = req.user;

    await leaveModel.create({ employeeName, employeeCompany, leaveType, fromDate, toDate, reason });
    return res.status(200).json({ success: true, message: "Leave requested" });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const myLeaves = async (req, res) => {
  try {
    const { employeeName } = req.user;
    const leaves = await leaveModel.find({ employeeName }).sort({ createdAt: -1 });
    return res.status(200).json({ success: true, message: "OK", data: leaves });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const pendingLeaves = async (req, res) => {
  try {
    const { companyName } = req.user;
    const leaves = await leaveModel
      .find({ employeeCompany: companyName, status: "Pending" })
      .sort({ createdAt: -1 });
    return res.status(200).json({ success: true, message: "OK", data: leaves });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const actionLeave = async (req, res) => {
  try {
    const { leaveId, action } = req.body;
    const status = action === "approve" ? "Approved" : "Rejected";
    await leaveModel.findByIdAndUpdate(leaveId, { status });
    return res.status(200).json({ success: true, message: `Leave ${status}` });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

module.exports = { requestLeave, myLeaves, pendingLeaves, actionLeave };
