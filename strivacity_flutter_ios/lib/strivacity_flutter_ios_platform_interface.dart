import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'strivacity_flutter_ios_method_channel.dart';

abstract class StrivacityFlutterIosPlatform extends PlatformInterface {
  /// Constructs a StrivacityFlutterIosPlatform.
  StrivacityFlutterIosPlatform() : super(token: _token);

  static final Object _token = Object();

  static StrivacityFlutterIosPlatform _instance = MethodChannelStrivacityFlutterIos();

  /// The default instance of [StrivacityFlutterIosPlatform] to use.
  ///
  /// Defaults to [MethodChannelStrivacityFlutterIos].
  static StrivacityFlutterIosPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [StrivacityFlutterIosPlatform] when
  /// they register themselves.
  static set instance(StrivacityFlutterIosPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
