import 'dart:async';

import 'package:big_lamp_web_controller/Data/lamp_state.dart';
import 'package:big_lamp_web_controller/Data/user.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FirebaseController {
  static final FirebaseController _instance = FirebaseController._();
  static FirebaseController get instance => _instance;

  AnimationController? animationController;

  final _lampRef = FirebaseDatabase.instance.ref("biglamp");
  final _usersRef = FirebaseDatabase.instance.ref("users");

  User? user;

  LampState currentLampState = const LampState();
  LampState serverLampState = const LampState();

  void Function(String key, User? user)? onChangeUsers;
  void Function(String key, LampState lampState)? onChangeLampState;

  Future<LampState> getLampStateFromServer() async {
    final ref = _lampRef.child('set');
    final event = await ref.once();

    serverLampState = LampState.fromJson(event.snapshot.value);
    currentLampState = serverLampState;

    return serverLampState;
  }

  Future<List<User>> adminGetAllUsers() async {
    if (this.user?.isAdmin != true) {
      return [];
    }

    final answer = await _usersRef.once();
    final json = answer.snapshot.value;
    if (json is! Map<String, dynamic>) {
      throw 'users admin is not Map<String, dynamic>';
    }

    final map = json as Map<String, dynamic>;

    List<User> users = [];

    map.forEach((key, value) {
      users.add(User.fromJson(key, value));
    });

    return users;
  }

  Future<void> adminSetUser(User user) async {
    if (this.user?.isAdmin != true) {
      return;
    }
    return _usersRef.child(user.key).set(user.toJson());
  }

  Future<void> adminDeleteUser(User user) async {
    if (this.user?.isAdmin != true) {
      return;
    }
    return _usersRef.child(user.key).remove();
  }

  /// Поиск пользователя по ключу. Если неудачно - null, Если удачно - User
  Future<User?> searchUserFromKey(String key) async {
    try {
      if (key == "") {
        return null;
      }
      var newRef = _usersRef.child(key);
      var event = await newRef.once();
      Object? value = event.snapshot.value;

      if (value == null) {
        return null;
      }

      return User.fromJson(key, value);
    } catch (error) {
      print('keysearch error: key $key ; error:  $error');
      return null;
    }
  }

  void setLampState(LampState newState) {
    currentLampState = newState;
  }

  void _lampMessage(String topic, dynamic data) {
    if (user == null) {
      return;
    }

    var ref = _lampRef.child(topic);
    ref.set(data);
  }

  void _updateLampStateToServer(LampState lampState) {
    if (user == null || user?.isSendEnable != true) {
      return;
    }

    final map = lampState.toJson();
    map['user'] = user!.key;
    _lampMessage('set', map);
    serverLampState = lampState;
  }

  void _updateLampStateCallback(dynamic json) {
    if (json == null) {
      return;
    }

    final map = json as Map<String, dynamic>;
    String from = map['user'] ?? "";

    final reciveLampState = LampState.fromJson(json);

    serverLampState = reciveLampState;

    if (from != user?.key) {
      currentLampState = serverLampState;
    }

    if (onChangeLampState != null) {
      onChangeLampState!(from, serverLampState);
    }
  }

  void _updateUsersCallback(String? key, dynamic json) {
    if (key == null) {
      return;
    }

    late User? user;

    if (json == null) {
      user = null;
    } else {
      user = User.fromJson(key, json);
    }

    if (onChangeUsers != null) {
      onChangeUsers!(key, user);
    }

    if (this.user != null && this.user?.key == key) {
      this.user = user;
    }
  }

  Future<void> _startInfinityLoop() {
    return Future.doWhile(() async {
      if (currentLampState != serverLampState) {
        _updateLampStateToServer(currentLampState);
      }

      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    });
  }

  void _init() async {
    getLampStateFromServer();

    _lampRef.child('set').onValue.listen((event) {
      _updateLampStateCallback(event.snapshot.value);
    });

    _lampRef.child('get').onValue.listen((event) {
      _updateLampStateCallback(event.snapshot.value);
    });

    _usersRef.onChildRemoved.asBroadcastStream().listen((event) {
      final key = event.snapshot.key;
      _updateUsersCallback(key, null);
    });

    _usersRef.onChildChanged.asBroadcastStream().listen((event) {
      final key = event.snapshot.key;
      final date = event.snapshot.value;
      _updateUsersCallback(key, date);
    });
  }

  FirebaseController._() {
    _init();
    _startInfinityLoop();
  }
}
