import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_strivacity_flutter.dart';

abstract class StrivacityFlutterPlatform extends PlatformInterface {
  StrivacityFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  /// The default instance of [StrivacityFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelStrivacityFlutter].
  static StrivacityFlutterPlatform get instance => _instance;
  static StrivacityFlutterPlatform _instance = MethodChannelStrivacityFlutter();

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [StrivacityFlutterPlatform] when they register themselves.
  static set instance(final StrivacityFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initiates the login process. Subclasses should implement this method to handle the specific login flow.
  dynamic login() {
    throw UnimplementedError('login() has not been implemented');
  }

  /// Registers a new user. Subclasses should implement this method to handle the specific registration flow.
  dynamic register() {
    throw UnimplementedError('register() has not been implemented');
  }

  /// Logs out the current user and optionally redirects to a post-logout URI.
  Future<void> logout() {
    throw UnimplementedError('logout() has not been implemented');
  }

  /// Refreshes the access token using the refresh token.
  Future<void> refresh() {
    throw UnimplementedError('refresh() has not been implemented');
  }

  /// Revokes the current access or refresh token.
  Future<void> revoke() {
    throw UnimplementedError('revoke() has not been implemented');
  }

  /// Exchanges a code token for an access token.
  Future<void> tokenExchange([Map<String, String> params = const {}]) {
    throw UnimplementedError('exchangeToken() has not been implemented');
  }
}
