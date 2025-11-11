import 'package:flutter_test/flutter_test.dart';
import 'package:strivacity_flutter_android/strivacity_flutter_android.dart';
import 'package:strivacity_flutter_android/strivacity_flutter_android_platform_interface.dart';
import 'package:strivacity_flutter_android/strivacity_flutter_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockStrivacityFlutterAndroidPlatform
    with MockPlatformInterfaceMixin
    implements StrivacityFlutterAndroidPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final StrivacityFlutterAndroidPlatform initialPlatform = StrivacityFlutterAndroidPlatform.instance;

  test('$MethodChannelStrivacityFlutterAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelStrivacityFlutterAndroid>());
  });

  test('getPlatformVersion', () async {
    StrivacityFlutterAndroid strivacityFlutterAndroidPlugin = StrivacityFlutterAndroid();
    MockStrivacityFlutterAndroidPlatform fakePlatform = MockStrivacityFlutterAndroidPlatform();
    StrivacityFlutterAndroidPlatform.instance = fakePlatform;

    expect(await strivacityFlutterAndroidPlugin.getPlatformVersion(), '42');
  });
}
