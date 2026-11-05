import 'package:flutter/widgets.dart';

/// Wraps the [FamilyPageStack] in your own surface: background, shape,
/// padding, drag handle, shadow. [child] is the page stack.
typedef FamilySurfaceBuilder = Widget Function(
  BuildContext context,
  Widget child,
);

/// How the pages are being presented.
enum FamilyPresentation {
  sheet,
  dialog;

  /// The presentation around [context], or null outside a [FamilyModalSheet].
  static FamilyPresentation? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<FamilyPresentationScope>()
      ?.presentation;
}

class FamilyPresentationScope extends InheritedWidget {
  const FamilyPresentationScope({
    super.key,
    required this.presentation,
    required super.child,
  });

  final FamilyPresentation presentation;

  @override
  bool updateShouldNotify(FamilyPresentationScope oldWidget) =>
      presentation != oldWidget.presentation;
}

const Color _defaultSurfaceColor = Color(0xFFFFFFFF);
const Radius _defaultSurfaceRadius = Radius.circular(24);

/// The surface used when no [FamilySurfaceBuilder] is given.
Widget defaultFamilySurface(BuildContext context, Widget child) {
  final presentation = FamilyPresentation.maybeOf(context);
  final sheet = presentation != FamilyPresentation.dialog;
  return ClipRRect(
    borderRadius: sheet
        ? const BorderRadius.vertical(top: _defaultSurfaceRadius)
        : const BorderRadius.all(_defaultSurfaceRadius),
    child: ColoredBox(
      color: _defaultSurfaceColor,
      child: sheet
          ? Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom,
              ),
              child: child,
            )
          : child,
    ),
  );
}

/// A [ModalBarrier] whose tap closes the route even when a page could be
/// popped, so tapping outside always dismisses rather than going back.
Widget buildFamilyBarrier({
  required ModalRoute<dynamic> route,
  required Color? barrierColor,
  required bool dismissible,
  required String? semanticsLabel,
  required Curve curve,
}) {
  void dismiss() {
    if (route.isCurrent) route.navigator?.pop();
  }

  final color = barrierColor;
  if (color != null && color.a != 0 && !route.offstage) {
    return AnimatedModalBarrier(
      color: route.animation!.drive(
        ColorTween(begin: color.withValues(alpha: 0), end: color)
            .chain(CurveTween(curve: curve)),
      ),
      dismissible: dismissible,
      semanticsLabel: semanticsLabel,
      barrierSemanticsDismissible: route.semanticsDismissible,
      onDismiss: dismiss,
    );
  }
  return ModalBarrier(
    dismissible: dismissible,
    semanticsLabel: semanticsLabel,
    barrierSemanticsDismissible: route.semanticsDismissible,
    onDismiss: dismiss,
  );
}
