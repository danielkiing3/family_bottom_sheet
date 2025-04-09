import 'package:flutter/material.dart';

AnimationStyle _defaultAnimationStyle = AnimationStyle(
    curve: Curves.easeInOutQuad, duration: Duration(milliseconds: 200));
BorderRadius _defaultBorderRadius = BorderRadius.circular(36);
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
  bool _isInitialBuild = true;

  final GlobalKey _measureKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.mainContentAnimationStyle.duration ??
          _defaultTransitionDuration,
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
  }

  @override
  Widget build(BuildContext context) {
    // Offscreen measurement widget
    if (_currentWidget != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isInitialBuild) {
          _measureCurrentWidget();
        }
      });
    }

    return Padding(
      padding: widget.mainContentPadding,
      child: ClipRRect(
        borderRadius: widget.mainContentBorderRadius,
        child: Container(
          color: widget.contentBackgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // -- Current widget offstage
              Offstage(
                child: SizedBox(key: _measureKey, child: _currentWidget),
              ),

              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  double displayHeight = _previousHeight +
                      (_currentHeight - _previousHeight) *
                          _heightAnimation.value;

                  return SizedBox(
                    height: displayHeight,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Stack(
                        children: [
                          if (_previousWidget != null &&
                              _heightAnimation.value < 1.0)
                            Opacity(
                              opacity: 1.0 - _heightAnimation.value,
                              child: SizedBox(child: _previousWidget),
                            ),
                          if (_currentWidget != null)
                            Opacity(
                              opacity: _heightAnimation.value,
                              child: SizedBox(child: _currentWidget),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(FamilyModalSheetAnimatedSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pageIndex != widget.pageIndex ||
        oldWidget.pages != widget.pages) {
      _previousWidget = _currentWidget;
      _previousHeight = _currentHeight > 0 ? _currentHeight : 0;

      if (widget.pages.isNotEmpty && widget.pageIndex < widget.pages.length) {
        _currentWidget = widget.pages[widget.pageIndex];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _measureCurrentWidget();
        });
      } else {
        _currentWidget = null;
        _currentHeight = 0;
      }

      _animationController.reset();
      _animationController.forward();
    }
  }

  /// Measures the current widget's height and updates initial values if needed.
  ///
  /// The method uses the [GlobalKey] to find the current context and
  /// retrieves the height of the widget using the [RenderBox]
  void _measureCurrentWidget() {
    final BuildContext? context = _measureKey.currentContext;

    if (context != null) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      _currentHeight = renderBox.size.height;

      if (_isInitialBuild) {
        _previousHeight = _currentHeight;
        _previousWidget = _currentWidget;
        _isInitialBuild = false;
      }

      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
