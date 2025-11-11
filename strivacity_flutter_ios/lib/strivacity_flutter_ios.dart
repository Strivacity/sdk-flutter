
import 'strivacity_flutter_ios_platform_interface.dart';

class StrivacityFlutterIos {
  Future<String?> getPlatformVersion() {
    return StrivacityFlutterIosPlatform.instance.getPlatformVersion();
  }
}
