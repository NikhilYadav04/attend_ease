import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/company/providers/company_provider.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/features/company/services/company_service.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/skeleton_box.dart';
import 'package:attend_ease/shared/widgets/app_text_field.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:attend_ease/core/router/app_router.dart';
import 'package:provider/provider.dart';

class CompanyHrScreen1 extends StatefulWidget {
  final void Function(int tabIndex) onSwitchTab;

  const CompanyHrScreen1({super.key, required this.onSwitchTab});

  @override
  State<CompanyHrScreen1> createState() => _CompanyHrScreen1State();
}

class _CompanyHrScreen1State extends State<CompanyHrScreen1> {
  final CompanyService _service = getIt<CompanyService>();
  final DateTime _now = DateTime.now();
  bool _loading = true;

  final TextEditingController _callIDCtrl = TextEditingController();
  final TextEditingController _usernameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAll());
  }

  @override
  void dispose() {
    _callIDCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    await _getCount();
    await _getReport();
    await _getStaffReportList();
    await _getStaffHistory();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _getCount() async {
    final res = await _service.getCount();
    if (!mounted) return;
    final p = context.read<CompanyProvider>();
    p.setDate(DateFormat('dd MMMM').format(_now));
    if (res.success && res.data != null) {
      p.updateCounts(
        res.data!['inCount'] as int,
        res.data!['outCount'] as int,
        res.data!['totalCount'] as int,
      );
    }
  }

  Future<void> _getReport() async {
    final res = await _service.getStaff();
    if (!mounted) return;
    if (res.success && res.data != null) {
      context.read<CompanyProvider>().setStaffReport(res.data!);
    }
  }

  Future<void> _getStaffReportList() async {
    final res = await _service.getCountList();
    if (!mounted) return;
    if (res.success && res.data != null) {
      context.read<CompanyProvider>().setStaffList(res.data!);
    }
  }

  Future<void> _getStaffHistory() async {
    final res = await _service.getCountHistory('');
    if (!mounted) return;
    final p = context.read<CompanyProvider>();
    if (res.success) {
      p.setSubmit(res.data ?? false);
      if (res.data ?? false) p.resetCounts();
    } else {
      toastMessageError(context, 'Error', res.message);
    }
  }

  Future<void> _submit() async {
    final p = context.read<CompanyProvider>();
    final res = await _service.storeCountHistory(
        p.totalCount, DateFormat('dd MMMM').format(_now));
    if (!mounted) return;
    if (res.success) {
      toastMessageSuccess(context, 'Success!', 'Report submitted');
      p.setSubmit(true);
      p.resetCounts();
    } else {
      toastMessageError(context, 'Error!', res.message);
    }
  }

  void _showVideoDialog(String employeeName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Video Meet — $employeeName', style: AppTextStyles.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _callIDCtrl,
              label: 'Call ID',
              hint: 'Enter a room code',
              prefixIcon: Icons.meeting_room_rounded,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _usernameCtrl,
              label: 'Your Name',
              hint: 'Admin name',
              prefixIcon: Icons.person_rounded,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            label: 'Join',
            width: 90,
            height: 40,
            icon: Icons.video_call_rounded,
            onPressed: () {
              final callID = _callIDCtrl.text.trim();
              final username = _usernameCtrl.text.trim();
              if (callID.isEmpty || username.isEmpty) return;
              context.pop();
              context.push(AppRoutes.call,
                  extra: {'callID': callID, 'username': username});
              _callIDCtrl.clear();
              _usernameCtrl.clear();
            },
          ),
        ],
      ),
    );
  }

  /// Maps staffList entries (currentDate = 'dd MMMM') to current week days.
  Map<DateTime, int> _buildWeekCountMap(List<dynamic> staffList) {
    final map = <DateTime, int>{};
    final fmt = DateFormat('dd MMMM');
    for (final entry in staffList) {
      final dateStr = entry['currentDate'] as String? ?? '';
      try {
        // Parse as current year — dd MMMM has no year
        final parsed = fmt.parse(dateStr);
        final dt = DateTime(_now.year, parsed.month, parsed.day);
        map[DateTime(dt.year, dt.month, dt.day)] =
            (entry['totalCount'] as num? ?? 0).toInt();
      } catch (_) {}
    }
    return map;
  }

  List<DateTime> _currentWeekDays() {
    final today = DateTime(_now.year, _now.month, _now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _HrDashboardSkeleton();
    }

    final p = context.watch<CompanyProvider>();
    final totalStaff = p.reportStaff.length;
    final presentToday = p.inCount;
    final absentToday =
        totalStaff > 0 ? (totalStaff - presentToday).clamp(0, totalStaff) : 0;
    final presentRate =
        totalStaff > 0 ? (presentToday / totalStaff * 100) : 0.0;

    final weekCountMap = _buildWeekCountMap(p.staffList);
    final weekDays = _currentWeekDays();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetchAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Attendance stat card ─────────────────────────────
              _AttendanceCard(
                inCount: p.inCount,
                outCount: p.outCount,
                date: p.currentDate,
                isSubmit: p.isSubmit,
                presentRate: presentRate,
                onSubmit: _submit,
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── KPI chips ────────────────────────────────────────
              Row(
                children: [
                  _KpiChip(
                    label: 'Total Staff',
                    value: '$totalStaff',
                    color: AppColors.primary,
                    icon: Icons.people_rounded,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _KpiChip(
                    label: 'Present',
                    value: '$presentToday',
                    color: AppColors.success,
                    icon: Icons.how_to_reg_rounded,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _KpiChip(
                    label: 'Absent',
                    value: '$absentToday',
                    color: AppColors.error,
                    icon: Icons.person_off_rounded,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Week trend ───────────────────────────────────────
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('This Week', style: AppTextStyles.title),
                        Text('Daily attendance count',
                            style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _WeekTrendChart(
                      weekDays: weekDays,
                      countMap: weekCountMap,
                      today: DateTime(_now.year, _now.month, _now.day),
                      totalStaff: totalStaff,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Quick actions ────────────────────────────────────
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
                    icon: Icons.person_add_rounded,
                    label: 'Add Staff',
                    subtitle: 'Register a new employee',
                    color: AppColors.primary,
                    onTap: () => context.push(AppRoutes.companyAddStaff),
                  ),
                  _ActionTile(
                    icon: Icons.bar_chart_rounded,
                    label: 'Staff Report',
                    subtitle: 'View attendance stats',
                    color: const Color(0xFF7C3AED),
                    onTap: () => widget.onSwitchTab(2),
                  ),
                  _ActionTile(
                    icon: Icons.video_call_rounded,
                    label: 'Video Meet',
                    subtitle: 'Start a live session',
                    color: const Color(0xFF0284C7),
                    onTap: () => _showVideoDialog('Team'),
                  ),
                  _ActionTile(
                    icon: Icons.history_rounded,
                    label: 'History',
                    subtitle: 'Count submission logs',
                    color: AppColors.secondary,
                    onTap: () => widget.onSwitchTab(1),
                  ),
                  _ActionTile(
                    icon: Icons.event_note_rounded,
                    label: 'Leave Requests',
                    subtitle: 'Approve or reject leaves',
                    color: const Color(0xFFD97706),
                    onTap: () => context.push(AppRoutes.companyLeaveRequests),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Staff overview ───────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Staff Overview', style: AppTextStyles.title),
                  Text('${p.reportStaff.length} employees',
                      style: AppTextStyles.caption),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (p.reportStaff.isEmpty)
                _EmptyState(
                  icon: Icons.people_outline_rounded,
                  message: 'No staff data yet.\nAdd staff to get started.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: p.reportStaff.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final staff = p.reportStaff[index];
                    final name = staff['employeeName'] ?? '';
                    final daysPresent =
                        (staff['daysPresent'] as num? ?? 0).toInt() % 30;
                    final percent = (daysPresent / 30 * 100);
                    return _StaffRow(
                      name: name,
                      percent: percent,
                      onNotify: () => _service.sendNotify(name),
                      onMeet: () => _showVideoDialog(name),
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

// ── Week trend chart ─────────────────────────────────────────────────────────

class _WeekTrendChart extends StatelessWidget {
  final List<DateTime> weekDays;
  final Map<DateTime, int> countMap;
  final DateTime today;
  final int totalStaff;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _maxBarHeight = 72.0;

  const _WeekTrendChart({
    required this.weekDays,
    required this.countMap,
    required this.today,
    required this.totalStaff,
  });

  @override
  Widget build(BuildContext context) {
    // Find the max count this week to normalise bar heights
    final counts = weekDays.map((d) => countMap[d] ?? 0).toList();
    final maxCount = counts.reduce((a, b) => a > b ? a : b);
    final normaliser = maxCount > 0 ? maxCount.toDouble() : 1.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final day = weekDays[i];
        final isToday = day == today;
        final isFuture = day.isAfter(today);
        final isWeekend = day.weekday == DateTime.saturday ||
            day.weekday == DateTime.sunday;
        final count = countMap[day] ?? 0;

        Color barColor;
        double barHeight;

        if (isWeekend || isFuture) {
          barColor = AppColors.surfaceVariant;
          barHeight = _maxBarHeight * 0.15;
        } else if (isToday) {
          barColor = AppColors.primary.withValues(alpha: 0.5);
          barHeight = count > 0
              ? (_maxBarHeight * 0.55).clamp(12, _maxBarHeight)
              : _maxBarHeight * 0.15;
        } else if (count > 0) {
          final rate = totalStaff > 0 ? count / totalStaff : 0.5;
          barColor = rate >= 0.75 ? AppColors.success : AppColors.secondary;
          barHeight = (_maxBarHeight * (count / normaliser)).clamp(8, _maxBarHeight);
        } else {
          barColor = AppColors.error.withValues(alpha: 0.35);
          barHeight = _maxBarHeight * 0.12;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Count label above bar
            Text(
              (isWeekend || isFuture || count == 0) ? '' : '$count',
              style: AppTextStyles.caption.copyWith(
                color: isToday ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 3),
            // Bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: 28,
              height: barHeight,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: isToday
                    ? Border.all(color: AppColors.primary, width: 1.5)
                    : null,
              ),
            ),
            const SizedBox(height: 5),
            // Day label
            Text(
              _dayLabels[i],
              style: AppTextStyles.caption.copyWith(
                color: isToday
                    ? AppColors.primary
                    : AppColors.textSecondary,
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

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _AttendanceCard extends StatelessWidget {
  final int inCount;
  final int outCount;
  final String date;
  final bool isSubmit;
  final double presentRate;
  final VoidCallback onSubmit;

  const _AttendanceCard({
    required this.inCount,
    required this.outCount,
    required this.date,
    required this.isSubmit,
    required this.presentRate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isGood = presentRate >= 75;
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatColumn(label: 'In', value: '$inCount'),
              _Separator(),
              _StatColumn(label: 'Out', value: '$outCount'),
              _Separator(),
              _StatColumn(label: 'Total', value: '${inCount + outCount}'),
              _Separator(),
              _StatColumn(label: 'Date', value: date, small: true),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Present Rate',
                style: AppTextStyles.caption
                    .copyWith(color: Colors.white.withValues(alpha: 0.7)),
              ),
              Text(
                presentRate > 0
                    ? '${presentRate.toStringAsFixed(0)}%'
                    : '—',
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
              value: (presentRate / 100).clamp(0, 1),
              minHeight: 5,
              color: isGood ? AppColors.success : AppColors.error,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: isSubmit ? 'Submitted' : 'Submit Attendance',
            onPressed: isSubmit ? null : onSubmit,
            color: isSubmit
                ? Colors.white.withValues(alpha: 0.2)
                : AppColors.secondary,
            height: 42,
            icon: isSubmit
                ? Icons.check_circle_rounded
                : Icons.upload_rounded,
          ),
        ],
      ),
    );
  }
}

class _KpiChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _KpiChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: AppTextStyles.title.copyWith(color: color),
                      overflow: TextOverflow.ellipsis),
                  Text(label,
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      height: 40, width: 1, color: Colors.white.withValues(alpha: 0.2));
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool small;

  const _StatColumn(
      {required this.label, required this.value, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: small
              ? AppTextStyles.title.copyWith(color: Colors.white)
              : AppTextStyles.stat,
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

class _StaffRow extends StatelessWidget {
  final String name;
  final double percent;
  final VoidCallback onNotify;
  final VoidCallback onMeet;

  const _StaffRow({
    required this.name,
    required this.percent,
    required this.onNotify,
    required this.onMeet,
  });

  @override
  Widget build(BuildContext context) {
    final isGood = percent >= 75;
    return AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: LinearProgressIndicator(
                          value: (percent / 100).clamp(0, 1),
                          minHeight: 5,
                          color: isGood ? AppColors.success : AppColors.error,
                          backgroundColor: AppColors.surfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${percent.toStringAsFixed(0)}%',
                      style: AppTextStyles.caption.copyWith(
                        color: isGood ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: onNotify,
            icon: Icon(Icons.notifications_rounded,
                color: isGood ? AppColors.success : AppColors.error, size: 20),
            tooltip: 'Send alert',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: onMeet,
            icon: const Icon(Icons.video_call_rounded,
                color: Color(0xFF0284C7), size: 20),
            tooltip: 'Video meet',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.sm),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _HrDashboardSkeleton extends StatelessWidget {
  const _HrDashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            // Stat cards row
            Row(children: const [
              Expanded(child: SkeletonBox.wide(height: 90, borderRadius: 12)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: SkeletonBox.wide(height: 90, borderRadius: 12)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: SkeletonBox.wide(height: 90, borderRadius: 12)),
            ]),
            const SizedBox(height: AppSpacing.md),
            // Progress bar card
            const SkeletonBox.wide(height: 60, borderRadius: 12),
            const SizedBox(height: AppSpacing.md),
            // Submit button
            const SkeletonBox.wide(height: 48, borderRadius: 12),
            const SizedBox(height: AppSpacing.lg),
            // Chart title
            const SkeletonBox(width: 140, height: 16),
            const SizedBox(height: AppSpacing.sm),
            // Week bar chart
            const SkeletonBox.wide(height: 140, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}
