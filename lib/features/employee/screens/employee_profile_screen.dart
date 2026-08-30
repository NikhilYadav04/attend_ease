import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/core/utils/attendance_time.dart';
import 'package:attend_ease/features/attendance/providers/attendance_provider.dart';
import 'package:attend_ease/features/employee/providers/employee_provider.dart';
import 'package:attend_ease/features/employee/services/employee_service.dart';
import 'package:attend_ease/features/auth/providers/auth_provider.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/app_text_field.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  final EmployeeService _service = getIt<EmployeeService>();
  final TextEditingController _positionCtrl = TextEditingController();
  String? _position;
  bool _loadingPosition = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchProfile());
  }

  @override
  void dispose() {
    _positionCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    final res = await _service.getProfile();
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() => _position = res.data!['employeePosition'] as String?);
    }
    setState(() => _loadingPosition = false);
  }

  Future<void> _editPosition() async {
    _positionCtrl.text = _position ?? '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Edit Job Title', style: AppTextStyles.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _positionCtrl,
              label: 'Job Title',
              hint: 'e.g. Software Engineer',
              prefixIcon: Icons.work_outline_rounded,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            label: 'Save',
            width: 112,
            height: 40,
            icon: Icons.check_rounded,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final newPosition = _positionCtrl.text.trim();
    if (newPosition.isEmpty) return;

    setState(() => _saving = true);
    final res = await _service.updateProfile(newPosition);
    if (!mounted) return;
    setState(() => _saving = false);

    if (res.success) {
      setState(() => _position = newPosition);
      toastMessageSuccess(context, 'Updated', 'Job title updated.');
    } else {
      toastMessageError(context, 'Error!', res.message);
    }
  }

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
    final monthRecords = ep.report
        .where((e) => AttendanceTime.isInMonth(e['Date'] as String? ?? '', now))
        .toList();

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
                          style: AppTextStyles.stat
                              .copyWith(color: AppColors.primary),
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
                    icon: Icons.work_outline_rounded,
                    label: 'Job Title',
                    value: _loadingPosition
                        ? '…'
                        : ((_position == null || _position!.isEmpty)
                            ? '—'
                            : _position!),
                    trailing: IconButton(
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.primary),
                            )
                          : const Icon(Icons.edit_rounded,
                              size: 18, color: AppColors.primary),
                      onPressed: _saving ? null : _editPosition,
                    ),
                  ),
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
  final Widget? trailing;

  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.trailing});

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
              Text(value,
                  style: AppTextStyles.bodyMedium,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
