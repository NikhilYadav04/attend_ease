const jwt = require("jsonwebtoken");
const companyModel = require("../models/company");
const employeeModel = require("../models/employee");

const SECRET = process.env.JWT_SECRET || "attend_ease_secret";

const identify = async (req, res) => {
  try {
    const { phone } = req.body;

    const company = await companyModel.findOne({ hrPhone: phone });
    if (company) {
      const token = jwt.sign(
        { companyName: company.companyName, companyID: company.companyID, type: "company" },
        SECRET,
        { expiresIn: "30d" }
      );
      return res.status(200).json({
        success: true,
        message: "Identified as HR",
        data: { role: "hr", companyName: company.companyName, companyID: company.companyID, companyHR: company.companyHR, token },
      });
    }

    const employee = await employeeModel.findOne({ employeeNumber: phone });
    if (employee) {
      const token = jwt.sign(
        { employeeName: employee.employeeName, employeeCompany: employee.employeeCompany, type: "employee" },
        SECRET,
        { expiresIn: "30d" }
      );
      return res.status(200).json({
        success: true,
        message: "Identified as employee",
        data: {
          role: "employee",
          employeeName: employee.employeeName,
          employeeID: employee.employeeID,
          employeeCompany: employee.employeeCompany,
          token,
        },
      });
    }

    return res.status(200).json({ success: true, message: "No account found", data: { role: "none" } });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

module.exports = { identify };
