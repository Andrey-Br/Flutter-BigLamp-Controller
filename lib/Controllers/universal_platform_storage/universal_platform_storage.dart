import 'web_platform_storage.dart' // Stub implementation
    if (dart.library.io) 'non_web_platform_storage.dart'; // dart:io implementation

class UniversalStorage {
  static final UniversalStorage instance = UniversalStorage._();

  UniversalStorage._();

  Future<String?> get(String key) async {
    return PlatformStorage.instance.get(key);
  }

  Future<void> set(String key, String value) async {
    PlatformStorage.instance.set(key, value);
  }

  Future<void> delete(String key) async {
    PlatformStorage.instance.delete(key);
  }
}
