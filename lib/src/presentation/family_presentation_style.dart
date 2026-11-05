import 'package:flutter/widgets.dart';

import '../motion/family_motion.dart';

/// How [FamilyModalSheet.show] presents its pages: a bottom sheet, a centred
/// dialog or adaptive
///
/// ```dart
/// presentation: const FamilyPresentationStyle.adaptive(
///   dialog: FamilyDialogStyle(constraints: BoxConstraints(maxWidth: 520)),
/// ),
/// ```
sealed class FamilyPresentationStyle {
  const FamilyPresentationStyle();

  /// A sheet that slides up from the bottom of the screen.
  const factory FamilyPresentationStyle.sheet({
    bool enableDrag,
    bool dragFromScroll,
    bool useSafeArea,
    double maxHeightFactor,
    BoxConstraints constraints,
    FamilyMotion motion,
  }) = FamilySheetStyle;

  /// A dialog centred on screen.
  const factory FamilyPresentationStyle.dialog({
    BoxConstraints constraints,
    EdgeInsets insetPadding,
    bool useSafeArea,
    FamilyDialogAnchor anchor,
    FamilyMotion motion,
    RouteTransitionsBuilder? transitionBuilder,
  }) = FamilyDialogStyle;

  /// A dialog when the screen is at least [breakpoint] wide, and
  /// a sheet otherwise.
  const factory FamilyPresentationStyle.adaptive({
    double breakpoint,
    FamilySheetStyle sheet,
    FamilyDialogStyle dialog,
  }) = FamilyAdaptiveStyle;
}

/// Which edge of a dialog stays still as it resizes between pages.
///
/// The dialog opens centred. With [top] or [bottom], that edge then stays
/// where it is and the other one moves, the way a sheet keeps its bottom edge.
/// If a page doesn't fit, the dialog slides just enough to keep it on screen,
/// and stays there when it shrinks again. It re-centres when the screen's
/// width changes
enum FamilyDialogAnchor {
  /// The header stays still and the dialog grows and shrinks downward.
  top,

  /// The dialog grows and shrinks around its middle.
  center,

  /// The bottom edge stays still.
  bottom,
}

/// A presentation that doesn't change with the screen: a sheet or a dialog.
sealed class FamilyFixedPresentationStyle extends FamilyPresentationStyle {
  const FamilyFixedPresentationStyle();
}

class FamilySheetStyle extends FamilyFixedPresentationStyle {
  const FamilySheetStyle({
    this.enableDrag = true,
    this.dragFromScroll = true,
    this.useSafeArea = true,
    this.maxHeightFactor = 1.0,
    this.constraints = const BoxConstraints(maxWidth: 640),
    this.motion = const FamilyMotion.spring(),
  }) : assert(maxHeightFactor > 0 && maxHeightFactor <= 1);

  /// Whether dragging the sheet down closes it. When false, a drag still
  /// stretches the sheet a little and springs it back.
  final bool enableDrag;

  /// Whether pulling a list down past its top drags the sheet, and pushing
  /// the sheet back up hands the gesture back to the list. Only applies when
  /// [enableDrag] is true.
  final bool dragFromScroll;

  /// Whether to keep the sheet below the top system inset (status bar,
  /// notch). Bottom insets are left to the surface.
  final bool useSafeArea;

  /// The tallest the sheet can be, as a fraction of the available height.
  final double maxHeightFactor;

  /// The sheet's size limits. The default caps the width at 640 and centres
  /// the sheet, so it doesn't stretch across a tablet. Pass
  /// `BoxConstraints()` for a full-width sheet.
  final BoxConstraints constraints;

  /// How the sheet slides in and out, and settles after a drag. Defaults to a
  /// 400ms spring with no bounce, which keeps the finger's speed on release.
  final FamilyMotion motion;
}

class FamilyDialogStyle extends FamilyFixedPresentationStyle {
  const FamilyDialogStyle({
    this.constraints = const BoxConstraints(maxWidth: 440),
    this.insetPadding = const EdgeInsets.all(24),
    this.useSafeArea = true,
    this.anchor = FamilyDialogAnchor.top,
    this.motion = const FamilyMotion.spring(
      duration: Duration(milliseconds: 300),
    ),
    this.transitionBuilder,
  });

  /// Which edge stays still when the dialog changes size between pages.
  final FamilyDialogAnchor anchor;

  /// The dialog's size limits. Pages size the dialog within them.
  final BoxConstraints constraints;

  /// The space kept between the dialog and the screen edges.
  final EdgeInsets insetPadding;

  /// Whether to keep the dialog clear of system insets (notch, home bar).
  final bool useSafeArea;

  /// How the dialog appears and disappears. Defaults to a 300ms spring with
  /// no bounce.
  final FamilyMotion motion;

  /// Builds the dialog's own enter and exit transition from an animation
  /// already shaped by [motion]. Defaults to a fade with a slight scale up.
  final RouteTransitionsBuilder? transitionBuilder;
}

class FamilyAdaptiveStyle extends FamilyPresentationStyle {
  const FamilyAdaptiveStyle({
    this.breakpoint = 600,
    this.sheet = const FamilySheetStyle(),
    this.dialog = const FamilyDialogStyle(),
  });

  /// The screen width from which a dialog is shown instead of a sheet.
  final double breakpoint;

  final FamilySheetStyle sheet;
  final FamilyDialogStyle dialog;
}
