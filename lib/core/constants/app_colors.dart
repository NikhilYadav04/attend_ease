// ignore_for_file: constant_identifier_names

import 'dart:ui';

// Legacy constants — kept for backward compatibility
const Color DARK_BLUE = Color(0xFF28318C);
const Color BUTTON_COLOR_1 = Color(0xFF0CC09D);
const Color BUTTON_COLOR_2 = Color(0xFFE6F9F5);

const Color GRADIENT_1 = Color(0xFF1F354D);
const Color GRADIENT_2 = Color(0xFF305077);

const Color BG = Color(0xFF7647EB);

// Semantic design tokens
abstract class AppColors {
  // Brand
  static const Color primary = Color(0xFF28318C);
  static const Color primaryLight = Color(0xFF3B4FD8);
  static const Color primaryContainer = Color(0xFFDDE2FF);

  // Accent
  static const Color secondary = Color(0xFF0CC09D);
  static const Color secondaryLight = Color(0xFFE6F9F5);

  // Backgrounds
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F8);

  // Semantic
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFB8C00);

  // Text
  static const Color textPrimary = Color(0xFF1A1D2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFADB5BD);

  // Borders / dividers
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);
}
