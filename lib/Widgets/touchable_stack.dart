import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// В отличие от Stack обрабатывает касания всех детей, а не только верхнего
class GlassyStack extends MultiChildRenderObjectWidget {
  const GlassyStack({super.key, super.children});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderGlassyStack();
  }
}

class _GlassyStackParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderGlassyStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _GlassyStackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _GlassyStackParentData> {
  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _GlassyStackParentData) {
      child.parentData = _GlassyStackParentData();
    }
  }

  Iterable<RenderBox> children() sync* {
    RenderBox? child = firstChild;

    while (child != null) {
      yield child;
      child = (child.parentData as _GlassyStackParentData).nextSibling;
    }
  }

  @override
  void performLayout() {
    for (var child in children()) {
      child.layout(constraints);
    }

    size = constraints.biggest;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    bool resultValue = false;

    for (var child in children()) {
      if (child.hitTest(result, position: position)) {
        resultValue = true;
      }
    }

    return resultValue;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for (var child in children()) {
      context.paintChild(child, offset);
    }
  }
}
