import 'package:flutter_test/flutter_test.dart';
import 'package:strivacity_flutter_ios/strivacity_flutter_ios.dart';
import 'package:strivacity_flutter_ios/strivacity_flutter_ios_platform_interface.dart';
import 'package:strivacity_flutter_ios/strivacity_flutter_ios_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockStrivacityFlutterIosPlatform
    with MockPlatformInterfaceMixin
    implements StrivacityFlutterIosPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final StrivacityFlutterIosPlatform initialPlatform = StrivacityFlutterIosPlatform.instance;

  test('$MethodChannelStrivacityFlutterIos is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelStrivacityFlutterIos>());
  });

  test('getPlatformVersion', () async {
    StrivacityFlutterIos strivacityFlutterIosPlugin = StrivacityFlutterIos();
    MockStrivacityFlutterIosPlatform fakePlatform = MockStrivacityFlutterIosPlatform();
    StrivacityFlutterIosPlatform.instance = fakePlatform;

    expect(await strivacityFlutterIosPlugin.getPlatformVersion(), '42');
  });
}
