import 'package:shared_preferences/shared_preferences.dart';

class PlatformStorage {
  static final PlatformStorage instance = PlatformStorage._();
  PlatformStorage._();

  Future<SharedPreferences> sharedPreferences = SharedPreferences.getInstance();

  void init() {}

  Future<String?> get(String key) async {
    return (await sharedPreferences).getString(key);
  }

  Future<void> set(String key, String value) async {
    (await sharedPreferences).setString(key, value);
  }

  Future<void> delete(String key) async {
    (await sharedPreferences).remove(key);
  }
}
