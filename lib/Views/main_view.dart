import 'package:big_lamp_web_controller/Controllers/main_view_controller.dart';
import 'package:big_lamp_web_controller/Views/loading_view.dart';
import 'package:big_lamp_web_controller/Widgets/changable_widget.dart';
import 'package:big_lamp_web_controller/Widgets/hexagnal_structure_widget.dart';
import 'package:big_lamp_web_controller/Widgets/highlight_cursor.dart';
import 'package:big_lamp_web_controller/Widgets/touchable_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'control_lamp_view.dart';
import 'login_view.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Provider<MainViewController>(
          create: (context) => MainViewController(), child: const MainWidget()),
    );
  }
}

class MainWidget extends StatelessWidget {
  const MainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainViewController, MainViewState>(
        buildWhen: (previous, current) =>
            previous.isLogined != current.isLogined ||
            previous.cursorColor != current.cursorColor,
        builder: (context, state) {
          return GlassyStack(
            children: [
              BlocBuilder<MainViewController, MainViewState>(
                  buildWhen: (previous, current) =>
                      previous.cursorColor != current.cursorColor,
                  builder: (context, state) {
                    return HighlightCursor(
                      color: state.cursorColor,
                      radius: 100,
                      backgroundColor: Colors.black,
                      repaintBoundary: true,
                    );
                  }),
              StructureHexagonalWidget(
                diameter: 50,
                padding: 10,
                // child: Center(child: FlutterLogo()),
                color: Colors.grey[900],
                repaintBoundary: true,
              ),
              Center(
                  child: FittedBox(
                child: Container(
                    // surfaceTintColor: Colors.white,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: state.darkColor.withAlpha(200),
                        border: Border.all(color: state.lightColor)),
                    child: ChangableWidget(
                      child: state.isLogined == null
                          ? const LoadingView()
                          : state.isLogined!
                              ? const ControlLampView()
                              : const LoginView(),
                    )),
              )),
            ],
          );
        });
  }
}
