import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class StructureHexagonalWidget extends SingleChildRenderObjectWidget {
  StructureHexagonalWidget(
      {Key? key,
      Widget? child,
      Color? color,
      this.backgroundColor,
      required this.diameter,
      this.padding = 1.0,
      this.repaintBoundary = true})
      : super(
            key: key,
            child: HexagonalPathWidget(
                color: color,
                diameter: diameter,
                withSafeArea: true,
                rotation: 0,
                child: child));

  final double padding;
  final double diameter;
  final Color? backgroundColor;
  final bool repaintBoundary;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderStructureHexagonalWidget(
        raduis: diameter,
        padding: padding,
        backgroundColor: backgroundColor,
        repaintBoundary: repaintBoundary);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderStructureHexagonalWidget renderObject) {
    renderObject
      ..diameter = diameter
      ..padding = padding
      ..backgroundColor = backgroundColor
      ..repaintBoundary = repaintBoundary;
  }
}

class RenderStructureHexagonalWidget extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderStructureHexagonalWidget(
      {required double raduis,
      required double padding,
      required Color? backgroundColor,
      required bool repaintBoundary})
      : _diameter = raduis,
        _padding = padding,
        _backgroundColor = backgroundColor,
        _repaintBoundary = repaintBoundary;

  bool _repaintBoundary;
  bool get repaintBoundary => _repaintBoundary;
  set repaintBoundary(bool value) {
    if (_repaintBoundary == value) {
      return;
    }

    _repaintBoundary = value;
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => _repaintBoundary;

  Color? _backgroundColor;
  set backgroundColor(Color? value) {
    if (_backgroundColor == value) {
      return;
    }

    _backgroundColor = value;
    markNeedsPaint();
  }

  Color? get backgroundColor => _backgroundColor;

  double _diameter;
  double get diameter => _diameter;
  set diameter(double value) {
    if (value == _diameter) {
      return;
    }

    _diameter = value;
    markNeedsPaint();
  }

  double get outRadius => diameter / 2;
  double get inRadius => outRadius * sin(pi * 2 / 3);
  double get difRadius => outRadius - inRadius;

  double _padding;
  double get padding => _padding;
  double get divPadding => padding / 2;
  set padding(double value) {
    if (_padding == value) {
      return;
    }

    _padding = value;
    markNeedsPaint();
  }

  double get yMath => outRadius * sin(pi / 3);
  double get xMath => outRadius * cos(pi / 3);

  double get xPadding => padding * cos(pi / 3);

  Offset get center => Offset(outRadius, outRadius);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    child?.layout(BoxConstraints.loose(size));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(child != null);

    final countWidth = size.width ~/ (diameter + padding);
    final countHeight = size.height ~/ ((inRadius * 2) + (padding / 2));
    final totalLength = (outRadius * 3) + padding;

    Offset start = Offset.zero;

    Offset second =
        start + Offset(xPadding + outRadius + xMath, inRadius + (padding / 4));

    Offset ydif = Offset(0, (inRadius * 2) + (padding / 2));

    context.pushClipRect(needsCompositing, offset, Offset.zero & size,
        (context, offset) {
      if (backgroundColor != null) {
        context.canvas.drawPaint(Paint()..color = backgroundColor!);
      }

      for (int y = -1; y <= countHeight + 1; y++) {
        final offY = ydif * y.toDouble();

        for (int i = -1; i <= countWidth; i++) {
          context.paintChild(
              child!,
              offY +
                  start +
                  offset +
                  Offset((totalLength * i) - (padding / 2), 0));
        }

        for (int i = -1; i <= countWidth; i++) {
          context.paintChild(
              child!,
              offY +
                  second +
                  offset +
                  Offset((totalLength * i) - (padding / 2), 0));
        }
      }
    });
  }
}

class HexagonalPathWidget extends SingleChildRenderObjectWidget {
  final double diameter;
  final Color? color;
  final double rotation;
  final bool withSafeArea;

