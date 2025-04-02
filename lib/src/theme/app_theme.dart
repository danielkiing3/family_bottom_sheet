import 'package:family_bottom_sheet/src/theme/app_colors.dart';
import 'package:family_bottom_sheet/src/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(),
      scaffoldBackgroundColor: AppColors.lightBackground,
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorderDefault,
        space: 0,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.lightSurfaceSecondary,
        border: OutlineInputBorder().copyWith(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      extensions: const [
        AppColorsExtension(
          background: AppColors.lightBackground,
          surface: AppColors.lightSurface,
          surfaceSecondary: AppColors.lightSurfaceSecondary,
          scrim: AppColors.lightScrim,
          textDefault: AppColors.lightTextDefault,
          textWeak: AppColors.lightTextWeak,
          iconDefault: AppColors.lightIconDefault,
          iconHighlighted: AppColors.lightIconHighlighted,
          borderDefault: AppColors.lightBorderDefault,
          borderGradient: AppColors.lightBorderGradient,
          lightBorderGradient: AppColors.lightBorderGradient,
          darkBorderGradient: AppColors.darkBorderGradient,
          skeleton: AppColors.lightSkeleton,
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: const ColorScheme.dark(),
      scaffoldBackgroundColor: AppColors.darkBackground,
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorderDefault,
        space: 0,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder().copyWith(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      extensions: const [
        AppColorsExtension(
          background: AppColors.darkBackground,
          surface: AppColors.darkSurface,
          surfaceSecondary: AppColors.darkSurfaceSecondary,
          scrim: AppColors.darkScrim,
          textDefault: AppColors.darkTextDefault,
          textWeak: AppColors.darkTextWeak,
          iconDefault: AppColors.darkIconDefault,
          iconHighlighted: AppColors.darkIconHighlighted,
          borderDefault: AppColors.darkBorderDefault,
          borderGradient: AppColors.darkBorderGradient,
          lightBorderGradient: AppColors.lightBorderGradient,
          darkBorderGradient: AppColors.darkBorderGradient,
          skeleton: AppColors.darkSkeleton,
        ),
      ],
    );
  }
}

extension AppThemeX on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>()!;

  AppTextStyles get textStyles => const AppTextStyles();
}
