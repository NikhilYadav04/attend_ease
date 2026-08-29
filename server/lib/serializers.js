/**
 * Response shapers — Prisma columns are camelCase (inTime, outCount, ...) but the
 * Flutter app was built against the old Mongoose field names (InTime, In, Out, ...).
 * These keep the JSON contract unchanged so no client code has to change.
 */

const { workedMinutes, OVERTIME_THRESHOLD_MINUTES } = require("../utils/timeUtils");

function attendanceRecordJSON(r, overtimeThresholdMinutes = OVERTIME_THRESHOLD_MINUTES) {
  const minutes = workedMinutes(r.inTime, r.outTime);
  return {
    InTime: r.inTime,
    OutTime: r.outTime,
    Date: r.date,
    isPresent: r.isPresent,
    isLate: r.isLate,
    workedMinutes: minutes,
    isOvertime: minutes !== null && minutes > overtimeThresholdMinutes,
  };
}

function staffCountJSON(c) {
  return { In: c.inCount, Out: c.outCount, Total: c.total };
}

module.exports = { attendanceRecordJSON, staffCountJSON };
