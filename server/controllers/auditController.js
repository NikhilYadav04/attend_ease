const prisma = require("../lib/prisma");

async function logAction(companyId, actorName, action, detail) {
  try {
    await prisma.auditLog.create({
      data: { companyId, actorName, action, detail: detail || null },
    });
  } catch (e) {
    console.error("[logAction]", e);
  }
}

const getAuditLog = async (req, res) => {
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

    const [logs, totalCount] = await Promise.all([
      prisma.auditLog.findMany({
        where: { companyId: company.id },
        orderBy: { createdAt: "desc" },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.auditLog.count({ where: { companyId: company.id } }),
    ]);

    return res.status(200).json({
      success: true,
      message: "OK",
      data: {
        items: logs.map((l) => ({
          id: l.id,
          actorName: l.actorName,
          action: l.action,
          detail: l.detail,
          createdAt: l.createdAt,
        })),
        page,
        totalPages: Math.max(1, Math.ceil(totalCount / limit)),
        totalCount,
      },
    });
  } catch (e) {
    console.error("[getAuditLog]", e);
    return res.status(500).json({ success: false, message: "Failed to load audit log" });
  }
};

module.exports = { logAction, getAuditLog };
