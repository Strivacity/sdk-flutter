import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:strivacity_flutter_platform_interface/strivacity_flutter_platform_interface.dart';

import 'login_handler.dart';
import 'utils/http_client.dart';
import 'logging.dart';

class StrivacitySDK extends StrivacityFlutterPlatform {
  // ignore: constant_identifier_names
  static const String STORE_KEY = 'Strivacity';

  late final HttpClient _httpClient = HttpClient(logging: _logging);
  final SDKStorage _storage;
  final Logging _logging;
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
    Logging? logging,
  })  : _storage = storage,
        _logging = logging ?? const DefaultLogging() {
    _logging.debug("Loading session from storage");
    _storage.get(STORE_KEY).then((data) {
      if (data != null && session == null) {
        _logging.debug("Session loaded successfully from storage");
        session = OidcSession.fromJson(jsonDecode(data));
      }
      _logging.info("Session initialized");
      _initialized = true;
    });
  }

  /// Initiates the login process with optional OIDC parameters.
  @override
  LoginHandler login([OidcParams? params]) {
    if (params?.prompt != 'create') {
      _logging.info("Login initiated");
    }
    params ??= OidcParams(scopes: tenantConfiguration.scopes);

    return LoginHandler(sdk: this, params: params, httpClient: _httpClient, logging: _logging);
  }

  /// Initiates the registration process with optional OIDC parameters.
  @override
  LoginHandler register([OidcParams? params]) {
    _logging.info("Registration initiated");
    params ??= OidcParams(prompt: 'create');

    return login(params);
  }

  /// Logs out the user and clears the session.
  @override
  Future<void> logout() async {
    _logging.debug("Logout initiated");
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
      _logging.debug("Profile removed from storage");
      _logging.info("User was logged out");
    }
  }

  /// Refreshes the access token using the refresh token.
  @override
  Future<void> refresh() async {
    _logging.info("Refreshing user session");
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
    _logging.debug("Session saved to storage successfully");
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
      _logging.debug("Profile removed from storage");
    }
  }

  /// Handles the entry process.
  @override
  Future<String> entry([Map<String, String> params = const {}]) async {
    final entryUri = Uri.parse('${tenantConfiguration.issuer}/provider/flow/entry');

    final queryParams = <String, String>{
      'client_id': tenantConfiguration.clientId,
      'redirect_uri': tenantConfiguration.redirectUri.toString(),
      ...params,
    };

    final finalUri = entryUri.replace(queryParameters: queryParams);

    try {
      final response = await _httpClient.get(finalUri.toString());

      if (response.responseCode == 400) {
        String message = 'Entry request failed with status 400';

        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          if (data['error'] != null) {
            message = '${data['error']}: ${data['error_description'] ?? ''}';
          } else if (data['errorKey'] != null) {
            message = data['errorKey'];
          }
        }

        throw OIDCError('Entry Error', message);
      }

      Uri redirectUri;

      // Try to parse response body as URL first, fall back to realUri
      try {
        redirectUri = Uri.parse(response.body.toString());
      } catch (_) {
        redirectUri = response.realUri!;
      }

      if (!redirectUri.toString().startsWith(tenantConfiguration.redirectUri.toString())) {
        throw OIDCError('OIDC Error', 'Invalid redirect URI');
      }

      final sessionId = redirectUri.queryParameters['session_id'];

      if (sessionId == null || sessionId.isEmpty) {
        throw OIDCError('OIDC Error', 'Session ID not found in entry response');
      }

      return sessionId;
    } catch (e) {
      if (e is OIDCError) {
        rethrow;
      }

      throw OIDCError('Entry Error', e.toString());
    }
  }

  /// Exchanges the authorization code for tokens.
  @override
  Future<void> tokenExchange([Map<String, String> params = const {}]) async {
    if (state == null) {
      _logging.error('Invalid or missing state');
      throw OIDCError('OIDC Error', 'Invalid or missing state');
    }
    if (params['error'] != null) {
      _logging.error('OIDC Error: ${params['error']} ${params['error_description']}');
      throw OIDCError(params['error']!, params['error_description']!);
    }
    if (params['code'] == null) {
      _logging.error('Invalid state');
      throw OIDCError('OIDC Error', 'Invalid state');
    }
    if (params['state'] != state?.id) {
      _logging.error('Invalid or missing codd');
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

    final sessionProposal = OidcSession.fromOidcResponse(response.body);

    if (sessionProposal.idTokenClaims?.nonce != state!.nonce) {
      _logging.error('Invalid nonce');
      throw OIDCError('OIDC Error', 'Invalid nonce');
    }
    if (sessionProposal.idTokenClaims?.issuer.scheme != tenantConfiguration.issuer.scheme ||
        sessionProposal.idTokenClaims?.issuer.host != tenantConfiguration.issuer.host) {
      _logging.error('Invalid issuer');
      throw OIDCError('OIDC Error', 'Invalid issuer');
    }
    if (sessionProposal.idTokenClaims?.audience.first != tenantConfiguration.clientId) {
      _logging.error('Invalid audience');
      throw OIDCError('OIDC Error', 'Invalid audience');
    }

    await _storage.put(STORE_KEY, jsonEncode(sessionProposal.toJson()));
    _logging.debug("Session saved to storage successfully");

    session = sessionProposal;
    _logging.info("User logged in successfully");
    state = null;
  }
}
