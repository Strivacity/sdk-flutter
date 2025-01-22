import 'jwt.dart';

class IdTokenClaims {
  final Map<String, dynamic> data;

  final DateTime authenticationTime;
  final DateTime expirationTime;
  final DateTime issuedAt;
  final Uri issuer;
  final String nonce;
  final String subject;
  final List<String> audience;

  IdTokenClaims(this.data)
      : authenticationTime = DateTime.fromMillisecondsSinceEpoch(data['auth_time'] * 1000),
        expirationTime = DateTime.fromMillisecondsSinceEpoch(data['exp'] * 1000),
        issuedAt = DateTime.fromMillisecondsSinceEpoch(data['iat'] * 1000),
        issuer = Uri.parse(data['iss']),
        nonce = data['nonce'],
        subject = data['sub'],
        audience = List<String>.from(data['aud']);

  String getString(String key) {
    return data[key];
  }

  Map<String, dynamic> toJson() {
    return data;
  }
}

class OidcParams {
  String? prompt;
  String? loginHint;
  List<String>? acrValues;
  List<String>? scopes;

  List<String> uiLocales = ['en-US'];

  OidcParams({this.prompt, this.loginHint, this.acrValues, this.scopes});

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'login_hint': loginHint,
      'acr_values': acrValues,
      'scopes': scopes,
      'ui_locales': uiLocales,
    };
  }
}

class OidcState {
  String id;
  String codeVerifier;
  String nonce;
  String codeChallenge;

  OidcState({required this.id, required this.codeVerifier, required this.nonce, required this.codeChallenge});

  static OidcState fromJSON(Map<String, String> data) {
    return OidcState(
        id: data['id'] as String, codeVerifier: data['codeVerifier'] as String, nonce: data['nonce'] as String, codeChallenge: data['codeChallenge'] as String);
  }
}

class OidcSession {
  final String? accessToken;
  final String? refreshToken;
  final DateTime expiration;
  final String idToken;
  IdTokenClaims? idTokenClaims;

  OidcSession({this.accessToken, this.refreshToken, required this.expiration, required this.idToken}) {
    idTokenClaims = IdTokenClaims(JWT.decode(idToken));
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiration': expiration.toIso8601String(),
      'idToken': idToken,
    };
  }

  static OidcSession fromJson(Map<String, dynamic> json) {
    return OidcSession(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expiration: DateTime.parse(json['expiration']),
      idToken: json['idToken'],
    );
  }

  static OidcSession fromOidcResponse(Map<String, dynamic> json) {
    return OidcSession(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiration: DateTime.now().add(Duration(seconds: json['expires_in'])),
      idToken: json['id_token'],
    );
  }
}
