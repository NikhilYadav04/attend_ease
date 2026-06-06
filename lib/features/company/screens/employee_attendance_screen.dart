import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

class EmployeeAttendanceScreen extends StatelessWidget {
  final String employeeName;
  final String employeeID;
  final List<dynamic> attendance;
  final int daysPresent;

  const EmployeeAttendanceScreen({
    super.key,
    required this.employeeName,
    required this.employeeID,
    required this.attendance,
    required this.daysPresent,
  });

  @override
  Widget build(BuildContext context) {
    // Sort records newest first
    final sorted = [...attendance]..sort((a, b) {
        final da = _parseDate(a['Date'] as String? ?? '');
        final db = _parseDate(b['Date'] as String? ?? '');
        return db.compareTo(da);
      });

    final total = sorted.length;
    final present = sorted.where((e) => e['isPresent'] == true).length;
    final rate = total == 0 ? 0.0 : present / total * 100;
    final isGood = rate >= 75;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(employeeName, style: AppTextStyles.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ── Summary card ──────────────────────────────────────────
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: isGood
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFFE4E6),
                      child: Text(
                        employeeName.isNotEmpty
                            ? employeeName[0].toUpperCase()
                            : '?',
                        style: AppTextStyles.headline.copyWith(
                          color: isGood ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(employeeName, style: AppTextStyles.bodyMedium),
                          if (employeeID.isNotEmpty)
                            Text('ID: $employeeID',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${rate.toStringAsFixed(0)}%',
                          style: AppTextStyles.headline.copyWith(
                            color: isGood ? AppColors.success : AppColors.error,
                          ),
                        ),
                        Text('attendance rate',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: (rate / 100).clamp(0.0, 1.0),
                    minHeight: 7,
                    color: isGood ? AppColors.success : AppColors.error,
                    backgroundColor: AppColors.surfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _StatPill(
                        label: '$present Present',
                        color: AppColors.success,
                        icon: Icons.check_circle_rounded),
                    const SizedBox(width: AppSpacing.sm),
                    _StatPill(
                        label: '${total - present} Absent',
                        color: AppColors.error,
                        icon: Icons.cancel_rounded),
                    const SizedBox(width: AppSpacing.sm),
                    _StatPill(
                        label: '$total Total',
                        color: AppColors.primary,
                        icon: Icons.calendar_month_rounded),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Records ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Attendance Log', style: AppTextStyles.title),
              Text('${sorted.length} records',
                  style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          if (sorted.isEmpty)
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.event_busy_rounded,
                        size: 36, color: AppColors.textHint),
                    const SizedBox(height: AppSpacing.sm),
                    Text('No attendance records yet.',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            ...sorted.map((record) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _AttendanceRow(record: record),
                )),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  DateTime _parseDate(String date) {
    // format: dd/MM/yy
    try {
      final parts = date.split('/');
      if (parts.length != 3) return DateTime(0);
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = 2000 + int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return DateTime(0);
    }
  }
}

class _AttendanceRow extends StatelessWidget {
  final dynamic record;
  const _AttendanceRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final date = record['Date'] as String? ?? '—';
    final inTime = record['InTime'] as String? ?? '—';
    final outTime = record['OutTime'] as String? ?? '—';
    final isPresent = record['isPresent'] as bool? ?? false;
    final hasOut = outTime != '00:00' && outTime != '—';

    String? hoursWorked;
    if (isPresent && hasOut) {
      hoursWorked = _calcHours(inTime, outTime);
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          // Date block
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPresent
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFFE4E6),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              isPresent
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: isPresent ? AppColors.success : AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: AppTextStyles.bodyMedium),
                if (isPresent) ...[
                  const SizedBox(height: 2),
                  Text(
                    'In $inTime  →  Out ${hasOut ? outTime : "—"}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  if (hoursWorked != null)
                    Text(
                      '$hoursWorked worked',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textHint),
                    ),
                ] else
                  Text('Absent',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.error)),
              ],
            ),
          ),

          // Status chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isPresent
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              isPresent ? 'Present' : 'Absent',
              style: AppTextStyles.caption.copyWith(
                color: isPresent ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _calcHours(String inTime, String outTime) {
    try {
      final inParts = inTime.split(':');
      final outParts = outTime.split(':');
      final inMins = int.parse(inParts[0]) * 60 + int.parse(inParts[1]);
      final outMins = int.parse(outParts[0]) * 60 + int.parse(outParts[1]);
      final diff = outMins - inMins;
      if (diff <= 0) return null;
      final h = diff ~/ 60;
      final m = diff % 60;
      if (h == 0) return '${m}m';
      if (m == 0) return '${h}h';
      return '${h}h ${m}m';
    } catch (_) {
      return null;
    }
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatPill(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
