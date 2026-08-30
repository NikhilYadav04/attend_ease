const prisma = require("../lib/prisma");
const { logAction } = require("./auditController");

function correctionJSON(c) {
  return {
    id: c.id,
    employeeName: c.employee.employeeName,
    employeeCompany: c.company.companyName,
    date: c.date,
    requestedInTime: c.requestedInTime,
    requestedOutTime: c.requestedOutTime,
    reason: c.reason,
    status: c.status,
  };
}

const requestCorrection = async (req, res) => {
  try {
    const { date, requestedInTime, requestedOutTime, reason } = req.body;
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

    await prisma.attendanceCorrection.create({
      data: {
        employeeId: employee.id,
        companyId: company.id,
        date,
        requestedInTime: requestedInTime || null,
        requestedOutTime: requestedOutTime || null,
        reason,
      },
    });

    return res.status(200).json({ success: true, message: "Correction requested" });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const myCorrections = async (req, res) => {
  try {
    const { employeeName, employeeCompany } = req.user;
    const company = await prisma.company.findUnique({ where: { companyName: employeeCompany } });
    const employee = company
      ? await prisma.employee.findUnique({
          where: { employeeName_companyId: { employeeName, companyId: company.id } },
        })
      : null;

    const corrections = employee
      ? await prisma.attendanceCorrection.findMany({
          where: { employeeId: employee.id },
          include: { employee: true, company: true },
          orderBy: { createdAt: "desc" },
        })
      : [];

    return res.status(200).json({ success: true, message: "OK", data: corrections.map(correctionJSON) });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const pendingCorrections = async (req, res) => {
  try {
    const { companyName } = req.user;
    const company = await prisma.company.findUnique({ where: { companyName } });
    const corrections = company
      ? await prisma.attendanceCorrection.findMany({
          where: { companyId: company.id, status: "Pending" },
          include: { employee: true, company: true },
          orderBy: { createdAt: "desc" },
        })
      : [];

    return res.status(200).json({ success: true, message: "OK", data: corrections.map(correctionJSON) });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const allCorrections = async (req, res) => {
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

    const [corrections, totalCount] = await Promise.all([
      prisma.attendanceCorrection.findMany({
        where: { companyId: company.id },
        include: { employee: true, company: true },
        orderBy: { createdAt: "desc" },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.attendanceCorrection.count({ where: { companyId: company.id } }),
    ]);

    return res.status(200).json({
      success: true,
      message: "OK",
      data: {
        items: corrections.map(correctionJSON),
        page,
        totalPages: Math.max(1, Math.ceil(totalCount / limit)),
        totalCount,
      },
    });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const actionCorrection = async (req, res) => {
  try {
    const { correctionId, action } = req.body;
    const { companyName } = req.user;

    if (action !== "approve" && action !== "reject") {
      return res.status(400).json({ success: false, message: "Action must be 'approve' or 'reject'" });
    }

    const status = action === "approve" ? "Approved" : "Rejected";
    const company = await prisma.company.findUnique({ where: { companyName } });
    const correction = company
      ? await prisma.attendanceCorrection.findFirst({
          where: { id: correctionId, companyId: company.id },
          include: { employee: true },
        })
      : null;

    if (!correction) {
      return res.status(404).json({ success: false, message: "Correction request not found for your company" });
    }

    if (status === "Approved") {
      const existing = await prisma.attendanceRecord.findUnique({
        where: { employeeId_date: { employeeId: correction.employeeId, date: correction.date } },
      });

      const inTime = correction.requestedInTime ?? existing?.inTime ?? "00:00";
      const outTime = correction.requestedOutTime ?? existing?.outTime ?? "00:00";
      const isPresent = inTime !== "00:00" && outTime !== "00:00";

      await prisma.attendanceRecord.upsert({
        where: { employeeId_date: { employeeId: correction.employeeId, date: correction.date } },
        update: { inTime, outTime, isPresent },
        create: {
          employeeId: correction.employeeId,
          date: correction.date,
          inTime,
          outTime,
          isPresent,
          isLate: false,
        },
      });
    }

    await prisma.attendanceCorrection.update({ where: { id: correction.id }, data: { status } });
    await logAction(
      company.id,
      companyName,
      `correction_${status.toLowerCase()}`,
      `${correction.employee.employeeName} — ${correction.date}`
    );

    return res.status(200).json({ success: true, message: `Correction ${status}` });
  } catch (e) {
    console.error("[actionCorrection]", e);
    return res.status(500).json({ success: false, message: "Correction action failed" });
  }
};

module.exports = { requestCorrection, myCorrections, pendingCorrections, allCorrections, actionCorrection };
