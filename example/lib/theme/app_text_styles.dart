import 'package:flutter/material.dart';

class AppTextStyles {
  const AppTextStyles();

  static const _heading = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 26 / 20,
    letterSpacing: -0.6,
  );

  static const _bodySmall = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: -0.36,
  );

  static const _bodyLarge = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 26 / 18,
    letterSpacing: -0.36,
  );

  static const _labelSmall = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0,
  );

  static const _labelLarge = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 26 / 18,
    letterSpacing: -0.36,
  );

  TextStyle get heading => _heading;

  TextStyle get bodySmall => _bodySmall;

  TextStyle get bodyLarge => _bodyLarge;

  TextStyle get labelSmall => _labelSmall;

  TextStyle get labelLarge => _labelLarge;
}
