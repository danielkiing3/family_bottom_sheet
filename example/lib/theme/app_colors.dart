import 'package:flutter/material.dart';

//Copied from https://github.com/ksokolovskyi/family_theme_switcher
abstract class AppColors {
  static const lightBackground = Color(0xFFFFFFFF);

  static const lightSurface = Color(0xFFFFFFFF);

  static const lightSurfaceSecondary = Color(0xFFF7F8F9);

  static const lightScrim = Color(0x4C000000);

  static const lightTextDefault = Color(0xFF222222);

  static const lightTextWeak = Color(0xFF999999);

  static const lightIconDefault = Color(0xFFB3B3B3);

  static const lightIconHighlighted = Color(0xFF222222);

  static const lightBorderDefault = Color(0xFFF7F7F7);

  static const lightBorderGradient = [
    Color(0xFF00B2FF),
    Color(0xFF91E0FF),
    Color(0xFF00B2FF),
  ];

  static const lightSkeleton = Color(0xFFF5F5F5);

  static const darkBackground = Color(0xFF000000);

  static const darkSurface = Color.fromARGB(255, 28, 28, 28);

  static const darkSurfaceSecondary = Color.fromARGB(255, 52, 52, 52);

  static const darkScrim = Color(0xCC000000);

  static const darkTextDefault = Color(0xFFFFFFFF);

  static const darkTextWeak = Color(0xFF666666);

  static const darkIconDefault = Color(0xFF666666);

  static const darkIconHighlighted = Color.fromARGB(255, 132, 132, 132);

  static const darkBorderDefault = Color(0xFF323232);

  static const darkBorderGradient = [
    Color(0xFF797579),
    Color(0xFFFFFCFF),
    Color(0xFF797579),
  ];

  static const darkSkeleton = Color(0xFF292929);
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.scrim,
    required this.textDefault,
    required this.textWeak,
    required this.iconDefault,
    required this.iconHighlighted,
    required this.borderDefault,
    required this.borderGradient,
    required this.lightBorderGradient,
    required this.darkBorderGradient,
    required this.skeleton,
  });

  final Color background;

  final Color surface;

  final Color surfaceSecondary;

  final Color scrim;

  final Color textDefault;

  final Color textWeak;

  final Color iconDefault;

  final Color iconHighlighted;

  final Color borderDefault;

  final List<Color> borderGradient;

  final List<Color> lightBorderGradient;

  final List<Color> darkBorderGradient;

  final Color skeleton;

  @override
  AppColorsExtension copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSecondary,
    Color? scrim,
    Color? textDefault,
    Color? textWeak,
    Color? iconDefault,
    Color? iconHighlighted,
    Color? borderDefault,
    List<Color>? borderGradient,
    List<Color>? lightBorderGradient,
    List<Color>? darkBorderGradient,
    Color? skeleton,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      scrim: scrim ?? this.scrim,
      textDefault: textDefault ?? this.textDefault,
      textWeak: textWeak ?? this.textWeak,
      iconDefault: iconDefault ?? this.iconDefault,
      iconHighlighted: iconHighlighted ?? this.iconHighlighted,
      borderDefault: borderDefault ?? this.borderDefault,
      borderGradient: borderGradient ?? this.borderGradient,
      lightBorderGradient: lightBorderGradient ?? this.lightBorderGradient,
      darkBorderGradient: darkBorderGradient ?? this.darkBorderGradient,
      skeleton: skeleton ?? this.skeleton,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }

    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary:
          Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      textDefault: Color.lerp(textDefault, other.textDefault, t)!,
      textWeak: Color.lerp(textWeak, other.textWeak, t)!,
      iconDefault: Color.lerp(iconDefault, other.iconDefault, t)!,
      iconHighlighted: Color.lerp(iconHighlighted, other.iconHighlighted, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderGradient: [
        for (final (i, color) in borderGradient.indexed)
          Color.lerp(color, other.borderGradient[i], t)!,
      ],
      lightBorderGradient: lightBorderGradient,
      darkBorderGradient: darkBorderGradient,
      skeleton: Color.lerp(skeleton, other.skeleton, t)!,
    );
  }
}
