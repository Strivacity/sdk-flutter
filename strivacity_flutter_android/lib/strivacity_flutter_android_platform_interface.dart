import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'strivacity_flutter_android_method_channel.dart';

abstract class StrivacityFlutterAndroidPlatform extends PlatformInterface {
  /// Constructs a StrivacityFlutterAndroidPlatform.
  StrivacityFlutterAndroidPlatform() : super(token: _token);

  static final Object _token = Object();

  static StrivacityFlutterAndroidPlatform _instance = MethodChannelStrivacityFlutterAndroid();

  /// The default instance of [StrivacityFlutterAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelStrivacityFlutterAndroid].
  static StrivacityFlutterAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StrivacityFlutterAndroidPlatform] when
  /// they register themselves.
  static set instance(StrivacityFlutterAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
