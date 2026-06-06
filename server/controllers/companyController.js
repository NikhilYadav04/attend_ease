const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const companyModel = require("../models/company");
const employeeModel = require("../models/employee");
const reportModel = require("../models/attendance");
const staffCountModel = require("../models/staffCount");
const staffReportModel = require("../models/staffReport");

const SECRET = process.env.JWT_SECRET || "attend_ease_secret";

const generateCompanyID = () =>
  "CO" + crypto.randomBytes(5).toString("hex").toUpperCase();

const addCompany = async (req, res) => {
  try {
    const { companyName, companyHR, companyCity, HRNumber } = req.body;

    const companyFound = await companyModel.findOne({ companyName });
    if (companyFound) {
      return res.status(400).json({ success: false, message: "Company already exists" });
    }

    const phoneAsEmployee = await employeeModel.findOne({ employeeNumber: HRNumber });
    if (phoneAsEmployee) {
      return res.status(400).json({
        success: false,
        message: "This phone number is already registered as an employee.",
      });
    }

    const companyID = generateCompanyID();

    await companyModel.findOneAndUpdate(
      { companyName, companyHR, companyCity },
      { companyID, hrPhone: HRNumber, $push: { companyMembers: `${companyHR}_HR` } },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    await staffCountModel.create({ companyName, In: 0, Out: 0, Total: 0 });

    const token = jwt.sign(
      { companyName, companyID, type: "company" },
      SECRET,
      { expiresIn: "30d" }
    );

    return res.status(200).json({
      success: true,
      message: "Company created",
      data: { token, companyID },
    });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const getReport = async (req, res) => {
  try {
    const { companyName } = req.user;
    const reports = await reportModel.find({ employeeCompany: companyName }).lean();

    const names = reports.map((r) => r.employeeName);
    const employees = await employeeModel
      .find({ employeeName: { $in: names }, employeeCompany: companyName }, { employeeName: 1, employeeID: 1, _id: 0 })
      .lean();
    const idMap = {};
    for (const e of employees) idMap[e.employeeName] = e.employeeID;

    const body = reports.map((r) => ({ ...r, employeeID: idMap[r.employeeName] ?? "" }));
    return res.status(200).json({ success: true, message: "OK", data: body });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const storeHistory = async (req, res) => {
  try {
    const { totalCount, currentDate } = req.body;
    const { companyName } = req.user;

    await staffReportModel.findOneAndUpdate(
      { companyName },
      { $push: { list: { isSubmit: true, totalCount, currentDate } } },
      { new: true, upsert: true }
    );

    const body = await staffReportModel.findOne({ companyName });
    const countBody = await staffCountModel.findOne({ companyName });
    if (countBody) {
      countBody.In = 0;
      countBody.Out = 0;
      countBody.Total = 0;
      await countBody.save();
    }

    return res.status(200).json({ success: true, message: "History stored", data: body });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const getHistory = async (req, res) => {
  try {
    const { companyName } = req.user;
    const body = await staffReportModel.findOne({ companyName });
    return res.status(200).json({ success: true, message: "OK", data: body ? body.list : [] });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const historyList = async (req, res) => {
  try {
    const { companyName } = req.user;
    const body = await staffReportModel.findOne({ companyName });
    return res.status(200).json({ success: true, message: "OK", data: body ? body.list : [] });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const sendNotifications = async (req, res) => {
  try {
    const { employeeName } = req.body;
    const body = await employeeModel.findOne({ employeeName });
    return res.status(200).json({ success: true, message: "OK", data: body ? body.employeeNumber : null });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

module.exports = { addCompany, getReport, storeHistory, getHistory, historyList, sendNotifications };
