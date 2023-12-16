import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/src/rendering/box.dart';

import 'dart:ui';

class AnimatedGradientSlider extends StatefulWidget {
  const AnimatedGradientSlider({
    super.key,
    required this.onChanged,
    required this.value,
    required this.minValue,
    required this.maxValue,
    this.axisDirection = AxisDirection.right,
    this.minLimit,
    this.maxLimit,
    required this.colors,
    this.borderColor,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 500),
    this.borderRadius,
  });

  final double value;
  final void Function(double value) onChanged;
  final double minValue;
  final double maxValue;
  final Duration duration;
  final List<Color> colors;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? minLimit;
  final double? maxLimit;
  final BorderRadius? borderRadius;
  final AxisDirection axisDirection;

  @override
  State<AnimatedGradientSlider> createState() => _AnimatedGradientSliderState();
}

class _AnimatedGradientSliderState extends State<AnimatedGradientSlider>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  double get currentValue =>
      lerpDouble(oldValue, newValue, animationController.value)!;
  double oldValue = 0;
  double newValue = 0;

  @override
  void initState() {
    super.initState();

    oldValue = widget.value;
    newValue = oldValue;
    animationController =
        AnimationController(vsync: this, duration: widget.duration)
          ..value = 1.0;
  }

  @override
  void didUpdateWidget(covariant AnimatedGradientSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (animationController.duration != widget.duration) {
      animationController.duration = widget.duration;
    }

    if (widget.value != newValue) {
      _animateMoveTo(widget.value);
    }
  }

  void _animateMoveTo(double newValue) {
    oldValue = currentValue;
    this.newValue = newValue;
    animationController.forward(from: 0.0);
  }

  void _onChanged(double value) {
    double result = value;

    if (widget.minLimit != null) {
      if (result < widget.minLimit!) {
        result = widget.minLimit!;
      }
    }

    if (widget.maxLimit != null) {
      if (result > widget.maxLimit!) {
        result = widget.maxLimit!;
      }
    }

    if (newValue == result) {
      return;
    }

    newValue = result;
    animationController.value = 1.0;
    widget.onChanged(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return GradientSlider(
            colors: widget.colors,
            value: currentValue,
            backgroundColor: widget.backgroundColor,
            borderColor: widget.borderColor,
            onValue: _onChanged,
            min: widget.minValue,
            max: widget.maxValue,
            borderRadius: widget.borderRadius,
            axisDirection: widget.axisDirection,
          );
        });
  }
}

class GradientSlider extends LeafRenderObjectWidget {
  const GradientSlider(
      {super.key,
      this.value = 50,
      this.min = 0,
      this.max = 100,
      required this.colors,
      this.backgroundColor,
      this.borderColor,
      this.axisDirection = AxisDirection.right,
      required this.onValue,
      this.borderRadius});

  final double value;
  final double min;
  final double max;
  final List<Color> colors;
  final Color? backgroundColor;
  final Color? borderColor;
  final void Function(double value) onValue;
  final AxisDirection axisDirection;
  final BorderRadius? borderRadius;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderGradientSlider(
        borderRadius: borderRadius,
        axisDirection: axisDirection,
        value: value,
        min: min,
        max: max,
        colors: colors,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        onValue: onValue);
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderGradientSlider renderObject) {
    renderObject
      ..axisDirection = axisDirection
      ..colors = colors
      ..backgroundColor = backgroundColor
      ..value = value
      ..min = min
      ..max = max
      ..onValue = onValue
      ..borderColor = borderColor;
  }
}

class _RenderGradientSlider extends RenderBox {
  _RenderGradientSlider(
      {required BorderRadius? borderRadius,
      required double value,
      required double min,
      required double max,
      required List<Color> colors,
      required Color? backgroundColor,
      required Color? borderColor,
      required AxisDirection axisDirection,
      required this.onValue})
      : _borderRadius = borderRadius,
        _axisDirection = axisDirection,
        _value = value,
        _min = min,
        _max = max,
        _colors = colors,
        _backgroundColor = backgroundColor,
        _borderColor = borderColor,
        lastValue = value;

  BorderRadius? _borderRadius;
  BorderRadius? get borderRadius => _borderRadius;
  set borderRadius(BorderRadius? value) {
    if (borderRadius == value) {
      return;
    }

    _borderRadius = value;
    markNeedsPaint();
  }

  AxisDirection _axisDirection;
  AxisDirection get axisDirection => _axisDirection;
  set axisDirection(AxisDirection value) {
    if (_axisDirection == value) {
      return;
    }

    _axisDirection = value;
    markNeedsPaint();
  }

  double _value;
  double get value => _value;
  set value(double value) {
    if (_value == value) {
      return;
    }

    lastValue = value;
    _value = value;
    markNeedsPaint();
  }

  double _min;
  double get min => _min;
  set min(double value) {
    if (_min == value) {
      return;
    }

    _min = value;
    markNeedsPaint();
  }

  double _max;
  double get max => _max;
  set max(double value) {
    if (_max == value) {
      return;
    }

    _max = value;
    markNeedsPaint();
  }

