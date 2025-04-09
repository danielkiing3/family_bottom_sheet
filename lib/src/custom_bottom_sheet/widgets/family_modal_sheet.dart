import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'family_bottom_sheet.dart';
import 'family_bottom_sheet_route.dart';

const Curve _modalBottomSheetCurve = Easing.legacyDecelerate;
const double _defaultScrollControlDisabledMaxHeightRatio = 1;

/// A customizable modal sheet widget for displaying dynamic content.
///
/// Typically used internally by [FamilyBottomSheetRoute] to build
/// the visual representation of the bottom sheet.
///
/// Allows control over appearance, drag behavior, scrolling,
/// and safe area handling.
class FamilyModalSheet<T> extends StatefulWidget {
  const FamilyModalSheet({
    super.key,
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
    this.safeAreaMinimum,
  });

  /// The route that defines the modal sheet’s behavior and configuration.
  final FamilyBottomSheetRoute<T> route;

  /// The widget builder that creates the content of the modal sheet.
  final WidgetBuilder builder;

  /// Whether the height of the sheet should be fully controlled by the content
  /// or allowed to expand based on constraints.
  final bool isScrollControlled;

  /// Ratio of the max height at which scroll control is disabled, allowing for
  /// a more free-flowing modal behavior. This defines the point at which the
  /// sheet's scroll behavior is no longer restricted.
  final double scrollControlDisabledMaxHeightRatio;

  /// The background color of the modal sheet.
  final Color? backgroundColor;

  /// The elevation (shadow depth) of the modal sheet, which affects the visual
  /// prominence and depth of the sheet.
  final double? elevation;

  /// The shape of the modal sheet’s border, allowing for custom corner radii
  /// or other shapes.
  final ShapeBorder? shape;

  /// The clipping behavior for the modal sheet’s content. Defines how the content
  /// should be clipped if it overflows the sheet’s bounds.
  final Clip? clipBehavior;

  /// Constraints to control the size and layout of the modal sheet. This allows
  /// for fine-grained control over the sheet's maximum and minimum sizes.
  final BoxConstraints? constraints;

  /// Whether the sheet can be dragged by the user to dismiss it.
  final bool enableDrag;

  /// Whether to show a drag handle for the user to interact with when dismissing
  /// the sheet.
  final bool showDragHandle;

  /// Optional minimum padding to apply when safe areas (e.g., notches) are present,
  /// ensuring that the sheet content is not obscured by such areas.
  final EdgeInsets? safeAreaMinimum;

  @override
  State<FamilyModalSheet> createState() => FamilyModalSheetState();

  /// Retrieves the nearest [FamilyModalSheetState] from the widget tree.
  ///
  /// This function looks for a [FamilyModalSheetState] either in the current
  /// [BuildContext] or by traversing the widget tree upwards to find the
  /// closest ancestor with this state. It ensures that the state of the
  /// [FamilyModalSheet] is available for further operations.
  ///
  /// Use this method when you need to access the state of a modal sheet
  /// (e.g., to push or pop pages or modify other properties) from a
  /// descendant widget in the tree.
  ///
  /// Throws an error if no ancestor state of type [FamilyModalSheetState] is found.
  /// Throws a [FlutterError] in debug mode, and an exception in release mode
  ///
  /// Example usage:
  /// ```dart
  /// final modalSheetState = FamilyModalSheetState.of(context);
  /// modalSheetState.pushPage(YourPageWidget());
  /// `
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

