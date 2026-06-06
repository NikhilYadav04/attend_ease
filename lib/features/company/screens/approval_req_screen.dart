import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/company/providers/company_provider.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ApprovalReqScreen extends StatelessWidget {
  const ApprovalReqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final staffList = context.watch<CompanyProvider>().staffList;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: staffList.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history_rounded,
                      size: 48, color: AppColors.textHint),
                  const SizedBox(height: AppSpacing.sm),
                  Text('No submissions yet.',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text('Staff Count History', style: AppTextStyles.headline),
                const SizedBox(height: AppSpacing.sm),
                Text('${staffList.length} submissions',
                    style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.md),

                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
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
                  final count = (item['totalCount'] as num? ?? 0).toInt();
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
                                '—',
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
              ],
            ),
    );
  }
}
