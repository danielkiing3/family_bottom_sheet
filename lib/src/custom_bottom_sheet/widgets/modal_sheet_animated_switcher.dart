import 'package:flutter/material.dart';

class FamilyModalSheetAnimatedSwitcher extends StatefulWidget {
  const FamilyModalSheetAnimatedSwitcher({
    super.key,
    required this.pageIndex,
    required this.pages,
  }) : assert(pageIndex >= 0 && pageIndex < pages.length);

  final int pageIndex;
  final List<Widget> pages;

  @override
  State<FamilyModalSheetAnimatedSwitcher> createState() =>
      _FamilyModalSheetAnimatedSwitcherState();
}

class _FamilyModalSheetAnimatedSwitcherState
    extends State<FamilyModalSheetAnimatedSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
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
      duration: const Duration(milliseconds: 200),
    );

    _heightAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutQuad,
      ),
    );

    if (widget.pages.isNotEmpty && widget.pageIndex < widget.pages.length) {
      _currentWidget = widget.pages[widget.pageIndex];
    } else {}
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(36),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // -- Offstage current widget
              Offstage(
                child: SizedBox(key: _measureKey, child: _currentWidget),
              ),

              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  // Calculate interpolated height
                  double displayHeight =
                      _previousHeight +
                      (_currentHeight - _previousHeight) *
                          _heightAnimation.value;

                  // Ensure we have a non-zero height
                  if (displayHeight <= 0) {
                    displayHeight = 100;
                  }

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
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant FamilyModalSheetAnimatedSwitcher oldWidget) {
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
