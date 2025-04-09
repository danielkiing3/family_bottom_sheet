import 'dart:math' as math;

import 'package:family_bottom_sheet/src/custom_bottom_sheet/widgets/modal_sheet_animated_switcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const Duration _bottomSheetEnterDuration = Duration(milliseconds: 250);
const Duration _bottomSheetExitDuration = Duration(milliseconds: 200);
const double _minFlingVelocity = 700.0;
const double _closeProgressThreshold = 0.5;

/// A callback for when the user begins dragging the bottom sheet.
///
/// Used by [BottomSheet.onDragStart].
typedef BottomSheetDragStartHandler = void Function(DragStartDetails details);

/// A callback for when the user stops dragging the bottom sheet.
///
/// Used by [BottomSheet.onDragEnd].
typedef BottomSheetDragEndHandler = void Function(DragEndDetails details,
    {required bool isClosing});

/// A customizable bottom sheet widget with built-in support for internal
/// navigation, multi-page stack, and drag-to-dismiss behavior.
class FamilyBottomSheet extends StatefulWidget {
  const FamilyBottomSheet({
    super.key,
    required this.pageIndex,
    required this.pages,
    required this.contentBackgroundColor,
    required this.onClosing,
    this.animationController,
    this.enableDrag = true,
    this.showDragHandle,
    this.dragHandleColor,
    this.dragHandleSize,
    this.onDragStart,
    this.onDragEnd,
    this.backgroundColor,
    this.shadowColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.mainContentPadding,
    this.mainContentBorderRadius,
    this.mainContentAnimationStyle,
  }) : assert(elevation == null || elevation >= 0.0);

  /// The animation controller that controls the bottom sheet's entrance and
  /// exit animations.
  ///
  /// The BottomSheet widget will manipulate the position of this animation, it
  /// is not just a passive observer.
  final AnimationController? animationController;

  /// Called when the bottom sheet begins to close.
  ///
  /// A bottom sheet might be prevented from closing (e.g., by user
  /// interaction) even after this callback is called. For this reason, this
  /// callback might be call multiple times for a given bottom sheet.
  final VoidCallback onClosing;

  /// If true, the bottom sheet can be dragged up and down and dismissed by
  /// swiping downwards.
  ///
  /// If [showDragHandle] is true, this only applies to the content below the drag handle,
  /// because the drag handle is always draggable.
  ///
  /// Default is true.
  final bool enableDrag;

  /// Specifies whether a drag handle is shown.
  final bool? showDragHandle;

  /// The bottom sheet drag handle's color.
  ///
  /// Defaults to [BottomSheetThemeData.dragHandleColor].
  /// If that is also null, defaults to [ColorScheme.onSurfaceVariant].
  final Color? dragHandleColor;

  /// Defaults to [BottomSheetThemeData.dragHandleSize].
  /// If that is also null, defaults to Size(32, 4).
  final Size? dragHandleSize;

  /// Called when the user begins dragging the bottom sheet vertically, if
  /// [enableDrag] is true.
  final BottomSheetDragStartHandler? onDragStart;

  // Called when the user stops dragging the bottom sheet, if [enableDrag]
  /// is true.
  final BottomSheetDragEndHandler? onDragEnd;

  /// The bottom sheet's background color.
  final Color? backgroundColor;

  /// The color of the shadow below the sheet.
  final Color? shadowColor;

  /// The elevation of the bottom sheet.
  final double? elevation;

  /// The shape of the bottom sheet.
  final ShapeBorder? shape;

  /// The clip behavior of the bottom sheet.
  final Clip? clipBehavior;

  /// The constraints of the bottom sheet.
  /// Defines minimum and maximum sizes for a [FamilyBottomSheet].
  final BoxConstraints? constraints;

  /// The current index of the page to display
  final int pageIndex;

  /// The list of pages to be display
  final List<Widget> pages;

  /// The background color of the modal sheet
  final Color contentBackgroundColor;

  /// The padding of the main content
  final EdgeInsets? mainContentPadding;

