import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Lays every page out at its own size and sizes itself between the page at
/// [fromIndex] and the page at [toIndex] by [progress].
///
/// Sizes are read during layout
class PageStackLayout extends MultiChildRenderObjectWidget {
  const PageStackLayout({
    super.key,
    required this.fromIndex,
    required this.toIndex,
    required this.progress,
    required this.alignment,
    required this.clipBehavior,
    super.children,
  });

  final int fromIndex;
  final int toIndex;
  final double progress;
  final AlignmentGeometry alignment;
  final Clip clipBehavior;

  @override
  RenderPageStack createRenderObject(BuildContext context) {
    return RenderPageStack(
      fromIndex: fromIndex,
      toIndex: toIndex,
      progress: progress,
      alignment: alignment.resolve(Directionality.maybeOf(context)),
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPageStack renderObject) {
    renderObject
      ..fromIndex = fromIndex
      ..toIndex = toIndex
      ..progress = progress
      ..alignment = alignment.resolve(Directionality.maybeOf(context))
      ..clipBehavior = clipBehavior;
  }
}

/// Marks whether one page of a [PageStackLayout] is painted.
class PageStackSlot extends ParentDataWidget<PageStackParentData> {
  const PageStackSlot({super.key, required this.visible, required super.child});

  final bool visible;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as PageStackParentData;
    if (parentData.visible != visible) {
      parentData.visible = visible;
      renderObject.parent?.markNeedsPaint();
      renderObject.parent?.markNeedsSemanticsUpdate();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => PageStackLayout;
}

class PageStackParentData extends ContainerBoxParentData<RenderBox> {
  bool visible = true;
}

class RenderPageStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, PageStackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, PageStackParentData> {
  RenderPageStack({
    required int fromIndex,
    required int toIndex,
    required double progress,
    required Alignment alignment,
    required Clip clipBehavior,
  })  : _fromIndex = fromIndex,
        _toIndex = toIndex,
        _progress = progress,
        _alignment = alignment,
        _clipBehavior = clipBehavior;

  int get fromIndex => _fromIndex;
  int _fromIndex;
  set fromIndex(int value) {
    if (_fromIndex == value) return;
    _fromIndex = value;
    markNeedsLayout();
  }

  int get toIndex => _toIndex;
  int _toIndex;
  set toIndex(int value) {
    if (_toIndex == value) return;
    _toIndex = value;
    markNeedsLayout();
  }

  double get progress => _progress;
  double _progress;
  set progress(double value) {
    if (_progress == value) return;
    _progress = value;
    markNeedsLayout();
  }

  Alignment get alignment => _alignment;
  Alignment _alignment;
  set alignment(Alignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior;
  set clipBehavior(Clip value) {
    if (_clipBehavior == value) return;
    _clipBehavior = value;
    markNeedsPaint();
  }

  bool _hasOverflow = false;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! PageStackParentData) {
      child.parentData = PageStackParentData();
    }
  }

  List<RenderBox> get _children => getChildrenAsList();

  BoxConstraints _childConstraints(BoxConstraints constraints) =>
      constraints.copyWith(minHeight: 0);

  Size _blend(Size from, Size to, BoxConstraints constraints) {
    return constraints.constrain(Size.lerp(from, to, progress)!);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final children = _children;
    if (children.isEmpty) return constraints.smallest;
    final childConstraints = _childConstraints(constraints);
    return _blend(
      children[fromIndex].getDryLayout(childConstraints),
      children[toIndex].getDryLayout(childConstraints),
      constraints,
    );
  }

  @override
  void performLayout() {
    final children = _children;
    if (children.isEmpty) {
      size = constraints.smallest;
      return;
    }

    final childConstraints = _childConstraints(constraints);
    for (final child in children) {
      child.layout(childConstraints, parentUsesSize: true);
    }
    size =
        _blend(children[fromIndex].size, children[toIndex].size, constraints);

    _hasOverflow = false;
    for (final child in children) {
      final parentData = child.parentData! as PageStackParentData;
      parentData.offset = alignment.alongOffset(size - child.size as Offset);
      if (parentData.visible &&
          (child.size.width > size.width || child.size.height > size.height)) {
        _hasOverflow = true;
      }
    }
  }

  double _blendIntrinsic(double Function(RenderBox child) intrinsic) {
    final children = _children;
    if (children.isEmpty) return 0;
    return ui.lerpDouble(
      intrinsic(children[fromIndex]),
      intrinsic(children[toIndex]),
      progress,
    )!;
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _blendIntrinsic((child) => child.getMinIntrinsicWidth(height));

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _blendIntrinsic((child) => child.getMaxIntrinsicWidth(height));

  @override
  double computeMinIntrinsicHeight(double width) =>
      _blendIntrinsic((child) => child.getMinIntrinsicHeight(width));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _blendIntrinsic((child) => child.getMaxIntrinsicHeight(width));

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final children = _children;
    if (children.isEmpty) return null;
    final child = children[toIndex];
    final parentData = child.parentData! as PageStackParentData;
    final distance = child.getDistanceToActualBaseline(baseline);
    return distance == null ? null : distance + parentData.offset.dy;
  }

  void _paintVisible(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as PageStackParentData;
      if (parentData.visible) {
        context.paintChild(child, offset + parentData.offset);
      }
      child = parentData.nextSibling;
    }
  }

  final LayerHandle<ClipRectLayer> _clipLayer = LayerHandle<ClipRectLayer>();

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_hasOverflow && clipBehavior != Clip.none) {
      _clipLayer.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        _paintVisible,
        clipBehavior: clipBehavior,
        oldLayer: _clipLayer.layer,
      );
    } else {
      _clipLayer.layer = null;
      _paintVisible(context, offset);
    }
  }

  @override
  void dispose() {
    _clipLayer.layer = null;
    super.dispose();
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) =>
      _hasOverflow && clipBehavior != Clip.none ? Offset.zero & size : null;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = lastChild;
    while (child != null) {
      final parentData = child.parentData! as PageStackParentData;
      if (parentData.visible) {
        final isHit = result.addWithPaintOffset(
          offset: parentData.offset,
          position: position,
          hitTest: (result, transformed) =>
              child!.hitTest(result, position: transformed),
        );
        if (isHit) return true;
      }
      child = parentData.previousSibling;
    }
    return false;
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    visitChildren((child) {
      if ((child.parentData! as PageStackParentData).visible) visitor(child);
    });
  }
}