  List<Color> _colors;
  List<Color> get colors => _colors;
  set colors(List<Color> value) {
    bool identityColors() {
      if (_colors.length != value.length) {
        return false;
      }

      for (int i = 0; i < _colors.length; i++) {
        if (_colors[i] != value[i]) {
          return false;
        }
      }

      return true;
    }

    if (identityColors()) {
      return;
    }

    _colors = value;
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

  Color? _borderColor;
  Color? get borderColor => _borderColor;
  set borderColor(Color? value) {
    if (value == _borderColor) {
      return;
    }

    _borderColor = value;
    markNeedsPaint();
  }

  void Function(double value) onValue;

  double lastValue;

  List<double> generateStopsFromCount(int count) {
    List<double> list = [];

    double k = 1 / (count - 1);

    for (int i = 0; i < count - 1; i++) {
      list.add(i * k);
    }

    list.add(1.0);

    return list;
  }

  /// Функция обратная lerp, Принимает отрезок, и точку находящуюся внутри орезка. Возвращает велечину относительного нахождения точки.
  /// Например с отрезком [start = 0.1,  end = 0.5] и point = 0.1 =>  0.0; [start = 0.1,  end = 0.5] и point = 0.3 =>  0.5
  double invertedLerp(double start, double end, double point) {
    final range = end - start;
    final position = point - start;
    return position / range;
  }

  /// Функция пропорционально переносит значение (value) из текущего диапазона значений
  /// (fromLow..fromHigh) в новый диапазон (toLow..toHigh), заданный параметрами.
  double convertValueInRange(double value, double fromLow, double fromHigh,
      double toLow, double toHigh,
      [bool clip = true]) {
    assert(fromLow != fromHigh);

    double procent = invertedLerp(fromLow, fromHigh, value);
    if (clip) {
      procent = procent.clamp(0.0, 1.0);
    }
    return lerpDouble(toLow, toHigh, procent)!;
  }

  @override
  bool hitTestSelf(Offset position) {
    return size.contains(position);
  }

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));

    if (event is PointerMoveEvent || event is PointerDownEvent) {
      late final double position;
      late final double range;

      switch (axisDirection) {
        case AxisDirection.down:
          range = size.height;
          position = event.localPosition.dy;

          break;

        case AxisDirection.up:
          range = size.height;
          position = range - event.localPosition.dy;

          break;

        case AxisDirection.left:
          range = size.width;
          position = range - event.localPosition.dx;
          break;

        case AxisDirection.right:
          range = size.width;
          position = event.localPosition.dx;
          break;

        default:
          throw "Error: Unknown AxisDirection: $axisDirection";
      }

      if (range == 0) {
        return;
      }

      double result = convertValueInRange(position, 0, range, min, max);

      if (lastValue != result) {
        lastValue = result;
        onValue(lastValue);
      }
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final border = borderRadius ?? BorderRadius.zero;

    late final Offset startOffset;
    late final Offset endOffsetGradient;
    late final Offset rectPoint;

    switch (axisDirection) {
      case AxisDirection.down:
        startOffset = Offset.zero;
        endOffsetGradient = Offset(0, size.height);
        rectPoint = Offset(
            size.width, convertValueInRange(value, min, max, 0, size.height));
        break;

      case AxisDirection.up:
        startOffset = Offset(0, size.height);
        endOffsetGradient = Offset.zero;
        rectPoint = Offset(
            size.width, convertValueInRange(value, min, max, size.height, 0));
        break;

      case AxisDirection.left:
        startOffset = Offset(size.width, 0);
        endOffsetGradient = Offset.zero;
        rectPoint = Offset(
            convertValueInRange(value, min, max, size.width, 0), size.height);
        break;

      case AxisDirection.right:
        endOffsetGradient = Offset(size.width, 0);
        startOffset = Offset.zero;
        rectPoint = Offset(
            convertValueInRange(value, min, max, 0, size.width), size.height);
        break;

      default:
        throw "Error: Unknown AxisDirection: $axisDirection";
    }

    RRect rrect = RRect.fromRectAndCorners(Offset.zero & size,
        topLeft: border.topLeft,
        topRight: border.topRight,
        bottomLeft: border.bottomLeft,
        bottomRight: border.topRight);

    context.pushClipRRect(needsCompositing, offset, Offset.zero & size, rrect,
        (context, offset) {
      if (backgroundColor != null) {
        context.canvas.drawPaint(Paint()..color = backgroundColor!);
      }

      if (colors.isNotEmpty) {
        context.pushClipRect(
            needsCompositing, offset, Rect.fromPoints(startOffset, rectPoint),
            (context, offset) {
          if (colors.length == 1) {
            context.canvas.drawPaint(Paint()..color = colors[0]);
          } else {
            context.canvas.drawPaint(Paint()
              ..shader = ui.Gradient.linear(
                  offset + startOffset,
                  offset + endOffsetGradient,
                  colors,
                  generateStopsFromCount(colors.length)));
          }
        });
      }
    });

    if (borderColor != null) {
      final borderRRect = RRect.fromRectAndCorners(offset & size,
          topLeft: border.topLeft,
          topRight: border.topRight,
          bottomLeft: border.bottomLeft,
          bottomRight: border.topRight);

      context.canvas.drawRRect(
          borderRRect,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = borderColor!);
    }
  }
}
