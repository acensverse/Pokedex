import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    const scheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      surface: AppColors.cardBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      // Kill tap feedback app-wide: no ripple, highlight or hover tint.
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      textTheme: const TextTheme(
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        labelLarge: AppTypography.labelLarge,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.amber
              : Colors.grey.shade400,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.amber.withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardBackground,
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
