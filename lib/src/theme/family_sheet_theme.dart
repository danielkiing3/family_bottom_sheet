import 'package:flutter/widgets.dart';

import '../motion/family_motion.dart';
import '../page_stack/family_page_transitions.dart';
import '../presentation/family_presentation.dart';
import '../presentation/family_presentation_style.dart';

/// Defaults for every [FamilyModalSheet.show] below a [FamilySheetTheme].
/// Anything passed to `show` itself wins.
@immutable
class FamilySheetThemeData {
  const FamilySheetThemeData({
    this.presentation,
    this.surfaceBuilder,
    this.pageTransitionBuilder,
    this.pageMotion,
    this.barrierColor,
    this.isDismissible,
  });

  /// How sheets are presented
  ///
  /// A custom resolver belongs in a top-level or static function, so this
  /// theme doesn't count as changed on every rebuild.
  final FamilyPresentationStyle? presentation;

  final FamilySurfaceBuilder? surfaceBuilder;

  /// Builds the transition for each page.
  ///
  /// {@macro family_bottom_sheet.page_transition_builder}
  final FamilyPageTransitionBuilder? pageTransitionBuilder;
  final FamilyMotion? pageMotion;
  final Color? barrierColor;
  final bool? isDismissible;

  FamilySheetThemeData copyWith({
    FamilyPresentationStyle? presentation,
    FamilySurfaceBuilder? surfaceBuilder,
    FamilyPageTransitionBuilder? pageTransitionBuilder,
    FamilyMotion? pageMotion,
    Color? barrierColor,
    bool? isDismissible,
  }) {
    return FamilySheetThemeData(
      presentation: presentation ?? this.presentation,
      surfaceBuilder: surfaceBuilder ?? this.surfaceBuilder,
      pageTransitionBuilder:
          pageTransitionBuilder ?? this.pageTransitionBuilder,
      pageMotion: pageMotion ?? this.pageMotion,
      barrierColor: barrierColor ?? this.barrierColor,
      isDismissible: isDismissible ?? this.isDismissible,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FamilySheetThemeData &&
      other.presentation == presentation &&
      other.surfaceBuilder == surfaceBuilder &&
      other.pageTransitionBuilder == pageTransitionBuilder &&
      other.pageMotion == pageMotion &&
      other.barrierColor == barrierColor &&
      other.isDismissible == isDismissible;

  @override
  int get hashCode => Object.hash(
        presentation,
        surfaceBuilder,
        pageTransitionBuilder,
        pageMotion,
        barrierColor,
        isDismissible,
      );
}

/// Sets the defaults for every [FamilyModalSheet.show] below it, so a call
/// only needs a `context` and a `builder`.
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => FamilySheetTheme(
///     data: FamilySheetThemeData(
///       presentation: const FamilyPresentationStyle.adaptive(),
///       surfaceBuilder: (context, child) => MySurface(child: child),
///     ),
///     child: child!,
///   ),
/// );
/// ```
class FamilySheetTheme extends InheritedTheme {
  const FamilySheetTheme({super.key, required this.data, required super.child});

  final FamilySheetThemeData data;

  /// The closest theme's data, or null without a [FamilySheetTheme] above.
  static FamilySheetThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FamilySheetTheme>()?.data;

  /// The closest theme's data, with what it leaves out filled in by the
  /// package defaults. Useful to change one thing for one sheet:
  ///
  /// ```dart
  /// presentation: FamilySheetTheme.of(context)
  ///     .presentation
  ///     .copyWith(enableDrag: false),
  /// ```
  static ResolvedFamilySheetThemeData of(BuildContext context) =>
      ResolvedFamilySheetThemeData._(maybeOf(context));

  @override
  Widget wrap(BuildContext context, Widget child) =>
      FamilySheetTheme(data: data, child: child);

  @override
  bool updateShouldNotify(FamilySheetTheme oldWidget) => data != oldWidget.data;
}

/// A [FamilySheetThemeData] with every gap filled by the package default, as
/// [FamilySheetTheme.of] returns it.
class ResolvedFamilySheetThemeData {
  const ResolvedFamilySheetThemeData._(this._data);

  final FamilySheetThemeData? _data;

  FamilyPresentationStyle get presentation =>
      _data?.presentation ?? const FamilySheetStyle();

  FamilySurfaceBuilder get surfaceBuilder =>
      _data?.surfaceBuilder ?? defaultFamilySurface;

  FamilyPageTransitionBuilder? get pageTransitionBuilder =>
      _data?.pageTransitionBuilder;

  FamilyMotion? get pageMotion => _data?.pageMotion;

  Color get barrierColor => _data?.barrierColor ?? defaultFamilyBarrierColor;

  bool get isDismissible => _data?.isDismissible ?? true;
}
