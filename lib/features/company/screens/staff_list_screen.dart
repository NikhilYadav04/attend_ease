import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/core/router/app_router.dart';
import 'package:attend_ease/features/company/providers/company_provider.dart';
import 'package:attend_ease/features/company/screens/employee_attendance_screen.dart';
import 'package:attend_ease/features/company/services/company_service.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/app_text_field.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum _Filter { all, atRisk, good }

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  final CompanyService _service = getIt<CompanyService>();
  final TextEditingController _callIDCtrl = TextEditingController();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  _Filter _activeFilter = _Filter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _callIDCtrl.dispose();
    _usernameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  double _percent(dynamic staff) {
    final days = (staff['daysPresent'] as num? ?? 0).toInt() % 30;
    return (days / 30 * 100).clamp(0, 100);
  }

  Future<void> _sendNotify(String employeeName) async {
    final res = await _service.sendNotify(employeeName);
    if (!mounted) return;
    if (res.success) {
      toastMessageSuccess(context, 'Sent', 'Notification sent to $employeeName');
    } else {
      toastMessageError(context, 'Error', res.message);
    }
  }

  void _showVideoDialog(String employeeName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title:
            Text('Video Meet — $employeeName', style: AppTextStyles.title),
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

  @override
  Widget build(BuildContext context) {
    final reportStaff = context.watch<CompanyProvider>().reportStaff;

    if (reportStaff.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_outline_rounded,
                  size: 48, color: AppColors.textHint),
              const SizedBox(height: AppSpacing.sm),
              Text('No staff data yet.',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    // Sort: at-risk first, then by name
    final sorted = [...reportStaff]..sort((a, b) {
        final aRisk = _percent(a) < 75;
        final bRisk = _percent(b) < 75;
        if (aRisk && !bRisk) return -1;
        if (!aRisk && bRisk) return 1;
        return (a['employeeName'] as String? ?? '')
            .compareTo(b['employeeName'] as String? ?? '');
      });

    final atRiskCount = sorted.where((s) => _percent(s) < 75).length;
    final goodCount = sorted.length - atRiskCount;

    final filtered = sorted.where((s) {
      final name = (s['employeeName'] as String? ?? '').toLowerCase();
      if (_searchQuery.isNotEmpty && !name.contains(_searchQuery)) return false;
      if (_activeFilter == _Filter.atRisk) return _percent(s) < 75;
      if (_activeFilter == _Filter.good) return _percent(s) >= 75;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ── Search ───────────────────────────────────────────
          TextField(
            controller: _searchCtrl,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: 'Search by name…',
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.textSecondary, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textSecondary, size: 18),
                      onPressed: () => _searchCtrl.clear(),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm, horizontal: AppSpacing.md),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Header ────────────────────────────────────────────
          Text('Staff Report', style: AppTextStyles.headline),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              _SummaryPill(
                label: '$atRiskCount at risk',
                color: AppColors.error,
                icon: Icons.warning_amber_rounded,
              ),
              const SizedBox(width: AppSpacing.sm),
              _SummaryPill(
                label: '$goodCount good standing',
                color: AppColors.success,
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Filter chips ──────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All  ${sorted.length}',
                  selected: _activeFilter == _Filter.all,
                  color: AppColors.primary,
                  onTap: () => setState(() => _activeFilter = _Filter.all),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'At Risk  $atRiskCount',
                  selected: _activeFilter == _Filter.atRisk,
                  color: AppColors.error,
                  icon: Icons.warning_amber_rounded,
                  onTap: () =>
                      setState(() => _activeFilter = _Filter.atRisk),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Good Standing  $goodCount',
                  selected: _activeFilter == _Filter.good,
                  color: AppColors.success,
                  icon: Icons.check_circle_rounded,
                  onTap: () => setState(() => _activeFilter = _Filter.good),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Staff cards ───────────────────────────────────────
          if (filtered.isEmpty)
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text('No staff in this category.',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary)),
              ),
            )
          else
            ...filtered.map((staff) {
              final name = staff['employeeName'] as String? ?? '?';
              final empID = staff['employeeID'] as String? ?? '';
              final daysPresent =
                  (staff['daysPresent'] as num? ?? 0).toInt() % 30;
              final daysAbsent = (30 - daysPresent).clamp(0, 30);
              final percent = _percent(staff);
              final isGood = percent >= 75;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EmployeeAttendanceScreen(
                        employeeName: name,
                        employeeID: empID,
                        attendance: (staff['attendance'] as List<dynamic>? ?? []),
                        daysPresent: daysPresent,
                      ),
                    ),
                  ),
                  child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Name row ─────────────────────────────
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isGood
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFFE4E6),
                            child: Text(
                              name[0].toUpperCase(),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isGood
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
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
                                if (empID.isNotEmpty)
                                  Text(
                                    'ID: $empID',
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary),
                                  ),
                                Text(
                                  '$daysPresent days present · $daysAbsent absent',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          // Attendance % + at-risk badge
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${percent.toStringAsFixed(0)}%',
                                style: AppTextStyles.title.copyWith(
                                  color: isGood
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                              if (!isGood)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE4E6),
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.full),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                          Icons.warning_amber_rounded,
                                          size: 10,
                                          color: AppColors.error),
                                      const SizedBox(width: 2),
                                      Text(
                                        'At Risk',
                                        style:
                                            AppTextStyles.caption.copyWith(
                                          color: AppColors.error,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // ── Progress bar ─────────────────────────
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                        child: LinearProgressIndicator(
                          value: (percent / 100).clamp(0, 1),
                          minHeight: 6,
                          color:
                              isGood ? AppColors.success : AppColors.error,
                          backgroundColor: AppColors.surfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // ── Action buttons ───────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              label: 'Send Alert',
                              height: 36,
                              color: isGood
                                  ? AppColors.success
                                  : AppColors.error,
                              icon: Icons.notifications_rounded,
                              onPressed: () => _sendNotify(name),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: PrimaryButton(
                              label: 'Video Meet',
                              height: 36,
                              color: const Color(0xFF0284C7),
                              icon: Icons.video_call_rounded,
                              onPressed: () => _showVideoDialog(name),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : AppColors.surface,
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13,
                  color: selected ? color : AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: selected ? color : AppColors.textSecondary,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _SummaryPill({
    required this.label,
    required this.color,
    required this.icon,
  });

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
