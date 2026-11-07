import 'package:flutter/material.dart';

import '../family_modal_sheet.dart';
import '../presentation/family_presentation.dart';
import '../presentation/family_presentation_style.dart';

// Material 3's bottom sheet corner radius.
const Radius _defaultRadius = Radius.circular(28);

/// A Material-styled preset over [FamilyModalSheet]. Import
/// `package:family_bottom_sheet/material.dart`.
///
/// Use [surface] in a [FamilySheetTheme] to make it the app-wide default, or
/// [show] for a one-off.
abstract final class FamilyMaterialSheet {
  /// A Material surface.
  ///
  /// Docked, it's the standard bottom sheet: it touches the bottom and sides
  /// of the screen, rounds its top corners, and runs its colour behind the
  /// home indicator while keeping the pages above it. Give it [padding] to
  /// float it as a card instead, with every corner rounded.
  ///
  /// Floating, it rounds every corner and drops the drag handle.
  ///
  /// [borderRadius] and [floatingBorderRadius] replace those corners when set,
  /// for the docked and the floating sheet.
  static FamilySurfaceBuilder surface({
    Color? backgroundColor,
    EdgeInsets padding = EdgeInsets.zero,
    BorderRadius? borderRadius,
    BorderRadius? floatingBorderRadius,
    double elevation = 0,
    bool showDragHandle = false,
  }) {
    return (context, child) {
      final isDocked =
          FamilyPresentation.maybeOf(context) != FamilyPresentation.floating;
      final isFlush = isDocked && padding == EdgeInsets.zero;
      final colors = Theme.of(context).colorScheme;

      // Flush against the bottom edge, the pages keep clear of the home
      // indicator inside the surface, so its colour runs behind it.
      final bottomInset = isFlush ? MediaQuery.paddingOf(context).bottom : 0.0;

      // Flush, only the top corners round
      final defaultCorners = isFlush
          ? const BorderRadius.vertical(top: _defaultRadius)
          : const BorderRadius.all(_defaultRadius);
      final corners = isDocked
          ? borderRadius ?? defaultCorners
          : floatingBorderRadius ?? defaultCorners;

      final surface = Material(
        color: backgroundColor ?? colors.surfaceContainerLow,
        elevation: elevation,
        borderRadius: corners,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDragHandle && isDocked)
              _DragHandle(color: colors.onSurfaceVariant),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: child,
              ),
            ),
          ],
        ),
      );
      if (!isDocked || isFlush) return surface;
      return SafeArea(
        top: false,
        child: Padding(padding: padding, child: surface),
      );
    };
  }

  /// Shows [builder]'s page with the [surface] look and Material's barrier
  /// colour and accessibility labels.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    FamilyPresentationStyle? presentation,
    Color? backgroundColor,
    EdgeInsets padding = EdgeInsets.zero,
    BorderRadius? borderRadius,
    BorderRadius? floatingBorderRadius,
    double elevation = 0,
    bool showDragHandle = false,
    Color? barrierColor,
    bool? isDismissible,
    bool? useRootNavigator,
    RouteSettings? routeSettings,
  }) {
    final localizations = MaterialLocalizations.of(context);
    return FamilyModalSheet.show<T>(
      context: context,
      builder: builder,
      presentation: presentation,
      surfaceBuilder: surface(
        backgroundColor: backgroundColor,
        padding: padding,
        borderRadius: borderRadius,
        floatingBorderRadius: floatingBorderRadius,
        elevation: elevation,
        showDragHandle: showDragHandle,
      ),
      barrierColor:
          barrierColor ?? Theme.of(context).bottomSheetTheme.modalBarrierColor,
      barrierLabel: localizations.scrimLabel,
      isDismissible: isDismissible,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      semanticsLabel: localizations.bottomSheetLabel,
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kMinInteractiveDimension,
      child: Center(
        child: Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
