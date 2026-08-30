import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/router/app_router.dart';
import 'package:attend_ease/features/auth/providers/auth_provider.dart';
import 'package:attend_ease/features/company/providers/company_provider.dart';
import 'package:attend_ease/shared/utils/logout_helper.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final company = context.watch<CompanyProvider>();

    final name = auth.adminName ?? 'Admin';
    final cName = auth.cName ?? '—';
    final cID = auth.cID ?? '—';
    final inCount = company.inCount;
    final outCount = company.outCount;
    final totalCount = company.totalCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Admin Profile', style: AppTextStyles.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // ── Avatar hero ───────────────────────────────────────────
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'A',
                      style: AppTextStyles.display
                          .copyWith(color: AppColors.primary),
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
                      'Administrator',
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
                      Text(cName, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Today's live stats ────────────────────────────────────
            Row(
              children: [
                _StatCard(
                  label: 'In',
                  value: '$inCount',
                  color: AppColors.success,
                  icon: Icons.login_rounded,
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatCard(
                  label: 'Out',
                  value: '$outCount',
                  color: AppColors.error,
                  icon: Icons.logout_rounded,
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatCard(
                  label: 'Total',
                  value: '$totalCount',
                  color: AppColors.primary,
                  icon: Icons.people_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Company details ───────────────────────────────────────
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.business_rounded,
                    label: 'Company Name',
                    value: cName,
                  ),
                  const Divider(height: AppSpacing.lg),
                  _CopyRow(
                    icon: Icons.badge_rounded,
                    label: 'Company ID',
                    value: cID,
                    onCopy: () {
                      Clipboard.setData(ClipboardData(text: cID));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Company ID copied'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const Divider(height: AppSpacing.lg),
                  _InfoRow(
                    icon: Icons.person_rounded,
                    label: 'Admin Name',
                    value: name,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Actions ───────────────────────────────────────────────
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.my_location_rounded,
                    label: 'Manage Office Location',
                    color: AppColors.secondary,
                    onTap: () => context.push(
                      AppRoutes.companyLocation,
                      extra: <String, dynamic>{
                        'companyName': cName,
                        'isEditing': true,
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  _ActionTile(
                    icon: Icons.event_note_rounded,
                    label: 'Leave Requests',
                    color: AppColors.primary,
                    onTap: () => context.push(AppRoutes.companyLeaveRequests),
                  ),
                  const Divider(height: 1, indent: 56),
                  _ActionTile(
                    icon: Icons.calendar_month_rounded,
                    label: 'Team Leave Calendar',
                    color: AppColors.secondary,
                    onTap: () => context.push(AppRoutes.companyTeamLeaveCalendar),
                  ),
                  const Divider(height: 1, indent: 56),
                  _ActionTile(
                    icon: Icons.edit_calendar_rounded,
                    label: 'Correction Requests',
                    color: const Color(0xFF0D9488),
                    onTap: () => context.push(AppRoutes.companyCorrectionRequests),
                  ),
                  const Divider(height: 1, indent: 56),
                  _ActionTile(
                    icon: Icons.admin_panel_settings_rounded,
                    label: 'Manage Admins',
                    color: AppColors.secondary,
                    onTap: () => context.push(AppRoutes.companyManageAdmins),
                  ),
                  const Divider(height: 1, indent: 56),
                  _ActionTile(
                    icon: Icons.event_rounded,
                    label: 'Company Holidays',
                    color: const Color(0xFF0D9488),
                    onTap: () => context.push(AppRoutes.companyHolidays),
                  ),
                  const Divider(height: 1, indent: 56),
                  _ActionTile(
                    icon: Icons.history_rounded,
                    label: 'Audit Log',
                    color: AppColors.textSecondary,
                    onTap: () => context.push(AppRoutes.companyAuditLog),
                  ),
                  const Divider(height: 1, indent: 56),
                  _ActionTile(
                    icon: Icons.settings_rounded,
                    label: 'Company Settings',
                    color: AppColors.textSecondary,
                    onTap: () => context.push(AppRoutes.companySettings),
                  ),
                  const Divider(height: 1, indent: 56),
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    color: AppColors.error,
                    onTap: () => performLogout(context),
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

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
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
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyles.headline.copyWith(color: color)),
            Text(label, style: AppTextStyles.caption),
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

class _CopyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _CopyRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onCopy,
  });

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
        IconButton(
          icon: const Icon(Icons.copy_rounded,
              size: 18, color: AppColors.textSecondary),
          onPressed: onCopy,
          tooltip: 'Copy ID',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(label, style: AppTextStyles.bodyMedium),
      trailing: Icon(Icons.chevron_right_rounded,
          size: 18, color: AppColors.textSecondary),
    );
  }
}
