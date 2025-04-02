import 'package:family_bottom_sheet/src/custom_bottom_sheet/widgets/bottom_sheet.dart';
import 'package:family_bottom_sheet/src/custom_bottom_sheet/widgets/bottom_sheet_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const Curve _modalBottomSheetCurve = Easing.legacyDecelerate;
const double _defaultScrollControlDisabledMaxHeightRatio = 9.0 / 16.0;

class FamilyModalSheet<T> extends StatefulWidget {
  const FamilyModalSheet({
    super.key,
    required this.pageIndexNotifier,
    required this.builder,
    required this.route,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.isScrollControlled = false,
    this.scrollControlDisabledMaxHeightRatio =
        _defaultScrollControlDisabledMaxHeightRatio,
    this.enableDrag = true,
    this.showDragHandle = false,
  });

  final FamilyBottomSheetRoute<T> route;
  final ValueNotifier<int> pageIndexNotifier;
  final WidgetBuilder builder;
  final bool isScrollControlled;
  final double scrollControlDisabledMaxHeightRatio;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;
  final bool enableDrag;
  final bool showDragHandle;

  static FamilyModalSheetState of(BuildContext context) {
    FamilyModalSheetState? familyModalSheetState;
    if (context is StatefulElement && context.state is FamilyModalSheetState) {
      familyModalSheetState = context.state as FamilyModalSheetState;
    }
    familyModalSheetState ??=
        context.findAncestorStateOfType<FamilyModalSheetState>();

    assert(() {
      if (familyModalSheetState == null) {
        throw FlutterError(
          'Error: No ancestor state of type [FamilyModalSheetState] found',
        );
      }
      return true;
    }());
    return familyModalSheetState!;
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool useRootNavigator = false,
    bool isScrollControlled = false,
    bool isDismissible = true,
  }) {
    final NavigatorState navigator = Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    );

    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );

    return navigator.push(
      FamilyBottomSheetRoute<T>(
        builder: builder,
        isScrollControlled: isScrollControlled,
      ),
    );
  }

  @override
  State<FamilyModalSheet> createState() => FamilyModalSheetState();
}

class FamilyModalSheetState extends State<FamilyModalSheet> {
  ParametricCurve<double> animationCurve = _modalBottomSheetCurve;

  List<Widget> _pages = [];

  List<Widget> get pages => _pages;

  Widget get currentPage => _pages[_currentPageIndex];

  int get currentPageIndex => _currentPageIndex;

  int get _currentPageIndex => widget.pageIndexNotifier.value;

  /// Setter to update the state of [widget.pageIndexNotifier]
  set _currentPageIndex(int value) {
    widget.pageIndexNotifier.value = value;
  }

  String _getRouteLabel(MaterialLocalizations localizations) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return '';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return localizations.dialogLabel;
    }
  }

  EdgeInsets _getNewClipDetails(Size topLayerSize) {
    return EdgeInsets.fromLTRB(0, 0, 0, topLayerSize.height);
  }

  void handleDragStart(DragStartDetails details) {
    // Allow the bottom sheet to track the user's finger accurately.
    animationCurve = Curves.linear;
  }

  void handleDragEnd(DragEndDetails details, {bool? isClosing}) {
    // Allow the bottom sheet to animate smoothly from its current position.
    animationCurve = Split(
      widget.route.animation!.value,
      endCurve: _modalBottomSheetCurve,
    );
  }

  @override
  void initState() {
    super.initState();

    _pages = [widget.builder(context)];
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final String routeLabel = _getRouteLabel(localizations);

    return AnimatedBuilder(
      animation: widget.route.animation!,
      builder: (BuildContext context, Widget? child) {
        final double animationValue = animationCurve.transform(
          widget.route.animation!.value,
        );

        return Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: routeLabel,
          explicitChildNodes: true,
          child: ClipRect(
            child: _BottomSheetLayoutWithSizeListener(
              onChildSizeChanged: (Size size) {
                widget.route.didChangeBarrierSemanticsClip(
                  _getNewClipDetails(size),
                );
              },
              animationValue: animationValue,
              isScrollControlled: widget.isScrollControlled,
              scrollControlDisabledMaxHeightRatio:
                  widget.scrollControlDisabledMaxHeightRatio,
              child: child,
            ),
          ),
        );
      },
      child: ValueListenableBuilder(
        valueListenable: widget.pageIndexNotifier,
        builder: (context, currentPageIndex, _) {
          return FamilyBottomSheet(
            pageIndex: currentPageIndex,
            pages: pages,
            onClosing: () {
              if (widget.route.isCurrent) {
                Navigator.pop(context);
              }
            },
            enableDrag: widget.enableDrag,
            backgroundColor: widget.backgroundColor,
            onDragStart: handleDragStart,
            onDragEnd: handleDragEnd,
          );
        },
      ),
    );
  }

  /// Add new page widget to [_pages] and update the [_currentPageIndex] to
  /// trigger a rebuild in the ValueListenerNotifier
  void pushPage(Widget page) {
    _pages = List<Widget>.of(_pages)..add(page);
    _currentPageIndex = _pages.length - 1;
  }

  /// Callback to remove the top widget page from the custom modal stack
  void popPage() {
    if (_pages.length > 1) {
      _pages = List<Widget>.of(_pages)..removeLast();
      _currentPageIndex--;
    } else {
      Navigator.of(context).pop();
    }
  }
}

