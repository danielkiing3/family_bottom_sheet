import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:scroll_drag_detector/scroll_drag_detector.dart';

import '../motion/family_motion.dart';
import '../page_stack/family_page_stack.dart';
import '../page_stack/family_page_transitions.dart';
import 'family_presentation.dart';
import 'family_presentation_style.dart';

part 'sheet_chrome.dart';

/// The modal route behind [FamilyModalSheet.show]: a [FamilyPageStack] shown
/// as a sheet docked to the bottom edge or floating in the middle.
///
/// With [FamilyPresentationStyle.adaptive] or [FamilyPresentationStyle.resolve]
/// it picks the placement on every layout, so resizing the window or rotating
/// the device moves the sheet live, even mid-drag.
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

  /// A sheet, adaptive, or your own rule.
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

  /// The presentation showing right now. With an adaptive or resolved
  /// [presentation] it changes as the screen does.
  FamilySheetStyle get currentPresentation => _current;
  late FamilySheetStyle _current;

  double _popVelocity = 0;

  AnimationController? get _routeController => controller;

  FamilyMotion get motion => _current.motion;

  FamilySheetStyle _resolve(BuildContext context) =>
      _resolveStyle(presentation, context);

  // Turns any presentation into the one sheet to show right now. A resolve's
  // rule can return adaptive or another resolve, so its answer is resolved
  // again.
  FamilySheetStyle _resolveStyle(
    FamilyPresentationStyle style,
    BuildContext context, {
    int depth = 0,
  }) {
    if (depth > _maxResolveDepth) {
      if (_hasReportedResolveLoop) return const FamilySheetStyle();
      _hasReportedResolveLoop = true;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: FlutterError.fromParts([
            ErrorSummary(
              'A FamilyPresentationStyle.resolve rule kept returning other '
              'resolves.',
            ),
            ErrorDescription(
              'It was resolved $_maxResolveDepth times without reaching a '
              'sheet, so it most likely returns itself. A docked sheet is '
              'shown instead.',
            ),
            ErrorHint(
              'Make the rule return FamilyPresentationStyle.sheet or '
              'FamilyPresentationStyle.adaptive.',
            ),
          ]),
          library: 'family_bottom_sheet',
        ),
      );
      return const FamilySheetStyle();
    }
    return switch (style) {
      final FamilyAdaptiveStyle adaptive =>
        adaptive.sheetFor(MediaQuery.maybeSizeOf(context)?.width ?? 0),
      final FamilyResolvedStyle resolved => _resolveStyle(
          resolved.resolve(context),
          context,
          depth: depth + 1,
        ),
      final FamilySheetStyle sheet => sheet,
    };
  }

  // Far more nested resolves than any real rule needs.
  static const int _maxResolveDepth = 16;
  bool _hasReportedResolveLoop = false;

  @override
  void install() {
    // Motion is read while the controller is created, so decide first, from
    // the navigator's context until the route has its own.
    _current = _resolve(navigator!.context);
    super.install();
  }

  @override
  Color? get barrierColor => _barrierColor;

  @override
  bool get barrierDismissible => isDismissible && canUserDismiss;

  // Back must respect the guard even on a single page, where no page stack
  // is in the way.
  @override
  RoutePopDisposition get popDisposition =>
      canUserDismiss ? super.popDisposition : RoutePopDisposition.doNotPop;

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

/// Shows the page stack in the sheet the route resolves to. Docked and
/// floating share this one wrapper, so a switch between them only moves the
/// sheet.
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

  @override
  Widget build(BuildContext context) {
    final style = _route._resolve(context);
    _route._current = style;

    final stack = FamilyPageStack(
      key: _stackKey,
      initialPage: _initialPage,
      transitionBuilder: _route.pageTransitionBuilder,
      motion: _route.pageMotion,
      canUserPop: () => _route.canUserDismiss,
      alignment: switch (style.placement) {
        FamilyDockedPlacement() => Alignment.topCenter,
        FamilyFloatingPlacement(:final anchor) => switch (anchor) {
            FamilyAnchor.top => Alignment.topCenter,
            FamilyAnchor.center => Alignment.center,
            FamilyAnchor.bottom => Alignment.bottomCenter,
          },
      },
    );

    return FamilyPresentationScope(
      presentation: switch (style.placement) {
        FamilyDockedPlacement() => FamilyPresentation.docked,
        FamilyFloatingPlacement() => FamilyPresentation.floating,
      },
      child: _SheetChrome(
        route: _route,
        style: style,
        child: Builder(
          builder: (context) =>
              (_route.surfaceBuilder ?? defaultFamilySurface)(context, stack),
        ),
      ),
    );
  }
}
