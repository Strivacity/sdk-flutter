import 'package:strivacity_flutter_platform_interface/strivacity_flutter_platform_interface.dart';

class MockSDKStorage extends SDKStorage {
  @override
  Future<void> clear() {
    return Future.value();
  }

  @override
  Future<String?> get(String key) {
    return Future.value(null);
  }

  @override
  Future<void> put(String key, String value) {
    return Future.value();
  }

  @override
  Future<void> remove(String key) {
    return Future.value();
  }
}
