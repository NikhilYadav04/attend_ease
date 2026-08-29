const jwt = require("jsonwebtoken");
const prisma = require("../lib/prisma");
const { verifyOtpToken } = require("../middleware/auth");

const SECRET = process.env.JWT_SECRET;

const identify = async (req, res) => {
  try {
    const { phone, otpToken } = req.body;

    if (!otpToken || !verifyOtpToken(otpToken, phone)) {
      return res.status(401).json({
        success: false,
        message: "Phone not verified. Complete OTP verification first.",
      });
    }

    const admin = await prisma.companyAdmin.findUnique({
      where: { phone },
      include: { company: true },
    });
    if (admin) {
      const token = jwt.sign(
        { companyName: admin.company.companyName, companyID: admin.company.companyCode, type: "company" },
        SECRET,
        { expiresIn: "30d" }
      );
      return res.status(200).json({
        success: true,
        message: "Identified as HR",
        data: {
          role: "hr",
          companyName: admin.company.companyName,
          companyID: admin.company.companyCode,
          companyHR: admin.name,
          token,
        },
      });
    }

    const employee = await prisma.employee.findFirst({
      where: { employeeNumber: phone, deletedAt: null },
      include: { company: true },
    });
    if (employee) {
      const token = jwt.sign(
        { employeeName: employee.employeeName, employeeCompany: employee.company.companyName, type: "employee" },
        SECRET,
        { expiresIn: "30d" }
      );
      return res.status(200).json({
        success: true,
        message: "Identified as employee",
        data: {
          role: "employee",
          employeeName: employee.employeeName,
          employeeID: employee.employeeCode,
          employeeCompany: employee.company.companyName,
          token,
        },
      });
    }

    return res.status(200).json({ success: true, message: "No account found", data: { role: "none" } });
  } catch (e) {
    console.error("[identify]", e);
    return res.status(500).json({ success: false, message: "Identification failed" });
  }
};

module.exports = { identify };
