import 'package:flutter/material.dart';

/// Palet warna aplikasi yang menyesuaikan Light / Dark Mode.
class AppColors {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color shadow;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.shadow,
  });

  static const light = AppColors(
    background: Color(0xFFF8FAFC),
    surface: Colors.white,
    surfaceAlt: Color(0xFFF1F5F9),
    border: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF334155),
    textMuted: Color(0xFF64748B),
    accent: Color(0xFF2563EB),
    shadow: Color(0x0F000000),
  );

  static const dark = AppColors(
    background: Color(0xFF0B1120),
    surface: Color(0xFF151E2E),
    surfaceAlt: Color(0xFF1E293B),
    border: Color(0xFF273449),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFFCBD5E1),
    textMuted: Color(0xFF94A3B8),
    accent: Color(0xFF60A5FA),
    shadow: Color(0x40000000),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppColors.light);
  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors c) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0284C7),
        brightness: brightness,
      ),
      scaffoldBackgroundColor: c.background,
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(backgroundColor: c.surface),
      dividerColor: c.border,
    );
  }
}
