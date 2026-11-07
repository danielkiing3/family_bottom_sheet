part of 'family_modal_route.dart';

const double _minFlingVelocity = 700.0;
const double _closeProgressThreshold = 0.5;

// How far the rubber band can stretch, and how stiff it is.
const double _overdragExtent = 300.0;
const double _overdragStiffness = 0.55;

/// Slides the surface up from the bottom to rest docked against the bottom edge
/// or floating in the middle, and handles dragging it closed and the rubber
/// band
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
  // The sheet's travel distance, set by the layout.
  final _SheetMetrics _metrics = _SheetMetrics();

  // Where a floating sheet's anchored edge sits.
  final _AnchorMemory _anchorMemory = _AnchorMemory();

  /// How far, in pixels, the sheet is stretched past where it can go:
  /// positive above fully open, negative below it while it can't close.
  late final AnimationController _overdrag = AnimationController.unbounded(
    vsync: this,
  );

  /// The finger's travel behind [_overdrag], before the rubber band.
  double _rawOverdrag = 0;

  FamilyModalRoute<T> get _route => widget.route;

  AnimationController get _controller => _route._routeController!;

  double get _travel => _metrics.travel;

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
    final height = _travel;
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
    final progressVelocity = -velocity / _travel;

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
    final style = widget.style;
    final placement = style.placement;
    final safe =
        style.useSafeArea ? MediaQuery.paddingOf(context) : EdgeInsets.zero;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    // The area the sheet may rest in. A docked sheet keeps below the status
    // bar and above the keyboard, and leaves the bottom inset to its surface.
    // A floating sheet keeps its inset padding from every edge.
    final area = switch (placement) {
      FamilyDockedPlacement() =>
        EdgeInsets.only(top: safe.top, bottom: keyboard),
      FamilyFloatingPlacement(:final insetPadding) => insetPadding +
          EdgeInsets.fromLTRB(
            safe.left,
            safe.top,
            safe.right,
            math.max(safe.bottom, keyboard),
          ),
    };
    final floating = placement is FamilyFloatingPlacement;

    // The sheet is moved clear of the system insets and the keyboard here, so
    // its pages don't make room for them again.
    final sheet = MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeLeft: floating,
        removeRight: floating,
        removeBottom: floating,
        child: widget.child,
      ),
    );

    return AnimatedBuilder(
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
              maxHeightFactor: style.maxHeightFactor,
              placement: placement,
              area: area,
              anchorMemory: _anchorMemory,
              metrics: _metrics,
            ),
            child: _withDragToDismiss(child!),
          ),
        ),
      ),
      child: sheet,
    );
  }
}

class _SheetMetrics {
  /// Pixels between fully closed and fully open.
  double travel = 1;
}

/// Positions the sheet inside [area].
///
/// Across, the sheet is centred. Down, it rests against the bottom edge when
/// docked, or where its anchor puts it when floating.
///
/// [progress] moves it from just below the screen (0) to that resting spot
/// (1), and [overdrag] stretches it past.
class _SheetLayoutDelegate extends SingleChildLayoutDelegate {
  const _SheetLayoutDelegate({
    required this.progress,
    required this.overdrag,
    required this.maxHeightFactor,
    required this.placement,
    required this.area,
    required this.anchorMemory,
    required this.metrics,
  });

  final double progress;
  final double overdrag;
  final double maxHeightFactor;
  final FamilySheetPlacement placement;
  final EdgeInsets area;
  final _AnchorMemory anchorMemory;
  final _SheetMetrics metrics;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints available) {
    final areaWidth = math.max(0.0, available.maxWidth - area.horizontal);
    final areaHeight = math.max(0.0, available.maxHeight - area.vertical);
    final width = math.min(areaWidth, placement.maxWidth);
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      maxHeight: areaHeight * maxHeightFactor,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final areaSize = area.deflateSize(size);
    final x = area.left + (areaSize.width - childSize.width) / 2;

    final resting = switch (placement) {
      FamilyDockedPlacement() => size.height - area.bottom - childSize.height,
      FamilyFloatingPlacement(:final anchor) => area.top +
          _anchoredOffset(
            room: areaSize.height - childSize.height,
            areaHeight: areaSize.height,
            width: size.width,
            anchor: anchor,
            memory: anchorMemory,
          ),
    };

    final closed = size.height;
    metrics.travel = math.max(closed - resting, 1);
    final y = closed + (resting - closed) * progress - overdrag;
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_SheetLayoutDelegate oldDelegate) =>
      progress != oldDelegate.progress ||
      overdrag != oldDelegate.overdrag ||
      maxHeightFactor != oldDelegate.maxHeightFactor ||
      placement != oldDelegate.placement ||
      area != oldDelegate.area;
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

/// Where an anchored edge sits, as a distance from its own side of the
/// available area, and the screen width and area height it was decided for.
/// Kept by a floating sheet so the edge stays put between pages.
class _AnchorMemory {
  double? width;
  double? areaHeight;
  double? gap;
}

/// How far down a box with [room] to spare sits, so the edge [anchor] names
/// stays still between pages.
double _anchoredOffset({
  required double room,
  required double areaHeight,
  required double width,
  required FamilyAnchor anchor,
  required _AnchorMemory memory,
}) {
  final spare = math.max(room, 0.0);

  // A new width (rotation, a resized window) starts over from the centre.
  // A new height alone (the keyboard) keeps the anchor.
  if (memory.width != width) {
    memory
      ..width = width
      ..areaHeight = areaHeight
      ..gap = spare / 2;
  }

  // Slide only as far as needed. A taller page keeps the slide; a shorter
  // area, e.g. the keyboard, doesn't, so the sheet returns when it's gone.
  final gap = (memory.gap ?? spare / 2).clamp(0.0, spare);
  if (memory.areaHeight == areaHeight) memory.gap = gap;

  return switch (anchor) {
    FamilyAnchor.top => gap,
    FamilyAnchor.center => spare / 2,
    FamilyAnchor.bottom => spare - gap,
  };
}
