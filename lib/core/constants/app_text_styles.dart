import 'package:flutter/material.dart';
import 'package:attend_ease/core/constants/app_colors.dart';

abstract class AppTextStyles {
  // Display — page hero numbers, big headings
  static const TextStyle display = TextStyle(
    fontFamily: 'Kumbh',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // Headline — section titles, dialog headings
  static const TextStyle headline = TextStyle(
    fontFamily: 'Kumbh',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  // Title — card titles, list headings
  static const TextStyle title = TextStyle(
    fontFamily: 'Kumbh-Med',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body — default text
  static const TextStyle body = TextStyle(
    fontFamily: 'Kumbh',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Body medium — slightly emphasised body
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Kumbh-Med',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Caption — timestamps, helper text
  static const TextStyle caption = TextStyle(
    fontFamily: 'Kumbh',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Label — badge text, small tags
  static const TextStyle label = TextStyle(
    fontFamily: 'Kumbh-Med',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.4,
  );

  // Button — all button labels
  static const TextStyle button = TextStyle(
    fontFamily: 'Kumbh-Med',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  // Stat — large numbers in dashboard cards
  static const TextStyle stat = TextStyle(
    fontFamily: 'Kumbh',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -1,
  );
}