  /// The border radius of the main content
  ///
  /// Defaults to placeholder value if no value is passed
  final BorderRadius? mainContentBorderRadius;

  /// The animation style of the animated switcher
  final AnimationStyle? mainContentAnimationStyle;

  static AnimationController createAnimationController(
    TickerProvider vsync, {
    AnimationStyle? sheetAnimationStyle,
  }) {
    return AnimationController(
      duration: sheetAnimationStyle?.duration ?? _bottomSheetEnterDuration,
      reverseDuration:
          sheetAnimationStyle?.reverseDuration ?? _bottomSheetExitDuration,
      debugLabel: 'BottomSheet',
      vsync: vsync,
    );
  }

  @override
  State<FamilyBottomSheet> createState() => _FamilyBottomSheetState();
}

class _FamilyBottomSheetState extends State<FamilyBottomSheet> {
  /// Key used to access the bottom sheet's child widget for layout and size calculations.
  final GlobalKey _childKey = GlobalKey(debugLabel: 'FamilyBottomSheet child');

  /// Returns the current height of the bottom sheet's child widget.
  ///
  /// Relies on the widget being laid out in the widget tree.
  double get _childHeight {
    final RenderBox renderBox =
        _childKey.currentContext!.findRenderObject()! as RenderBox;
    return renderBox.size.height;
  }

  /// Whether the bottom sheet is in the process of being dismissed
  /// via animation (e.g., user swipe down or programmatic pop).
  bool get _dismissUnderway =>
      widget.animationController!.status == AnimationStatus.reverse;

  /// Tracks the current interaction states (e.g., hovered, pressed, focused)
  /// of the drag handle widget.
  Set<WidgetState> dragHandleStates = <WidgetState>{};

  /// Handles the drag start gesture on the bottom sheet.
  ///
  /// Invokes the [onDragStart] callback if provided.
  /// Also updates the internal [dragHandleStates] to include
  /// [WidgetState.pressed] to reflect the active drag interaction.
  void _handleDragStart(DragStartDetails details) {
    setState(() {
      dragHandleStates.add(WidgetState.dragged);
    });
    widget.onDragStart?.call(details);
  }

  /// Handles the drag update gesture on the bottom sheet.
  ///
  /// Updates the bottom sheet's position based on the user's finger movement.
  void _handleDragUpdate(DragUpdateDetails details) {
    assert(
      (widget.enableDrag || (widget.showDragHandle ?? false)) &&
          widget.animationController != null,
      "'FamilyBottomSheet.animationController' cannot be null when 'FamilyBottomSheet.enableDrag' or 'FamilyBottomSheet.showDragHandle' is true. "
      "Use 'FamilyBottomSheet.createAnimationController' to create one, or provide another AnimationController.",
    );
    if (_dismissUnderway) {
      return;
    }
    widget.animationController!.value -= details.primaryDelta! / _childHeight;
  }

  /// Handles the drag end gesture on the bottom sheet.
  ///
  /// Removes the pressed state from [dragHandleStates] and
  /// invokes the [onDragEnd] callback if provided.
  void _handleDragEnd(DragEndDetails details) {
    assert(
      (widget.enableDrag || (widget.showDragHandle ?? false)) &&
          widget.animationController != null,
      "'FamilyBottomSheet.animationController' cannot be null when 'FamilyBottomSheet.enableDrag' or 'FamilyBottomSheet.showDragHandle' is true. "
      "Use 'FamilyBottomSheet.createAnimationController' to create one, or provide another AnimationController.",
    );
    if (_dismissUnderway) {
      return;
    }
    setState(() {
      dragHandleStates.remove(WidgetState.dragged);
    });
    bool isClosing = false;
    if (details.velocity.pixelsPerSecond.dy > _minFlingVelocity) {
      final double flingVelocity =
          -details.velocity.pixelsPerSecond.dy / _childHeight;
      if (widget.animationController!.value > 0.0) {
        widget.animationController!.fling(velocity: flingVelocity);
      }
      if (flingVelocity < 0.0) {
        isClosing = true;
      }
    } else if (widget.animationController!.value < _closeProgressThreshold) {
      if (widget.animationController!.value > 0.0) {
        widget.animationController!.fling(velocity: -1.0);
      }
      isClosing = true;
    } else {
      widget.animationController!.forward();
    }

    widget.onDragEnd?.call(details, isClosing: isClosing);

    if (isClosing) {
      widget.onClosing();
    }
  }

