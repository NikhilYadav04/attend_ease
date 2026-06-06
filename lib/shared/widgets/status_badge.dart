import 'package:flutter/material.dart';
import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';

enum BadgeStatus { success, error, warning, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeStatus status;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.status = BadgeStatus.neutral,
    this.icon,
  });

  Color get _bg => switch (status) {
        BadgeStatus.success => const Color(0xFFDCFCE7),
        BadgeStatus.error => const Color(0xFFFFE4E6),
        BadgeStatus.warning => const Color(0xFFFFF7ED),
        BadgeStatus.neutral => AppColors.surfaceVariant,
      };

  Color get _fg => switch (status) {
        BadgeStatus.success => AppColors.success,
        BadgeStatus.error => AppColors.error,
        BadgeStatus.warning => AppColors.warning,
        BadgeStatus.neutral => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: _fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: _fg),
          ),
        ],
      ),
    );
  }
}
