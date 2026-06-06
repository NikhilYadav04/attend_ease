import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

Widget backgroundContainer(double currentWidth, double currentHeight) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary, Color(0xFF1A2070)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    height: currentHeight * 0.62,
  );
}

Widget titleWidget(double currentWidth, double currentHeight, double textScale,
    Animation<double> textAnimation) {
  return FadeTransition(
    opacity: textAnimation,
    child: const Text(
      'Attend Ease',
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'Tansek',
        fontSize: 36,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
  );
}

Widget welcomeText(double currentWidth, double currentHeight, double textScale,
    Animation<double> textAnimation) {
  return FadeTransition(
    opacity: textAnimation,
    child: Text(
      'Smart attendance management\nfor modern teams.',
      textAlign: TextAlign.center,
      style: AppTextStyles.body.copyWith(
        color: Colors.white.withValues(alpha: 0.82),
        fontSize: 15,
        height: 1.6,
      ),
    ),
  );
}

Widget Logo(double width, double height) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
    child: Image.asset(
      'assets/home_screen/table.png',
      height: height * 0.32,
      width: height * 0.32,
    ),
  );
}

Widget companyButton(void Function() onTap, double width, double height,
    double textScaleFactor, BuildContext context) {
  return _HomeActionButton(
    label: 'Create Company Account',
    icon: Icons.business_rounded,
    onTap: onTap,
    isPrimary: true,
  );
}

Widget existText(double width, double height, double textScaleFactor) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Text(
      'Join Existing Company',
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.primary,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.primary,
      ),
    ),
  );
}

Widget widgetDivider(double currentWidth, double currentHeight) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    child: Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text('or',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
        ),
        const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
      ],
    ),
  );
}

class _HomeActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _HomeActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        height: 52,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: isPrimary
              ? null
              : Border.all(color: AppColors.border, width: 1.5),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isPrimary ? Colors.white : AppColors.primary,
                size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: isPrimary ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
