const prisma = require("../lib/prisma");
const { serverNow, distanceMeters } = require("../utils/attendanceUtils");
const { attendanceRecordJSON } = require("../lib/serializers");

async function checkGeoFence(employeeCompany, latitude, longitude) {
  const lat = parseFloat(latitude);
  const lng = parseFloat(longitude);
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
    return { ok: false, status: 400, message: "Valid latitude and longitude are required" };
  }

  const company = await prisma.company.findUnique({ where: { companyName: employeeCompany } });
  const office = company
    ? await prisma.location.findUnique({ where: { companyId: company.id } })
    : null;
  if (!office) {
    return { ok: false, status: 400, message: "Company location not set" };
  }

  const distance = distanceMeters(
    parseFloat(office.latitude),
    parseFloat(office.longitude),
    lat,
    lng
  );

  if (distance > office.radius) {
    return {
      ok: false,
      status: 403,
      message: "Outside office radius. Move closer to mark attendance.",
    };
  }

  return { ok: true, office };
}

async function findEmployee(employeeName, employeeCompany) {
  const company = await prisma.company.findUnique({ where: { companyName: employeeCompany } });
  if (!company) return { company: null, employee: null };
  const employee = await prisma.employee.findUnique({
    where: { employeeName_companyId: { employeeName, companyId: company.id } },
  });
  return { company, employee };
}

const markIn = async (req, res) => {
  try {
    const { latitude, longitude } = req.body;
    const { employeeName, employeeCompany } = req.user;

    const fence = await checkGeoFence(employeeCompany, latitude, longitude);
    if (!fence.ok) {
      return res.status(fence.status).json({ success: false, message: fence.message });
    }

    const { company, employee } = await findEmployee(employeeName, employeeCompany);
    if (!employee) {
      return res.status(404).json({ success: false, message: "Employee record not found" });
    }

    const { time, date } = serverNow();

    const existing = await prisma.attendanceRecord.findUnique({
      where: { employeeId_date: { employeeId: employee.id, date } },
    });
    if (existing) {
      return res.status(200).json({
        success: true,
        message: "Already punched in",
        data: { InTime: existing.inTime, Date: existing.date },
      });
    }

    const isLate = Boolean(fence.office.workStartTime) && time > fence.office.workStartTime;

    await prisma.attendanceRecord.create({
      data: { employeeId: employee.id, inTime: time, outTime: "00:00", date, isPresent: false, isLate },
    });

    await prisma.staffCount.update({
      where: { companyId: company.id },
      data: { inCount: { increment: 1 }, total: { increment: 1 } },
    });

    return res.status(200).json({
      success: true,
      message: "Punched in",
      data: { InTime: time, Date: date, isLate },
    });
  } catch (e) {
    console.error("[markIn]", e);
    return res.status(500).json({ success: false, message: "Punch in failed" });
  }
};

const markOut = async (req, res) => {
  try {
    const { latitude, longitude } = req.body;
    const { employeeName, employeeCompany } = req.user;

    const fence = await checkGeoFence(employeeCompany, latitude, longitude);
    if (!fence.ok) {
      return res.status(fence.status).json({ success: false, message: fence.message });
    }

    const { company, employee } = await findEmployee(employeeName, employeeCompany);
    if (!employee) {
      return res.status(404).json({ success: false, message: "Employee record not found" });
    }

    const { time, date } = serverNow();

    const record = await prisma.attendanceRecord.findUnique({
      where: { employeeId_date: { employeeId: employee.id, date } },
    });
    if (!record) {
      return res.status(400).json({ success: false, message: "You must punch in first" });
    }

    if (record.outTime !== "00:00") {
      const daysPresent = await prisma.attendanceRecord.count({
        where: { employeeId: employee.id, isPresent: true },
      });
      return res.status(200).json({
        success: true,
        message: "Already punched out",
        data: { totalDays: daysPresent, OutTime: record.outTime },
      });
    }

    await prisma.attendanceRecord.update({
      where: { id: record.id },
      data: { outTime: time, isPresent: true },
    });

    const daysPresent = await prisma.attendanceRecord.count({
      where: { employeeId: employee.id, isPresent: true },
    });

    await prisma.staffCount.update({
      where: { companyId: company.id },
      data: { outCount: { increment: 1 } },
    });

    return res.status(200).json({
      success: true,
      message: "Punched out",
      data: { totalDays: daysPresent, OutTime: time },
    });
  } catch (e) {
    console.error("[markOut]", e);
    return res.status(500).json({ success: false, message: "Punch out failed" });
  }
};

const getAttend = async (req, res) => {
  try {
    const dateParam = req.body.Date;
    const { employeeName, employeeCompany } = req.user;

    const { company, employee } = await findEmployee(employeeName, employeeCompany);
    if (!employee) {
      return res.status(200).json({ success: false, message: "Record not found" });
    }

    const record = await prisma.attendanceRecord.findUnique({
      where: { employeeId_date: { employeeId: employee.id, date: dateParam } },
    });
    if (!record) {
      return res.status(200).json({ success: false, message: "No record for this date" });
    }

    return res.status(200).json({
      success: true,
      message: "OK",
      data: attendanceRecordJSON(record, company.overtimeThresholdMinutes),
    });
  } catch (e) {
    console.error("[getAttend]", e);
    return res.status(500).json({ success: false, message: "Request failed" });
  }
};

const getAttendDays = async (req, res) => {
  try {
    const { employeeName, employeeCompany } = req.user;
    const { employee } = await findEmployee(employeeName, employeeCompany);

    if (!employee) {
      return res.status(200).json({ success: false, message: "Record not found" });
    }

    const daysPresent = await prisma.attendanceRecord.count({
      where: { employeeId: employee.id, isPresent: true },
    });

    return res.status(200).json({ success: true, message: "OK", data: [{ daysPresent }] });
  } catch (e) {
    console.error("[getAttendDays]", e);
    return res.status(500).json({ success: false, message: "Request failed" });
  }
};

module.exports = { markIn, markOut, getAttend, getAttendDays };
