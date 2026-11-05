part of 'family_modal_route.dart';

const double _minFlingVelocity = 700.0;
const double _closeProgressThreshold = 0.5;

// How far the rubber band can stretch, and how stiff it is.
const double _overdragExtent = 300.0;
const double _overdragStiffness = 0.55;

/// Slides the surface up from the bottom, and handles dragging it closed and
/// the rubber band.
class _SheetChrome<T> extends StatefulWidget {
  const _SheetChrome({
    required this.route,
    required this.style,
    required this.child,
  });

  final FamilyModalRoute<T> route;
  final FamilySheetStyle style;
  final Widget child;

  @override
  State<_SheetChrome<T>> createState() => _SheetChromeState<T>();
}

class _SheetChromeState<T> extends State<_SheetChrome<T>>
    with SingleTickerProviderStateMixin {
  final GlobalKey _sheetKey = GlobalKey(debugLabel: 'FamilySheet');

  /// How far, in pixels, the sheet is stretched past where it can go:
  /// positive above fully open, negative below it while it can't close.
  late final AnimationController _overdrag = AnimationController.unbounded(
    vsync: this,
  );

  /// The finger's travel behind [_overdrag], before the rubber band.
  double _rawOverdrag = 0;

  FamilyModalRoute<T> get _route => widget.route;

  AnimationController get _controller => _route._routeController!;

  double get _sheetHeight =>
      (_sheetKey.currentContext!.findRenderObject()! as RenderBox).size.height;

  bool get _dismissUnderway => _controller.status == AnimationStatus.reverse;

  bool _isUserGesture = false;
  bool _canClose = true;

  static double _rubberBand(double raw) {
    final stretched = _overdragExtent *
        (1 - (1 / (raw.abs() * _overdragStiffness / _overdragExtent + 1)));
    return raw.sign * stretched;
  }

  static double _unRubberBand(double stretched) {
    final fraction = (stretched.abs() / _overdragExtent).clamp(0.0, 0.99);
    final raw = (1 / (1 - fraction) - 1) * _overdragExtent / _overdragStiffness;
    return stretched.sign * raw;
  }

  void _handleDragStart() {
    // Read when the drag starts, so a guard that turns on mid-drag still lets
    // the sheet settle back open.
    _canClose = widget.style.enableDrag && _route.canUserDismiss;

    // Catch a stretch that's still springing back.
    _overdrag.stop();
    _rawOverdrag = _unRubberBand(_overdrag.value);

    if (!_isUserGesture) {
      _isUserGesture = true;
      _route.navigator?.didStartUserGesture();
    }
  }

  void _handleDragUpdate(double delta) {
    if (_dismissUnderway) return;
    final height = _sheetHeight;
    var up = -delta;

    // The sheet itself moves first, and whatever is left stretches it.
    if (_canClose && _rawOverdrag == 0) {
      final next = _controller.value + up / height;
      if (next <= 1) {
        _controller.value = next;
        return;
      }
      _controller.value = 1;
      up = (next - 1) * height;
    }

    final raw = _rawOverdrag + up;
    if (_canClose && raw < 0) {
      _rawOverdrag = 0;
      _overdrag.value = 0;
      _controller.value += raw / height;
      return;
    }
    _rawOverdrag = raw;
    _overdrag.value = _rubberBand(raw);
  }

  void _handleDragEnd(double velocity, {bool willScroll = false}) {
    _stopUserGesture();
    if (_dismissUnderway) return;

    if (_rawOverdrag != 0 || !_canClose) {
      _settleOpen(stretchVelocity: -velocity);
      return;
    }

    // In sheet progress per second, positive when opening.
    final progressVelocity = -velocity / _sheetHeight;

    final isClosing = !willScroll &&
        (velocity > _minFlingVelocity ||
            (_controller.value < _closeProgressThreshold &&
                velocity > -_minFlingVelocity));

    if (isClosing) {
      _route.popWithVelocity(progressVelocity);
    } else {
      _controller.animateWithMotion(
        _route.motion,
        target: 1,
        velocity: willScroll ? 0 : progressVelocity,
      );
    }
  }

  void _handleDragCancel() {
    _stopUserGesture();
    if (!_dismissUnderway) _settleOpen();
  }

  void _settleOpen({double stretchVelocity = 0}) {
    _rawOverdrag = 0;
    if (_overdrag.value != 0) {
      _overdrag.animateWithMotion(
        _route.motion,
        target: 0,
        velocity: stretchVelocity,
      );
    }
    if (_controller.value < 1) {
      _controller.animateWithMotion(_route.motion, target: 1);
    }
  }

  void _stopUserGesture() {
    if (_isUserGesture) {
      _isUserGesture = false;
      _route.navigator?.didStopUserGesture();
    }
  }

  @override
  void dispose() {
    _stopUserGesture();
    _overdrag.dispose();
    super.dispose();
  }

  Widget _withDragToDismiss(Widget child) {
    // A sheet that can't close still takes drags, so it stretches and springs
    // back rather than feeling stuck.
    if (!widget.style.dragFromScroll) {
      return _VerticalDragDetector(
        onStart: (_) => _handleDragStart(),
        onUpdate: (details) => _handleDragUpdate(details.primaryDelta!),
        onEnd: (details) => _handleDragEnd(details.velocity.pixelsPerSecond.dy),
        onCancel: _handleDragCancel,
        child: child,
      );
    }

    return ScrollDragDetector(
      // While the sheet is partly dragged down, dragging up moves the sheet
      // rather than scrolling the list.
      scrollableCanMoveBack: _controller.value < 1 || _overdrag.value != 0,
      onVerticalDragStart: (_, __) => _handleDragStart(),
      onVerticalDragUpdate: (details, _) =>
          _handleDragUpdate(details.primaryDelta!),
      onVerticalDragEnd: (details, willScroll) => _handleDragEnd(
        details.velocity.pixelsPerSecond.dy,
        willScroll: willScroll,
      ),
      onVerticalDragCancel: _handleDragCancel,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheet = KeyedSubtree(key: _sheetKey, child: widget.child);

    final Widget layout = AnimatedBuilder(
      animation: Listenable.merge([_route.animation, _overdrag]),
      builder: (context, child) => Semantics(
        scopesRoute: true,
        namesRoute: true,
        label: _route.semanticsLabel,
        explicitChildNodes: true,
        child: ClipRect(
          child: CustomSingleChildLayout(
            delegate: _SheetLayoutDelegate(
              progress: _route.animation!.value,
              overdrag: _overdrag.value,
              maxHeightFactor: widget.style.maxHeightFactor,
              constraints: widget.style.constraints,
            ),
            child: _withDragToDismiss(child!),
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: sheet,
      ),
    );

    return widget.style.useSafeArea
        ? SafeArea(bottom: false, child: layout)
        : MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: layout,
          );
  }
}

class _SheetLayoutDelegate extends SingleChildLayoutDelegate {
  const _SheetLayoutDelegate({
    required this.progress,
    required this.overdrag,
    required this.maxHeightFactor,
    required this.constraints,
  });

  final double progress;
  final double overdrag;
  final double maxHeightFactor;
  final BoxConstraints constraints;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints available) {
    final width = constraints.constrainWidth(available.maxWidth);
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      minHeight: constraints.minHeight,
      maxHeight: constraints.constrainHeight(
        available.maxHeight * maxHeightFactor,
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(
      (size.width - childSize.width) / 2,
      size.height - childSize.height * progress - overdrag,
    );
  }

  @override
  bool shouldRelayout(_SheetLayoutDelegate oldDelegate) =>
      progress != oldDelegate.progress ||
      overdrag != oldDelegate.overdrag ||
      maxHeightFactor != oldDelegate.maxHeightFactor ||
      constraints != oldDelegate.constraints;
}

class _VerticalDragDetector extends StatelessWidget {
  const _VerticalDragDetector({
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    required this.onCancel,
    required this.child,
  });

  final GestureDragStartCallback onStart;
  final GestureDragUpdateCallback onUpdate;
  final GestureDragEndCallback onEnd;
  final GestureDragCancelCallback onCancel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      excludeFromSemantics: true,
      gestures: {
        VerticalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(debugOwner: this),
          (instance) => instance
            ..onStart = onStart
            ..onUpdate = onUpdate
            ..onEnd = onEnd
            ..onCancel = onCancel
            ..onlyAcceptDragOnThreshold = true,
        ),
      },
      child: child,
    );
  }
}