  /// Determines whether the draggable scrollable sheet's extent
  /// has changed enough to require a rebuild or layout update.
  ///
  /// Returns `true` if the extent has changed significantly.
  bool extentChanged(DraggableScrollableNotification notification) {
    if (notification.extent == notification.minExtent &&
        notification.shouldCloseOnMinExtent) {
      widget.onClosing();
    }
    return false;
  }

  /// Handles the hover state of the drag handle (primarily for desktop/web).
  ///
  /// Updates [dragHandleStates] to include or remove [WidgetState.hovered]
  /// based on whether the pointer is hovering over the drag handle.
  void _handleDragHandleHover(bool hovering) {
    if (hovering != dragHandleStates.contains(WidgetState.hovered)) {
      setState(() {
        if (hovering) {
          dragHandleStates.add(WidgetState.hovered);
        } else {
          dragHandleStates.remove(WidgetState.hovered);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final BottomSheetThemeData bottomSheetTheme =
        Theme.of(context).bottomSheetTheme;
    final bool useMaterial3 = Theme.of(context).useMaterial3;
    final BottomSheetThemeData defaults = useMaterial3
        ? _BottomSheetDefaultsM3(context)
        : const BottomSheetThemeData();
    final BoxConstraints? constraints = widget.constraints ??
        bottomSheetTheme.constraints ??
        defaults.constraints;
    final Color? color = widget.backgroundColor ??
        bottomSheetTheme.backgroundColor ??
        defaults.backgroundColor;
    final Color? surfaceTintColor =
        bottomSheetTheme.surfaceTintColor ?? defaults.surfaceTintColor;
    final Color? shadowColor = widget.shadowColor ??
        bottomSheetTheme.shadowColor ??
        defaults.shadowColor;
    final double elevation = widget.elevation ??
        bottomSheetTheme.elevation ??
        defaults.elevation ??
        0;
    final ShapeBorder? shape =
        widget.shape ?? bottomSheetTheme.shape ?? defaults.shape;
    final Clip clipBehavior =
        widget.clipBehavior ?? bottomSheetTheme.clipBehavior ?? Clip.none;
    final bool showDragHandle = widget.showDragHandle ??
        (widget.enableDrag && (bottomSheetTheme.showDragHandle ?? false));

    Widget? dragHandle;
    if (showDragHandle) {
      dragHandle = _DragHandle(
        onSemanticsTap: widget.onClosing,
        handleHover: _handleDragHandleHover,
        states: dragHandleStates,
        dragHandleColor: widget.dragHandleColor,
        dragHandleSize: widget.dragHandleSize,
      );
      // Only add [_BottomSheetGestureDetector] to the drag handle when the rest of the
      // bottom sheet is not draggable. If the whole bottom sheet is draggable,
      // no need to add it.
      if (!widget.enableDrag) {
        dragHandle = _BottomSheetGestureDetector(
          onVerticalDragStart: _handleDragStart,
          onVerticalDragUpdate: _handleDragUpdate,
          onVerticalDragEnd: _handleDragEnd,
          child: dragHandle,
        );
      }
    }

    final pageContent = FamilyModalSheetAnimatedSwitcher(
      pageIndex: widget.pageIndex,
      pages: widget.pages,
      contentBackgroundColor: widget.contentBackgroundColor,
      mainContentPadding: widget.mainContentPadding,
      mainContentBorderRadius: widget.mainContentBorderRadius,
      mainContentAnimationStyle: widget.mainContentAnimationStyle,
    );

    Widget bottomSheet = Material(
      key: _childKey,
      color: color,
      elevation: elevation,
      surfaceTintColor: surfaceTintColor,
      shadowColor: shadowColor,
      shape: shape,
      clipBehavior: clipBehavior,
      child: NotificationListener<DraggableScrollableNotification>(
        onNotification: extentChanged,
        child: !showDragHandle
            ? pageContent
            : Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  dragHandle!,
                  Padding(
                    padding: const EdgeInsets.only(
                      top: kMinInteractiveDimension,
                    ),
                    child: pageContent,
                  ),
                ],
              ),
      ),
    );

    if (constraints != null) {
      bottomSheet = Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1.0,
        child: ConstrainedBox(constraints: constraints, child: bottomSheet),
      );
    }

    return !widget.enableDrag
        ? bottomSheet
        : _BottomSheetGestureDetector(
            onVerticalDragStart: _handleDragStart,
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            child: bottomSheet,
          );
  }
}

/// Copied from the Flutter framework
///
/// This widget is used to display the drag handle on the bottom sheet
class _DragHandle extends StatelessWidget {
  const _DragHandle({
    required this.onSemanticsTap,
    required this.handleHover,
    required this.states,
    this.dragHandleColor,
    this.dragHandleSize,
  });

