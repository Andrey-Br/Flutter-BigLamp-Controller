class User {
  const User(
      {this.key = "",
      this.info = "",
      this.isAdmin = false,
      this.isSendEnable = true});

  final String key;
  final String info;
  final bool isAdmin;
  final bool isSendEnable;

  User copyWith({
    String? key,
    String? info,
    bool? isAdmin,
    bool? isSendEnable,
  }) =>
      User(
          info: info ?? this.info,
          key: key ?? this.key,
          isAdmin: isAdmin ?? this.isAdmin,
          isSendEnable: isSendEnable ?? this.isSendEnable);

  factory User.fromJson(String code, dynamic json) {
    if (json == null) {
      throw "JSON is null";
    }

    if (json is Map<String, dynamic>) {
      final map = json as Map<String, dynamic>;
      late String info;
      late bool isAdmin;
      late bool isSendEnable;

      if (!map.containsKey('info')) {
        info = "Unknown";
      } else {
        info = map['info']! as String;
      }

      if (map.containsKey('isAdmin')) {
        isAdmin = (map['isAdmin'] as int) == 1;
      } else {
        isAdmin = false;
      }

      if (map.containsKey('isSendEnable')) {
        isSendEnable = (map['isSendEnable'] as int) == 1;
      } else {
        isSendEnable = true;
      }

      return User(
          key: code, info: info, isAdmin: isAdmin, isSendEnable: isSendEnable);
    } else if (json is String) {
      return User(key: code, info: json, isAdmin: false, isSendEnable: true);
    } else {
      throw "JSON unknown";
    }
  }

  dynamic toJson() {
    return {
      'info': info,
      'isAdmin': isAdmin ? 1 : 0,
      'isSendEnable': isSendEnable ? 1 : 0
    };
  }
}
