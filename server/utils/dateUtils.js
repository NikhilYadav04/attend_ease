function parseDdMmYy(dateStr) {
  const parts = dateStr.split("/");
  if (parts.length !== 3) return null;
  const [d, m, y] = parts.map(Number);
  if (!d || !m || Number.isNaN(y)) return null;
  return new Date(2000 + y, m - 1, d);
}

function formatDdMmYy(date) {
  const dd = String(date.getDate()).padStart(2, "0");
  const mm = String(date.getMonth() + 1).padStart(2, "0");
  const yy = String(date.getFullYear()).slice(-2);
  return `${dd}/${mm}/${yy}`;
}

function expandDateRange(fromStr, toStr) {
  const from = parseDdMmYy(fromStr);
  const to = parseDdMmYy(toStr);
  if (!from || !to || to < from) return [];
  const dates = [];
  const cur = new Date(from);
  while (cur <= to) {
    dates.push(formatDdMmYy(cur));
    cur.setDate(cur.getDate() + 1);
  }
  return dates;
}

module.exports = { parseDdMmYy, formatDdMmYy, expandDateRange };
