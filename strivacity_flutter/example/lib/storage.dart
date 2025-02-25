import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

class KeychainStorage extends SDKStorage {
  final storage = FlutterSecureStorage();

  @override
  Future<void> clear() {
    return storage.deleteAll();
  }

  @override
  Future<String?> get(String key) {
    return storage.read(key: key);
  }

  @override
  Future<void> put(String key, String value) {
    return storage.write(key: key, value: value);
  }

  @override
  Future<void> remove(String key) {
    return storage.delete(key: key);
  }
}
