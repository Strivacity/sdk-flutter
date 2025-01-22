import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:strivacity_flutter_platform_interface/strivacity_flutter_platform_interface.dart';

import 'sdk.dart';
import 'utils/crypto.dart';
import 'utils/http_client.dart';

/// Handles the login process for the Strivacity SDK.
class LoginHandler {
  late HttpClient _httpClient;
  late StrivacitySDK _sdk;
  late OidcParams _params;
  String? _sessionId;

  LoginHandler({required sdk, required params, required httpClient}) {
    _sdk = sdk;
    _params = params;
    _httpClient = httpClient;
  }

  /// Starts a new session and returns the session data.
  ///
  /// Throws an [OIDCError] if there is an issue starting the session.
  Future<Map<String, dynamic>> startSession() async {
    _sdk.state = _generateState();
    var uri = _generateAuthorizationUri(_params);
    uri = uri.replace(queryParameters: {
      ...uri.queryParameters,
      'state': _sdk.state!.id,
      'code_challenge': _sdk.state!.codeChallenge,
      'nonce': _sdk.state!.nonce,
    });

    final response = await _httpClient.followUntil(uri.toString(), (HttpResponse httpResponse) {
      if (!httpResponse.headers.containsKey('location')) {
        return true;
      }

      final redirectUri = Uri.parse(httpResponse.headers['location']!.first);
      return _sdk.tenantConfiguration.redirectUri.host == redirectUri.host ||
          (_sdk.tenantConfiguration.issuer.host == redirectUri.host && redirectUri.path == 'oauth2/error');
    });

    if (response.headers['location'] == null) {
      throw OIDCError('OIDC Error', response.body);
    }

    final redirectUri = Uri.parse(response.headers['location']!.first);

    if (redirectUri.queryParameters['error'] != null) {
      throw OIDCError(redirectUri.queryParameters['error']!, redirectUri.queryParameters['error_description']!);
    }

    if (redirectUri.queryParameters['code'] != null) {
      if (!redirectUri.toString().startsWith(_sdk.tenantConfiguration.redirectUri.toString())) {
        throw OIDCError('OIDC Error', 'Invalid redirect URI');
      }

      await _sdk.tokenExchange(redirectUri.queryParameters);
    }

    if (redirectUri.queryParameters['session_id'] == null) {
      throw OIDCError('Failed to start a session', '"session_id" is missing');
    }

    _sessionId = redirectUri.queryParameters['session_id'];

    return submitForm();
  }

  /// Finalizes the session using the provided [finalizeUrl].
  ///
  /// Throws an [OIDCError] if there is an issue finalizing the session.
  Future<void> finalizeSession(String finalizeUrl) async {
    final response = await _httpClient.followUntil(finalizeUrl, (HttpResponse httpResponse) {
      if (!httpResponse.headers.containsKey('location')) {
        return true;
      }

      final redirectUri = Uri.parse(httpResponse.headers['location']!.first);
      return _sdk.tenantConfiguration.redirectUri.host == redirectUri.host ||
          (_sdk.tenantConfiguration.issuer.host == redirectUri.host && redirectUri.path == 'oauth2/error');
    });

    if (response.headers['location'] == null) {
      throw OIDCError('OIDC Error', response.body);
    }

    final redirectUri = Uri.parse(response.headers['location']!.first);

    if (!redirectUri.toString().startsWith(_sdk.tenantConfiguration.redirectUri.toString())) {
      throw OIDCError('OIDC Error', 'Invalid redirect URI');
    }

    await _sdk.tokenExchange(redirectUri.queryParameters);
  }

  /// Submits a form with the optional [formId] and [data].
  ///
  /// Returns the response body as a [Map<String, dynamic>].
  ///
  /// Throws a [FallbackError] if there is an issue with the form submission.
  Future<Map<String, dynamic>> submitForm([String? formId, Map<String, dynamic>? data]) async {
    Map<String, dynamic> body = {};

    try {
      final response =
          await _httpClient.post('${_sdk.tenantConfiguration.issuer}/flow/api/v1/${formId != null ? 'form/$formId' : 'init'}', (RequestOptions options) {
        options.headers = {
          'Authorization': 'Bearer $_sessionId',
          'Content-Type': 'application/json',
        };
        options.data = jsonEncode(data ?? {});
      });

      body = response.body;

      if (body['finalizeUrl'] != null) {
        try {
          await finalizeSession(body['finalizeUrl']);
        } catch (e) {
          rethrow;
        }
      } else if (body['hostedUrl'] != null && body['forms'] == null && body['messages'] == null) {
        throw FallbackError(Uri.parse(body['hostedUrl']));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 && e.response?.data != null) {
        body = e.response!.data;
      } else if (e.response?.statusCode == 403 || e.response?.data['hostedUrl'] != null) {
        throw FallbackError(e.response?.data['hostedUrl'] != null ? Uri.parse(e.response!.data['hostedUrl']) : null);
      } else {
        rethrow;
      }
    }

    return body;
  }

  /// Generates the authorization URI based on the provided [params].
  Uri _generateAuthorizationUri(OidcParams? params) {
    final uri = Uri.parse('${_sdk.tenantConfiguration.issuer}/oauth2/auth');

    return uri.replace(queryParameters: {
      'client_id': _sdk.tenantConfiguration.clientId,
      'redirect_uri': _sdk.tenantConfiguration.redirectUri.toString(),
      'response_type': 'code',
      'response_mode': 'query',
      'scope': params?.scopes?.join(' ') ?? '',
      'code_challenge_method': 'S256',
      'ui_locales': params?.uiLocales != null && params!.uiLocales.isNotEmpty ? params.uiLocales.join(' ') : 'en-US',
      if (params?.prompt != null && params!.prompt!.isNotEmpty) 'prompt': params.prompt,
      if (params?.acrValues != null && params!.acrValues!.isNotEmpty) 'acr_values': params.acrValues!.join(' '),
      if (params?.loginHint != null && params!.loginHint!.isNotEmpty) 'login_hint': params.loginHint,
    });
  }

  /// Generates a new OIDC state.
  OidcState _generateState() {
    final codeVerifier = Crypto.generateRandomString(32);
    final codeChallenge = Crypto.generateCodeChallenge(codeVerifier);

    return OidcState(id: Crypto.generateRandomString(16), nonce: Crypto.generateRandomString(16), codeVerifier: codeVerifier, codeChallenge: codeChallenge);
  }
}
