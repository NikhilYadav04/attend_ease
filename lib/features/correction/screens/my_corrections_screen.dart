import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/correction/providers/correction_provider.dart';
import 'package:attend_ease/features/correction/screens/correction_request_screen.dart';
import 'package:attend_ease/features/correction/services/correction_service.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:attend_ease/shared/widgets/skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCorrectionsScreen extends StatefulWidget {
  const MyCorrectionsScreen({super.key});

  @override
  State<MyCorrectionsScreen> createState() => _MyCorrectionsScreenState();
}

class _MyCorrectionsScreenState extends State<MyCorrectionsScreen> {
  final CorrectionService _service = CorrectionService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCorrections());
  }

  Future<void> _fetchCorrections() async {
    setState(() => _loading = true);
    final res = await _service.getMyCorrections();
    if (!mounted) return;
    if (res.success && res.data != null) {
      context.read<CorrectionProvider>().setMyCorrections(res.data!);
    }
    setState(() => _loading = false);
  }

  Future<void> _openRequest() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CorrectionRequestScreen()),
    );
    if (result == true) _fetchCorrections();
  }

  @override
  Widget build(BuildContext context) {
    final corrections = context.watch<CorrectionProvider>().myCorrections;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('Attendance Corrections', style: AppTextStyles.title),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: RefreshIndicator(
          color: AppColors.secondary,
          onRefresh: _fetchCorrections,
          child: _loading
              ? const _CorrectionListSkeleton()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimaryButton(
                        label: 'Request Correction',
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
                          Text('${corrections.length} total', style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (corrections.isEmpty)
                        AppCard(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.history_toggle_off_rounded,
                                    size: 40, color: AppColors.textHint),
                                const SizedBox(height: AppSpacing.sm),
                                Text('No correction requests yet.',
                                    style: AppTextStyles.body
                                        .copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: corrections.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) =>
                              _CorrectionCard(correction: corrections[index]),
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

class _CorrectionCard extends StatelessWidget {
  final dynamic correction;

  const _CorrectionCard({required this.correction});

  @override
  Widget build(BuildContext context) {
    final date = correction['date'] as String? ?? '—';
    final inTime = correction['requestedInTime'] as String?;
    final outTime = correction['requestedOutTime'] as String?;
    final reason = correction['reason'] as String? ?? '—';
    final status = (correction['status'] as String? ?? 'pending').toLowerCase();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.edit_calendar_rounded,
                color: Color(0xFFD97706), size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(date, style: AppTextStyles.bodyMedium),
                    _StatusChip(status: status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (inTime != null) 'In → $inTime',
                    if (outTime != null) 'Out → $outTime',
                  ].join('   '),
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
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
        style: AppTextStyles.caption.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CorrectionListSkeleton extends StatelessWidget {
  const _CorrectionListSkeleton();

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
