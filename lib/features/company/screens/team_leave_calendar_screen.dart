import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/utils/attendance_time.dart';
import 'package:attend_ease/features/company/services/company_service.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class TeamLeaveCalendarScreen extends StatefulWidget {
  const TeamLeaveCalendarScreen({super.key});

  @override
  State<TeamLeaveCalendarScreen> createState() => _TeamLeaveCalendarScreenState();
}

class _TeamLeaveCalendarScreenState extends State<TeamLeaveCalendarScreen> {
  final CompanyService _service = CompanyService();
  final _displayFmt = DateFormat('dd MMM yyyy');

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<String>> _leaveByDate = {};
  Map<DateTime, String> _holidayByDate = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAll());
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    final results = await Future.wait([_service.getStaff(), _service.getHolidays()]);
    if (!mounted) return;

    final staffRes = results[0];
    final leaveByDate = <DateTime, List<String>>{};
    if (staffRes.success && staffRes.data != null) {
      for (final staff in staffRes.data!) {
        final name = staff['employeeName'] as String? ?? '?';
        final onLeaveDates = staff['onLeaveDates'] as List<dynamic>? ?? [];
        for (final raw in onLeaveDates) {
          final dt = AttendanceTime.parseEntryDate(raw as String? ?? '');
          if (dt == null) continue;
          final key = DateTime.utc(dt.year, dt.month, dt.day);
          leaveByDate.putIfAbsent(key, () => []).add(name);
        }
      }
    }

    final holidayRes = results[1];
    final holidayByDate = <DateTime, String>{};
    if (holidayRes.success && holidayRes.data != null) {
      for (final holiday in holidayRes.data!) {
        final dt = AttendanceTime.parseEntryDate(holiday['date'] as String? ?? '');
        if (dt == null) continue;
        holidayByDate[DateTime.utc(dt.year, dt.month, dt.day)] = holiday['name'] as String? ?? 'Holiday';
      }
    }

    setState(() {
      _leaveByDate = leaveByDate;
      _holidayByDate = holidayByDate;
      _loading = false;
    });
  }

  List<String> _leaveNamesFor(DateTime day) =>
      _leaveByDate[DateTime.utc(day.year, day.month, day.day)] ?? const [];

  String? _holidayNameFor(DateTime day) =>
      _holidayByDate[DateTime.utc(day.year, day.month, day.day)];

  @override
  Widget build(BuildContext context) {
    final selectedLeaves = _leaveNamesFor(_selectedDay);
    final selectedHoliday = _holidayNameFor(_selectedDay);

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('Team Leave Calendar', style: AppTextStyles.title),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _fetchAll,
          child: _loading
              ? const _CalendarSkeleton()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: TableCalendar(
                          rowHeight: 44,
                          daysOfWeekHeight: 36,
                          firstDay: DateTime.utc(2024, 1, 1),
                          lastDay: DateTime.utc(2027, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          onDaySelected: (selected, focused) => setState(() {
                            _selectedDay = selected;
                            _focusedDay = focused;
                          }),
                          onPageChanged: (focused) => setState(() => _focusedDay = focused),
                          headerStyle: HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: false,
                            titleTextStyle: AppTextStyles.title,
                            leftChevronIcon:
                                const Icon(Icons.chevron_left, color: AppColors.primary),
                            rightChevronIcon:
                                const Icon(Icons.chevron_right, color: AppColors.primary),
                          ),
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle:
                                AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                            selectedDecoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle:
                                AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                            defaultTextStyle: AppTextStyles.body,
                          ),
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              final holiday = _holidayNameFor(day);
                              final leaveCount = _leaveNamesFor(day).length;
                              final markColor = holiday != null
                                  ? const Color(0xFF7C3AED)
                                  : leaveCount > 0
                                      ? AppColors.secondary
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
                                        fontWeight:
                                            markColor != null ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                    ),
                                    if (leaveCount > 0 && holiday == null)
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
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _LegendDot(color: const Color(0xFF7C3AED), label: 'Holiday'),
                          const SizedBox(width: AppSpacing.md),
                          _LegendDot(color: AppColors.secondary, label: 'On Leave'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(_displayFmt.format(_selectedDay), style: AppTextStyles.title),
                      const SizedBox(height: AppSpacing.sm),
                      if (selectedHoliday != null)
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              const Icon(Icons.event_rounded,
                                  color: Color(0xFF7C3AED), size: 20),
                              const SizedBox(width: AppSpacing.sm),
                              Text(selectedHoliday, style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ),
                      if (selectedHoliday != null && selectedLeaves.isNotEmpty)
                        const SizedBox(height: AppSpacing.sm),
                      if (selectedLeaves.isEmpty && selectedHoliday == null)
                        AppCard(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.event_available_rounded,
                                    size: 36, color: AppColors.textHint),
                                const SizedBox(height: AppSpacing.sm),
                                Text('Everyone is in on this day.',
                                    style: AppTextStyles.body
                                        .copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        )
                      else if (selectedLeaves.isNotEmpty) ...[
                        Text('${selectedLeaves.length} on leave',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: AppSpacing.sm),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: selectedLeaves.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
                          itemBuilder: (context, index) {
                            final name = selectedLeaves[index];
                            return AppCard(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                                      style: AppTextStyles.caption
                                          .copyWith(color: AppColors.secondary),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(name, style: AppTextStyles.bodyMedium),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _CalendarSkeleton extends StatelessWidget {
  const _CalendarSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox.wide(height: 320, borderRadius: 12),
          const SizedBox(height: AppSpacing.lg),
          const SkeletonBox(width: 140, height: 16),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonBox.wide(height: 60, borderRadius: 12),
        ],
      ),
    );
  }
}
