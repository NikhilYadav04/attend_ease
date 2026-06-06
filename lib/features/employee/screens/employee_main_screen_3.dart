import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/employee/providers/employee_provider.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/features/employee/services/employee_service.dart';
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

class _EmployeeMainScreen3State extends State<EmployeeMainScreen3> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  /// The month currently displayed in summary + log (independent of calendar focus).
  DateTime _displayMonth = DateTime(DateTime.now().year, DateTime.now().month);

  final EmployeeService _service = getIt<EmployeeService>();
  List<DateTime> _presentDates = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDates());
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
          final dt = _parseDate(entry['Date'] as String? ?? '');
          if (dt != null) dates.add(DateTime.utc(dt.year, dt.month, dt.day));
        }
      }
      setState(() => _presentDates = dates);
    }
  }

  DateTime? _parseDate(String raw) {
    final parts = raw.split('/');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    return DateTime(y < 100 ? 2000 + y : y, m, d);
  }

  /// Returns hours worked string "Xh Ym" or null.
  String? _hoursWorked(String? inTime, String? outTime) {
    if (inTime == null || outTime == null) return null;
    if (inTime == '—' || outTime == '—') return null;
    if (inTime == '00:00' || outTime == '00:00') return null;
    final inP = inTime.split(':');
    final outP = outTime.split(':');
    if (inP.length != 2 || outP.length != 2) return null;
    final inMins = (int.tryParse(inP[0]) ?? 0) * 60 + (int.tryParse(inP[1]) ?? 0);
    final outMins = (int.tryParse(outP[0]) ?? 0) * 60 + (int.tryParse(outP[1]) ?? 0);
    final diff = outMins - inMins;
    if (diff <= 0) return null;
    final h = diff ~/ 60;
    final m = diff % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// Summary stats for a given month.
  Map<String, int> _monthStats(List<dynamic> report, DateTime month) {
    final records = report.where((e) {
      final dt = _parseDate(e['Date'] as String? ?? '');
      if (dt == null) return false;
      return dt.month == month.month && dt.year == month.year;
    }).toList();
    final present = records.where((e) => e['isPresent'] == true).length;
    final absent = records.where((e) => e['isPresent'] == false).length;
    return {'present': present, 'absent': absent, 'total': records.length};
  }

  /// Filtered log for _displayMonth.
  List<dynamic> _monthLog(List<dynamic> report) {
    return report.where((e) {
      final dt = _parseDate(e['Date'] as String? ?? '');
      if (dt == null) return false;
      return dt.month == _displayMonth.month && dt.year == _displayMonth.year;
    }).toList();
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
    final pdf = pw.Document();
    final now = DateTime.now();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Text('Attendance Report',
              style: pw.TextStyle(
                  fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(
              'Generated: ${DateFormat('dd MMM yyyy').format(now)}',
              style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Status', 'Punch In', 'Punch Out', 'Hours'],
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.blueGrey100),
            data: report
                .map((e) => [
                      e['Date'] ?? '—',
                      e['isPresent'] == true ? 'Present' : 'Absent',
                      e['InTime'] ?? '—',
                      e['OutTime'] ?? '—',
                      _hoursWorked(e['InTime'], e['OutTime']) ?? '—',
                    ])
                .toList(),
            cellStyle: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'attendance_${DateFormat('yyyy_MM').format(now)}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = context.watch<EmployeeProvider>().report;
    final stats = _monthStats(report, _displayMonth);
    final log = _monthLog(report);
    final isCurrentMonth = _displayMonth.year == DateTime.now().year &&
        _displayMonth.month == DateTime.now().month;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: _fetchDates,
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
                  onDaySelected: (selected, focused) => setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                    _displayMonth =
                        DateTime(focused.year, focused.month);
                  }),
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
                      return Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isPresent
                              ? AppColors.success.withValues(alpha: 0.15)
                              : null,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '${day.day}',
                              style: AppTextStyles.body.copyWith(
                                color: isPresent
                                    ? AppColors.success
                                    : AppColors.textPrimary,
                                fontWeight: isPresent
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            if (isPresent)
                              Positioned(
                                bottom: 2,
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
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
                    final isPresent = entry['isPresent'] == true;
                    final inT = entry['InTime'] as String? ?? '—';
                    final outT = entry['OutTime'] as String? ?? '—';
                    final worked = _hoursWorked(inT, outT);
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
                                Row(
                                  children: [
                                    Text(
                                      isPresent ? 'Present' : 'Absent',
                                      style: AppTextStyles.caption.copyWith(
                                        color: isPresent
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                    ),
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
