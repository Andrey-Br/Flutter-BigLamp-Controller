import 'dart:html';

class PlatformStorage {
  static final PlatformStorage instance = PlatformStorage._();
  PlatformStorage._() {
    _init();
  }

  void _init() {}

  Future<String?> get(String key) async {
    return window.localStorage[key];
  }

  Future<void> set(String key, String value) async {
    window.localStorage[key] = value;
  }

  Future<void> delete(String key) async {
    window.localStorage.remove(key);
  }
}
