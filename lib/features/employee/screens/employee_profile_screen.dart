import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/attendance/providers/attendance_provider.dart';
import 'package:attend_ease/features/employee/providers/employee_provider.dart';
import 'package:attend_ease/features/auth/providers/auth_provider.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EmployeeProfileScreen extends StatelessWidget {
  const EmployeeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthProvider>();
    final ap = context.watch<AttendanceProvider>();
    final ep = context.watch<EmployeeProvider>();

    final name = session.eName ?? 'Employee';
    final id = session.eID ?? '—';
    final company = session.eCName ?? '—';

    // This month attendance
    final now = DateTime.now();
    final monthRecords = ep.report.where((e) {
      final parts = (e['Date'] as String? ?? '').split('/');
      if (parts.length != 3) return false;
      final month = int.tryParse(parts[1]) ?? 0;
      final yearShort = int.tryParse(parts[2]) ?? 0;
      final year = yearShort < 100 ? 2000 + yearShort : yearShort;
      return month == now.month && year == now.year;
    }).toList();

    final presentThisMonth =
        monthRecords.where((e) => e['isPresent'] == true).length;
    final monthRate = monthRecords.isEmpty
        ? 0.0
        : presentThisMonth / monthRecords.length * 100;
    final monthName = DateFormat('MMMM').format(now);
    final isGoodRate = monthRate >= 75;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('My Profile', style: AppTextStyles.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // ── Avatar hero ──────────────────────────────────────
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.secondaryLight,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'E',
                      style: AppTextStyles.display
                          .copyWith(color: AppColors.secondary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(name, style: AppTextStyles.headline),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'ID: $id',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.business_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(company, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Stats row ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg, horizontal: AppSpacing.md),
                    child: Column(
                      children: [
                        Text(
                          '${ap.totalDays.clamp(0, 9999)}',
                          style: AppTextStyles.stat,
                        ),
                        const SizedBox(height: 4),
                        Text('Total Days', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg, horizontal: AppSpacing.md),
                    child: Column(
                      children: [
                        Text(
                          '${monthRate.toStringAsFixed(0)}%',
                          style: AppTextStyles.stat.copyWith(
                            color: isGoodRate
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('$monthName Rate',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Details card ──────────────────────────────────────
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _InfoRow(
                      icon: Icons.person_rounded,
                      label: 'Full Name',
                      value: name),
                  const Divider(height: AppSpacing.lg),
                  _InfoRow(
                      icon: Icons.badge_rounded,
                      label: 'Employee ID',
                      value: id),
                  const Divider(height: AppSpacing.lg),
                  _InfoRow(
                      icon: Icons.business_rounded,
                      label: 'Company',
                      value: company),
                  const Divider(height: AppSpacing.lg),
                  _InfoRow(
                    icon: Icons.event_available_rounded,
                    label: 'Present This Month',
                    value:
                        '$presentThisMonth / ${monthRecords.length} days',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary)),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
