import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strivacity_flutter_ios/strivacity_flutter_ios_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelStrivacityFlutterIos platform = MethodChannelStrivacityFlutterIos();
  const MethodChannel channel = MethodChannel('strivacity_flutter_ios');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
