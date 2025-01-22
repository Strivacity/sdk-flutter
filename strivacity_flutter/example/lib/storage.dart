import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

class KeychainStorage extends SDKStorage {
  @override
  Future<void> clear() {
    return FlutterKeychain.clear();
  }

  @override
  Future<String?> get(String key) {
    return FlutterKeychain.get(key: key);
  }

  @override
  Future<void> put(String key, String value) {
    return FlutterKeychain.put(key: key, value: value);
  }

  @override
  Future<void> remove(String key) {
    return FlutterKeychain.remove(key: key);
  }
}
