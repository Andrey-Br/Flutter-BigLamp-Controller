import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class HighlightCursor extends LeafRenderObjectWidget {
  const HighlightCursor(
      {required this.color,
      this.backgroundColor,
      this.repaintBoundary = true,
      required this.radius,
      this.smooth = 0,
      super.key});

  final Color color;
  final Color? backgroundColor;
  final bool repaintBoundary;
  final double radius;
  final double smooth;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderHighlightCursour(
        color: color,
        backgroundColor: backgroundColor,
        repaintBoundary: repaintBoundary,
        radius: radius,
        smooth: smooth);
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderHighlightCursour renderObject) {
    renderObject
      ..color = color
      ..backgroundColor = backgroundColor
      ..repaintBoundary = repaintBoundary
      ..radius = radius
      ..smooth = smooth;
  }
}

class _RenderHighlightCursour extends RenderBox {
  _RenderHighlightCursour(
      {required Color color,
      required Color? backgroundColor,
      required bool repaintBoundary,
      required double radius,
      required double smooth})
      : _color = color,
        _backgroundColor = backgroundColor,
        _repaintBoundary = repaintBoundary,
        _radius = radius,
        _smooth = smooth;

  Offset cursorPosition = Offset.zero;
  double open = 1.0;

  Color _color;
  Color get color => _color;
  set color(Color value) {
    if (_color == value) {
      return;
    }

    _color = value;
    markNeedsPaint();
  }

  Color? _backgroundColor;
  Color? get backgroundColor => _backgroundColor;
  set backgroundColor(Color? value) {
    if (_backgroundColor == value) {
      return;
    }

    _backgroundColor = value;
    markNeedsPaint();
  }

  bool _repaintBoundary;
  bool get repaintBoundary => _repaintBoundary;
  set repaintBoundary(bool value) {
    if (_repaintBoundary == value) {
      return;
    }

    _repaintBoundary = value;
    markParentNeedsLayout();
  }

  double _radius;
  double get radius => _radius;
  set radius(double value) {
    if (_radius == value) {
      return;
    }

    _radius = value;
    markNeedsPaint();
  }

  double _smooth;
  double get smooth => _smooth;
  set smooth(double value) {
    if (_smooth == value) {
      return;
    }

    _smooth = value;
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => _repaintBoundary;

  @override
  bool hitTestSelf(Offset position) {
    return size.contains(position);
  }

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));

    if (event is PointerHoverEvent || event is PointerMoveEvent) {
      cursorPosition = event.localPosition;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.pushClipRect(needsCompositing, offset, Offset.zero & size,
        (context, offset) {
      if (backgroundColor != null) {
        context.canvas.drawPaint(Paint()..color = backgroundColor!);
      }

      final double sizeCircle = radius * open;

      final paint = Paint()
        ..shader = ui.Gradient.radial(cursorPosition, radius,
            [color, color, color.withAlpha(0)], [0, smooth, 1.0]);

      context.canvas.drawCircle(cursorPosition + offset, sizeCircle, paint);
    });
  }
}
