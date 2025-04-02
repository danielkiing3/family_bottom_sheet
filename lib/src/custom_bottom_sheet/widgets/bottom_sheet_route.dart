import 'package:family_bottom_sheet/src/custom_bottom_sheet/widgets/modal_sheet.dart';
import 'package:flutter/material.dart';

const double _defaultScrollControlDisabledMaxHeightRatio = 9.0 / 16.0;

class FamilyBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  FamilyBottomSheetRoute({
    required super.builder,
    required super.isScrollControlled,
    super.capturedThemes,
    super.barrierOnTapHint,
    super.backgroundColor,
    super.elevation,
    super.shape,
    super.clipBehavior,
    super.constraints,
    super.modalBarrierColor,
    super.isDismissible = true,
    super.enableDrag = true,
    super.showDragHandle,
    super.scrollControlDisabledMaxHeightRatio =
        _defaultScrollControlDisabledMaxHeightRatio,
    super.settings,
    super.requestFocus,
    super.transitionAnimationController,
    super.anchorPoint,
    super.useSafeArea = false,
    super.sheetAnimationStyle,
  });

  final ValueNotifier<EdgeInsets> _clipDetailsNotifier =
      ValueNotifier<EdgeInsets>(EdgeInsets.zero);

  /// Updates the details regarding how the [SemanticsNode.rect] (focus) of
  /// the barrier for this [ModalBottomSheetRoute] should be clipped.
  ///
  /// Returns true if the clipDetails did change and false otherwise.
  bool didChangeBarrierSemanticsClip(EdgeInsets newClipDetails) {
    if (_clipDetailsNotifier.value == newClipDetails) {
      return false;
    }
    _clipDetailsNotifier.value = newClipDetails;
    return true;
  }

  @override
  void dispose() {
    _clipDetailsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget content = DisplayFeatureSubScreen(
      anchorPoint: anchorPoint,
      child: FamilyModalSheet(
        route: this,
        pageIndexNotifier: ValueNotifier<int>(0),
        builder: builder,
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
