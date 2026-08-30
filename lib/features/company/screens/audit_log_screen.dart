import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/company/services/company_service.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final CompanyService _service = CompanyService();
  final _displayFmt = DateFormat('dd MMM yyyy, hh:mm a');
  List<dynamic> _logs = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 1;
  int _totalPages = 1;

  static const _actionIcons = {
    'admin_added': Icons.admin_panel_settings_rounded,
    'admin_removed': Icons.admin_panel_settings_rounded,
    'employee_added': Icons.person_add_rounded,
    'employee_removed': Icons.person_remove_rounded,
    'bulk_import': Icons.upload_file_rounded,
    'leave_approved': Icons.event_available_rounded,
    'leave_rejected': Icons.event_busy_rounded,
    'correction_approved': Icons.edit_calendar_rounded,
    'correction_rejected': Icons.edit_calendar_rounded,
    'holiday_added': Icons.event_rounded,
    'holiday_removed': Icons.event_busy_rounded,
    'settings_updated': Icons.settings_rounded,
  };

  static const _actionLabels = {
    'admin_added': 'Admin added',
    'admin_removed': 'Admin removed',
    'employee_added': 'Employee added',
    'employee_removed': 'Employee removed',
    'bulk_import': 'Bulk import',
    'leave_approved': 'Leave approved',
    'leave_rejected': 'Leave rejected',
    'correction_approved': 'Correction approved',
    'correction_rejected': 'Correction rejected',
    'holiday_added': 'Holiday added',
    'holiday_removed': 'Holiday removed',
    'settings_updated': 'Settings updated',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchLogs());
  }

  Future<void> _fetchLogs() async {
    setState(() => _loading = true);
    final res = await _service.getAuditLog(page: 1);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() {
        _logs = res.data!['items'] as List<dynamic>? ?? [];
        _page = res.data!['page'] as int? ?? 1;
        _totalPages = res.data!['totalPages'] as int? ?? 1;
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _page >= _totalPages) return;
    setState(() => _loadingMore = true);
    final res = await _service.getAuditLog(page: _page + 1);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() {
        _logs = [..._logs, ...(res.data!['items'] as List<dynamic>? ?? [])];
        _page = res.data!['page'] as int? ?? _page;
        _totalPages = res.data!['totalPages'] as int? ?? _totalPages;
      });
    }
    setState(() => _loadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('Audit Log', style: AppTextStyles.title),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _fetchLogs,
          child: _loading
              ? const _AuditLogSkeleton()
              : _logs.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      children: [
                        AppCard(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.history_rounded,
                                    size: 36, color: AppColors.textHint),
                                const SizedBox(height: AppSpacing.sm),
                                Text('No activity recorded yet.',
                                    style: AppTextStyles.body
                                        .copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _logs.length + (_page < _totalPages ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        if (index == _logs.length) {
                          return Center(
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
                          );
                        }
                        final log = _logs[index];
                        final action = log['action'] as String? ?? '';
                        final actorName = log['actorName'] as String? ?? '';
                        final detail = log['detail'] as String?;
                        final createdAt = DateTime.tryParse(log['createdAt'] as String? ?? '');
                        return AppCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Icon(
                                  _actionIcons[action] ?? Icons.info_outline_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_actionLabels[action] ?? action,
                                        style: AppTextStyles.bodyMedium),
                                    if (detail != null && detail.isNotEmpty)
                                      Text(detail,
                                          style: AppTextStyles.caption
                                              .copyWith(color: AppColors.textSecondary)),
                                    const SizedBox(height: 2),
                                    Text(
                                      'by $actorName'
                                      '${createdAt != null ? ' · ${_displayFmt.format(createdAt.toLocal())}' : ''}',
                                      style: AppTextStyles.caption
                                          .copyWith(color: AppColors.textHint, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}

class _AuditLogSkeleton extends StatelessWidget {
  const _AuditLogSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: List.generate(5, (_) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: SkeletonBox.wide(height: 60, borderRadius: 12),
        )),
      ),
    );
  }
}
