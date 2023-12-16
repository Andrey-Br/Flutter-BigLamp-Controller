library changeble_widget;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ChangableWidgetController {
  _ChangableWidgetState? _state;

  void setWidget(Widget? newWidget) {
    assert(_state != null);
    _state!.startAnimation(newWidget);
  }

  void closeWidget() {
    assert(_state != null);
    _state!.startAnimation(null);
  }

  void setDuration(Duration duration) {
    assert(_state != null);
    _state!.animationController.duration = duration;
  }
}

class ChangableWidget extends StatefulWidget {
  const ChangableWidget({this.child, this.controller, super.key});

  final Widget? child;

  final ChangableWidgetController? controller;

  @override
  State<ChangableWidget> createState() => _ChangableWidgetState();
}

class _ChangableWidgetState extends State<ChangableWidget>
    with TickerProviderStateMixin {
  late final animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));

  Widget? currentWidget;
  Widget? oldWidget;

  @override
  void didUpdateWidget(ChangableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.child == currentWidget) {
      return;
    } else {
      startAnimation(widget.child);
    }
  }

  void startAnimation(Widget? newWidget) {
    oldWidget = currentWidget;
    currentWidget = newWidget;

    animationController.forward(from: 0.0);
  }

  @override
  void initState() {
    super.initState();
    currentWidget = widget.child;
    animationController.value = 1.0;

    if (widget.controller != null) {
      widget.controller!._state = this;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          if (animationController.value == 1.0) {
            return currentWidget ?? const SizedBox.shrink();
          }

          return ChangableWidgetMultiRender(
            animation: animationController.value,
            startChild: oldWidget ?? const SizedBox.shrink(),
            finalChild: currentWidget ?? const SizedBox.shrink(),
          );
        });
  }
}

class ChangableWidgetMultiRender extends MultiChildRenderObjectWidget {
  ChangableWidgetMultiRender(
      {Key? key,
      required this.startChild,
      required this.finalChild,
      required this.animation})
      : super(key: key, children: [startChild, finalChild]);

  final Widget startChild;
  final Widget finalChild;
  final double animation;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderChangableWidget(animation);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderChangableWidget renderObject) {
    renderObject.animation = animation;
  }
}

class ChangableWidgetParentData extends ContainerBoxParentData<RenderBox> {
  double scale = 1;
}

class RenderChangableWidget extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ChangableWidgetParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ChangableWidgetParentData> {
  RenderChangableWidget(this._animation);

  double _animation;

  Size startChildSize = const Size(0, 0);
  Size finalChildSize = const Size(0, 0);

  set animation(double value) {
    if (_animation == value) {
      return;
    }

    _animation = value;
    markParentNeedsLayout();
    markNeedsPaint();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! ChangableWidgetParentData) {
      child.parentData = ChangableWidgetParentData();
    }
  }

  Size _performLayout(BoxConstraints constraints, {required bool isDry}) {
    RenderBox startChild = firstChild!;
    final startChildParentData =
        startChild.parentData as ChangableWidgetParentData;

    assert(startChildParentData.nextSibling != null);

    RenderBox finalChild = startChildParentData.nextSibling!;

    if (isDry) {
      final sizeStart = startChild.computeDryLayout(constraints);
      final sizeFinal = finalChild.computeDryLayout(constraints);

      return Size.lerp(sizeStart, sizeFinal, _animation)!;
    } else {
      startChild.layout(constraints, parentUsesSize: true);
      finalChild.layout(constraints, parentUsesSize: true);

      startChildSize = startChild.size;
      finalChildSize = finalChild.size;

      return Size.lerp(startChildSize, finalChildSize, _animation)!;
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _performLayout(constraints, isDry: true);

  @override
  void performLayout() {
    assert(firstChild != null);

    RenderBox startChild = firstChild!;
    final startChildParentData =
        startChild.parentData as ChangableWidgetParentData;

    assert(startChildParentData.nextSibling != null);

    RenderBox finalChild = startChildParentData.nextSibling!;
    final finalChildParentData =
        finalChild.parentData as ChangableWidgetParentData;

    size = _performLayout(constraints, isDry: false);

    startChildParentData.scale = _calculateKoefScale(startChildSize, size);

    startChildParentData.offset = _calculateLocalPosition(
        startChildSize * startChildParentData.scale, size);

    finalChildParentData.scale = _calculateKoefScale(finalChildSize, size);

    finalChildParentData.offset = _calculateLocalPosition(
        finalChildSize * finalChildParentData.scale, size);
  }

  /// Функция просчитывает насколько должен масштабироваться виджет, по сравнению с внешним контейнером
  double _calculateKoefScale(Size widgetSize, Size containerSize) {
    if (widgetSize.shortestSide == 0) {
      return 0;
    }

    final double kWidth = containerSize.width / widgetSize.width;
    final double kHeight = containerSize.height / widgetSize.height;
    return kWidth <= kHeight ? kWidth : kHeight;
  }

  /// Высчитывает начальное положение виджета, чтобы он отображался по центру
  Offset _calculateLocalPosition(Size widgetSize, Size containerSize) {
    final double startWidth = (containerSize.width - widgetSize.width) / 2;
    final double startHeight = (containerSize.height - widgetSize.height) / 2;

    return Offset(startWidth, startHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(firstChild != null);

    RenderBox startChild = firstChild!;
    final startChildParentData =
        startChild.parentData as ChangableWidgetParentData;

    assert(startChildParentData.nextSibling != null);

    RenderBox finalChild = startChildParentData.nextSibling!;
    final finalChildParentData =
        finalChild.parentData as ChangableWidgetParentData;

    // context.paintChild(startChild, offset);

    // context.pushTransform(
    //     needsCompositing,
    //     offset,
    //     Matrix4.identity()
    //       ..scale(finalChildParentData.scale, finalChildParentData.scale),
    //     (context, offset) {
    //   context.pushOpacity(offset, (_animation * 255).toInt(),
    //       (context, offset) {
    //     context.paintChild(finalChild, offset - finalChildParentData.offset);
    //   });
    // });

    context.pushClipRect(needsCompositing, offset, Offset.zero & size,
        (context, offset) {
      context.pushOpacity(offset, ((1 - _animation) * 255).toInt(),
          (context, offset) {
        context.pushTransform(
            needsCompositing,
            offset + startChildParentData.offset,
            Matrix4.identity()
              ..scale(startChildParentData.scale, startChildParentData.scale),
            (context, offset) {
          context.paintChild(startChild, offset);
        });
      });

      context.pushOpacity(offset, ((_animation) * 255).toInt(),
          (context, offset) {
        context.pushTransform(
            needsCompositing,
            offset + finalChildParentData.offset,
            Matrix4.identity()
              ..scale(finalChildParentData.scale, finalChildParentData.scale),
            (context, offset) {
          context.paintChild(finalChild, offset);
        });
      });
    });
  }
}
