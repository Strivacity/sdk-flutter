
import 'strivacity_flutter_android_platform_interface.dart';

class StrivacityFlutterAndroid {
  Future<String?> getPlatformVersion() {
    return StrivacityFlutterAndroidPlatform.instance.getPlatformVersion();
  }
}
