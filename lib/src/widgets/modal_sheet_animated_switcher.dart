import 'dart:math' as math;

import 'package:flutter/material.dart';

AnimationStyle _defaultAnimationStyle = AnimationStyle(
    curve: Curves.easeInOutQuad, duration: Duration(milliseconds: 200));
const BorderRadius _defaultBorderRadius = BorderRadius.all(Radius.circular(36));
const EdgeInsets _defaultContentPadding = EdgeInsets.symmetric(horizontal: 16);
const Curve _defaultTransitionCurve = Curves.easeInOutQuad;
const Duration _defaultTransitionDuration = Duration(milliseconds: 200);

class FamilyModalSheetAnimatedSwitcher extends StatefulWidget {
  FamilyModalSheetAnimatedSwitcher({
    super.key,
    required this.pageIndex,
    required this.pages,
    required this.contentBackgroundColor,
    AnimationStyle? mainContentAnimationStyle,
    EdgeInsets? mainContentPadding,
    BorderRadius? mainContentBorderRadius,
  })  : mainContentAnimationStyle =
            mainContentAnimationStyle ?? _defaultAnimationStyle,
        mainContentPadding = mainContentPadding ?? _defaultContentPadding,
        mainContentBorderRadius =
            mainContentBorderRadius ?? _defaultBorderRadius,
        assert(pageIndex >= 0 && pageIndex < pages.length && pages.isNotEmpty);

  /// The current index of the page to display
  final int pageIndex;

  /// The list of pages to be display
  final List<Widget> pages;

  /// The background color of the modal sheet
  final Color contentBackgroundColor;

  /// The padding of the main content
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 16)` if no value is passed
  final EdgeInsets mainContentPadding;

  /// The border radius of the main content
  ///
  /// Defaults to placeholder value if no value is passed
  final BorderRadius mainContentBorderRadius;

  /// The animation style of the animated switcher
  final AnimationStyle mainContentAnimationStyle;

  @override
  State<FamilyModalSheetAnimatedSwitcher> createState() =>
      _FamilyModalSheetAnimatedSwitcherState();
}

class _FamilyModalSheetAnimatedSwitcherState
    extends State<FamilyModalSheetAnimatedSwitcher>
    with SingleTickerProviderStateMixin {
  /// The animation controller for the animated switcher
  late AnimationController _animationController;

  /// The animation for the height of the animated switcher
  late Animation<double> _heightAnimation;

  Widget? _currentWidget;
  Widget? _previousWidget;
  double _previousHeight = 0;
  double _currentHeight = 0;
  bool _hasMeasuredOnce = false;

  final GlobalKey _measureKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.mainContentAnimationStyle.duration ??
          _defaultTransitionDuration,
      value: 1.0,
    );

    _heightAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve:
            widget.mainContentAnimationStyle.curve ?? _defaultTransitionCurve,
        reverseCurve: widget.mainContentAnimationStyle.reverseCurve,
      ),
    );

    _currentWidget = widget.pages[widget.pageIndex];
    _previousWidget = _currentWidget;

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _measureCurrentWidget());
  }

  @override
  void didUpdateWidget(FamilyModalSheetAnimatedSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pageIndex != widget.pageIndex ||
        oldWidget.pages != widget.pages) {
      _previousWidget = _currentWidget;
      _previousHeight = _currentHeight;

      _currentWidget = widget.pages[widget.pageIndex];

      WidgetsBinding.instance
          .addPostFrameCallback((_) => _measureCurrentWidget());

      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.mainContentPadding,
      child: ClipRRect(
        borderRadius: widget.mainContentBorderRadius,
        child: ColoredBox(
          color: widget.contentBackgroundColor,
          child: Stack(
            children: [
              // Offstage render of the new widget used for height measurement,
              // enabling a smooth height interpolation during transition
              if (_currentWidget case final current?)
                Offstage(
                  child: KeyedSubtree(key: _measureKey, child: current),
                ),

              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final animationValue = _heightAnimation.value;
                  return switch (animationValue) {
                    // Animation is in progress
                    // We want to:
                    // - animate the height between the previous and current widgets,
                    // - crossfade the two widgets for visual continuity,
                    // - ensure no content is clipped during the transition.
                    < 1.0 => SizedBox(
                        // Interpolate height based on animation progress
                        height: _previousHeight +
                            (_currentHeight - _previousHeight) * animationValue,
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          // Allow the content to overflow up to the maximum height of both widgets
                          // to prevent clipping during the transition
                          maxHeight: math.max(_previousHeight, _currentHeight),
                          child: Stack(
                            children: [
                              // Fade out the previous widget
                              if (_previousWidget case final previous?)
                                Opacity(
                                    opacity: 1.0 - animationValue,
                                    child: previous),
                              // Fade in the current widget
                              if (_currentWidget case final current?)
                                Opacity(
                                    opacity: animationValue, child: current),
                            ],
                          ),
                        ),
                      ),
                    // Animation is complete
                    // We can now display only the final widget without any extra layout or opacity overhead.
                    _ => _currentWidget ?? const SizedBox.shrink(),
                  };
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Measures the current widget's height and updates initial values if needed.
  ///
  /// The method uses the [GlobalKey] to find the current context and
  /// retrieves the height of the widget using the [RenderBox]
  void _measureCurrentWidget() {
    final BuildContext? context = _measureKey.currentContext;
    if (context == null) return;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final currentHeight = renderObject.size.height;

    // Initial measurement: set previous height to current height
    if (!_hasMeasuredOnce) {
      _previousHeight = currentHeight;
      _hasMeasuredOnce = true;
    }

    // Only update and rebuild if the height has changed
    if (mounted && _currentHeight != currentHeight) {
      setState(() => _currentHeight = currentHeight);
    }
  }
}
