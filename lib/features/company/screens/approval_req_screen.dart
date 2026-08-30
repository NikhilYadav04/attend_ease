import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/features/company/services/company_service.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

class ApprovalReqScreen extends StatefulWidget {
  const ApprovalReqScreen({super.key});

  @override
  State<ApprovalReqScreen> createState() => _ApprovalReqScreenState();
}

class _ApprovalReqScreenState extends State<ApprovalReqScreen>
    with AutomaticKeepAliveClientMixin {
  final CompanyService _service = getIt<CompanyService>();
  List<dynamic> _staffList = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 1;
  int _totalPages = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final res = await _service.getCountList(page: 1);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() {
        _staffList = res.data!['items'] as List<dynamic>? ?? [];
        _page = res.data!['page'] as int? ?? 1;
        _totalPages = res.data!['totalPages'] as int? ?? 1;
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _page >= _totalPages) return;
    setState(() => _loadingMore = true);
    final res = await _service.getCountList(page: _page + 1);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() {
        _staffList = [
          ..._staffList,
          ...(res.data!['items'] as List<dynamic>? ?? []),
        ];
        _page = res.data!['page'] as int? ?? _page;
        _totalPages = res.data!['totalPages'] as int? ?? _totalPages;
      });
    }
    setState(() => _loadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final staffList = _staffList;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _fetch,
              child: staffList.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 120),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.history_rounded,
                                    size: 48, color: AppColors.textHint),
                                const SizedBox(height: AppSpacing.sm),
                                Text('No submissions yet.',
                                    style: AppTextStyles.body.copyWith(
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: [
                        Text('Staff Count History',
                            style: AppTextStyles.headline),
                        const SizedBox(height: AppSpacing.sm),
                        Text('${staffList.length} submissions',
                            style: AppTextStyles.caption),
                        const SizedBox(height: AppSpacing.md),

                        // Header row
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text('Date',
                                      style: AppTextStyles.label.copyWith(
                                          color: AppColors.textSecondary))),
                              Expanded(
                                  child: Text('Present',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.label.copyWith(
                                          color: AppColors.textSecondary))),
                              Expanded(
                                  child: Text('Total',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.label.copyWith(
                                          color: AppColors.textSecondary))),
                            ],
                          ),
                        ),

                        ...List.generate(staffList.length, (index) {
                          final item = staffList[index];
                          final count =
                              (item['totalCount'] as num? ?? 0).toInt();
                          final totalEmployees =
                              item['totalEmployees'] as num?;
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: AppCard(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryContainer,
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.sm),
                                          ),
                                          child: const Icon(
                                              Icons.calendar_today_rounded,
                                              color: AppColors.primary,
                                              size: 16),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Text(
                                            item['currentDate'] ?? '—',
                                            style: AppTextStyles.bodyMedium,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        '$count',
                                        style: AppTextStyles.title.copyWith(
                                            color: AppColors.secondary),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        totalEmployees != null
                                            ? '${totalEmployees.toInt()}'
                                            : '—',
                                        style: AppTextStyles.body.copyWith(
                                            color: AppColors.textSecondary),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        if (_page < _totalPages)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md),
                              child: _loadingMore
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary),
                                    )
                                  : TextButton(
                                      onPressed: _loadMore,
                                      child: Text('Load More',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                  color: AppColors.primary)),
                                    ),
                            ),
                          ),
                      ],
                    ),
            ),
    );
  }
}
