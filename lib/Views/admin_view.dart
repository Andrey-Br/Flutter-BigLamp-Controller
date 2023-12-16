import 'package:big_lamp_web_controller/Controllers/admin_view_controller.dart';
import 'package:big_lamp_web_controller/Data/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
          child: Provider<AdminViewController>(
        create: (context) => AdminViewController(),
        child: const Center(child: AdminWidget()),
      )),
    );
  }
}

class AdminWidget extends StatelessWidget {
  const AdminWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminViewController>();

    return BlocBuilder<AdminViewController, AdminViewState>(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(10),
            width: 600,
            height: double.infinity,
            child: Column(children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new)),
                  const Text("Admin Controll"),
                  const Expanded(child: SizedBox.shrink()),
                  IconButton(
                      onPressed: () {
                        bloc.updateUserList();
                      },
                      icon: const Icon(Icons.refresh)),
                  IconButton(
                      onPressed: () {
                        bloc.createNewUser();
                      },
                      icon: const Icon(Icons.add)),
                ],
              ),
              Expanded(
                child: ListView(
                  children: state.users
                      .map<Widget>((user) => UserInfo(user))
                      .toList(),
                ),
              ),
              if (state.editUser != null) const EditUser(),
            ]),
          );
        });
  }
}

class EditUser extends StatelessWidget {
  const EditUser({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminViewController>();
    return BlocBuilder<AdminViewController, AdminViewState>(
        bloc: bloc,
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            width: double.infinity,
            height: 100,
            child: Row(children: [
              /// Сгенерировать ключ
              IconButton(
                  onPressed: () {
                    bloc.editUserGenerateKey();
                  },
                  icon: const Icon(Icons.generating_tokens)),

              /// Ввод своего ключа
              Expanded(
                flex: 1,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "key",
                    border: OutlineInputBorder(),
                  ),
                  controller: bloc.keyEditingController,
                  onChanged: (value) {
                    bloc.changeEdit((user) => user.copyWith(key: value));
                  },
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              /// Ввод информации
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "info",
                    border: OutlineInputBorder(),
                  ),
                  controller: bloc.infoEditingController,
                  onChanged: (value) =>
                      bloc.changeEdit((user) => user.copyWith(info: value)),
                ),
              ),

              /// Включить/Выключить админ мод
              IconButton(
                onPressed: () => bloc.changeEdit(
                    (user) => user.copyWith(isAdmin: !user.isAdmin)),
                icon: Icon(
                  Icons.assignment_ind_outlined,
                  size: 30,
                  color: bloc.editUser?.isAdmin == true
                      ? Colors.blue
                      : Colors.grey,
                ),
              ),

              /// Включить/Выключить режим превью
              IconButton(
                onPressed: () => bloc.changeEdit(
                    (user) => user.copyWith(isSendEnable: !user.isSendEnable)),
                icon: Icon(
                  Icons.voice_over_off_outlined,
                  size: 30,
                  color: bloc.editUser?.isSendEnable == false
                      ? Colors.red
                      : Colors.grey,
                ),
              ),

              /// Отправить на сервер
              IconButton(
                onPressed: () => bloc.sendEditUserToServer(),
                icon: const Icon(
                  Icons.send_rounded,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
            ]),
          );
        });
  }
}

class UserInfo extends StatelessWidget {
  const UserInfo(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminViewController>();
    final bool isSelected = bloc.editUser?.key == user.key;

    return GestureDetector(
      onTap: () => bloc.selectEditUser(user),
      child: Card(
        color: isSelected ? Colors.grey[800] : null,
        child: Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          height: 50,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (user.isAdmin)
              const Icon(
                Icons.assignment_ind_outlined,
                size: 30,
                color: Colors.blue,
              ),
            if (user.isSendEnable == false)
              const Icon(
                Icons.voice_over_off_outlined,
                size: 30,
                color: Colors.red,
              ),
            const SizedBox(
              width: 5,
            ),
            Text(user.info),
            const Expanded(child: SizedBox.shrink()),
            IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: user.key));
                },
                icon: const Icon(
                  Icons.copy,
                )),
            const SizedBox(
              width: 5,
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () {
                bloc.deleteUser(user);
              },
              icon: const Icon(
                Icons.delete_forever,
                color: Colors.red,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
