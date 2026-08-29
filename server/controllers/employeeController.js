const jwt = require("jsonwebtoken");
const prisma = require("../lib/prisma");
const { verifyOtpToken } = require("../middleware/auth");
const { attendanceRecordJSON, staffCountJSON } = require("../lib/serializers");
const { logAction } = require("./auditController");

const SECRET = process.env.JWT_SECRET;

async function addOneEmployee(company, companyID, { employeeName, employeeNumber, employeePosition }) {
  const phoneAsHR = await prisma.companyAdmin.findUnique({ where: { phone: employeeNumber } });
  if (phoneAsHR) {
    return { ok: false, message: "This phone number is already registered as an HR." };
  }

  const employeeCode = `${employeeName}_${companyID}`;
  const employee = await prisma.employee.upsert({
    where: { employeeName_companyId: { employeeName, companyId: company.id } },
    update: { employeeNumber, employeePosition, employeeCode, deletedAt: null },
    create: { employeeName, employeeNumber, employeePosition, employeeCode, companyId: company.id },
  });
  return { ok: true, employee };
}

const addEmployee = async (req, res) => {
  try {
    const { employeeName, employeeNumber, employeePosition } = req.body;
    const { companyName, companyID } = req.user;

    const company = await prisma.company.findUnique({ where: { companyName } });
    if (!company) {
      return res.status(404).json({ success: false, message: "Company not found" });
    }

    const result = await addOneEmployee(company, companyID, { employeeName, employeeNumber, employeePosition });
    if (!result.ok) {
      return res.status(400).json({ success: false, message: result.message });
    }

    await logAction(company.id, companyName, "employee_added", employeeName);

    const body = {
      employeeName: result.employee.employeeName,
      employeeNumber: result.employee.employeeNumber,
      employeePosition: result.employee.employeePosition,
      employeeID: result.employee.employeeCode,
      employeeCompany: company.companyName,
    };

    return res.status(200).json({ success: true, message: "Employee added", data: body });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const bulkAddEmployees = async (req, res) => {
  try {
    const { employees } = req.body;
    const { companyName, companyID } = req.user;

    if (!Array.isArray(employees) || employees.length === 0) {
      return res.status(400).json({ success: false, message: "employees must be a non-empty array" });
    }

    const company = await prisma.company.findUnique({ where: { companyName } });
    if (!company) {
      return res.status(404).json({ success: false, message: "Company not found" });
    }

    const results = [];
    for (let i = 0; i < employees.length; i++) {
      const row = employees[i] || {};
      const { employeeName, employeeNumber, employeePosition } = row;
      if (!employeeName || !employeeNumber || !employeePosition) {
        results.push({
          row: i + 1,
          employeeName: employeeName || "",
          success: false,
          message: "Missing required fields",
        });
        continue;
      }
      try {
        const result = await addOneEmployee(company, companyID, { employeeName, employeeNumber, employeePosition });
        results.push({
          row: i + 1,
          employeeName,
          success: result.ok,
          message: result.ok ? "Added" : result.message,
        });
      } catch (e) {
        results.push({ row: i + 1, employeeName, success: false, message: e.message });
      }
    }

    const succeeded = results.filter((r) => r.success).length;
    await logAction(company.id, companyName, "bulk_import", `${succeeded} of ${results.length} rows added`);

    return res.status(200).json({ success: true, message: "Bulk import processed", data: results });
  } catch (e) {
    console.error("[bulkAddEmployees]", e);
    return res.status(500).json({ success: false, message: "Bulk import failed" });
  }
};

const joinEmployee = async (req, res) => {
  try {
    const { companyName, employeeID, employeeName, otpToken } = req.body;

    const company = await prisma.company.findUnique({ where: { companyName } });
    if (!company) {
      return res.status(404).json({ success: false, message: "Company not found" });
    }

    const employee = await prisma.employee.findUnique({
      where: { employeeName_companyId: { employeeName, companyId: company.id } },
    });
    if (!employee || employee.deletedAt) {
      return res.status(404).json({ success: false, message: "Employee not registered in this company" });
    }

    if (employee.employeeCode !== employeeID) {
      return res.status(401).json({ success: false, message: "Invalid Employee ID" });
    }

    if (!otpToken || !verifyOtpToken(otpToken, employee.employeeNumber)) {
      return res.status(401).json({
        success: false,
        message: "Phone not verified for this employee. Login with the phone number registered by your HR.",
      });
    }

    const token = jwt.sign(
      { employeeName, employeeCompany: companyName, type: "employee" },
      SECRET,
      { expiresIn: "30d" }
    );

    return res.status(200).json({ success: true, message: "Joined", data: { token } });
  } catch (e) {
    console.error("[joinEmployee]", e);
    return res.status(500).json({ success: false, message: "Join failed" });
  }
};

const getHistory = async (req, res) => {
  try {
    const { employeeName, employeeCompany } = req.user;
    const company = await prisma.company.findUnique({ where: { companyName: employeeCompany } });
    const employee = company
      ? await prisma.employee.findUnique({
          where: { employeeName_companyId: { employeeName, companyId: company.id } },
          include: { attendance: true },
        })
      : null;

    return res.status(200).json({
      success: true,
      message: "OK",
      data: employee
        ? employee.attendance.map((a) => attendanceRecordJSON(a, company.overtimeThresholdMinutes))
        : [],
    });
  } catch (e) {
    console.error("[getHistory]", e);
    return res.status(500).json({ success: false, message: "Request failed" });
  }
};

const changeCount = async (req, res) => {
  try {
    const { inCount, outCount, TotalCount } = req.body;
    const { employeeCompany } = req.user;

    const values = [inCount, outCount, TotalCount].map(Number);
    if (values.some((v) => !Number.isInteger(v) || v < 0 || v > 1)) {
      return res.status(400).json({ success: false, message: "Counts must be 0 or 1" });
    }

    const company = await prisma.company.findUnique({ where: { companyName: employeeCompany } });
    if (!company) {
      return res.status(404).json({ success: false, message: "Company not found" });
    }

    const updated = await prisma.staffCount.update({
      where: { companyId: company.id },
      data: {
        inCount: { increment: values[0] },
        outCount: { increment: values[1] },
        total: { increment: values[2] },
      },
    });

    return res.status(200).json({ success: true, message: "Count updated", data: staffCountJSON(updated) });
  } catch (e) {
    console.error("[changeCount]", e);
    return res.status(500).json({ success: false, message: "Count update failed" });
  }
};

const getCount = async (req, res) => {
  try {
    const { companyName } = req.user;
    const company = await prisma.company.findUnique({ where: { companyName } });
    const body = company
      ? await prisma.staffCount.findUnique({ where: { companyId: company.id } })
      : null;

    return res.status(200).json({ success: true, message: "OK", data: body ? staffCountJSON(body) : null });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const removeEmployee = async (req, res) => {
  try {
    const { employeeName } = req.body;
    const { companyName } = req.user;

    const company = await prisma.company.findUnique({ where: { companyName } });
    if (!company) {
      return res.status(404).json({ success: false, message: "Company not found" });
    }

    const employee = await prisma.employee.findUnique({
      where: { employeeName_companyId: { employeeName, companyId: company.id } },
    });
    if (!employee) {
      return res.status(404).json({ success: false, message: "Employee not found" });
    }
    if (employee.deletedAt) {
      return res.status(200).json({ success: true, message: "Employee already removed" });
    }

    await prisma.employee.update({
      where: { id: employee.id },
      data: { deletedAt: new Date() },
    });
    await logAction(company.id, companyName, "employee_removed", employeeName);

    return res.status(200).json({ success: true, message: "Employee removed" });
  } catch (e) {
    console.error("[removeEmployee]", e);
    return res.status(500).json({ success: false, message: "Failed to remove employee" });
  }
};

module.exports = {
  addEmployee,
  bulkAddEmployees,
  joinEmployee,
  getHistory,
  changeCount,
  getCount,
  removeEmployee,
};
