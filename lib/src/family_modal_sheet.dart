import 'package:flutter/widgets.dart';

import 'motion/family_motion.dart';
import 'page_stack/family_page_stack.dart';
import 'page_stack/family_page_transitions.dart';
import 'presentation/family_presentation.dart';
import 'presentation/family_presentation_style.dart';
import 'presentation/family_modal_route.dart';
import 'theme/family_sheet_theme.dart';

/// Shows a stack of pages as a sheet docked to the bottom or floating in the
/// middle, or whichever suits the screen, and lets the pages push and pop each
/// other.
///
/// The package draws nothing itself. Give it your look with a
/// [FamilySurfaceBuilder], once for the whole app with a [FamilySheetTheme] or
/// per call.
///
/// ```dart
/// await FamilyModalSheet.show<void>(
///   context: context,
///   builder: (context) => const FirstPage(),
/// );
///
/// // From inside any page:
/// FamilyModalSheet.of(context).pushPage(const SecondPage());
/// FamilyModalSheet.of(context).popPage();
/// ```
abstract final class FamilyModalSheet {
  /// The page stack of the sheet around [context].
  static FamilyPageStackState of(BuildContext context) =>
      FamilyPageStack.of(context);

  /// Like [of], but null outside a sheet.
  static FamilyPageStackState? maybeOf(BuildContext context) =>
      FamilyPageStack.maybeOf(context);

  /// Shows [builder]'s page as the first page of a sheet.
  ///
  /// Every option left null falls back to the closest [FamilySheetTheme],
  /// then to the package default.
  ///
  /// - `presentation`: a sheet (docked or floating), adaptive, or
  ///   your own rule with [FamilyPresentationStyle.resolve]. Defaults to a
  ///   docked sheet.
  /// - `surfaceBuilder`: your background, shape, padding and drag handle
  ///   around the pages. Defaults to [defaultFamilySurface].
  /// - `pageTransitionBuilder` / `pageMotion`: how pages animate into each
  ///   other, and how the sheet resizes between them.
  /// - `barrierColor`, `isDismissible`: the barrier behind, and whether
  ///   tapping it closes the sheet.
  /// - `useRootNavigator`: whether to show the sheet over every nested
  ///   navigator. Defaults to false.
  ///
  /// Returns the value the sheet is popped with.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    FamilyPresentationStyle? presentation,
    FamilySurfaceBuilder? surfaceBuilder,
    FamilyPageTransitionBuilder? pageTransitionBuilder,
    FamilyMotion? pageMotion,
    Color? barrierColor,
    String? barrierLabel,
    bool? isDismissible,
    bool? useRootNavigator,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    String? semanticsLabel,
  }) {
    final theme = FamilySheetTheme.maybeOf(context);
    final resolvedSurface = surfaceBuilder ?? theme?.surfaceBuilder;
    final resolvedTransition =
        pageTransitionBuilder ?? theme?.pageTransitionBuilder;
    final resolvedPageMotion = pageMotion ?? theme?.pageMotion;
    final resolvedBarrierColor =
        barrierColor ?? theme?.barrierColor ?? defaultFamilyBarrierColor;
    final resolvedDismissible = isDismissible ?? theme?.isDismissible ?? true;

    final style =
        presentation ?? theme?.presentation ?? const FamilySheetStyle();
    final navigator = Navigator.of(
      context,
      rootNavigator: useRootNavigator ?? false,
    );

    return navigator.push(
      FamilyModalRoute<T>(
        builder: builder,
        presentation: style,
        surfaceBuilder: resolvedSurface,
        pageTransitionBuilder: resolvedTransition,
        pageMotion: resolvedPageMotion,
        capturedThemes: InheritedTheme.capture(
          from: context,
          to: navigator.context,
        ),
        barrierColor: resolvedBarrierColor,
        barrierLabel: barrierLabel,
        isDismissible: resolvedDismissible,
        anchorPoint: anchorPoint,
        semanticsLabel: semanticsLabel,
        settings: routeSettings,
      ),
    );
  }
}
