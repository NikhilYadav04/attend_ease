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
    const company = await prisma.company.findUnique({ where: { companyName } });
    const logs = company
      ? await prisma.auditLog.findMany({
          where: { companyId: company.id },
          orderBy: { createdAt: "desc" },
          take: 200,
        })
      : [];

    return res.status(200).json({
      success: true,
      message: "OK",
      data: logs.map((l) => ({
        id: l.id,
        actorName: l.actorName,
        action: l.action,
        detail: l.detail,
        createdAt: l.createdAt,
      })),
    });
  } catch (e) {
    console.error("[getAuditLog]", e);
    return res.status(500).json({ success: false, message: "Failed to load audit log" });
  }
};

module.exports = { logAction, getAuditLog };
