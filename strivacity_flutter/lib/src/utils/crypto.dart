import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class Crypto {
  /// Generates a random state string.
  ///
  /// Returns a 16-byte random string encoded in base64 URL format.
  static String generateState() {
    return generateRandomString(16);
  }

  /// Generates a random nonce string.
  ///
  /// Returns a 16-byte random string encoded in base64 URL format.
  static String generateNonce() {
    return generateRandomString(16);
  }

  /// Generates a random code verifier string.
  ///
  /// Returns a 32-byte random string encoded in base64 URL format.
  static String generateCodeVerifier() {
    return generateRandomString(32);
  }

  /// Generates a code challenge from the given code verifier.
  ///
  /// Takes a [codeVerifier] string, hashes it using SHA-256, and returns
  /// the result encoded in base64 URL format without padding.
  static String generateCodeChallenge(String codeVerifier) {
    var bytes = utf8.encode(codeVerifier);
    var digest = sha256.convert(bytes);

    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  /// Generates a random string of the specified byte length.
  ///
  /// Takes an integer [byteLengths] representing the number of random bytes
  /// to generate, and returns the result encoded in base64 URL format without padding.
  static String generateRandomString(int byteLengths) {
    final Random random = Random.secure();
    final Uint8List bytes = Uint8List(byteLengths);
    for (int i = 0; i < byteLengths; i++) {
      bytes[i] = random.nextInt(256);
    }

    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