  /// Shows a customizable modal bottom sheet with support for internal page
  /// navigation and smooth in-place transitions between content views.
  ///
  /// This enables building flows where users can navigate deeper within the
  /// same bottom sheet — without dismissing or presenting a new sheet —
  /// inspired by the Family app's bottom sheet design language.
  ///
  /// {@template FamilyBottomSheet.ModalSheet}
  ///
  /// This function creates and pushes a [FamilyBottomSheetRoute] onto the
  /// navigator stack, allowing full control over appearance, behavior, and
  /// animation styles of the bottom sheet.
  ///
  /// Parameters:
  /// - `context`: The build context to retrieve the [Navigator] and theming.
  /// - `builder`: The widget builder for the bottom sheet's content.
  /// - `contentBackgroundColor`: The background color for the main content area of the sheet.
  /// - `mainContentBorderRadius`: Optional border radius for the main content area.
  /// - `mainContentPadding`: Optional padding for the main content area.
  /// - `safeAreaMinimum`: Minimum padding to apply when `useSafeArea` is true.
  /// - `backgroundColor`: The background color behind the sheet (typically the sheet's container).
  /// - `barrierLabel`: Semantic label for the modal barrier.
  /// - `elevation`: Elevation of the sheet material.
  /// - `shape`: Custom shape of the sheet.
  /// - `clipBehavior`: Clip behavior for the sheet.
  /// - `constraints`: Constraints for the sheet's size.
  /// - `isScrollControlled`: Whether the sheet can take up the full height of the screen.
  /// - `useRootNavigator`: Whether to push the sheet using the root navigator.
  /// - `isDismissible`: Whether tapping outside dismisses the sheet.
  /// - `enableDrag`: Whether the sheet can be dismissed by dragging down.
  /// - `showDragHandle`: Whether to display a drag handle at the top of the sheet.
  /// - `useSafeArea`: Whether to apply padding for safe areas (notches, etc).
  /// - `routeSettings`: Optional settings to pass to the route.
  /// - `transitionAnimationController`: Optional animation controller for the route transition.
  /// - `anchorPoint`: Optional anchor point for positioning the sheet.
  /// - `mainContentAnimationStyle`: Custom animation style for the main content appearance.
  /// - `sheetAnimationStyle`: Custom animation style for the overall sheet appearance.
  ///
  /// Returns a [Future] that resolves to the value passed to [Navigator.pop] when the sheet is dismissed.
  /// {@endtemplate}
  ///
  /// Example usage:
  /// ```dart
  /// final result = await FamilyBottomSheet.show(
  ///   context: context,
  ///   builder: (context) => YourBottomSheetContent(),
  ///   contentBackgroundColor: Colors.white,
  /// );
  /// ```
  ///
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    required Color contentBackgroundColor,
    BorderRadius? mainContentBorderRadius,
    EdgeInsets? mainContentPadding,
    EdgeInsets? safeAreaMinimum,
    Color? backgroundColor,
    String? barrierLabel,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
    BoxConstraints? constraints,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool? showDragHandle,
    bool useSafeArea = true,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
    AnimationStyle? mainContentAnimationStyle,
    AnimationStyle? sheetAnimationStyle,
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
        contentBackgroundColor: contentBackgroundColor,
        capturedThemes: InheritedTheme.capture(
          from: context,
          to: navigator.context,
        ),
        barrierLabel: barrierLabel ?? localizations.scrimLabel,
        barrierOnTapHint: localizations.scrimOnTapHint(
          localizations.bottomSheetLabel,
        ),
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        constraints: constraints,
        isDismissible: isDismissible,
        useSafeArea: useSafeArea,
        enableDrag: enableDrag,
        modalBarrierColor: barrierColor ??
            Theme.of(context).bottomSheetTheme.modalBarrierColor,
        showDragHandle: showDragHandle,
        settings: routeSettings,
        transitionAnimationController: transitionAnimationController,
        anchorPoint: anchorPoint,
        sheetAnimationStyle: sheetAnimationStyle,
        safeAreaMinimum: safeAreaMinimum,
        mainContentPadding: mainContentPadding,
        mainContentBorderRadius: mainContentBorderRadius,
        mainContentAnimationStyle: mainContentAnimationStyle,
      ),
    );
  }

  /// Shows a customizable modal bottom sheet that follows Flutter's default
  /// Material Design style but still supports internal navigation and
  /// customizable behavior.
  ///
  ///
  /// Use this when you want a bottom sheet that closely resembles Flutter's
  /// Material Design out-of-the-box, with sensible default values for a
  /// more streamlined implementation. This version comes with default styling
  /// choices like rounded corners and minimal safe area handling, making it
  /// quick to use while still offering full flexibility for customization.
  ///
  /// Like [show], it supports pushing and popping pages within the bottom sheet
  /// for internal navigation, giving you the ability to navigate deeper into
  /// content without dismissing or creating new sheets.
  ///
  /// Use this when you want a bottom sheet that feels consistent with
  /// standard Flutter components — simple, familiar, and platform-aligned.
  ///
  /// {@macro FamilyBottomSheet.ModalSheet}
  ///
  /// Example usage:
  /// ```dart
  /// final result = await FamilyBottomSheet.showMaterialDefault(
  ///   context: context,
  ///   builder: (context) => YourBottomSheetContent(),
  ///   contentBackgroundColor: Colors.black,
  /// );
  /// ```
  ///
  static Future<T?> showMaterialDefault<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    required Color contentBackgroundColor,
    BorderRadius mainContentBorderRadius = const BorderRadius.only(
      topLeft: Radius.circular(36),
      topRight: Radius.circular(36),
    ),
    EdgeInsets mainContentPadding = EdgeInsets.zero,
    EdgeInsets? safeAreaMinimum,
    Color? backgroundColor,
    String? barrierLabel,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
    BoxConstraints? constraints,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool? showDragHandle,
    bool useSafeArea = false,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
    AnimationStyle? mainContentAnimationStyle,
    AnimationStyle? sheetAnimationStyle,
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
        contentBackgroundColor: contentBackgroundColor,
        capturedThemes: InheritedTheme.capture(
          from: context,
          to: navigator.context,
        ),
        barrierLabel: barrierLabel ?? localizations.scrimLabel,
        barrierOnTapHint: localizations.scrimOnTapHint(
          localizations.bottomSheetLabel,
        ),
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        constraints: constraints,
        isDismissible: isDismissible,
        useSafeArea: useSafeArea,
        enableDrag: enableDrag,
        modalBarrierColor: barrierColor ??
            Theme.of(context).bottomSheetTheme.modalBarrierColor,
        showDragHandle: showDragHandle,
        settings: routeSettings,
        transitionAnimationController: transitionAnimationController,
        anchorPoint: anchorPoint,
        sheetAnimationStyle: sheetAnimationStyle,
        safeAreaMinimum: safeAreaMinimum,
        mainContentPadding: mainContentPadding,
        mainContentBorderRadius: mainContentBorderRadius,
        mainContentAnimationStyle: mainContentAnimationStyle,
      ),
    );
  }
}

