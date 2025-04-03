import 'package:family_bottom_sheet/src/custom_bottom_sheet/widgets/modal_sheet.dart';
import 'package:flutter/material.dart';

class FamilyBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  final EdgeInsets? safeAreaMinimum;
  final Color contentBackgroundColor;

  FamilyBottomSheetRoute({
    required super.builder,
    required super.isScrollControlled,
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
    super.requestFocus,
    super.transitionAnimationController,
    super.anchorPoint,
    super.useSafeArea = true,
    AnimationStyle? sheetAnimationStyle,
    this.safeAreaMinimum = const EdgeInsets.only(bottom: 4),
  }) : super(
         sheetAnimationStyle:
             sheetAnimationStyle ??
             AnimationStyle(
               duration: const Duration(milliseconds: 200),
               reverseDuration: const Duration(milliseconds: 200),
             ),
       );

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

  AnimationController? animationController;

  @override
  AnimationController createAnimationController() {
    assert(animationController == null);
    if (transitionAnimationController != null) {
      animationController = transitionAnimationController;
      willDisposeAnimationController = false;
    } else {
      animationController = BottomSheet.createAnimationController(
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
        pageIndexNotifier: ValueNotifier<int>(0),
        builder: builder,
        isScrollControlled: isScrollControlled,
        backgroundColor:
            backgroundColor ??
            sheetTheme.modalBackgroundColor ??
            sheetTheme.backgroundColor,
        elevation:
            elevation ?? sheetTheme.modalElevation ?? sheetTheme.elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        constraints: constraints,
        enableDrag: enableDrag,
        showDragHandle:
            showDragHandle ??
            (enableDrag && (sheetTheme.showDragHandle ?? false)),
        safeAreaMinimum: safeAreaMinimum,
      ),
    );

    final Widget bottomSheet =
        useSafeArea
            ? SafeArea(bottom: false, child: content)
            : MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: content,
            );

    return capturedThemes?.wrap(bottomSheet) ?? bottomSheet;
  }
}
