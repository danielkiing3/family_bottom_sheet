import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:scroll_drag_detector/scroll_drag_detector.dart';

import '../motion/family_motion.dart';
import '../page_stack/family_page_stack.dart';
import '../page_stack/family_page_transitions.dart';
import 'family_presentation.dart';
import 'family_presentation_style.dart';

part 'dialog_chrome.dart';
part 'sheet_chrome.dart';

/// The modal route behind [FamilyModalSheet.show]: a [FamilyPageStack] shown
/// as a bottom sheet or a centred dialog.
///
/// With [FamilyPresentationStyle.adaptive] it picks sheet or dialog on every
/// layout, so resizing the window or rotating the device switches it live.
/// The pages move across untouched, so their state survives the switch.
///
/// Prefer [FamilyModalSheet.show]. Subclass this route to override
/// [canUserDismiss].
class FamilyModalRoute<T> extends PopupRoute<T> {
  FamilyModalRoute({
    required this.builder,
    this.presentation = const FamilySheetStyle(),
    this.surfaceBuilder,
    this.pageTransitionBuilder,
    this.pageMotion,
    this.capturedThemes,
    Color? barrierColor = const Color(0x8A000000),
    this.isDismissible = true,
    this.barrierLabel,
    this.anchorPoint,
    this.semanticsLabel,
    super.settings,
  }) : _barrierColor = barrierColor;

  /// Builds the first page.
  final WidgetBuilder builder;

  /// A sheet, a dialog, or adaptive.
  final FamilyPresentationStyle presentation;

  /// Wraps the page stack in your surface. Defaults to [defaultFamilySurface].
  final FamilySurfaceBuilder? surfaceBuilder;

  /// Builds the transition for each page.
  ///
  /// {@macro family_bottom_sheet.page_transition_builder}
  final FamilyPageTransitionBuilder? pageTransitionBuilder;

  /// How pages move into each other, and the size change between them.
  final FamilyMotion? pageMotion;

  final CapturedThemes? capturedThemes;

  /// Whether tapping the barrier closes the route, when [canUserDismiss].
  final bool isDismissible;

  final Offset? anchorPoint;

  /// Announced by screen readers when the route opens.
  final String? semanticsLabel;

  final Color? _barrierColor;

  /// Whether the user can close the route right now, by tapping the barrier,
  /// dragging it away, or going back. Going back to an earlier page is
  /// blocked too.
  ///
  /// Override it to block closing while something can't be interrupted, e.g. a
  /// payment in flight, and call [changedInternalState] when it changes so the
  /// barrier updates. Closing from code with [Navigator.pop] still works.
  bool get canUserDismiss => true;

  /// The presentation showing right now. With an adaptive [presentation] it
  /// changes as the screen does.
  FamilyFixedPresentationStyle get currentPresentation => _current;
  late FamilyFixedPresentationStyle _current;

  double _popVelocity = 0;

  AnimationController? get _routeController => controller;

  FamilyMotion get motion => switch (_current) {
        FamilySheetStyle(:final motion) => motion,
        FamilyDialogStyle(:final motion) => motion,
      };

  FamilyFixedPresentationStyle _resolve(double width) => switch (presentation) {
        FamilyAdaptiveStyle(:final breakpoint, :final dialog, :final sheet) =>
          width >= breakpoint ? dialog : sheet,
        final FamilyFixedPresentationStyle style => style,
      };

  @override
  void install() {
    // Motion is read while the controller is created, so decide first.
    _current = _resolve(
      MediaQuery.maybeSizeOf(navigator!.context)?.width ?? 0,
    );
    super.install();
  }

  @override
  Color? get barrierColor => _barrierColor;

  @override
  bool get barrierDismissible => isDismissible && canUserDismiss;

  @override
  final String? barrierLabel;

  @override
  Duration get transitionDuration => switch (motion) {
        SpringFamilyMotion(:final duration) => duration,
        CurvedFamilyMotion(:final duration) => duration,
      };

  @override
  Simulation? createSimulation({required bool forward}) {
    final velocity = forward ? 0.0 : _popVelocity;
    _popVelocity = 0;
    return motion.simulate(
      from: controller!.value,
      to: forward ? 1 : 0,
      velocity: velocity,
    );
  }

  /// Pops the route, carrying [velocity] (in route progress per second, so
  /// negative when closing) into the close animation.
  void popWithVelocity(double velocity) {
    if (!isCurrent) return;
    _popVelocity = velocity;
    navigator?.pop();
  }

  @override
  Widget buildModalBarrier() {
    return buildFamilyBarrier(
      route: this,
      barrierColor: barrierColor,
      dismissible: barrierDismissible,
      semanticsLabel: barrierLabel,
      curve: barrierCurve,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget content = DisplayFeatureSubScreen(
      anchorPoint: anchorPoint,
      child: _AdaptiveChrome<T>(route: this),
    );
    return capturedThemes?.wrap(content) ?? content;
  }
}

/// Shows the page stack in a sheet or a dialog, whichever the width calls for,
/// moving the same stack across when that changes.
class _AdaptiveChrome<T> extends StatefulWidget {
  const _AdaptiveChrome({required this.route});

  final FamilyModalRoute<T> route;

  @override
  State<_AdaptiveChrome<T>> createState() => _AdaptiveChromeState<T>();
}

class _AdaptiveChromeState<T> extends State<_AdaptiveChrome<T>> {
  final GlobalKey _stackKey = GlobalKey(debugLabel: 'FamilyPageStack');

  late final Widget _initialPage = Builder(builder: widget.route.builder);

  FamilyModalRoute<T> get _route => widget.route;

  Widget _surface(Widget stack) {
    return Builder(
      builder: (context) =>
          (_route.surfaceBuilder ?? defaultFamilySurface)(context, stack),
    );
  }

  void _settleAfterSwitch() {
    final controller = _route._routeController;
    if (controller == null ||
        controller.status == AnimationStatus.reverse ||
        controller.value >= 1) {
      return;
    }
    controller.animateWithMotion(_route.motion, target: 1);
  }

  @override
  Widget build(BuildContext context) {
    final style = _route._resolve(MediaQuery.sizeOf(context).width);
    if (style.runtimeType != _route._current.runtimeType) {
      // A drag may have been cut short by the switch, so make sure the route
      // ends up fully open.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _settleAfterSwitch();
      });
    }
    _route._current = style;

    final isDialog = style is FamilyDialogStyle;
    final stack = FamilyPageStack(
      key: _stackKey,
      initialPage: _initialPage,
      transitionBuilder: _route.pageTransitionBuilder,
      motion: _route.pageMotion,
      canUserPop: () => _route.canUserDismiss,
      alignment: switch (style) {
        FamilySheetStyle() => Alignment.topCenter,
        FamilyDialogStyle(:final anchor) => switch (anchor) {
            FamilyDialogAnchor.top => Alignment.topCenter,
            FamilyDialogAnchor.center => Alignment.center,
            FamilyDialogAnchor.bottom => Alignment.bottomCenter,
          },
      },
    );

    return FamilyPresentationScope(
      presentation:
          isDialog ? FamilyPresentation.dialog : FamilyPresentation.sheet,
      child: switch (style) {
        FamilyDialogStyle() => _DialogChrome(
            route: _route,
            style: style,
            child: _surface(stack),
          ),
        FamilySheetStyle() => _SheetChrome(
            route: _route,
            style: style,
            child: _surface(stack),
          ),
      },
    );
  }
}
