import 'dart:convert';

class JWT {
  static Map<String, dynamic> decode(String jwtEncoded) {
    final parts = jwtEncoded.split('.');

    if (parts.length != 3) {
      throw Exception('Invalid JWT');
    }

    return jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }
}
