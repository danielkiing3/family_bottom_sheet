import 'package:flutter/widgets.dart';

import '../motion/family_motion.dart';

/// Picks the presentation to use right now. Called on every layout, so the
/// sheet follows the screen as it changes. It may return any presentation,
/// [FamilyPresentationStyle.adaptive] included.
///
/// Define it once, as a top-level or static function, not inline in `build`.
/// A function written inline is a new one on every rebuild, so a
/// [FamilySheetTheme] holding it would count as changed every time and rebuild
/// every open sheet.
///
/// ```dart
/// FamilyPresentationStyle appPresentation(BuildContext context) =>
///     MediaQuery.orientationOf(context) == Orientation.landscape
///         ? const FamilyPresentationStyle.sheet(
///             placement: FamilySheetPlacement.floating(),
///           )
///         : const FamilyPresentationStyle.sheet();
/// ```
typedef FamilyPresentationResolver = FamilyPresentationStyle Function(
  BuildContext context,
);

/// How [FamilyModalSheet.show] presents its pages: a sheet docked to the
/// bottom or floating in the middle, or one picked by the screen.
///
/// ```dart
/// presentation: const FamilyPresentationStyle.adaptive(),
/// ```
sealed class FamilyPresentationStyle {
  const FamilyPresentationStyle();

  /// A sheet that slides up from the bottom of the screen, docked to the
  /// bottom edge or floating in the middle depending on [placement].
  const factory FamilyPresentationStyle.sheet({
    FamilySheetPlacement placement,
    bool enableDrag,
    bool dragFromScroll,
    bool useSafeArea,
    double maxHeightFactor,
    FamilyMotion motion,
  }) = FamilySheetStyle;

  /// A sheet docked to the bottom on narrow screens and floating in the middle
  /// from [breakpoint] wide, this respond to layout size changes from MediaQuery.
  const factory FamilyPresentationStyle.adaptive({
    double breakpoint,
    bool enableDrag,
    bool dragFromScroll,
    bool useSafeArea,
    double maxHeightFactor,
    FamilyMotion motion,
    FamilyDockedPlacement docked,
    FamilyFloatingPlacement floating,
  }) = FamilyAdaptiveStyle;

  const factory FamilyPresentationStyle.resolve(
    FamilyPresentationResolver resolver,
  ) = FamilyResolvedStyle;

  FamilyPresentationStyle copyWith({
    bool? enableDrag,
    bool? dragFromScroll,
    bool? useSafeArea,
    double? maxHeightFactor,
    FamilyMotion? motion,
  });
}

/// Which edge stays still as a floating sheet resizes between pages.
enum FamilyAnchor {
  /// The header stays still and it grows and shrinks downward.
  top,

  /// It grows and shrinks around its middle.
  center,

  /// The bottom edge stays still.
  bottom,
}

/// This is the resting state of a sheet
sealed class FamilySheetPlacement {
  const FamilySheetPlacement();

  /// Against the bottom edge, the usual phone sheet.
  const factory FamilySheetPlacement.docked({double maxWidth}) =
      FamilyDockedPlacement;

  /// In the middle of the screen, the usual tablet sheet.
  const factory FamilySheetPlacement.floating({
    double maxWidth,
    FamilyAnchor anchor,
    EdgeInsets insetPadding,
  }) = FamilyFloatingPlacement;

  /// The widest the sheet can be, centered when wider than the current screen
  /// size
  double get maxWidth;
}

class FamilyDockedPlacement extends FamilySheetPlacement {
  const FamilyDockedPlacement({this.maxWidth = 640});

  @override
  final double maxWidth;

  FamilyDockedPlacement copyWith({double? maxWidth}) =>
      FamilyDockedPlacement(maxWidth: maxWidth ?? this.maxWidth);

  @override
  bool operator ==(Object other) =>
      other is FamilyDockedPlacement && other.maxWidth == maxWidth;

  @override
  int get hashCode => maxWidth.hashCode;
}

class FamilyFloatingPlacement extends FamilySheetPlacement {
  const FamilyFloatingPlacement({
    this.maxWidth = 540,
    this.anchor = FamilyAnchor.top,
    this.insetPadding = const EdgeInsets.all(24),
  });

  @override
  final double maxWidth;

