import 'package:flutter/material.dart';
import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';

enum ButtonVariant { filled, outlined, ghost }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.filled,
    this.color,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary;

    switch (variant) {
      case ButtonVariant.outlined:
        return _OutlinedBtn(
          label: label,
          onPressed: onPressed,
          color: bg,
          height: height,
          width: width,
          icon: icon,
          isLoading: isLoading,
        );
      case ButtonVariant.ghost:
        return _GhostBtn(
          label: label,
          onPressed: onPressed,
          color: bg,
          height: height,
          width: width,
          isLoading: isLoading,
        );
      case ButtonVariant.filled:
        return _FilledBtn(
          label: label,
          onPressed: onPressed,
          color: bg,
          textColor: textColor,
          height: height,
          width: width,
          icon: icon,
          isLoading: isLoading,
        );
    }
  }
}

class _FilledBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color? textColor;
  final double height;
  final double? width;
  final IconData? icon;
  final bool isLoading;

  const _FilledBtn({
    required this.label,
    this.onPressed,
    required this.color,
    this.textColor,
    required this.height,
    this.width,
    this.icon,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.6),
          foregroundColor: textColor ?? Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(label, style: AppTextStyles.button),
                ],
              ),
      ),
    );
  }
}

class _OutlinedBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final double height;
  final double? width;
  final IconData? icon;
  final bool isLoading;

  const _OutlinedBtn({
    required this.label,
    this.onPressed,
    required this.color,
    required this.height,
    this.width,
    this.icon,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.button.copyWith(color: color),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GhostBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final double height;
  final double? width;
  final bool isLoading;

  const _GhostBtn({
    required this.label,
    this.onPressed,
    required this.color,
    required this.height,
    this.width,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(color: color),
        ),
      ),
    );
  }
}
