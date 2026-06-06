const jwt = require("jsonwebtoken");
const employeeModel = require("../models/employee");
const companyModel = require("../models/company");
const reportModel = require("../models/attendance");
const staffCountModel = require("../models/staffCount");

const SECRET = process.env.JWT_SECRET || "attend_ease_secret";

const addEmployee = async (req, res) => {
  try {
    const { employeeName, employeeNumber, employeePosition } = req.body;
    const { companyName, companyID } = req.user;

    const phoneAsHR = await companyModel.findOne({ hrPhone: employeeNumber });
    if (phoneAsHR) {
      return res.status(400).json({
        success: false,
        message: "This phone number is already registered as an HR.",
      });
    }

    const body = await employeeModel.findOneAndUpdate(
      { employeeName, employeeNumber, employeePosition, employeeCompany: companyName },
      { employeeID: `${employeeName}_${companyID}` },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    await companyModel.updateOne(
      { companyID },
      { $push: { companyMembers: `${employeeName}_${companyName}` } }
    );

    await reportModel.create({ employeeName, employeeCompany: companyName, daysPresent: 0, attendance: [] });

    return res.status(200).json({ success: true, message: "Employee added", data: body });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const joinEmployee = async (req, res) => {
  try {
    const { companyName, employeeID, employeeName } = req.body;

    const company = await companyModel.findOne({ companyName });
    if (!company) {
      return res.status(401).json({ success: false, message: "Company not found" });
    }

    const employee = await employeeModel.findOne({ employeeName, employeeCompany: companyName });
    if (!employee) {
      return res.status(401).json({ success: false, message: "Employee not registered in this company" });
    }

    const token = jwt.sign(
      { employeeName, employeeCompany: companyName, type: "employee" },
      SECRET,
      { expiresIn: "30d" }
    );

    return res.status(200).json({ success: true, message: "Joined", data: { token } });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const getHistory = async (req, res) => {
  try {
    const { employeeName } = req.user;
    const body = await reportModel.findOne({ employeeName });
    return res.status(200).json({ success: true, message: "OK", data: body ? body.attendance : [] });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const changeCount = async (req, res) => {
  try {
    const { inCount, outCount, TotalCount } = req.body;
    const { employeeCompany } = req.user;

    const updated = await staffCountModel.findOneAndUpdate(
      { companyName: employeeCompany },
      { $inc: { In: inCount, Out: outCount, Total: TotalCount } },
      { new: true }
    );

    return res.status(200).json({ success: true, message: "Count updated", data: updated });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const getCount = async (req, res) => {
  try {
    const { companyName } = req.user;
    const body = await staffCountModel.findOne({ companyName });
    return res.status(200).json({ success: true, message: "OK", data: body });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

module.exports = { addEmployee, joinEmployee, getHistory, changeCount, getCount };
