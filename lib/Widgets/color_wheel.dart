import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class _PainterCursor extends CustomPainter {
  final Offset cursorDirection;
  final double cursorProcent;
  final Color color;

  const _PainterCursor(
      {required this.cursorDirection,
      required this.cursorProcent,
      required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final cursorLocalPosition = (cursorDirection * radius) + center;

    canvas.drawCircle(
        cursorLocalPosition,
        radius * cursorProcent,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0);

    canvas.drawCircle(
        cursorLocalPosition, radius * cursorProcent, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PainterCursor oldDelegate) {
    return true;
  }
}

class _PainterCircle extends CustomPainter {
  const _PainterCircle(
      {required this.whiteProcent, required this.cursorProcent});

  static const List<Color> _circleColors = [
    Color(0xFFFF0000),
    Color(0xFFFFFF00),
    Color(0xFF00FF00),
    Color(0xFF00FFFF),
    Color(0xFF0000FF),
    Color(0xFFFF00FF),
    Color(0xFFFF0000),
  ];
  static const List<double> _circleStops = [
    0.0,
    1 / 6,
    2 / 6,
    3 / 6,
    4 / 6,
    5 / 6,
    1.0,
  ];
  static const List<Color> _circleWhite = [
    Color(0xFFffffff),
    Color(0xFFffffff),
    Color(0x00ffffff),
  ];

  final double whiteProcent;
  final double cursorProcent;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final whiteRadius = radius * (1 - cursorProcent);

    final rainbowShader =
        ui.Gradient.sweep(center, _circleColors, _circleStops);
    final whiteShader = ui.Gradient.radial(
        center, whiteRadius, _circleWhite, [0.0, whiteProcent, 1.0]);

    canvas.drawCircle(center, radius, Paint()..shader = rainbowShader);
    canvas.drawCircle(center, whiteRadius, Paint()..shader = whiteShader);
  }

  @override
  bool shouldRepaint(_PainterCircle oldDelegate) {
    return oldDelegate.whiteProcent != whiteProcent ||
        oldDelegate.cursorProcent != cursorProcent;
  }
}

class SelectColorWheel extends StatefulWidget {
  const SelectColorWheel(
      {super.key,
      this.color = Colors.white,
      this.size,
      required this.onChangeColor,
      this.cursorProcent = 0.2,
      this.whiteProcent = 0.2,
      this.stickWhite = true,
      this.duration = const Duration(milliseconds: 500),
      this.animateWhen});

  final Color color;
  final double? size;
  final void Function(Color color) onChangeColor;
  final double cursorProcent;
  final double whiteProcent;
  final bool stickWhite;
  final Duration duration;
  final bool Function(Color currentColor)? animateWhen;

  @override
  State<SelectColorWheel> createState() => _SelectColorWheelState();
}

class _SelectColorWheelState extends State<SelectColorWheel>
    with TickerProviderStateMixin {
  late final AnimationController animationController;

  late Offset oldCursorDirection;
  late Offset newCursorDirection;

  Offset get cursorDirection => Offset.lerp(
      oldCursorDirection, newCursorDirection, animationController.value)!;
  late Color lastColor;

  Color get color => colorFromOffsetDirection(cursorDirection);

  double get maxCursorDistance => (1 - widget.cursorProcent);

  Offset offsetDirectionFromColor(Color color) {
    HSVColor col = HSVColor.fromColor(color).withValue(1);

    if (col.saturation == 0) {
      return Offset.zero;
    }

    final direction = (col.hue / 180) * pi;
    double distance =
        ui.lerpDouble(widget.whiteProcent, maxCursorDistance, col.saturation)!;

    return Offset.fromDirection(direction, distance);
  }

  Color colorFromOffsetDirection(Offset directionOffet) {
    if (directionOffet.distance < widget.whiteProcent) {
      return Colors.white;
    }

    final direction = directionOffet.direction > 0
        ? directionOffet.direction
        : directionOffet.direction + (2 * pi);

    final hue = direction / pi * 180;

    double saturation = invertedLerp(
        widget.whiteProcent, maxCursorDistance, directionOffet.distance);

    if (saturation < 0) {
      saturation = 0;
    }

    if (saturation > 1.0) {
      saturation = 1.0;
    }

    return HSVColor.fromAHSV(1.0, hue, saturation, 1.0).toColor();
  }

  /// Функция обратная lerp, Принимает отрезок, и точку находящуюся внутри орезка. Возвращает велечину относительного нахождения точки.
  /// Например с отрезком [start = 0.1,  end = 0.5] и point = 0.1 =>  0.0; [start = 0.1,  end = 0.5] и point = 0.3 =>  0.5
  double invertedLerp(double start, double end, double point) {
    final range = end - start;
    final position = point - start;
    return position / range;
  }

  void updateStateFromDirectionOffset(Offset directionOffet) {
    final distance = min(directionOffet.distance, maxCursorDistance);
    newCursorDirection =
        Offset.fromDirection(directionOffet.direction, distance);

    if (widget.stickWhite && color == Colors.white) {
      newCursorDirection = Offset.zero;
    }

    animationController.value = 1.0;

    if (lastColor == color) {
      return;
    }

    lastColor = color;
    widget.onChangeColor(lastColor);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: widget.duration);
    animationController.value = 1.0;
    lastColor = widget.color;
    newCursorDirection = offsetDirectionFromColor(lastColor);
    oldCursorDirection = newCursorDirection;
  }

  void startAnimateToColor(Color color) {
    oldCursorDirection = cursorDirection;
    newCursorDirection = offsetDirectionFromColor(color);
    animationController.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(covariant SelectColorWheel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animateWhen != null && widget.animateWhen!(lastColor)) {
      startAnimateToColor(widget.color);
    }

    animationController.duration = widget.duration;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = AnimatedBuilder(
        animation: animationController,
        builder: (context, animation) => LayoutBuilder(
              builder: (context, constraints) {
                Size size = constraints.biggest;
                double radius = size.shortestSide / 2;
                Offset center = Offset(size.width / 2, size.height / 2);

                return Listener(
                  child: Stack(children: [
                    RepaintBoundary(
                      child: CustomPaint(
                          size: size,
                          painter: _PainterCircle(
                              whiteProcent: widget.whiteProcent,
                              cursorProcent: widget.cursorProcent)),
                    ),
                    CustomPaint(
                        size: size,
                        painter: _PainterCursor(
                            cursorDirection: cursorDirection,
                            cursorProcent: widget.cursorProcent,
                            color: color)),
                  ]),
                  onPointerDown: (event) {
                    final localOffset = event.localPosition - center;
                    updateStateFromDirectionOffset(Offset.fromDirection(
                        localOffset.direction, localOffset.distance / radius));
                  },
                  onPointerMove: (event) {
                    final localOffset = event.localPosition - center;
                    updateStateFromDirectionOffset(Offset.fromDirection(
                        localOffset.direction, localOffset.distance / radius));
                  },
                );
              },
            ));

    child = SizedBox.square(
        dimension: widget.size ?? double.infinity, child: child);

    return child;
  }
}
