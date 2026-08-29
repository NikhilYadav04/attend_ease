class AttendanceTime {
  static DateTime? parseEntryDate(String raw) {
    final parts = raw.split('/');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    return DateTime(y < 100 ? 2000 + y : y, m, d);
  }

  static String? calcHoursWorked(String? inTime, String? outTime) {
    if (inTime == null || outTime == null) return null;
    if (inTime == '—' || outTime == '—') return null;
    if (inTime == '00:00' || outTime == '00:00') return null;
    final inParts = inTime.split(':');
    final outParts = outTime.split(':');
    if (inParts.length != 2 || outParts.length != 2) return null;
    final inMins =
        (int.tryParse(inParts[0]) ?? 0) * 60 + (int.tryParse(inParts[1]) ?? 0);
    final outMins =
        (int.tryParse(outParts[0]) ?? 0) * 60 + (int.tryParse(outParts[1]) ?? 0);
    final diff = outMins - inMins;
    if (diff <= 0) return null;
    final h = diff ~/ 60;
    final m = diff % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  static bool isInMonth(String raw, DateTime month) {
    final dt = parseEntryDate(raw);
    if (dt == null) return false;
    return dt.month == month.month && dt.year == month.year;
  }
}
