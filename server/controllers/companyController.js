const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const prisma = require("../lib/prisma");
const { verifyOtpToken } = require("../middleware/auth");
const { attendanceRecordJSON } = require("../lib/serializers");
const { parseDdMmYy, formatDdMmYy, expandDateRange } = require("../utils/dateUtils");
const { workedMinutes } = require("../utils/timeUtils");
const { logAction } = require("./auditController");

const SECRET = process.env.JWT_SECRET;

const generateCompanyID = () =>
  "CO" + crypto.randomBytes(5).toString("hex").toUpperCase();

const addCompany = async (req, res) => {
  try {
    const { companyName, companyHR, companyCity, HRNumber, otpToken } = req.body;

    if (!otpToken || !verifyOtpToken(otpToken, HRNumber)) {
      return res.status(401).json({
        success: false,
        message: "Phone not verified. Complete OTP verification first.",
      });
    }

    const companyFound = await prisma.company.findUnique({ where: { companyName } });
    if (companyFound) {
      return res.status(400).json({ success: false, message: "Company already exists" });
    }

    const phoneAsEmployee = await prisma.employee.findUnique({ where: { employeeNumber: HRNumber } });
    if (phoneAsEmployee) {
      return res.status(400).json({
        success: false,
        message: "This phone number is already registered as an employee.",
      });
    }

    const companyCode = generateCompanyID();

    const company = await prisma.$transaction(async (tx) => {
      const created = await tx.company.create({
        data: { companyName, companyHr: companyHR, companyCity, companyCode, hrPhone: HRNumber },
      });
      await tx.staffCount.create({ data: { companyId: created.id } });
      await tx.companyAdmin.create({
        data: { companyId: created.id, name: companyHR, phone: HRNumber },
      });
      return created;
    });

    const token = jwt.sign(
      { companyName, companyID: company.companyCode, type: "company" },
      SECRET,
      { expiresIn: "30d" }
    );

    return res.status(200).json({
      success: true,
      message: "Company created",
      data: { token, companyID: company.companyCode },
    });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const getReport = async (req, res) => {
  try {
    const { companyName } = req.user;
    const company = await prisma.company.findUnique({ where: { companyName } });
    if (!company) {
      return res.status(200).json({ success: true, message: "OK", data: [] });
    }

    const employees = await prisma.employee.findMany({
      where: { companyId: company.id, deletedAt: null },
      include: { attendance: true, leaves: { where: { status: "Approved" } } },
    });

    const body = employees.map((e) => {
      const onLeaveDates = [
        ...new Set(e.leaves.flatMap((lv) => expandDateRange(lv.fromDate, lv.toDate))),
      ];
      return {
        employeeName: e.employeeName,
        employeeCompany: company.companyName,
        employeeID: e.employeeCode,
        daysPresent: e.attendance.filter((a) => a.isPresent).length,
        attendance: e.attendance.map((a) => attendanceRecordJSON(a, company.overtimeThresholdMinutes)),
        onLeaveDates,
        leaveQuota: e.leaveQuota,
        leaveUsed: onLeaveDates.length,
      };
    });

    return res.status(200).json({ success: true, message: "OK", data: body });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const storeHistory = async (req, res) => {
  try {
    const { totalCount, currentDate } = req.body;
    const { companyName } = req.user;

    const company = await prisma.company.findUnique({ where: { companyName } });
    if (!company) {
      return res.status(404).json({ success: false, message: "Company not found" });
    }

    const totalEmployees = await prisma.employee.count({
      where: { companyId: company.id, deletedAt: null },
    });

    await prisma.staffReportEntry.create({
      data: {
        companyId: company.id,
        isSubmit: true,
        totalCount: Number(totalCount),
        totalEmployees,
        currentDate,
      },
    });

    const list = await prisma.staffReportEntry.findMany({ where: { companyId: company.id } });

    await prisma.staffCount.update({
      where: { companyId: company.id },
      data: { inCount: 0, outCount: 0, total: 0 },
    });

    return res.status(200).json({ success: true, message: "History stored", data: { companyName, list } });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const getHistory = async (req, res) => {
  try {
    const { companyName } = req.user;
    const company = await prisma.company.findUnique({ where: { companyName } });
    const list = company
      ? await prisma.staffReportEntry.findMany({ where: { companyId: company.id } })
      : [];
    return res.status(200).json({ success: true, message: "OK", data: list });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const historyList = async (req, res) => {
  try {
    const { companyName } = req.user;
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit) || 20));
    const company = await prisma.company.findUnique({ where: { companyName } });

    if (!company) {
      return res.status(200).json({
        success: true,
        message: "OK",
        data: { items: [], page, totalPages: 1, totalCount: 0 },
      });
    }

    const [list, totalCount] = await Promise.all([
      prisma.staffReportEntry.findMany({
        where: { companyId: company.id },
        orderBy: { createdAt: "desc" },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.staffReportEntry.count({ where: { companyId: company.id } }),
    ]);

    return res.status(200).json({
      success: true,
      message: "OK",
      data: {
        items: list,
        page,
        totalPages: Math.max(1, Math.ceil(totalCount / limit)),
        totalCount,
      },
    });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const sendNotifications = async (req, res) => {
  try {
    const { employeeName } = req.body;
    const { companyName } = req.user;

    const company = await prisma.company.findUnique({ where: { companyName } });
    const employee = company
      ? await prisma.employee.findUnique({
          where: { employeeName_companyId: { employeeName, companyId: company.id } },
        })
      : null;

    return res.status(200).json({
      success: true,
      message: "OK",
      data: employee && !employee.deletedAt ? employee.employeeNumber : null,
    });
  } catch (e) {
    console.error("[sendNotifications]", e);
    return res.status(500).json({ success: false, message: "Request failed" });
  }
};

const addAdmin = async (req, res) => {
  try {
    const { name, phone } = req.body;
    const { companyName } = req.user;

    const company = await prisma.company.findUnique({ where: { companyName } });
    if (!company) {
      return res.status(404).json({ success: false, message: "Company not found" });
    }

    const phoneAsEmployee = await prisma.employee.findUnique({ where: { employeeNumber: phone } });
    if (phoneAsEmployee) {
      return res.status(400).json({
        success: false,
        message: "This phone number is already registered as an employee.",
      });
    }

    const phoneAsAdmin = await prisma.companyAdmin.findUnique({ where: { phone } });
    if (phoneAsAdmin) {
      return res.status(400).json({
        success: false,
        message: "This phone number is already registered as an admin.",
      });
    }

    const admin = await prisma.companyAdmin.create({
      data: { companyId: company.id, name, phone },
    });

    await logAction(company.id, companyName, "admin_added", `${name} (${phone})`);

    return res.status(200).json({
      success: true,
      message: "Admin added",
      data: { id: admin.id, name: admin.name, phone: admin.phone },
    });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const listAdmins = async (req, res) => {
  try {
    const { companyName } = req.user;
    const company = await prisma.company.findUnique({ where: { companyName } });
    const admins = company
      ? await prisma.companyAdmin.findMany({ where: { companyId: company.id } })
      : [];

    return res.status(200).json({
      success: true,
      message: "OK",
      data: admins.map((a) => ({ id: a.id, name: a.name, phone: a.phone })),
    });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const removeAdmin = async (req, res) => {
  try {
    const { phone } = req.body;
    const { companyName } = req.user;

    const company = await prisma.company.findUnique({ where: { companyName } });
    if (!company) {
      return res.status(404).json({ success: false, message: "Company not found" });
    }

    const admin = await prisma.companyAdmin.findFirst({ where: { phone, companyId: company.id } });
    if (!admin) {
      return res.status(404).json({ success: false, message: "Admin not found for your company" });
    }

    const adminCount = await prisma.companyAdmin.count({ where: { companyId: company.id } });
    if (adminCount <= 1) {
      return res.status(400).json({ success: false, message: "A company must have at least one admin" });
    }

    await prisma.companyAdmin.delete({ where: { id: admin.id } });
    await logAction(company.id, companyName, "admin_removed", `${admin.name} (${admin.phone})`);

    return res.status(200).json({ success: true, message: "Admin removed" });
  } catch (e) {
    console.error("[removeAdmin]", e);
    return res.status(500).json({ success: false, message: "Failed to remove admin" });
  }
};

const getAnalytics = async (req, res) => {
  try {
    const { companyName } = req.user;
    const company = await prisma.company.findUnique({ where: { companyName } });
    if (!company) {
      return res.status(200).json({
        success: true,
        message: "OK",
        data: { trend: [], pendingLeaves: 0, approvedThisMonth: 0, lateThisWeek: 0, hoursThisWeek: 0 },
      });
    }

    const employees = await prisma.employee.findMany({
      where: { companyId: company.id, deletedAt: null },
      select: { id: true },
    });
    const employeeIds = employees.map((e) => e.id);

    const records = await prisma.attendanceRecord.findMany({
      where: { employeeId: { in: employeeIds } },
      select: { date: true, isPresent: true, isLate: true, inTime: true, outTime: true },
    });

    const now = new Date();
    const queryMonth = parseInt(req.query.month, 10);
    const queryYear = parseInt(req.query.year, 10);
    const month = queryMonth >= 1 && queryMonth <= 12 ? queryMonth : now.getMonth() + 1;
    const year = queryYear >= 2000 ? queryYear : now.getFullYear();
    const isCurrentMonth = year === now.getFullYear() && month === now.getMonth() + 1;
    const daysInMonth = new Date(year, month, 0).getDate();
    const lastDay = isCurrentMonth ? now.getDate() : daysInMonth;

    const byDate = new Map();
    for (const r of records) {
      const d = parseDdMmYy(r.date);
      if (!d || d.getFullYear() !== year || d.getMonth() !== month - 1) continue;
      const entry = byDate.get(r.date) || { date: r.date, present: 0, late: 0, total: 0 };
      entry.total += 1;
      if (r.isPresent) entry.present += 1;
      if (r.isLate) entry.late += 1;
      byDate.set(r.date, entry);
    }

    // Every day of the month up to today (or month end), so the chart is
    // evenly spaced and short/sparse months don't look broken.
    const trend = [];
    for (let d = 1; d <= lastDay; d++) {
      const dateStr = formatDdMmYy(new Date(year, month - 1, d));
      trend.push(byDate.get(dateStr) || { date: dateStr, present: 0, late: 0, total: 0 });
    }

    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
    const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    const pendingLeaves = await prisma.leave.count({
      where: { companyId: company.id, status: "Pending" },
    });
    const approvedThisMonth = await prisma.leave.count({
      where: { companyId: company.id, status: "Approved", createdAt: { gte: monthStart } },
    });
    const lateThisWeek = records.filter((r) => {
      if (!r.isLate) return false;
      const d = parseDdMmYy(r.date);
      return d && d >= weekAgo;
    }).length;

    const hoursThisWeek = records.reduce((sum, r) => {
      const d = parseDdMmYy(r.date);
      if (!d || d < weekAgo) return sum;
      const minutes = workedMinutes(r.inTime, r.outTime);
      return minutes ? sum + minutes / 60 : sum;
    }, 0);

    return res.status(200).json({
      success: true,
      message: "OK",
      data: {
        trend,
        month,
        year,
        pendingLeaves,
        approvedThisMonth,
        lateThisWeek,
        hoursThisWeek: Math.round(hoursThisWeek * 10) / 10,
      },
    });
  } catch (e) {
    console.error("[getAnalytics]", e);
    return res.status(500).json({ success: false, message: "Failed to load analytics" });
  }
};

const getCompanySettings = async (req, res) => {
  try {
    const { companyName } = req.user;
    const company = await prisma.company.findUnique({ where: { companyName } });
    if (!company) {
      return res.status(404).json({ success: false, message: "Company not found" });
    }
    return res.status(200).json({
      success: true,
      message: "OK",
      data: {
        companyName: company.companyName,
        companyCity: company.companyCity,
        overtimeThresholdHours: company.overtimeThresholdMinutes / 60,
      },
    });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const updateCompanySettings = async (req, res) => {
  try {
    const { companyCity, overtimeThresholdHours } = req.body;
    const { companyName } = req.user;

    const hours = Number(overtimeThresholdHours);
    if (!Number.isFinite(hours) || hours <= 0 || hours > 24) {
      return res.status(400).json({ success: false, message: "Shift hours must be between 0 and 24" });
    }

    const updated = await prisma.company.update({
      where: { companyName },
      data: { companyCity, overtimeThresholdMinutes: Math.round(hours * 60) },
    });

    await logAction(updated.id, companyName, "settings_updated", `City: ${companyCity}, Shift: ${hours}h`);

    return res.status(200).json({
      success: true,
      message: "Company settings updated",
      data: {
        companyName: updated.companyName,
        companyCity: updated.companyCity,
        overtimeThresholdHours: updated.overtimeThresholdMinutes / 60,
      },
    });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

module.exports = {
  addCompany,
  getReport,
  storeHistory,
  getHistory,
  historyList,
  sendNotifications,
  addAdmin,
  listAdmins,
  removeAdmin,
  getAnalytics,
  getCompanySettings,
  updateCompanySettings,
};