  /// Which edge stays still as the sheet resizes between pages.
  final FamilyAnchor anchor;

  /// The space kept between the sheet and the screen edges.
  final EdgeInsets insetPadding;

  FamilyFloatingPlacement copyWith({
    double? maxWidth,
    FamilyAnchor? anchor,
    EdgeInsets? insetPadding,
  }) {
    return FamilyFloatingPlacement(
      maxWidth: maxWidth ?? this.maxWidth,
      anchor: anchor ?? this.anchor,
      insetPadding: insetPadding ?? this.insetPadding,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FamilyFloatingPlacement &&
      other.maxWidth == maxWidth &&
      other.anchor == anchor &&
      other.insetPadding == insetPadding;

  @override
  int get hashCode => Object.hash(maxWidth, anchor, insetPadding);
}

class FamilySheetStyle extends FamilyPresentationStyle {
  const FamilySheetStyle({
    this.placement = const FamilyDockedPlacement(),
    this.enableDrag = true,
    this.dragFromScroll = true,
    this.useSafeArea = true,
    this.maxHeightFactor = 1.0,
    this.motion = const FamilyMotion.spring(),
  }) : assert(maxHeightFactor > 0 && maxHeightFactor <= 1);

  /// Docked to the bottom edge or floating in the middle
  final FamilySheetPlacement placement;

  /// Whether dragging the sheet down closes it. When false, a drag still
  /// stretches the sheet a little and springs it back.
  final bool enableDrag;

  /// Whether pulling a list down past its top drags the sheet, and pushing
  /// the sheet back up hands the gesture back to the list. Only applies when
  /// [enableDrag] is true.
  final bool dragFromScroll;

  /// Whether to keep the sheet clear of system insets: below the status bar
  /// when docked, and clear of every edge when floating. A docked sheet leaves
  /// the bottom inset to its surface.
  final bool useSafeArea;

  /// The tallest the sheet can be, as a fraction of the available height.
  final double maxHeightFactor;

  /// How the sheet slides in and out, and settles after a drag. Defaults to a
  /// 400ms spring with no bounce, which keeps the finger's speed on release.
  final FamilyMotion motion;

  @override
  FamilySheetStyle copyWith({
    FamilySheetPlacement? placement,
    bool? enableDrag,
    bool? dragFromScroll,
    bool? useSafeArea,
    double? maxHeightFactor,
    FamilyMotion? motion,
  }) {
    return FamilySheetStyle(
      placement: placement ?? this.placement,
      enableDrag: enableDrag ?? this.enableDrag,
      dragFromScroll: dragFromScroll ?? this.dragFromScroll,
      useSafeArea: useSafeArea ?? this.useSafeArea,
      maxHeightFactor: maxHeightFactor ?? this.maxHeightFactor,
      motion: motion ?? this.motion,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FamilySheetStyle &&
      other.placement == placement &&
      other.enableDrag == enableDrag &&
      other.dragFromScroll == dragFromScroll &&
      other.useSafeArea == useSafeArea &&
      other.maxHeightFactor == maxHeightFactor &&
      other.motion == motion;

  @override
  int get hashCode => Object.hash(
        placement,
        enableDrag,
        dragFromScroll,
        useSafeArea,
        maxHeightFactor,
        motion,
      );
}

class FamilyAdaptiveStyle extends FamilyPresentationStyle {
  const FamilyAdaptiveStyle({
    this.breakpoint = 600,
    this.enableDrag = true,
    this.dragFromScroll = true,
    this.useSafeArea = true,
    this.maxHeightFactor = 1.0,
    this.motion = const FamilyMotion.spring(),
    this.docked = const FamilyDockedPlacement(),
    this.floating = const FamilyFloatingPlacement(),
  });

  /// The screen width from which the sheet floats instead of docking.
  final double breakpoint;

  final bool enableDrag;
  final bool dragFromScroll;
  final bool useSafeArea;
  final double maxHeightFactor;
  final FamilyMotion motion;

  /// What only applies while the sheet is docked.
  final FamilyDockedPlacement docked;

  /// What only applies while the sheet is floating.
  final FamilyFloatingPlacement floating;

  /// The sheet for a screen [width] wide.
  FamilySheetStyle sheetFor(double width) {
    return FamilySheetStyle(
      placement: width >= breakpoint ? floating : docked,
      enableDrag: enableDrag,
      dragFromScroll: dragFromScroll,
      useSafeArea: useSafeArea,
      maxHeightFactor: maxHeightFactor,
      motion: motion,
    );
  }

  @override
  FamilyAdaptiveStyle copyWith({
    double? breakpoint,
    bool? enableDrag,
    bool? dragFromScroll,
    bool? useSafeArea,
    double? maxHeightFactor,
    FamilyMotion? motion,
    FamilyDockedPlacement? docked,
    FamilyFloatingPlacement? floating,
  }) {
    return FamilyAdaptiveStyle(
      breakpoint: breakpoint ?? this.breakpoint,
      enableDrag: enableDrag ?? this.enableDrag,
      dragFromScroll: dragFromScroll ?? this.dragFromScroll,
      useSafeArea: useSafeArea ?? this.useSafeArea,
      maxHeightFactor: maxHeightFactor ?? this.maxHeightFactor,
      motion: motion ?? this.motion,
      docked: docked ?? this.docked,
      floating: floating ?? this.floating,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FamilyAdaptiveStyle &&
      other.breakpoint == breakpoint &&
      other.enableDrag == enableDrag &&
      other.dragFromScroll == dragFromScroll &&
      other.useSafeArea == useSafeArea &&
      other.maxHeightFactor == maxHeightFactor &&
      other.motion == motion &&
      other.docked == docked &&
      other.floating == floating;

  @override
  int get hashCode => Object.hash(
        breakpoint,
        enableDrag,
        dragFromScroll,
        useSafeArea,
        maxHeightFactor,
        motion,
        docked,
        floating,
      );
}

class FamilyResolvedStyle extends FamilyPresentationStyle {
  const FamilyResolvedStyle(this.resolver) : _changes = const _SharedChanges();

  const FamilyResolvedStyle._(this.resolver, this._changes);

  final FamilyPresentationResolver resolver;

  // Held as data rather than wrapped in a new function, so two identical
  // copies still compare equal.
  final _SharedChanges _changes;

  /// What [resolver] picks for [context], with any [copyWith] changes applied.
  /// It may still be adaptive or another resolve; the route resolves it the
  /// rest of the way.
  FamilyPresentationStyle resolve(BuildContext context) =>
      _changes.applyTo(resolver(context));

  @override
  FamilyResolvedStyle copyWith({
    bool? enableDrag,
    bool? dragFromScroll,
    bool? useSafeArea,
    double? maxHeightFactor,
    FamilyMotion? motion,
  }) {
    return FamilyResolvedStyle._(
      resolver,
      _SharedChanges(
        enableDrag: enableDrag ?? _changes.enableDrag,
        dragFromScroll: dragFromScroll ?? _changes.dragFromScroll,
        useSafeArea: useSafeArea ?? _changes.useSafeArea,
        maxHeightFactor: maxHeightFactor ?? _changes.maxHeightFactor,
        motion: motion ?? _changes.motion,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FamilyResolvedStyle &&
      other.resolver == resolver &&
      other._changes == _changes;

  @override
  int get hashCode => Object.hash(resolver, _changes);
}

class _SharedChanges {
  const _SharedChanges({
    this.enableDrag,
    this.dragFromScroll,
    this.useSafeArea,
    this.maxHeightFactor,
    this.motion,
  });

  final bool? enableDrag;
  final bool? dragFromScroll;
  final bool? useSafeArea;
  final double? maxHeightFactor;
  final FamilyMotion? motion;

  FamilyPresentationStyle applyTo(FamilyPresentationStyle style) {
    return style.copyWith(
      enableDrag: enableDrag,
      dragFromScroll: dragFromScroll,
      useSafeArea: useSafeArea,
      maxHeightFactor: maxHeightFactor,
      motion: motion,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _SharedChanges &&
      other.enableDrag == enableDrag &&
      other.dragFromScroll == dragFromScroll &&
      other.useSafeArea == useSafeArea &&
      other.maxHeightFactor == maxHeightFactor &&
      other.motion == motion;

  @override
  int get hashCode => Object.hash(
        enableDrag,
        dragFromScroll,
        useSafeArea,
        maxHeightFactor,
        motion,
      );
}
