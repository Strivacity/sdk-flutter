import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'strivacity_flutter_ios_platform_interface.dart';

/// An implementation of [StrivacityFlutterIosPlatform] that uses method channels.
class MethodChannelStrivacityFlutterIos extends StrivacityFlutterIosPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('strivacity_flutter_ios');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
