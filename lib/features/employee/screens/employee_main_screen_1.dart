import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/attendance/providers/attendance_provider.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/core/utils/attendance_time.dart';
import 'package:attend_ease/features/attendance/services/attendance_service.dart';
import 'package:attend_ease/features/employee/providers/employee_provider.dart';
import 'package:attend_ease/shared/widgets/skeleton_box.dart';
import 'package:attend_ease/features/employee/services/employee_service.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EmployeeMainScreen1 extends StatefulWidget {
  final void Function(int tabIndex) onSwitchTab;

  const EmployeeMainScreen1({super.key, required this.onSwitchTab});

  @override
  State<EmployeeMainScreen1> createState() => _EmployeeMainScreen1State();
}

class _EmployeeMainScreen1State extends State<EmployeeMainScreen1>
    with AutomaticKeepAliveClientMixin {
  final AttendanceService _attendanceService = getIt<AttendanceService>();
  final EmployeeService _employeeService = getIt<EmployeeService>();
  final DateTime _now = DateTime.now();
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final attendanceProvider = context.read<AttendanceProvider>();
    final date = DateFormat('dd/MM/yy').format(_now);

    final result = await _attendanceService.getAttendance(date);
    final daysResult = await _attendanceService.getAttendanceDays();

    if (!mounted) return;

    if (result.success && result.data != null) {
      attendanceProvider.setInTimeDisplay(result.data!['inTime'] ?? '00:00');
      attendanceProvider.setInTime(result.data!['inTime'] ?? '00:00');
      attendanceProvider.setOutTime(result.data!['outTime'] ?? '00:00');
      attendanceProvider.setPresent(result.data!['isPresent'] ?? false);
      if (daysResult.success && daysResult.data != null) {
        attendanceProvider.setTotalDays(daysResult.data!);
      }
    } else {
      attendanceProvider.setInTimeDisplay('00:00');
      attendanceProvider.setInTime('00:00');
      attendanceProvider.setOutTime('00:00');
      attendanceProvider.setPresent(false);
      attendanceProvider.setTotalDays(0);
      final isEmptyState = result.message == 'No record for this date' ||
          result.message == 'Record not found';
      if (!isEmptyState) {
        toastMessageError(context, 'Error!', result.message);
      }
    }

    final listRes = await _employeeService.getReport();
    if (mounted && listRes.success && listRes.data != null) {
      context.read<EmployeeProvider>().setReport(listRes.data!);
    }

    if (mounted) setState(() => _loading = false);
  }

  double _monthRate(EmployeeProvider ep) {
    final now = DateTime.now();
    final monthRecords = ep.report
        .where((e) => AttendanceTime.isInMonth(e['Date'] as String? ?? '', now))
        .toList();
    if (monthRecords.isEmpty) return 0;
    final present = monthRecords.where((e) => e['isPresent'] == true).length;
    return present / monthRecords.length * 100;
  }

  /// Builds a map of DateTime (date-only) → isPresent from report.
  Map<DateTime, bool> _buildPresenceMap(List<dynamic> report) {
    final map = <DateTime, bool>{};
    for (final e in report) {
      final dt = AttendanceTime.parseEntryDate(e['Date'] as String? ?? '');
      if (dt != null) {
        map[DateTime(dt.year, dt.month, dt.day)] = e['isPresent'] == true;
      }
    }
    return map;
  }

  /// Returns list of 7 DateTimes for Mon–Sun of the current week.
  List<DateTime> _currentWeekDays() {
    final today = DateTime(_now.year, _now.month, _now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  /// Counts consecutive present days going backwards from yesterday.
  int _calcStreak(Map<DateTime, bool> presenceMap) {
    int streak = 0;
    DateTime cursor = DateTime(_now.year, _now.month, _now.day)
        .subtract(const Duration(days: 1));
    while (true) {
      // Skip weekends in streak count
      if (cursor.weekday == DateTime.saturday ||
          cursor.weekday == DateTime.sunday) {
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      final present = presenceMap[cursor];
      if (present == true) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const _EmployeeDashboardSkeleton();
    }

    final ap = context.watch<AttendanceProvider>();
    final ep = context.watch<EmployeeProvider>();
    final monthRate = _monthRate(ep);
    final monthName = DateFormat('MMM').format(_now);
    final presenceMap = _buildPresenceMap(ep.report);
    final weekDays = _currentWeekDays();
    final streak = _calcStreak(presenceMap);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Today's stat card ──────────────────────────────
              _TodayCard(
                inTime: ap.inTimeDisplay,
                outTime: ap.outTime,
                isPresent: ap.isPresent,
                totalDays: ap.totalDays,
                date: DateFormat('EEEE, dd MMM').format(_now),
                monthRate: monthRate,
                monthName: monthName,
                weekDays: weekDays,
                presenceMap: presenceMap,
                streak: streak,
                today: DateTime(_now.year, _now.month, _now.day),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Quick actions ──────────────────────────────────
              Text('Quick Actions', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.sm),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.55,
                children: [
                  _ActionTile(
                    icon: Icons.fingerprint_rounded,
                    label: 'Mark Attendance',
                    subtitle: 'Punch in / out for today',
                    color: AppColors.secondary,
                    onTap: () => widget.onSwitchTab(1),
                  ),
                  _ActionTile(
                    icon: Icons.calendar_month_rounded,
                    label: 'History',
                    subtitle: 'Your attendance log',
                    color: AppColors.primary,
                    onTap: () => widget.onSwitchTab(2),
                  ),
                  _ActionTile(
                    icon: Icons.event_note_rounded,
                    label: 'My Leaves',
                    subtitle: 'Request & track leaves',
                    color: const Color(0xFFD97706),
                    onTap: () => widget.onSwitchTab(3),
                  ),
                ],
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

class _TodayCard extends StatelessWidget {
  final String inTime;
  final String outTime;
  final bool isPresent;
  final int totalDays;
  final String date;
  final double monthRate;
  final String monthName;
  final List<DateTime> weekDays;
  final Map<DateTime, bool> presenceMap;
  final int streak;
  final DateTime today;

  const _TodayCard({
    required this.inTime,
    required this.outTime,
    required this.isPresent,
    required this.totalDays,
    required this.date,
    required this.monthRate,
    required this.monthName,
    required this.weekDays,
    required this.presenceMap,
    required this.streak,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final isGoodRate = monthRate >= 75;
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
          // Date + status badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: AppTextStyles.caption
                    .copyWith(color: Colors.white.withValues(alpha: 0.75)),
              ),
              StatusBadge(
                label: isPresent ? 'Present' : 'Absent',
                status: isPresent ? BadgeStatus.success : BadgeStatus.error,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Punch times + days present
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TimeColumn(label: 'Punch In', value: inTime),
              Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.2)),
              _TimeColumn(label: 'Punch Out', value: outTime),
              Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.2)),
              _TimeColumn(
                  label: 'Days Present',
                  value: '${totalDays.clamp(0, 9999)}'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: AppSpacing.md),

          // ── 7-day mini bar chart ───────────────────────────
          _WeekBarChart(
            weekDays: weekDays,
            presenceMap: presenceMap,
            today: today,
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: AppSpacing.sm),

          // Month rate + streak row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Month rate
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$monthName Attendance',
                      style: AppTextStyles.caption
                          .copyWith(color: Colors.white.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(
                        value: (monthRate / 100).clamp(0, 1),
                        minHeight: 5,
                        color: isGoodRate ? AppColors.success : AppColors.error,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Attendance rate %
              Text(
                '${monthRate.toStringAsFixed(0)}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isGoodRate ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),

          // Streak badge — only show if streak > 0
          if (streak > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '$streak day streak — keep it up!',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFFFBBF24),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _WeekBarChart extends StatelessWidget {
  final List<DateTime> weekDays;
  final Map<DateTime, bool> presenceMap;
  final DateTime today;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _maxBarHeight = 32.0;

  const _WeekBarChart({
    required this.weekDays,
    required this.presenceMap,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final day = weekDays[i];
        final isToday = day == today;
        final isFuture = day.isAfter(today);
        final isWeekend = day.weekday == DateTime.saturday ||
            day.weekday == DateTime.sunday;
        final present = presenceMap[day];

        Color barColor;
        double barHeight;

        if (isWeekend) {
          barColor = Colors.white.withValues(alpha: 0.12);
          barHeight = _maxBarHeight * 0.25;
        } else if (isFuture) {
          barColor = Colors.white.withValues(alpha: 0.12);
          barHeight = _maxBarHeight * 0.3;
        } else if (isToday) {
          barColor = AppColors.secondary.withValues(alpha: 0.8);
          barHeight = _maxBarHeight * 0.65;
        } else if (present == true) {
          barColor = AppColors.success;
          barHeight = _maxBarHeight;
        } else if (present == false) {
          barColor = AppColors.error.withValues(alpha: 0.7);
          barHeight = _maxBarHeight * 0.4;
        } else {
          // No record yet (working day that passed without data)
          barColor = Colors.white.withValues(alpha: 0.15);
          barHeight = _maxBarHeight * 0.3;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 20,
              height: barHeight,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: isToday
                    ? Border.all(color: AppColors.secondary, width: 1.5)
                    : null,
              ),
            ),
            const SizedBox(height: 5),
            // Day label
            Text(
              _dayLabels[i],
              style: AppTextStyles.caption.copyWith(
                color: isToday
                    ? AppColors.secondary
                    : Colors.white.withValues(alpha: 0.6),
                fontWeight:
                    isToday ? FontWeight.w700 : FontWeight.w400,
                fontSize: 10,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final String label;
  final String value;

  const _TimeColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headline.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption
              .copyWith(color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis),
                Text(subtitle,
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton ─────────────────────────────────────────────────────────────────

class _EmployeeDashboardSkeleton extends StatelessWidget {
  const _EmployeeDashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today card
            const SkeletonBox.wide(height: 220, borderRadius: 16),
            const SizedBox(height: AppSpacing.lg),

            // Section title
            const SkeletonBox(width: 120, height: 16),
            const SizedBox(height: AppSpacing.sm),

            // Quick action grid
            Row(children: const [
              Expanded(child: SkeletonBox.wide(height: 80, borderRadius: 12)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: SkeletonBox.wide(height: 80, borderRadius: 12)),
            ]),
            const SizedBox(height: AppSpacing.sm),
            Row(children: const [
              Expanded(child: SkeletonBox.wide(height: 80, borderRadius: 12)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: SkeletonBox.wide(height: 80, borderRadius: 12)),
            ]),
            const SizedBox(height: AppSpacing.lg),

            // Attendance history card
            const SkeletonBox.wide(height: 160, borderRadius: 16),
          ],
        ),
      ),
    );
  }
}
