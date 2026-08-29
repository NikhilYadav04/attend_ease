require("dotenv").config();
const jwt = require("jsonwebtoken");
const prisma = require("../lib/prisma");

const SECRET = process.env.JWT_SECRET;
if (!SECRET) {
  console.error("FATAL: JWT_SECRET is not set. Server will not start.");
  process.exit(1);
}

function verifyToken(req, res, next) {
  const auth = req.headers["authorization"];
  if (!auth || !auth.startsWith("Bearer ")) {
    return res
      .status(401)
      .json({ success: false, message: "No token provided" });
  }
  const token = auth.split(" ")[1];
  try {
    req.user = jwt.verify(token, SECRET);
    next();
  } catch (e) {
    return res
      .status(401)
      .json({ success: false, message: "Invalid or expired token" });
  }
}

function requireRole(role) {
  return (req, res, next) => {
    if (!req.user || req.user.type !== role) {
      return res
        .status(403)
        .json({ success: false, message: "Forbidden for this role" });
    }
    next();
  };
}

function verifyOtpToken(otpToken, phone) {
  try {
    const decoded = jwt.verify(otpToken, SECRET);
    return decoded.purpose === "otp" && decoded.phone === phone;
  } catch (e) {
    return false;
  }
}

async function requireActiveEmployee(req, res, next) {
  try {
    const { employeeName, employeeCompany } = req.user;
    const company = await prisma.company.findUnique({ where: { companyName: employeeCompany } });
    const employee = company
      ? await prisma.employee.findUnique({
          where: { employeeName_companyId: { employeeName, companyId: company.id } },
        })
      : null;

    if (!employee || employee.deletedAt) {
      return res.status(401).json({ success: false, message: "Account deactivated" });
    }
    next();
  } catch (e) {
    return res.status(500).json({ success: false, message: "Failed to verify account status" });
  }
}

module.exports = verifyToken;
module.exports.requireRole = requireRole;
module.exports.verifyOtpToken = verifyOtpToken;
module.exports.requireActiveEmployee = requireActiveEmployee;