  const HexagonalPathWidget(
      {required this.diameter,
      Key? key,
      this.color,
      Widget? child,
      this.withSafeArea = false,
      this.rotation = 0})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderHexagonalPathWidget(
        color: color,
        diameter: diameter,
        withSafeArea: withSafeArea,
        rotataion: rotation);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderHexagonalPathWidget renderObject) {
    renderObject
      ..diameter = diameter
      ..color = color
      ..withSafeArea = withSafeArea
      ..rotation = rotation;
  }
}

class RenderHexagonalPathWidget extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderHexagonalPathWidget(
      {required double diameter,
      required Color? color,
      bool withSafeArea = false,
      double rotataion = 0})
      : _diameter = diameter,
        _color = color,
        _withSafeArea = withSafeArea,
        _rotation = rotataion;

  bool _withSafeArea;
  bool get withSafeArea => _withSafeArea;
  set withSafeArea(bool value) {
    if (_withSafeArea == value) {
      return;
    }

    _withSafeArea = value;
    markParentNeedsLayout();
    markNeedsPaint();
  }

  double _rotation;
  double get rotation => _rotation;
  set rotation(double value) {
    if (_rotation == value) {
      return;
    }

    _rotation = value;

    if (withSafeArea) {
      markNeedsPaint();
    } else {
      markParentNeedsLayout();
      markNeedsPaint();
    }
  }

  double _diameter;
  double get diameter => _diameter;
  set diameter(double value) {
    if (_diameter == value) {
      return;
    }
    _diameter = value;
    markParentNeedsLayout();
    markNeedsPaint();
  }

  double get radius => diameter / 2;

  Offset get center => Offset(needSize.width / 2, needSize.height / 2);

  late Path _path;

  Size needSize = Size(0, 0);

  Color? _color;
  set color(Color? value) {
    if (_color == value) {
      return;
    }

    _color = value;

    markNeedsPaint();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (!_path.contains(position)) {
      return false;
    }
    return child?.hitTest(result, position: position) ?? false;
  }

  Size getSizeWithoutSafeArea() {
    final points = hexPathPoints(rotation, radius);

    double maxWidth = 0;
    double maxHeight = 0;

    for (var point in points) {
      maxWidth = max(maxWidth, point.dx);
      maxHeight = max(maxHeight, point.dy);
    }

    return Size(maxWidth * 2, maxHeight * 2);
  }

  @override
  void performLayout() {
    // final maxConstrainsSize = constraints.biggest.shortestSide;
    // final resultSize = min(_diameter, maxConstrainsSize);

    if (withSafeArea) {
      needSize = Size.square(diameter);
    } else {
      needSize = getSizeWithoutSafeArea();
    }

    size = Size(min(needSize.width, constraints.maxWidth),
        min(needSize.height, constraints.maxHeight));

    child?.layout(BoxConstraints.loose(needSize));
  }

  static Iterable<Offset> hexPathPoints(double rotation,
          [double distance = 1]) =>
      <Offset>[
        for (int i = 0; i < 6; i++)
          Offset.fromDirection(rotation + (i * pi / 3), distance)
      ];

  Path generatePath(double diameter) {
    final points = hexPathPoints(rotation, radius);

    _path = Path();

    _path.moveTo((center + points.last).dx, (center + points.last).dy);

    for (var point in points) {
      _path.lineTo((center + point).dx, (center + point).dy);
    }

    _path.close();

    return _path;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(!(_color == null && child == null));

    final path = generatePath(_diameter);

    context.pushClipRect(needsCompositing, offset, Offset.zero & size,
        (context, offset) {
      context.pushClipPath(needsCompositing, offset, offset & size, path,
          (context, offset) {
        final canvas = context.canvas;

        if (_color != null) {
          canvas.drawPaint(Paint()..color = _color!);
        }

        if (child != null) {
          context.paintChild(child!, offset);
        }
      });
    });
  }
}
