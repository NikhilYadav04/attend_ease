import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/features/leave/providers/leave_provider.dart';
import 'package:attend_ease/features/leave/services/leave_service.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:attend_ease/shared/widgets/skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HrLeaveScreen extends StatefulWidget {
  const HrLeaveScreen({super.key});

  @override
  State<HrLeaveScreen> createState() => _HrLeaveScreenState();
}

class _HrLeaveScreenState extends State<HrLeaveScreen> {
  final LeaveService _service = LeaveService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchLeaves());
  }

  Future<void> _fetchLeaves() async {
    setState(() => _loading = true);
    final res = await _service.getPendingLeaves();
    if (!mounted) return;
    if (res.success && res.data != null) {
      context.read<LeaveProvider>().setPendingLeaves(res.data!);
    }
    setState(() => _loading = false);
  }

  Future<void> _action(String leaveId, String action) async {
    final res = await _service.actionLeave(leaveId, action);
    if (!mounted) return;
    if (res.success) {
      final label = action == 'approve' ? 'Approved' : 'Rejected';
      toastMessageSuccess(context, label, 'Leave request updated.');
      _fetchLeaves();
    } else {
      toastMessageError(context, 'Error!', res.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaves = context.watch<LeaveProvider>().pendingLeaves;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('Leave Requests', style: AppTextStyles.title),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _fetchLeaves,
          child: _loading
              ? const _LeaveListSkeleton(color: AppColors.primary)
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pending Requests', style: AppTextStyles.title),
                          Text('${leaves.length} pending',
                              style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (leaves.isEmpty)
                        AppCard(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xl),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 40,
                                    color: AppColors.textHint),
                                const SizedBox(height: AppSpacing.sm),
                                Text('No pending leave requests.',
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
                          itemCount: leaves.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final leave = leaves[index];
                            final id = leave['_id'] as String? ??
                                leave['id'] as String? ??
                                '';
                            return _PendingLeaveCard(
                              leave: leave,
                              onApprove: () => _action(id, 'approve'),
                              onReject: () => _action(id, 'reject'),
                            );
                          },
                        ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _PendingLeaveCard extends StatelessWidget {
  final dynamic leave;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingLeaveCard({
    required this.leave,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final name = leave['employeeName'] as String? ?? 'Employee';
    final type = leave['leaveType'] as String? ?? '—';
    final from = leave['fromDate'] as String? ?? '—';
    final to = leave['toDate'] as String? ?? '—';
    final reason = leave['reason'] as String? ?? '—';

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.primary),
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
                    Text(
                      '$type  •  $from → $to',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'Pending',
                  style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFFD97706),
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            reason,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Approve',
                  icon: Icons.check_rounded,
                  color: AppColors.success,
                  height: 38,
                  onPressed: onApprove,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PrimaryButton(
                  label: 'Reject',
                  icon: Icons.close_rounded,
                  color: AppColors.error,
                  height: 38,
                  onPressed: onReject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaveListSkeleton extends StatelessWidget {
  final Color color;
  const _LeaveListSkeleton({required this.color});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: List.generate(4, (_) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonBox.wide(height: 16, borderRadius: 6),
              SizedBox(height: 8),
              SkeletonBox(width: 200, height: 13, borderRadius: 6),
              SizedBox(height: 8),
              SkeletonBox(width: 120, height: 13, borderRadius: 6),
              SizedBox(height: 12),
              SkeletonBox.wide(height: 1, borderRadius: 0),
            ],
          ),
        )),
      ),
    );
  }
}
