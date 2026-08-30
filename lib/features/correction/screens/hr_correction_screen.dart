import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/features/correction/providers/correction_provider.dart';
import 'package:attend_ease/features/correction/services/correction_service.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:attend_ease/shared/widgets/skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HrCorrectionScreen extends StatefulWidget {
  const HrCorrectionScreen({super.key});

  @override
  State<HrCorrectionScreen> createState() => _HrCorrectionScreenState();
}

class _HrCorrectionScreenState extends State<HrCorrectionScreen> {
  final CorrectionService _service = CorrectionService();
  final TextEditingController _searchCtrl = TextEditingController();
  bool _loading = true;
  bool _historyMode = false;
  bool _historyLoaded = false;
  bool _loadingMore = false;
  int _historyPage = 1;
  int _historyTotalPages = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCorrections());
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCorrections() async {
    setState(() => _loading = true);
    final res = await _service.getPendingCorrections();
    if (!mounted) return;
    if (res.success && res.data != null) {
      context.read<CorrectionProvider>().setPendingCorrections(res.data!);
    }
    setState(() => _loading = false);
  }

  Future<void> _fetchHistory() async {
    setState(() => _loading = true);
    final res = await _service.getAllCorrections(page: 1);
    if (!mounted) return;
    if (res.success && res.data != null) {
      context
          .read<CorrectionProvider>()
          .setAllCorrections(res.data!['items'] as List<dynamic>? ?? []);
      _historyPage = res.data!['page'] as int? ?? 1;
      _historyTotalPages = res.data!['totalPages'] as int? ?? 1;
    }
    setState(() {
      _loading = false;
      _historyLoaded = true;
    });
  }

  Future<void> _loadMoreHistory() async {
    if (_loadingMore || _historyPage >= _historyTotalPages) return;
    setState(() => _loadingMore = true);
    final res = await _service.getAllCorrections(page: _historyPage + 1);
    if (!mounted) return;
    if (res.success && res.data != null) {
      context
          .read<CorrectionProvider>()
          .appendAllCorrections(res.data!['items'] as List<dynamic>? ?? []);
      _historyPage = res.data!['page'] as int? ?? _historyPage;
      _historyTotalPages = res.data!['totalPages'] as int? ?? _historyTotalPages;
    }
    setState(() => _loadingMore = false);
  }

  void _switchMode(bool history) {
    if (_historyMode == history) return;
    setState(() => _historyMode = history);
    if (history && !_historyLoaded) _fetchHistory();
  }

  Future<void> _action(String correctionId, String action) async {
    final res = await _service.actionCorrection(correctionId, action);
    if (!mounted) return;
    if (res.success) {
      final label = action == 'approve' ? 'Approved' : 'Rejected';
      toastMessageSuccess(context, label, 'Correction request updated.');
      _fetchCorrections();
    } else {
      toastMessageError(context, 'Error!', res.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CorrectionProvider>();
    final corrections = _historyMode
        ? provider.allCorrections
            .where((c) => (c['status'] as String? ?? '') != 'Pending')
            .toList()
        : provider.pendingCorrections;
    final filteredCorrections = corrections.where((c) {
      final name = (c['employeeName'] as String? ?? '').toLowerCase();
      return _searchQuery.isEmpty || name.contains(_searchQuery);
    }).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('Correction Requests', style: AppTextStyles.title),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _historyMode ? _fetchHistory : _fetchCorrections,
          child: _loading
              ? const _CorrectionListSkeleton()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Row(
                        children: [
                          _ModeChip(
                            label: 'Pending',
                            selected: !_historyMode,
                            onTap: () => _switchMode(false),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _ModeChip(
                            label: 'History',
                            selected: _historyMode,
                            onTap: () => _switchMode(true),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_historyMode ? 'Past Requests' : 'Pending Requests',
                              style: AppTextStyles.title),
                          Text(
                              _historyMode
                                  ? '${filteredCorrections.length} total'
                                  : '${filteredCorrections.length} pending',
                              style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (filteredCorrections.isEmpty)
                        AppCard(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded,
                                    size: 40, color: AppColors.textHint),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                    corrections.isEmpty
                                        ? (_historyMode
                                            ? 'No past correction requests yet.'
                                            : 'No pending correction requests.')
                                        : 'No matches for "$_searchQuery".',
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
                          itemCount: filteredCorrections.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final correction = filteredCorrections[index];
                            if (_historyMode) {
                              return _HistoryCorrectionCard(correction: correction);
                            }
                            final id = correction['id'] as String? ?? '';
                            return _PendingCorrectionCard(
                              correction: correction,
                              onApprove: () => _action(id, 'approve'),
                              onReject: () => _action(id, 'reject'),
                            );
                          },
                        ),
                      if (_historyMode && _historyPage < _historyTotalPages)
                        Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            child: _loadingMore
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: AppColors.primary),
                                  )
                                : TextButton(
                                    onPressed: _loadMoreHistory,
                                    child: Text('Load More',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(color: AppColors.primary)),
                                  ),
                          ),
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

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.selected,
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
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _HistoryCorrectionCard extends StatelessWidget {
  final dynamic correction;

  const _HistoryCorrectionCard({required this.correction});

  @override
  Widget build(BuildContext context) {
    final name = correction['employeeName'] as String? ?? 'Employee';
    final date = correction['date'] as String? ?? '—';
    final inTime = correction['requestedInTime'] as String?;
    final outTime = correction['requestedOutTime'] as String?;
    final reason = correction['reason'] as String? ?? '—';
    final status = (correction['status'] as String? ?? '').toLowerCase();
    final isApproved = status == 'approved';
    final statusColor = isApproved ? AppColors.success : AppColors.error;
    final statusBg =
        isApproved ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E6);

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
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.bodyMedium, overflow: TextOverflow.ellipsis),
                    Text(
                      [
                        date,
                        if (inTime != null) 'In → $inTime',
                        if (outTime != null) 'Out → $outTime',
                      ].join('   •   '),
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  isApproved ? 'Approved' : 'Rejected',
                  style: AppTextStyles.caption
                      .copyWith(color: statusColor, fontWeight: FontWeight.w600),
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
        ],
      ),
    );
  }
}

class _PendingCorrectionCard extends StatelessWidget {
  final dynamic correction;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingCorrectionCard({
    required this.correction,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final name = correction['employeeName'] as String? ?? 'Employee';
    final date = correction['date'] as String? ?? '—';
    final inTime = correction['requestedInTime'] as String?;
    final outTime = correction['requestedOutTime'] as String?;
    final reason = correction['reason'] as String? ?? '—';

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
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.bodyMedium, overflow: TextOverflow.ellipsis),
                    Text(
                      [
                        date,
                        if (inTime != null) 'In → $inTime',
                        if (outTime != null) 'Out → $outTime',
                      ].join('   •   '),
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'Pending',
                  style: AppTextStyles.caption
                      .copyWith(color: const Color(0xFFD97706), fontWeight: FontWeight.w600),
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
