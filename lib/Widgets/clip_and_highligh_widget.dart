import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ClipRRectAndHighlight extends SingleChildRenderObjectWidget {
  const ClipRRectAndHighlight(
      {this.borderRadius = BorderRadius.zero,
      this.color,
      this.backroundColor,
      this.borderWidth = 0,
      this.height,
      this.width,
      super.key,
      super.child});

  final BorderRadius borderRadius;
  final Color? color;
  final Color? backroundColor;
  final double borderWidth;
  final double? height;
  final double? width;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderClipRRectAndHighlight(
      color: color,
      backgroundColor: backroundColor,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      width: width,
      height: height,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderClipRRectAndHighlight renderObject) {
    renderObject
      ..backroundColor = backroundColor
      ..color = color
      ..borderRadius = borderRadius
      ..borderWidth = borderWidth
      ..height = height
      ..width = width;
  }
}

class _RenderClipRRectAndHighlight extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderClipRRectAndHighlight({
    required BorderRadius borderRadius,
    required Color? color,
    required Color? backgroundColor,
    required double borderWidth,
    required double? width,
    required double? height,
  })  : _borderRadius = borderRadius,
        _color = color,
        _backroundColor = backgroundColor,
        _borderWidth = borderWidth,
        _width = width,
        _height = height;

  BorderRadius _borderRadius;
  BorderRadius get borderRadius => _borderRadius;
  set borderRadius(BorderRadius value) {
    if (value == _borderRadius) {
      return;
    }
    _borderRadius = value;
  }

  Color? _color;
  Color? get color => _color;
  set color(Color? value) {
    if (value == _color) {
      return;
    }
    _color = value;

    markNeedsPaint();
  }

  Color? _backroundColor;
  Color? get backroundColor => _backroundColor;
  set backroundColor(Color? value) {
    if (value == _backroundColor) {
      return;
    }
    _backroundColor = value;

    markNeedsPaint();
  }

  double _borderWidth;
  double get borderWidth => _borderWidth;
  set borderWidth(double value) {
    if (value == _borderWidth) {
      return;
    }
    _borderWidth = value;
    markNeedsPaint();
  }

  double? _height;
  double? get height => _height;
  set height(double? value) {
    if (value == _height) {
      return;
    }
    _height = value;
    markNeedsLayout();
  }

  double? _width;
  double? get width => _width;
  set width(double? value) {
    if (value == _width) {
      return;
    }
    _width = value;

    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = constraints
        .constrain(Size(width ?? double.infinity, height ?? double.infinity));

    if (child != null) {
      child!.layout(BoxConstraints.loose(size));
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child != null) {
      child!.hitTest(result, position: position);
    }
    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RRect rrect = RRect.fromRectAndCorners(
      Offset.zero & size,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    context.pushClipRRect(needsCompositing, offset, offset & size, rrect,
        (context, offset) {
      if (backroundColor != null) {
        context.canvas.drawPaint(Paint()..color = backroundColor!);
      }

      if (child != null) {
        context.paintChild(child!, offset);
      }
    });

    if (color != null && borderWidth > 0) {
      context.canvas.drawRRect(
          rrect.shift(offset),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = color!
            ..strokeWidth = borderWidth);
    }
  }
}
