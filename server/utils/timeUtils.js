const OVERTIME_THRESHOLD_MINUTES = 9 * 60;

function workedMinutes(inTime, outTime) {
  if (!inTime || !outTime || inTime === "00:00" || outTime === "00:00") return null;
  const [inH, inM] = inTime.split(":").map(Number);
  const [outH, outM] = outTime.split(":").map(Number);
  if ([inH, inM, outH, outM].some(Number.isNaN)) return null;
  const diff = outH * 60 + outM - (inH * 60 + inM);
  return diff > 0 ? diff : null;
}

module.exports = { workedMinutes, OVERTIME_THRESHOLD_MINUTES };
