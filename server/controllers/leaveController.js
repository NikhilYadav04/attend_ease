const prisma = require("../lib/prisma");
const { expandDateRange } = require("../utils/dateUtils");
const { logAction } = require("./auditController");

async function usedLeaveDays(employeeId) {
  const leaves = await prisma.leave.findMany({ where: { employeeId, status: "Approved" } });
  const days = new Set(leaves.flatMap((lv) => expandDateRange(lv.fromDate, lv.toDate)));
  return days.size;
}

function leaveJSON(l) {
  return {
    id: l.id,
    employeeName: l.employee.employeeName,
    employeeCompany: l.company.companyName,
    leaveType: l.leaveType,
    fromDate: l.fromDate,
    toDate: l.toDate,
    reason: l.reason,
    status: l.status,
  };
}

const requestLeave = async (req, res) => {
  try {
    const { leaveType, fromDate, toDate, reason } = req.body;
    const { employeeName, employeeCompany } = req.user;

    const company = await prisma.company.findUnique({ where: { companyName: employeeCompany } });
    const employee = company
      ? await prisma.employee.findUnique({
          where: { employeeName_companyId: { employeeName, companyId: company.id } },
        })
      : null;
    if (!employee) {
      return res.status(404).json({ success: false, message: "Employee record not found" });
    }

    const requestedDays = expandDateRange(fromDate, toDate).length;
    const used = await usedLeaveDays(employee.id);
    const remaining = employee.leaveQuota - used;
    if (requestedDays > remaining) {
      return res.status(400).json({
        success: false,
        message: `Insufficient leave balance. ${remaining} of ${employee.leaveQuota} days remaining.`,
      });
    }

    await prisma.leave.create({
      data: { employeeId: employee.id, companyId: company.id, leaveType, fromDate, toDate, reason },
    });

    return res.status(200).json({ success: true, message: "Leave requested" });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const myBalance = async (req, res) => {
  try {
    const { employeeName, employeeCompany } = req.user;
    const company = await prisma.company.findUnique({ where: { companyName: employeeCompany } });
    const employee = company
      ? await prisma.employee.findUnique({
          where: { employeeName_companyId: { employeeName, companyId: company.id } },
        })
      : null;
    if (!employee) {
      return res.status(404).json({ success: false, message: "Employee record not found" });
    }

    const used = await usedLeaveDays(employee.id);
    return res.status(200).json({
      success: true,
      message: "OK",
      data: { quota: employee.leaveQuota, used, remaining: employee.leaveQuota - used },
    });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const myLeaves = async (req, res) => {
  try {
    const { employeeName, employeeCompany } = req.user;
    const company = await prisma.company.findUnique({ where: { companyName: employeeCompany } });
    const employee = company
      ? await prisma.employee.findUnique({
          where: { employeeName_companyId: { employeeName, companyId: company.id } },
        })
      : null;

    const leaves = employee
      ? await prisma.leave.findMany({
          where: { employeeId: employee.id },
          include: { employee: true, company: true },
          orderBy: { createdAt: "desc" },
        })
      : [];

    return res.status(200).json({ success: true, message: "OK", data: leaves.map(leaveJSON) });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const pendingLeaves = async (req, res) => {
  try {
    const { companyName } = req.user;
    const company = await prisma.company.findUnique({ where: { companyName } });
    const leaves = company
      ? await prisma.leave.findMany({
          where: { companyId: company.id, status: "Pending" },
          include: { employee: true, company: true },
          orderBy: { createdAt: "desc" },
        })
      : [];

    return res.status(200).json({ success: true, message: "OK", data: leaves.map(leaveJSON) });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const allLeaves = async (req, res) => {
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

    const [leaves, totalCount] = await Promise.all([
      prisma.leave.findMany({
        where: { companyId: company.id },
        include: { employee: true, company: true },
        orderBy: { createdAt: "desc" },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.leave.count({ where: { companyId: company.id } }),
    ]);

    return res.status(200).json({
      success: true,
      message: "OK",
      data: {
        items: leaves.map(leaveJSON),
        page,
        totalPages: Math.max(1, Math.ceil(totalCount / limit)),
        totalCount,
      },
    });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const actionLeave = async (req, res) => {
  try {
    const { leaveId, action } = req.body;
    const { companyName } = req.user;

    if (action !== "approve" && action !== "reject") {
      return res.status(400).json({ success: false, message: "Action must be 'approve' or 'reject'" });
    }

    const status = action === "approve" ? "Approved" : "Rejected";
    const company = await prisma.company.findUnique({ where: { companyName } });
    const leave = company
      ? await prisma.leave.findFirst({
          where: { id: leaveId, companyId: company.id },
          include: { employee: true },
        })
      : null;

    if (!leave) {
      return res.status(404).json({ success: false, message: "Leave not found for your company" });
    }

    await prisma.leave.update({ where: { id: leave.id }, data: { status } });
    await logAction(
      company.id,
      companyName,
      `leave_${status.toLowerCase()}`,
      `${leave.employee.employeeName} — ${leave.fromDate} to ${leave.toDate}`
    );

    return res.status(200).json({ success: true, message: `Leave ${status}` });
  } catch (e) {
    console.error("[actionLeave]", e);
    return res.status(500).json({ success: false, message: "Leave action failed" });
  }
};

module.exports = { requestLeave, myLeaves, myBalance, pendingLeaves, allLeaves, actionLeave };
