import 'package:flutter/services.dart';

import 'strivacity_flutter_platform.dart';
import 'oidc.dart';

const MethodChannel _channel = MethodChannel('strivacity.com/strivacity_flutter');

class MethodChannelStrivacityFlutter extends StrivacityFlutterPlatform {
  @override
  dynamic login([OidcParams? params]) {
    return _channel.invokeMethod<void>('login', [params]);
  }

  @override
  dynamic register([OidcParams? params]) {
    return _channel.invokeMethod<void>('register', [params]);
  }

  @override
  Future<void> logout() async {
    await _channel.invokeMethod<void>('logout');
  }

  @override
  Future<void> refresh() async {
    await _channel.invokeMethod<void>('refresh');
  }

  @override
  Future<void> revoke() async {
    await _channel.invokeMethod<void>('revoke');
  }

  @override
  Future<void> tokenExchange([Map<String, String> params = const {}]) async {
    await _channel.invokeMethod<void>('exchangeToken', [params]);
  }
}
