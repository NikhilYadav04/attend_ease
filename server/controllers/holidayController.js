const prisma = require("../lib/prisma");
const { logAction } = require("./auditController");

const addHoliday = async (req, res) => {
  try {
    const { date, name } = req.body;
    const { companyName } = req.user;

    const company = await prisma.company.findUnique({ where: { companyName } });
    if (!company) {
      return res.status(404).json({ success: false, message: "Company not found" });
    }

    const existing = await prisma.holiday.findUnique({
      where: { companyId_date: { companyId: company.id, date } },
    });
    if (existing) {
      return res.status(400).json({ success: false, message: "A holiday is already set for this date" });
    }

    const holiday = await prisma.holiday.create({
      data: { companyId: company.id, date, name },
    });

    await logAction(company.id, companyName, "holiday_added", `${name} — ${date}`);

    return res.status(200).json({
      success: true,
      message: "Holiday added",
      data: { id: holiday.id, date: holiday.date, name: holiday.name },
    });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const listHolidays = async (req, res) => {
  try {
    const companyName = req.user.companyName || req.user.employeeCompany;
    const company = await prisma.company.findUnique({ where: { companyName } });
    const holidays = company
      ? await prisma.holiday.findMany({ where: { companyId: company.id } })
      : [];

    return res.status(200).json({
      success: true,
      message: "OK",
      data: holidays.map((h) => ({ id: h.id, date: h.date, name: h.name })),
    });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const removeHoliday = async (req, res) => {
  try {
    const { holidayId } = req.body;
    const { companyName } = req.user;

    const company = await prisma.company.findUnique({ where: { companyName } });
    if (!company) {
      return res.status(404).json({ success: false, message: "Company not found" });
    }

    const holiday = await prisma.holiday.findFirst({ where: { id: holidayId, companyId: company.id } });
    if (!holiday) {
      return res.status(404).json({ success: false, message: "Holiday not found for your company" });
    }

    await prisma.holiday.delete({ where: { id: holiday.id } });
    await logAction(company.id, companyName, "holiday_removed", `${holiday.name} — ${holiday.date}`);

    return res.status(200).json({ success: true, message: "Holiday removed" });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

module.exports = { addHoliday, listHolidays, removeHoliday };
