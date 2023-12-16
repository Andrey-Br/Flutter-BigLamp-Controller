import 'dart:math';

import 'package:big_lamp_web_controller/Controllers/firebase_database_controller.dart';
import 'package:big_lamp_web_controller/Data/user.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminViewState {
  final User? editUser;
  final List<User> users;

  const AdminViewState({this.editUser, this.users = const []});

  AdminViewState copyWith({User? editUser, List<User>? users}) =>
      AdminViewState(
          editUser: editUser ?? this.editUser, users: users ?? this.users);

  AdminViewState disableEdit({List<User>? users}) =>
      AdminViewState(editUser: null, users: users ?? this.users);
}

class AdminViewController extends Cubit<AdminViewState> {
  AdminViewController([super.initialState = const AdminViewState()]) {
    updateUserList();
  }

  TextEditingController keyEditingController = TextEditingController();
  TextEditingController infoEditingController = TextEditingController();

  List<User> get users => state.users;
  User? get editUser => state.editUser;

  final FirebaseController _firebase = FirebaseController.instance;

  void updateUserList() {
    _firebase.adminGetAllUsers().then((value) {
      emit(state.disableEdit(users: value));
    });
  }

  void deleteUser(User user) {
    _firebase.adminDeleteUser(user).then((_) => updateUserList());
  }

  void setUser(User user) {
    _firebase.adminSetUser(user).then((_) => updateUserList());
  }

  String generateRandomKey([int chars = 10]) {
    final rand = Random();
    String result = '';

    while (result.length < chars) {
      bool upper = rand.nextInt(2) == 1;
      String add = rand.nextInt(36).toRadixString(36);
      if (upper) {
        add = add.toUpperCase();
      }

      result += add;
    }

    return result;
  }

  void editUserGenerateKey() {
    if (editUser == null) {
      return;
    }

    emit(
        state.copyWith(editUser: editUser!.copyWith(key: generateRandomKey())));

    keyEditingController.text = editUser!.key;
  }

  void createNewUser() {
    emit(
        state.copyWith(editUser: User(info: 'info', key: generateRandomKey())));

    selectEditUser(editUser!);
  }

  void selectEditUser(User user) {
    emit(state.copyWith(editUser: user));

    keyEditingController.text = user.key;
    infoEditingController.text = user.info;
  }

  void changeEdit(User Function(User user) edit) {
    User user =
        edit(state.editUser ?? User(info: 'info', key: generateRandomKey()));
    emit(state.copyWith(editUser: user));
  }

  void sendEditUserToServer() {
    if (editUser == null) {
      return;
    }

    if (editUser!.info.isEmpty || editUser!.key.isEmpty) {
      return;
    }

    _firebase.adminSetUser(editUser!).then((value) => updateUserList());
  }
}
