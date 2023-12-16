import 'dart:math';

import 'package:big_lamp_web_controller/Controllers/firebase_database_controller.dart';
import 'package:big_lamp_web_controller/Controllers/universal_platform_storage/universal_platform_storage.dart';
import 'package:big_lamp_web_controller/Data/lamp_state.dart';
import 'package:big_lamp_web_controller/Data/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainViewState {
  final bool? isLogined;
  final User? user;
  final LampState lampState;

  MainViewState(
      {this.isLogined,
      this.user = const User(),
      this.lampState = const LampState()});

  Color get cursorColor {
    if (isLogined == null || isLogined == false || lampState.power == false) {
      return Colors.grey[800]!;
    } else {
      return Color.lerp(
          Colors.grey, lampState.color, 0.2 + (lampState.bright / 150))!;
    }
  }

  Color get lightColor => Color.lerp(Colors.white, cursorColor, 0.2)!;

  Color get darkColor => Color.lerp(Colors.black, cursorColor, 0.1)!;

  MainViewState copyWith({
    bool? isLogined,
    User? user,
    LampState? lampState,
  }) =>
      MainViewState(
        isLogined: isLogined ?? this.isLogined,
        user: user ?? this.user,
        lampState: lampState ?? this.lampState,
      );
}

class MainViewController extends Cubit<MainViewState> {
  MainViewController() : super(MainViewState()) {
    _init();
  }

  final _storage = UniversalStorage.instance;
  final _firebase = FirebaseController.instance;

  Future<bool> checkKey(String key) async {
    /// Проверяем в базе данных
    User? user = await _firebase.searchUserFromKey(key);

    /// Если не нашли
    if (user == null) {
      emit(state.copyWith(isLogined: false));
      return false;
    } else {
      _storage.set('key', key);
      final lampState = await _firebase.getLampStateFromServer();
      _firebase.user = user;
      emit(state.copyWith(isLogined: true, user: user, lampState: lampState));
      return true;
    }
  }

  LampState generateRandomLampState() {
    Random rand = Random();

    final color = Color.fromARGB(
        1, rand.nextInt(255), rand.nextInt(255), rand.nextInt(255));

    final bright = rand.nextInt(100);

    final power = rand.nextBool();

    return LampState(power: power, bright: bright, color: color);
  }

  /// Только для тестов
  void startAutoGenerateState() async {
    for (;;) {
      await Future.delayed(Duration(seconds: 1));

      final newLampState = generateRandomLampState();
      emit(state.copyWith(lampState: newLampState));

      _firebase.setLampState(newLampState);
    }
  }

  void setBright(int value) {
    if (!_changeEnable) {
      return;
    }

    late final int v;

    if (value < 5) {
      v = 5;
    } else {
      if (value > 100) {
        v = 100;
      } else {
        v = value;
      }
    }

    if (state.lampState.bright == v) {
      return;
    }

    final newState = state.copyWith(
      lampState: state.lampState.copyWith(bright: v),
    );

    emit(newState);
    _firebase.setLampState(state.lampState);
  }

  void setPower(bool value) {
    if (!_changeEnable) {
      return;
    }

    final newState =
        state.copyWith(lampState: state.lampState.copyWith(power: value));
    emit(newState);
    _firebase.setLampState(state.lampState);
  }

  void setColor(Color value) {
    if (!_changeEnable) {
      return;
    }

    final newState =
        state.copyWith(lampState: state.lampState.copyWith(color: value));
    emit(newState);
    _firebase.setLampState(state.lampState);
  }

  void logout() {
    if (state.user != null) {
      _storage.delete('key');
    }
    emit(state.copyWith(isLogined: false, user: null));
    _firebase.user = null;
  }

  void _severChangeUserCallback(String key, User? user) {
    if (state.user == null) {
      return;
    }

    if (key != state.user!.key) {
      return;
    }

    if (user == null) {
      emit(state.copyWith(isLogined: false, user: null));
    } else {
      emit(state.copyWith(user: user));
    }
  }

  void _serverChangeLampState(String key, LampState lampState) {
    if (state.user == null || state.isLogined == false) {
      return;
    }

    if (key != state.user!.key && state.lampState != lampState) {
      emit(state.copyWith(lampState: lampState));
    }
  }

  bool get _changeEnable => state.isLogined ?? false;

  void _init() async {
    _firebase.onChangeUsers = _severChangeUserCallback;
    _firebase.onChangeLampState = _serverChangeLampState;

    /// Ищем созраненный ключ
    String? key = await _storage.get('key');

    /// Если не нашли
    if (key == null) {
      emit(state.copyWith(isLogined: false));
    } else {
      final isConnect = await checkKey(key);
      if (isConnect == false) {
        _storage.delete(key);
      }
    }

    startAutoGenerateState();
  }
}
