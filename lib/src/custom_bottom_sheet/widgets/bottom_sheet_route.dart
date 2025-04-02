import 'package:family_bottom_sheet/src/custom_bottom_sheet/widgets/modal_sheet.dart';
import 'package:flutter/material.dart';

class FamilyBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  final EdgeInsets? safeAreaMinimum;

  FamilyBottomSheetRoute({
    required super.builder,
    required super.isScrollControlled,
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

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final BottomSheetThemeData sheetTheme = Theme.of(context).bottomSheetTheme;
    final BottomSheetThemeData defaults =
        Theme.of(context).useMaterial3
            ? _BottomSheetDefaultsM3(context)
            : const BottomSheetThemeData();

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
            sheetTheme.backgroundColor ??
            defaults.backgroundColor,
        elevation:
            elevation ??
            sheetTheme.modalElevation ??
            sheetTheme.elevation ??
            defaults.modalElevation,
        shape: shape,
        clipBehavior: clipBehavior,
        constraints: constraints,
        enableDrag: enableDrag,
        showDragHandle:
            showDragHandle ??
            (enableDrag && (sheetTheme.showDragHandle ?? false)),
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

/// Copied from the Flutter framework
///
/// Default Material 3 spec for Bottom Sheet
class _BottomSheetDefaultsM3 extends BottomSheetThemeData {
  _BottomSheetDefaultsM3(this.context)
    : super(
        elevation: 1.0,
        modalElevation: 1.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        ),
        constraints: const BoxConstraints(maxWidth: 640),
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get backgroundColor => _colors.surfaceContainerLow;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get dragHandleColor => _colors.onSurfaceVariant;

  @override
  Size? get dragHandleSize => const Size(32, 4);

  @override
  BoxConstraints? get constraints => const BoxConstraints(maxWidth: 640.0);
}
