const prisma = require("../lib/prisma");

const storeLocation = async (req, res) => {
  try {
    const { latitude, longitude, radius, workStartTime } = req.body;
    const { companyName } = req.user;

    const company = await prisma.company.findUnique({ where: { companyName } });
    if (!company) {
      return res.status(404).json({ success: false, message: "Company not found" });
    }

    const data = { latitude, longitude, radius: Number(radius) };
    if (workStartTime) data.workStartTime = workStartTime;

    const body = await prisma.location.upsert({
      where: { companyId: company.id },
      update: data,
      create: { ...data, companyId: company.id },
    });

    return res.status(200).json({ success: true, message: "Location stored", data: body });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const getLocation = async (req, res) => {
  try {
    const { employeeCompany } = req.user;
    const company = await prisma.company.findUnique({ where: { companyName: employeeCompany } });
    const body = company
      ? await prisma.location.findUnique({ where: { companyId: company.id } })
      : null;

    if (!body) {
      return res.status(200).json({ success: false, message: "Location not set" });
    }

    return res.status(200).json({ success: true, message: "OK", data: body });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const getCompanyLocation = async (req, res) => {
  try {
    const { companyName } = req.user;
    const company = await prisma.company.findUnique({ where: { companyName } });
    const body = company
      ? await prisma.location.findUnique({ where: { companyId: company.id } })
      : null;

    if (!body) {
      return res.status(200).json({ success: false, message: "Location not set" });
    }

    return res.status(200).json({ success: true, message: "OK", data: body });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

module.exports = { storeLocation, getLocation, getCompanyLocation };