  final VoidCallback? onSemanticsTap;
  final ValueChanged<bool> handleHover;
  final Set<WidgetState> states;
  final Color? dragHandleColor;
  final Size? dragHandleSize;

  @override
  Widget build(BuildContext context) {
    final BottomSheetThemeData bottomSheetTheme =
        Theme.of(context).bottomSheetTheme;
    final BottomSheetThemeData m3Defaults = _BottomSheetDefaultsM3(context);
    final Size handleSize = dragHandleSize ??
        bottomSheetTheme.dragHandleSize ??
        m3Defaults.dragHandleSize!;

    return MouseRegion(
      onEnter: (PointerEnterEvent event) => handleHover(true),
      onExit: (PointerExitEvent event) => handleHover(false),
      child: Semantics(
        label: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        container: true,
        onTap: onSemanticsTap,
        child: SizedBox(
          width: math.max(handleSize.width, kMinInteractiveDimension),
          height: math.max(handleSize.height, kMinInteractiveDimension),
          child: Center(
            child: Container(
              height: handleSize.height,
              width: handleSize.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(handleSize.height / 2),
                color: WidgetStateProperty.resolveAs<Color?>(
                      dragHandleColor,
                      states,
                    ) ??
                    WidgetStateProperty.resolveAs<Color?>(
                      bottomSheetTheme.dragHandleColor,
                      states,
                    ) ??
                    m3Defaults.dragHandleColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Copied from the Flutter framework
///
/// This widget is used to detect vertical drag gestures on the bottom sheet
class _BottomSheetGestureDetector extends StatelessWidget {
  const _BottomSheetGestureDetector({
    required this.child,
    required this.onVerticalDragStart,
    required this.onVerticalDragUpdate,
    required this.onVerticalDragEnd,
  });

  final Widget child;
  final GestureDragStartCallback onVerticalDragStart;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      excludeFromSemantics: true,
      gestures: <Type, GestureRecognizerFactory<GestureRecognizer>>{
        VerticalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(debugOwner: this),
          (VerticalDragGestureRecognizer instance) {
            instance
              ..onStart = onVerticalDragStart
              ..onUpdate = onVerticalDragUpdate
              ..onEnd = onVerticalDragEnd
              ..onlyAcceptDragOnThreshold = true;
          },
        ),
      },
      child: child,
    );
  }
}

/// Copied from the Flutter framework. The Material 3 defaults spec for bottom sheet
///
/// This class is used to provide the default values for the bottom sheet theme
class _BottomSheetDefaultsM3 extends BottomSheetThemeData {
  _BottomSheetDefaultsM3(this.context)
      : super(
          elevation: 1.0,
          modalElevation: 1.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
          ),
          constraints: const BoxConstraints(maxWidth: 640),
        );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get backgroundColor => _colors.surfaceContainerLow;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get dragHandleColor => _colors.onSurfaceVariant;

  @override
  Size? get dragHandleSize => const Size(32, 4);

  @override
  BoxConstraints? get constraints => const BoxConstraints(maxWidth: 640.0);
}
