import 'package:big_lamp_web_controller/Controllers/main_view_controller.dart';
import 'package:big_lamp_web_controller/Views/admin_view.dart';
import 'package:big_lamp_web_controller/Widgets/clip_and_highligh_widget.dart';
import 'package:big_lamp_web_controller/Widgets/gradient_slider.dart';
import 'package:big_lamp_web_controller/Widgets/color_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ControlLampView extends StatelessWidget {
  const ControlLampView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainViewController>();
    return BlocBuilder<MainViewController, MainViewState>(
        bloc: bloc,
        buildWhen: (previous, current) =>
            current.lampState != previous.lampState ||
            previous.user != current.user,
        builder: (context, state) {
          return Container(
            width: 600,
            height: 500,
            padding: const EdgeInsets.all(10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Lamp Controller",
                      style: TextStyle(fontSize: 40, color: state.lightColor),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.user?.info ?? "Unknown user",
                              style: TextStyle(
                                  fontSize: 15, color: state.lightColor),
                            ),
                            if (state.user?.isSendEnable == false)
                              Text(
                                "[Только просмотр]",
                                style: TextStyle(
                                    fontSize: 15, color: state.lightColor),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (state.user?.isAdmin == true)
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminView(),
                                ));
                          },
                          icon: Icon(
                            Icons.assignment_ind_outlined,
                            size: 20,
                            color: state.lightColor,
                          )),
                    IconButton(
                        onPressed: () {
                          bloc.logout();
                        },
                        icon: Icon(
                          Icons.logout,
                          size: 20,
                          color: state.lightColor,
                        )),
                  ]),
              const SizedBox(height: 30),
              Flexible(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const BrightAndPowerWidget(
                          axis: Axis.vertical, size: Size(100, 400)),
                      SizedBox(
                        width: 400,
                        height: 400,
                        child: SelectColorWheel(
                          cursorProcent: 0.15,
                          whiteProcent: 0.1,
                          color: state.lampState.color,
                          animateWhen: (color) =>
                              color != state.lampState.color,
                          onChangeColor: (color) => bloc.setColor(color),
                        ),
                      ),
                    ]),
              ),
            ]),
          );
        });
  }
}

class BrightAndPowerWidget extends StatelessWidget {
  const BrightAndPowerWidget({
    required this.axis,
    super.key,
    required this.size,
  });

  final Axis axis;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainViewController>();
    return BlocBuilder<MainViewController, MainViewState>(
        bloc: bloc,
        buildWhen: (previous, current) =>
            previous.lampState != current.lampState,
        builder: (context, state) {
          Widget button = GestureDetector(
              onTap: () {
                bloc.setPower(!state.lampState.power);
              },
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: state.lampState.power
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Container(
                  color: state.cursorColor,
                  height: size.shortestSide,
                  width: size.shortestSide,
                  child: Icon(
                    Icons.light_mode_outlined,
                    size: size.shortestSide,
                    color: state.darkColor,
                  ),
                ),
                secondChild: SizedBox(
                  height: size.shortestSide,
                  width: size.shortestSide,
                  child: Icon(
                    Icons.light_mode_outlined,
                    size: size.shortestSide,
                    color: Colors.grey,
                  ),
                ),
              ));

          Widget slider = Expanded(
            child: AnimatedGradientSlider(
                value: state.lampState.bright.toDouble(),
                axisDirection: axis == Axis.horizontal
                    ? AxisDirection.right
                    : AxisDirection.up,
                minLimit: 5,
                minValue: 0,
                maxValue: 100,
                borderColor: state.lightColor,

                // backgroundColor: state.darkColor,
                colors: [
                  Colors.grey.withAlpha(100),
                  state.lampState.color,
                ],
                onChanged: (value) {
                  bloc.setBright(value.toInt());
                }),
          );

          Widget child = axis == Axis.horizontal
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [slider, button],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min, children: [button, slider]);

          return ClipRRectAndHighlight(
            child: child,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            color: state.lightColor,
            width: size.width,
            height: size.height,
            borderWidth: 1.0,
          );
        });
  }
}
