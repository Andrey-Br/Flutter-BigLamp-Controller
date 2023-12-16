import 'package:big_lamp_web_controller/Controllers/main_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MainViewController>();
    return Container(
      padding: const EdgeInsets.all(20),
      width: 300,
      height: 150,
      child: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Введите код",
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox.square(dimension: 10),
          TextField(
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30),
            onChanged: (str) async {
              bloc.checkKey(str);
            },
          ),
        ],
      )),
    );
  }
}
