import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/leave/providers/leave_provider.dart';
import 'package:attend_ease/features/leave/screens/leave_request_screen.dart';
import 'package:attend_ease/features/leave/services/leave_service.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:attend_ease/shared/widgets/skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyLeavesScreen extends StatefulWidget {
  const MyLeavesScreen({super.key});

  @override
  State<MyLeavesScreen> createState() => _MyLeavesScreenState();
}

class _MyLeavesScreenState extends State<MyLeavesScreen>
    with AutomaticKeepAliveClientMixin {
  final LeaveService _service = LeaveService();
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchLeaves());
  }

  Future<void> _fetchLeaves() async {
    setState(() => _loading = true);
    final res = await _service.getMyLeaves();
    if (!mounted) return;
    if (res.success && res.data != null) {
      context.read<LeaveProvider>().setMyLeaves(res.data!);
    }
    setState(() => _loading = false);
  }

  Future<void> _openRequest() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LeaveRequestScreen()),
    );
    if (result == true) _fetchLeaves();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final leaves = context.watch<LeaveProvider>().myLeaves;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: _fetchLeaves,
        child: _loading
            ? const _MyLeaveSkeleton()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryButton(
                      label: 'Request Leave',
                      icon: Icons.add_rounded,
                      color: AppColors.secondary,
                      onPressed: _openRequest,
                      height: 46,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('My Requests', style: AppTextStyles.title),
                        Text('${leaves.length} total',
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
                              const Icon(Icons.event_busy_rounded,
                                  size: 40, color: AppColors.textHint),
                              const SizedBox(height: AppSpacing.sm),
                              Text('No leave requests yet.',
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
                        itemBuilder: (context, index) =>
                            _LeaveCard(leave: leaves[index]),
                      ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final dynamic leave;

  const _LeaveCard({required this.leave});

  @override
  Widget build(BuildContext context) {
    final type = leave['leaveType'] as String? ?? '—';
    final from = leave['fromDate'] as String? ?? '—';
    final to = leave['toDate'] as String? ?? '—';
    final reason = leave['reason'] as String? ?? '—';
    final status = (leave['status'] as String? ?? 'pending').toLowerCase();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _typeColor(type).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(_typeIcon(type), color: _typeColor(type), size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(type, style: AppTextStyles.bodyMedium),
                    _StatusChip(status: status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$from → $to',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'sick':
        return AppColors.error;
      case 'casual':
        return AppColors.secondary;
      case 'annual':
        return AppColors.primary;
      default:
        return const Color(0xFFD97706);
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'sick':
        return Icons.medical_services_rounded;
      case 'casual':
        return Icons.beach_access_rounded;
      case 'annual':
        return Icons.event_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;

    switch (status) {
      case 'approved':
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        label = 'Approved';
        break;
      case 'rejected':
        bg = AppColors.error.withValues(alpha: 0.12);
        fg = AppColors.error;
        label = 'Rejected';
        break;
      default:
        bg = const Color(0xFFFFF3CD);
        fg = const Color(0xFFD97706);
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption
            .copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MyLeaveSkeleton extends StatelessWidget {
  const _MyLeaveSkeleton();

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
