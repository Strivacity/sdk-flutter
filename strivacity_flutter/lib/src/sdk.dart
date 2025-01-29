import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:strivacity_flutter_platform_interface/strivacity_flutter_platform_interface.dart';

import 'login_handler.dart';
import 'utils/http_client.dart';

class StrivacitySDK extends StrivacityFlutterPlatform {
  // ignore: constant_identifier_names
  static const String STORE_KEY = 'Strivacity';

  final HttpClient _httpClient = HttpClient();
  final SDKStorage _storage;
  bool _initialized = false;
  Future<bool>? _isAuthenticated;

  /// Configuration for the tenant.
  final TenantConfiguration tenantConfiguration;

  /// Current OIDC session.
  OidcSession? session;

  /// Current OIDC state.
  OidcState? state;

  /// Returns the ID token claims.
  IdTokenClaims? get idTokenClaims {
    return session?.idTokenClaims;
  }

  /// Returns the access token.
  String? get accessToken {
    return session?.accessToken;
  }

  /// Checks if the access token is expired.
  bool get accessTokenExpired {
    return session?.accessToken == null || (session?.expiration.isBefore(DateTime.now()) ?? true);
  }

  /// Returns the refresh token.
  String? get refreshToken {
    return session?.refreshToken;
  }

  /// Checks if the user is authenticated.
  Future<bool> get isAuthenticated async {
    if (_isAuthenticated != null) {
      return _isAuthenticated!;
    }

    while (!_initialized) {
      await Future.delayed(Duration(milliseconds: 10));
    }

    _isAuthenticated = Future<bool>(() async {
      try {
        if (refreshToken != null && accessTokenExpired) {
          await refresh();
        }
      } catch (e) {
        // ignored
      }

      await Future.delayed(Duration(milliseconds: 10));
      bool isAuthenticated = !accessTokenExpired;
      _isAuthenticated = null;
      return isAuthenticated;
    });

    return _isAuthenticated!;
  }

  /// Initializes the SDK with the given tenant configuration and storage.
  StrivacitySDK({
    required this.tenantConfiguration,
    required SDKStorage storage,
    this.session,
  }) : _storage = storage {
    _storage.get(STORE_KEY).then((data) {
      if (data != null && session == null) {
        session = OidcSession.fromJson(jsonDecode(data));
      }

      _initialized = true;
    });
  }

  /// Initiates the login process with optional OIDC parameters.
  @override
  LoginHandler login([OidcParams? params]) {
    params ??= OidcParams();
    params.scopes ??= tenantConfiguration.scopes;

    return LoginHandler(sdk: this, params: params, httpClient: _httpClient);
  }

  /// Initiates the registration process with optional OIDC parameters.
  @override
  LoginHandler register([OidcParams? params]) {
    params ??= OidcParams();
    params.prompt = 'create';

    return login(params);
  }

  /// Logs out the user and clears the session.
  @override
  Future<void> logout() async {
    if (session?.idToken == null) {
      return;
    }

    try {
      await _httpClient.get(Uri.parse('${tenantConfiguration.issuer}/oauth2/sessions/logout').replace(queryParameters: {
        'id_token_hint': session!.idToken,
        'post_logout_redirect_uri': tenantConfiguration.postLogoutUri.toString(),
      }).toString());
    } catch (e) {
      // ignored
    } finally {
      session = null;
      await _storage.remove(STORE_KEY);
    }
  }

  /// Refreshes the access token using the refresh token.
  @override
  Future<void> refresh() async {
    if (session?.refreshToken == null) {
      return;
    }

    final response = await _httpClient.sendTokenRequest('${tenantConfiguration.issuer}/oauth2/token', (RequestOptions options) {
      options.data = {
        'grant_type': 'refresh_token',
        'client_id': tenantConfiguration.clientId,
        'refresh_token': session!.refreshToken,
      };
    });

    session = OidcSession.fromOidcResponse(response.body);

    await _storage.put(STORE_KEY, jsonEncode(session!.toJson()));
  }

  /// Revokes the current session tokens.
  @override
  Future<void> revoke() async {
    if (session == null) {
      return;
    }

    try {
      if (session!.refreshToken != null && session!.refreshToken!.isNotEmpty) {
        await _httpClient.sendTokenRequest('${tenantConfiguration.issuer}/oauth2/revoke', (RequestOptions options) {
          options.data = {
            'client_id': tenantConfiguration.clientId,
            'token_type_hint': 'refresh_token',
            'token': session!.refreshToken,
          };
        });
      } else if (session!.accessToken != null && session!.accessToken!.isNotEmpty) {
        await _httpClient.sendTokenRequest('${tenantConfiguration.issuer}/oauth2/revoke', (RequestOptions options) {
          options.data = {
            'client_id': tenantConfiguration.clientId,
            'token_type_hint': 'access_token',
            'token': session!.accessToken,
          };
        });
      }
    } catch (e) {
      // ignored
    } finally {
      session = null;
      await _storage.remove(STORE_KEY);
    }
  }

  /// Exchanges the authorization code for tokens.
  @override
  Future<void> tokenExchange([Map<String, String> params = const {}]) async {
    if (state == null) {
      throw OIDCError('OIDC Error', 'Invalid or missing state');
    }
    if (params['error'] != null) {
      throw OIDCError(params['error']!, params['error_description']!);
    }
    if (params['code'] == null) {
      throw OIDCError('OIDC Error', 'Invalid state');
    }
    if (params['state'] != state?.id) {
      throw OIDCError('OIDC Error', 'Invalid or missing code');
    }

    final response = await _httpClient.sendTokenRequest(
        '${tenantConfiguration.issuer}/oauth2/token',
        (RequestOptions options) => {
              options.data = {
                'grant_type': 'authorization_code',
                'client_id': tenantConfiguration.clientId,
                'redirect_uri': tenantConfiguration.redirectUri.toString(),
                'code_verifier': state!.codeVerifier,
                'code': params['code'],
              }
            });

    session = OidcSession.fromOidcResponse(response.body);

    if (session?.idTokenClaims?.nonce != state!.nonce) {
      throw OIDCError('OIDC Error', 'Invalid nonce');
    }
    if (session?.idTokenClaims?.issuer.scheme != tenantConfiguration.issuer.scheme || session?.idTokenClaims?.issuer.host != tenantConfiguration.issuer.host) {
      throw OIDCError('OIDC Error', 'Invalid issuer');
    }
    if (session?.idTokenClaims?.audience.first != tenantConfiguration.clientId) {
      throw OIDCError('OIDC Error', 'Invalid audience');
    }

    state = null;

    await _storage.put(STORE_KEY, jsonEncode(session!.toJson()));
  }
}
