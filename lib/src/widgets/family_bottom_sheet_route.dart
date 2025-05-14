import 'package:flutter/material.dart';

import '../family_modal_sheet.dart';
import 'family_bottom_sheet.dart';

final _defaultAnimationStyle = AnimationStyle(
  duration: const Duration(milliseconds: 200),
  reverseDuration: const Duration(milliseconds: 200),
);

/// A custom modal route for displaying a [FamilyBottomSheet].
///
/// This route provides additional configuration for styling and layout
/// of the bottom sheet's main content area.
class FamilyBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  FamilyBottomSheetRoute({
    required super.builder,
    required super.isScrollControlled,
    required this.scrollControlDisabledMaxHeightRatioValue,
    required this.contentBackgroundColor,
    super.capturedThemes,
    super.barrierOnTapHint,
    super.backgroundColor = Colors.transparent,
    super.elevation,
    super.shape,
    super.clipBehavior,
    super.constraints,
    super.modalBarrierColor,
    super.isDismissible = true,
    super.enableDrag = true,
    super.barrierLabel,
    super.showDragHandle,
    super.settings,
    super.transitionAnimationController,
    super.anchorPoint,
    super.useSafeArea = true,
    AnimationStyle? sheetAnimationStyle,
    this.safeAreaMinimum = const EdgeInsets.only(bottom: 4),
    this.mainContentPadding,
    this.mainContentBorderRadius,
    this.mainContentAnimationStyle,
  }) : super(
          sheetAnimationStyle: sheetAnimationStyle ?? _defaultAnimationStyle,
        );

  /// The background color of the bottom sheet's main content area.
  final Color contentBackgroundColor;

  /// Optional minimum padding to apply respecting the device's safe area.
  ///
  /// This is useful for adding consistent padding at the bottom
  /// (e.g., above system gestures).
  final EdgeInsets? safeAreaMinimum;

  /// Optional padding around the main content of the sheet.
  ///
  /// This padding is applied outside the content area.
  final EdgeInsets? mainContentPadding;

  /// Optional border radius for the main content container.
  ///
  /// This controls the rounding of the sheet's corners.
  final BorderRadius? mainContentBorderRadius;

  /// Optional animation style used when switching between pages
  /// inside the bottom sheet.
  ///
  /// Defines how content transitions are animated.
  final AnimationStyle? mainContentAnimationStyle;

  final double scrollControlDisabledMaxHeightRatioValue;

  final ValueNotifier<EdgeInsets> _clipInsetssNotifier =
      ValueNotifier<EdgeInsets>(EdgeInsets.zero);

  /// Updates the details regarding how the [SemanticsNode.rect] (focus) of
  /// the barrier for this [ModalBottomSheetRoute] should be clipped.
  ///
  /// Returns true if the clipDetails did change and false otherwise.
  bool didChangeBarrierSemanticsClip(EdgeInsets newClipInsets) {
    if (_clipInsetssNotifier.value == newClipInsets) {
      return false;
    }
    _clipInsetssNotifier.value = newClipInsets;
    return true;
  }

  @override
  void dispose() {
    _clipInsetssNotifier.dispose();
    super.dispose();
  }

  /// The animation controller that controls the modal sheet's entrance and
  /// exit animations.
  AnimationController? animationController;

  @override
  AnimationController createAnimationController() {
    assert(animationController == null);
    if (transitionAnimationController != null) {
      animationController = transitionAnimationController;
      willDisposeAnimationController = false;
    } else {
      animationController = FamilyBottomSheet.createAnimationController(
        navigator!,
        sheetAnimationStyle: sheetAnimationStyle,
      );
    }
    return animationController!;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final BottomSheetThemeData sheetTheme = Theme.of(context).bottomSheetTheme;

    final Widget content = DisplayFeatureSubScreen(
      anchorPoint: anchorPoint,
      child: FamilyModalSheet(
        route: this,
        builder: builder,
        isScrollControlled: isScrollControlled,
        scrollControlDisabledMaxHeightRatio:
            scrollControlDisabledMaxHeightRatioValue,
        backgroundColor: backgroundColor ??
            sheetTheme.modalBackgroundColor ??
            sheetTheme.backgroundColor,
        elevation:
            elevation ?? sheetTheme.modalElevation ?? sheetTheme.elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        constraints: constraints,
        enableDrag: enableDrag,
        showDragHandle: showDragHandle ??
            (enableDrag && (sheetTheme.showDragHandle ?? false)),
        safeAreaMinimum: safeAreaMinimum,
      ),
    );

    final Widget bottomSheet = useSafeArea
        ? SafeArea(bottom: false, child: content)
        : MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: content,
          );

    return capturedThemes?.wrap(bottomSheet) ?? bottomSheet;
  }
}