// Copied from the Flutter framework
class _BottomSheetLayoutWithSizeListener extends SingleChildRenderObjectWidget {
  const _BottomSheetLayoutWithSizeListener({
    required this.onChildSizeChanged,
    required this.animationValue,
    required this.isScrollControlled,
    required this.scrollControlDisabledMaxHeightRatio,
    super.child,
  });

  final ValueChanged<Size> onChildSizeChanged;
  final double animationValue;
  final bool isScrollControlled;
  final double scrollControlDisabledMaxHeightRatio;

  @override
  _RenderBottomSheetLayoutWithSizeListener createRenderObject(
    BuildContext context,
  ) {
    return _RenderBottomSheetLayoutWithSizeListener(
      onChildSizeChanged: onChildSizeChanged,
      animationValue: animationValue,
      isScrollControlled: isScrollControlled,
      scrollControlDisabledMaxHeightRatio: scrollControlDisabledMaxHeightRatio,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderBottomSheetLayoutWithSizeListener renderObject,
  ) {
    renderObject.onChildSizeChanged = onChildSizeChanged;
    renderObject.animationValue = animationValue;
    renderObject.isScrollControlled = isScrollControlled;
    renderObject.scrollControlDisabledMaxHeightRatio =
        scrollControlDisabledMaxHeightRatio;
  }
}

class _RenderBottomSheetLayoutWithSizeListener extends RenderShiftedBox {
  _RenderBottomSheetLayoutWithSizeListener({
    RenderBox? child,
    required ValueChanged<Size> onChildSizeChanged,
    required double animationValue,
    required bool isScrollControlled,
    required double scrollControlDisabledMaxHeightRatio,
  }) : _onChildSizeChanged = onChildSizeChanged,
       _animationValue = animationValue,
       _isScrollControlled = isScrollControlled,
       _scrollControlDisabledMaxHeightRatio =
           scrollControlDisabledMaxHeightRatio,
       super(child);

  Size _lastSize = Size.zero;

  ValueChanged<Size> get onChildSizeChanged => _onChildSizeChanged;
  ValueChanged<Size> _onChildSizeChanged;
  set onChildSizeChanged(ValueChanged<Size> newCallback) {
    if (_onChildSizeChanged == newCallback) {
      return;
    }

    _onChildSizeChanged = newCallback;
    markNeedsLayout();
  }

  double get animationValue => _animationValue;
  double _animationValue;
  set animationValue(double newValue) {
    if (_animationValue == newValue) {
      return;
    }

    _animationValue = newValue;
    markNeedsLayout();
  }

  bool get isScrollControlled => _isScrollControlled;
  bool _isScrollControlled;
  set isScrollControlled(bool newValue) {
    if (_isScrollControlled == newValue) {
      return;
    }

    _isScrollControlled = newValue;
    markNeedsLayout();
  }

  double get scrollControlDisabledMaxHeightRatio =>
      _scrollControlDisabledMaxHeightRatio;
  double _scrollControlDisabledMaxHeightRatio;
  set scrollControlDisabledMaxHeightRatio(double newValue) {
    if (_scrollControlDisabledMaxHeightRatio == newValue) {
      return;
    }

    _scrollControlDisabledMaxHeightRatio = newValue;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) => 0.0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0.0;

  @override
  double computeMinIntrinsicHeight(double width) => 0.0;

  @override
  double computeMaxIntrinsicHeight(double width) => 0.0;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final RenderBox? child = this.child;
    if (child == null) {
      return null;
    }
    final BoxConstraints childConstraints = _getConstraintsForChild(
      constraints,
    );
    final double? result = child.getDryBaseline(childConstraints, baseline);
    if (result == null) {
      return null;
    }
    final Size childSize =
        childConstraints.isTight
            ? childConstraints.smallest
            : child.getDryLayout(childConstraints);
    return result + _getPositionForChild(constraints.biggest, childSize).dy;
  }

  BoxConstraints _getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      maxHeight:
          isScrollControlled
              ? constraints.maxHeight
              : constraints.maxHeight * scrollControlDisabledMaxHeightRatio,
    );
  }

  Offset _getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * animationValue);
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    final RenderBox? child = this.child;
    if (child == null) {
      return;
    }

    final BoxConstraints childConstraints = _getConstraintsForChild(
      constraints,
    );
    assert(childConstraints.debugAssertIsValid(isAppliedConstraint: true));
    child.layout(childConstraints, parentUsesSize: !childConstraints.isTight);
    final BoxParentData childParentData = child.parentData! as BoxParentData;
    final Size childSize =
        childConstraints.isTight ? childConstraints.smallest : child.size;
    childParentData.offset = _getPositionForChild(size, childSize);

    if (_lastSize != childSize) {
      _lastSize = childSize;
      _onChildSizeChanged.call(_lastSize);
    }
  }
}
