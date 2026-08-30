import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/auth/providers/auth_provider.dart';
import 'package:attend_ease/features/correction/screens/my_corrections_screen.dart';
import 'package:attend_ease/features/employee/providers/employee_provider.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/core/utils/attendance_time.dart';
import 'package:attend_ease/features/employee/services/employee_service.dart';
import 'package:attend_ease/features/leave/services/leave_service.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class EmployeeMainScreen3 extends StatefulWidget {
  const EmployeeMainScreen3({super.key});

  @override
  State<EmployeeMainScreen3> createState() => _EmployeeMainScreen3State();
}

class _EmployeeMainScreen3State extends State<EmployeeMainScreen3>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  /// The month currently displayed in summary + log (independent of calendar focus).
  DateTime _displayMonth = DateTime(DateTime.now().year, DateTime.now().month);

  final EmployeeService _service = getIt<EmployeeService>();
  final LeaveService _leaveService = LeaveService();
  final _dateFmt = DateFormat('dd/MM/yy');
  List<DateTime> _presentDates = [];
  Set<DateTime> _onLeaveDates = {};
  Map<DateTime, String> _holidayNames = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDates();
      _fetchOnLeaveDates();
      _fetchHolidayDates();
    });
  }

  Future<void> _fetchHolidayDates() async {
    final res = await _service.getHolidays();
    if (!mounted || !res.success || res.data == null) return;
    final names = <DateTime, String>{};
    for (final holiday in res.data!) {
      final dt = AttendanceTime.parseEntryDate(holiday['date'] as String? ?? '');
      if (dt != null) {
        names[DateTime.utc(dt.year, dt.month, dt.day)] =
            holiday['name'] as String? ?? 'Holiday';
      }
    }
    setState(() => _holidayNames = names);
  }

  String? _holidayNameFor(DateTime day) {
    for (final entry in _holidayNames.entries) {
      if (isSameDay(entry.key, day)) return entry.value;
    }
    return null;
  }

  void _showDayHint(DateTime day, List<dynamic> report) {
    final holidayName = _holidayNameFor(day);
    final isOnLeave = _onLeaveDates.any((d) => isSameDay(d, day));
    final entry = report.firstWhere(
      (e) => isSameDay(
          AttendanceTime.parseEntryDate(e['Date'] as String? ?? '') ??
              DateTime(0),
          day),
      orElse: () => null,
    );

    String? hint;
    if (holidayName != null) {
      hint = '🎉 $holidayName · Holiday';
    } else if (isOnLeave) {
      hint = 'On Leave';
    } else if (entry != null && entry['isPresent'] == true) {
      final inT = entry['InTime'] as String?;
      hint = (inT != null && inT != '00:00') ? 'Present · in $inT' : 'Present';
    }

    if (hint == null) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(hint),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  Future<void> _fetchDates() async {
    final res = await _service.getReport();
    if (!mounted) return;
    if (res.success && res.data != null) {
      final list = res.data!;
      context.read<EmployeeProvider>().setReport(list);
      final dates = <DateTime>[];
      for (final entry in list) {
        if (entry['isPresent'] == true) {
          final dt = AttendanceTime.parseEntryDate(entry['Date'] as String? ?? '');
          if (dt != null) dates.add(DateTime.utc(dt.year, dt.month, dt.day));
        }
      }
      setState(() => _presentDates = dates);
    }
  }

  Future<void> _fetchOnLeaveDates() async {
    final res = await _leaveService.getMyLeaves();
    if (!mounted) return;
    if (!res.success || res.data == null) return;

    final dates = <DateTime>{};
    for (final leave in res.data!) {
      if ((leave['status'] as String? ?? '') != 'Approved') continue;
      final from = AttendanceTime.parseEntryDate(leave['fromDate'] as String? ?? '');
      final to = AttendanceTime.parseEntryDate(leave['toDate'] as String? ?? '');
      if (from == null || to == null || to.isBefore(from)) continue;
      var current = from;
      while (!current.isAfter(to)) {
        dates.add(DateTime.utc(current.year, current.month, current.day));
        current = current.add(const Duration(days: 1));
      }
    }
    setState(() => _onLeaveDates = dates);
  }

  /// Summary stats for a given month.
  Map<String, int> _monthStats(List<dynamic> report, DateTime month) {
    final records = report.where((e) {
      final dt = AttendanceTime.parseEntryDate(e['Date'] as String? ?? '');
      if (dt == null) return false;
      return dt.month == month.month && dt.year == month.year;
    }).toList();
    final present = records.where((e) => e['isPresent'] == true).length;
    final absent = records.where((e) => e['isPresent'] == false).length;
    return {'present': present, 'absent': absent, 'total': records.length};
  }

  /// Filtered log for _displayMonth, with synthetic "On Leave" entries merged in.
  List<dynamic> _monthLog(List<dynamic> report) {
    final realEntries = report.where((e) {
      final dt = AttendanceTime.parseEntryDate(e['Date'] as String? ?? '');
      if (dt == null) return false;
      return dt.month == _displayMonth.month && dt.year == _displayMonth.year;
    }).toList();

    final realDates = realEntries
        .map((e) => AttendanceTime.parseEntryDate(e['Date'] as String? ?? ''))
        .whereType<DateTime>()
        .map((d) => DateTime.utc(d.year, d.month, d.day))
        .toSet();

    final leaveEntries = _onLeaveDates
        .where((d) =>
            d.month == _displayMonth.month &&
            d.year == _displayMonth.year &&
            !realDates.contains(d))
        .map((d) => <String, dynamic>{'Date': _dateFmt.format(d), 'onLeave': true})
        .toList();

    final merged = [...realEntries, ...leaveEntries];
    merged.sort((a, b) {
      final da = AttendanceTime.parseEntryDate(a['Date'] as String? ?? '') ?? DateTime(0);
      final db = AttendanceTime.parseEntryDate(b['Date'] as String? ?? '') ?? DateTime(0);
      return db.compareTo(da);
    });
    return merged;
  }

  void _prevMonth() => setState(() {
        _displayMonth =
            DateTime(_displayMonth.year, _displayMonth.month - 1);
        _focusedDay = _displayMonth;
      });

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_displayMonth.year, _displayMonth.month + 1);
    if (next.isAfter(DateTime(now.year, now.month))) return;
    setState(() {
      _displayMonth = next;
      _focusedDay = _displayMonth;
    });
  }

  Future<void> _exportPdf(List<dynamic> report) async {
    final brand = PdfColor.fromInt(AppColors.primary.toARGB32());
    final pdf = pw.Document();
    final now = DateTime.now();
    final session = context.read<AuthProvider>();

    final total = report.length;
    final present = report.where((e) => e['isPresent'] == true).length;
    final absent = total - present;
    final rate = total > 0 ? (present / total * 100) : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
        build: (ctx) => [
          // ── Header ────────────────────────────────────────────
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Attendance Report',
                      style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: brand)),
                  pw.SizedBox(height: 4),
                  pw.Text(session.eName ?? 'Employee',
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      '${session.eCName ?? '—'}'
                      '${(session.eID ?? '').isNotEmpty ? '   ·   ID: ${session.eID}' : ''}',
                      style:
                          const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
              pw.Text('Generated ${DateFormat('dd MMM yyyy').format(now)}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Divider(color: brand, thickness: 1.2),
          pw.SizedBox(height: 14),

          // ── Summary strip ───────────────────────────────────────
          pw.Row(
            children: [
              _pdfStat('Total', '$total', brand),
              pw.SizedBox(width: 8),
              _pdfStat('Present', '$present', PdfColors.green700),
              pw.SizedBox(width: 8),
              _pdfStat('Absent', '$absent', PdfColors.red700),
              pw.SizedBox(width: 8),
              _pdfStat('Rate', '${rate.toStringAsFixed(0)}%', brand),
            ],
          ),
          pw.SizedBox(height: 16),

          // ── Table ────────────────────────────────────────────
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.2),
              1: pw.FlexColumnWidth(1.6),
              2: pw.FlexColumnWidth(1.6),
              3: pw.FlexColumnWidth(1.6),
              4: pw.FlexColumnWidth(1.4),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: brand),
                children: ['Date', 'Status', 'Punch In', 'Punch Out', 'Hours']
                    .map((h) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 6, vertical: 6),
                          child: pw.Text(h,
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white)),
                        ))
                    .toList(),
              ),
              for (var i = 0; i < report.length; i++)
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: i.isEven ? PdfColors.grey100 : PdfColors.white),
                  children: [
                    _pdfCell(report[i]['Date'] ?? '—'),
                    _pdfCell(
                      report[i]['isPresent'] == true ? 'Present' : 'Absent',
                      color: report[i]['isPresent'] == true
                          ? PdfColors.green700
                          : PdfColors.red700,
                      bold: true,
                    ),
                    _pdfCell(report[i]['InTime'] ?? '—'),
                    _pdfCell(report[i]['OutTime'] ?? '—'),
                    _pdfCell(AttendanceTime.calcHoursWorked(
                            report[i]['InTime'], report[i]['OutTime']) ??
                        '—'),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'attendance_${DateFormat('yyyy_MM').format(now)}.pdf',
    );
  }

  pw.Widget _pdfStat(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey50,
          border: pw.Border.all(color: color, width: 0.6),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
            pw.Text(label,
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
          ],
        ),
      ),
    );
  }

  pw.Widget _pdfCell(String text, {PdfColor? color, bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontSize: 9.5,
              color: color ?? PdfColors.black,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final report = context.watch<EmployeeProvider>().report;
    final stats = _monthStats(report, _displayMonth);
    final log = _monthLog(report);
    final isCurrentMonth = _displayMonth.year == DateTime.now().year &&
        _displayMonth.month == DateTime.now().month;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: () => Future.wait([_fetchDates(), _fetchOnLeaveDates(), _fetchHolidayDates()]),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Month navigation header ────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _prevMonth,
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: AppColors.primary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(_displayMonth),
                    style: AppTextStyles.title,
                  ),
                  IconButton(
                    onPressed: isCurrentMonth ? null : _nextMonth,
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: isCurrentMonth
                          ? AppColors.textHint
                          : AppColors.primary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Monthly summary card ───────────────────────────
              _MonthlySummaryCard(
                present: stats['present']!,
                absent: stats['absent']!,
                total: stats['total']!,
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Calendar card ──────────────────────────────────
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: TableCalendar(
                  rowHeight: 44,
                  daysOfWeekHeight: 36,
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2026, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                      _displayMonth =
                          DateTime(focused.year, focused.month);
                    });
                    _showDayHint(selected, report);
                  },
                  onFormatChanged: (format) =>
                      setState(() => _calendarFormat = format),
                  onPageChanged: (focused) => setState(() {
                    _focusedDay = focused;
                    _displayMonth = DateTime(focused.year, focused.month);
                  }),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: AppTextStyles.title,
                    leftChevronIcon: const Icon(Icons.chevron_left,
                        color: AppColors.primary),
                    rightChevronIcon: const Icon(Icons.chevron_right,
                        color: AppColors.primary),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.primary),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white),
                    weekendTextStyle:
                        AppTextStyles.body.copyWith(color: AppColors.error),
                    defaultTextStyle: AppTextStyles.body,
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final isPresent = _presentDates
                          .any((d) => isSameDay(d, day));
                      final isOnLeave = !isPresent &&
                          _onLeaveDates.any((d) => isSameDay(d, day));
                      final isHoliday = !isPresent && !isOnLeave &&
                          _holidayNames.keys.any((d) => isSameDay(d, day));
                      final markColor = isPresent
                          ? AppColors.success
                          : isOnLeave
                              ? AppColors.secondary
                              : isHoliday
                                  ? const Color(0xFF7C3AED)
                                  : null;
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: markColor?.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '${day.day}',
                              style: AppTextStyles.body.copyWith(
                                color: markColor ?? AppColors.textPrimary,
                                fontWeight: markColor != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            if (markColor != null)
                              Positioned(
                                bottom: 2,
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: markColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Attendance log header ──────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Attendance Log', style: AppTextStyles.title),
                  Row(
                    children: [
                      Text('${_presentDates.length} days present',
                          style: AppTextStyles.caption),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyCorrectionsScreen()),
                        ),
                        child: const Icon(
                          Icons.edit_calendar_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: report.isEmpty ? null : () => _exportPdf(report),
                        child: Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 20,
                          color: report.isEmpty
                              ? AppColors.textHint
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              if (log.isEmpty)
                AppCard(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.event_busy_rounded,
                            size: 40, color: AppColors.textHint),
                        const SizedBox(height: AppSpacing.sm),
                        Text('No records for this month.',
                            style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: log.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final entry = log[index];
                    final onLeave = entry['onLeave'] == true;
                    if (onLeave) return _OnLeaveRow(date: entry['Date'] as String? ?? '—');

                    final isPresent = entry['isPresent'] == true;
                    final isLate = entry['isLate'] == true;
                    final isOvertime = entry['isOvertime'] == true;
                    final inT = entry['InTime'] as String? ?? '—';
                    final outT = entry['OutTime'] as String? ?? '—';
                    final worked = AttendanceTime.calcHoursWorked(inT, outT);
                    return AppCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm),
                      child: Row(
                        children: [
                          // Status icon box
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isPresent
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFFE4E6),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Icon(
                              isPresent
                                  ? Icons.check_rounded
                                  : Icons.close_rounded,
                              color: isPresent
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          // Date + status
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry['Date'] ?? '—',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                const SizedBox(height: 2),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      isPresent ? 'Present' : 'Absent',
                                      style: AppTextStyles.caption.copyWith(
                                        color: isPresent
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                    ),
                                    if (isLate) ...[
                                      Text(
                                        '  ·  ',
                                        style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textHint),
                                      ),
                                      Text(
                                        'Late',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                    if (isOvertime) ...[
                                      Text(
                                        '  ·  ',
                                        style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textHint),
                                      ),
                                      Text(
                                        'Overtime',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                    if (worked != null) ...[
                                      Text(
                                        '  ·  ',
                                        style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textHint),
                                      ),
                                      const Icon(
                                        Icons.schedule_rounded,
                                        size: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        worked,
                                        style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Punch times
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _TimeTag(label: 'IN', value: inT),
                              const SizedBox(height: 4),
                              _TimeTag(label: 'OUT', value: outT),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _MonthlySummaryCard extends StatelessWidget {
  final int present;
  final int absent;
  final int total;

  const _MonthlySummaryCard({
    required this.present,
    required this.absent,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final rate = total > 0 ? present / total * 100 : 0.0;
    final isGood = rate >= 75;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F354D), Color(0xFF305077)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rate row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Rate',
                style: AppTextStyles.caption
                    .copyWith(color: Colors.white.withValues(alpha: 0.7)),
              ),
              Text(
                '${rate.toStringAsFixed(0)}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isGood ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: (rate / 100).clamp(0, 1),
              minHeight: 6,
              color: isGood ? AppColors.success : AppColors.error,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Stat chips ─────────────────────────────────────
          Row(
            children: [
              _StatChip(
                label: 'Present',
                value: '$present',
                color: AppColors.success,
                icon: Icons.check_circle_rounded,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatChip(
                label: 'Absent',
                value: '$absent',
                color: AppColors.error,
                icon: Icons.cancel_rounded,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatChip(
                label: 'Tracked',
                value: '$total',
                color: AppColors.secondary,
                icon: Icons.calendar_month_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 3),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnLeaveRow extends StatelessWidget {
  final String date;

  const _OnLeaveRow({required this.date});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.beach_access_rounded,
                color: AppColors.secondary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  'On Leave',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeTag extends StatelessWidget {
  final String label;
  final String value;

  const _TimeTag({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label  ',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
