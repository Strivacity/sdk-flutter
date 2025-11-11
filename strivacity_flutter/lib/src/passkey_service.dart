import 'package:flutter/services.dart';

/// Service for handling passkey (WebAuthn) operations.
/// 
/// This service provides methods for passkey authentication and enrollment
/// using platform-specific implementations (Android Credential Manager API
/// and iOS ASAuthorization API).
class PasskeyService {
  static const MethodChannel _channel = MethodChannel('strivacity_flutter/passkey');

  /// Authenticates a user using a passkey (WebAuthn assertion).
  /// 
  /// Takes [assertionOptions] containing the WebAuthn PublicKeyCredentialRequestOptions
  /// from the server and returns the WebAuthn assertion response.
  /// 
  /// Throws [PlatformException] if the authentication fails or is cancelled.
  /// 
  /// Example:
  /// ```dart
  /// final result = await PasskeyService.authenticate({
  ///   'challenge': 'base64-challenge',
  ///   'rpId': 'example.com',
  ///   'allowCredentials': [...]
  /// });
  /// ```
  static Future<Map<String, dynamic>> authenticate(Map<String, dynamic> assertionOptions) async {
    try {
      final result = await _channel.invokeMethod('authenticate', assertionOptions);
      return Map<String, dynamic>.from(result as Map);
    } on PlatformException catch (e) {
      throw PasskeyException(
        'Authentication failed: ${e.message}',
        code: e.code,
        details: e.details,
      );
    }
  }

  /// Registers a new passkey (WebAuthn attestation).
  /// 
  /// Takes [enrollOptions] containing the WebAuthn PublicKeyCredentialCreationOptions
  /// from the server and returns the WebAuthn attestation response.
  /// 
  /// Throws [PlatformException] if the enrollment fails or is cancelled.
  /// 
  /// Example:
  /// ```dart
  /// final result = await PasskeyService.enroll({
  ///   'challenge': 'base64-challenge',
  ///   'rp': {'id': 'example.com', 'name': 'Example'},
  ///   'user': {...},
  ///   'pubKeyCredParams': [...]
  /// });
  /// ```
  static Future<Map<String, dynamic>> enroll(Map<String, dynamic> enrollOptions) async {
    try {
      final result = await _channel.invokeMethod('enroll', enrollOptions);
      return Map<String, dynamic>.from(result as Map);
    } on PlatformException catch (e) {
      throw PasskeyException(
        'Enrollment failed: ${e.message}',
        code: e.code,
        details: e.details,
      );
    }
  }

  /// Checks if passkey is available on the current device.
  /// 
  /// Returns `true` if the device supports passkey operations, `false` otherwise.
  static Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}

/// Exception thrown when passkey operations fail.
class PasskeyException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  PasskeyException(this.message, {this.code, this.details});

  @override
  String toString() => 'PasskeyException: $message (code: $code)';
}