class FamilyModalSheetState extends State<FamilyModalSheet> {
  ParametricCurve<double> _animationCurve = _modalBottomSheetCurve;

  /// A [ValueNotifier] that holds the current index of the page being displayed
  /// in the modal sheet. Used to trigger rebuilds when the page index changes.
  final ValueNotifier<int> _pageIndexNotifier = ValueNotifier<int>(0);

  /// The route that manages the modal sheet's configuration and navigation behavior.
  late FamilyBottomSheetRoute _route;

  /// A list that holds the pages (widgets) currently pushed onto the modal sheet.
  List<Widget> _pages = [];

  /// A getter that returns the list of pages currently in the modal sheet stack.
  List<Widget> get pages => _pages;

  /// A private getter that returns the value of the page index stored in
  /// [_pageIndexNotifier]. This value determines which page is currently displayed.
  int get _currentPageIndex => _pageIndexNotifier.value;

  /// Setter to update the state of [widget.pageIndexNotifier]
  set _currentPageIndex(int value) {
    _pageIndexNotifier.value = value;
  }

  /// The label for the route
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
    _animationCurve = Curves.linear;
  }

  void handleDragEnd(DragEndDetails details, {bool? isClosing}) {
    // Allow the bottom sheet to animate smoothly from its current position.
    _animationCurve = Split(
      widget.route.animation!.value,
      endCurve: _modalBottomSheetCurve,
    );
  }

  @override
  void initState() {
    super.initState();

    _route = widget.route;
    _pages = [widget.route.builder(context)];
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
      animation: _route.animation!,
      builder: (BuildContext context, Widget? child) {
        final double animationValue = _animationCurve.transform(
          _route.animation!.value,
        );

        return Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: routeLabel,
          explicitChildNodes: true,
          child: ClipRect(
            child: _BottomSheetLayoutWithSizeListener(
              onChildSizeChanged: (Size size) {
                _route.didChangeBarrierSemanticsClip(
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
        valueListenable: _pageIndexNotifier,
        builder: (context, currentPageIndex, _) {
          return SafeArea(
            bottom: _route.useSafeArea,
            minimum: widget.safeAreaMinimum ?? EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: FamilyBottomSheet(
                contentBackgroundColor: _route.contentBackgroundColor,
                pageIndex: currentPageIndex,
                animationController: _route.animationController,
                pages: pages,
                onClosing: () {
                  if (_route.isCurrent) {
                    Navigator.pop(context);
                  }
                },
                backgroundColor: widget.backgroundColor ?? Colors.transparent,
                elevation: widget.elevation,
                shape: widget.shape,
                clipBehavior: widget.clipBehavior,
                constraints: widget.constraints,
                enableDrag: widget.enableDrag,
                showDragHandle: widget.showDragHandle,
                onDragStart: handleDragStart,
                onDragEnd: handleDragEnd,
                mainContentPadding: _route.mainContentPadding,
                mainContentAnimationStyle: _route.mainContentAnimationStyle,
                mainContentBorderRadius: _route.mainContentBorderRadius,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Adds a new page widget to the modal stack and updates the current page index
  /// to trigger a rebuild in the [ValueNotifier]. This allows the modal sheet to
  /// display new content by pushing the page onto the navigation stack.
  void pushPage(Widget page) {
    _pages = List<Widget>.of(_pages)..add(page);
    _currentPageIndex = _pages.length - 1;
  }

  /// Removes the top widget page from the custom modal stack.
  ///
  /// If the stack has more than one page, the top page is removed and the current
  /// page index is decremented to display the next page in the stack.
  ///
  /// If there is only one page left in the stack, it will pop the modal sheet,
  /// effectively dismissing it.
  void popPage() {
    if (_pages.length > 1) {
      _pages = List<Widget>.of(_pages)..removeLast();
      _currentPageIndex--;
    } else {
      Navigator.of(context).pop();
    }
  }
}

/// Copied from the Flutter framework
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
  })  : _onChildSizeChanged = onChildSizeChanged,
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
    final Size childSize = childConstraints.isTight
        ? childConstraints.smallest
        : child.getDryLayout(childConstraints);
    return result + _getPositionForChild(constraints.biggest, childSize).dy;
  }

  BoxConstraints _getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      maxHeight: isScrollControlled
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
