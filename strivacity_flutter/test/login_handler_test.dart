import 'package:flutter_test/flutter_test.dart';
import 'package:strivacity_flutter/src/utils/http_client.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

import 'mocks/sdk_storage.dart';
import 'mocks/test_logging.dart';

void main() {
  LoginHandler createLoginHandler(OidcParams params) {
    final logging = TestLogging();
    final client = HttpClient(logging: logging);
    return LoginHandler(
      sdk: StrivacitySDK(tenantConfiguration: fakeConfig, storage: MockSDKStorage()),
      params: params,
      httpClient: client,
      logging: logging,
    );
  }

  group('generateParams', () {
    group('scope', () {
      test('should add optional scope when defined 1 value', () {
        const scope = 'acr1';
        final handler = createLoginHandler(OidcParams(scopes: [scope]));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), contains('scope=${Uri.encodeQueryComponent(scope)}'));
      });
      test('should add optional scope when defined multiple value', () {
        const scope1 = 'acr1';
        const scope2 = 'acr2/';
        final handler = createLoginHandler(OidcParams(scopes: [scope1, scope2]));

        final uri = handler.generateAuthorizationUri();

        expect(
            uri.toString(), contains('scope=${Uri.encodeQueryComponent(scope1)}+${Uri.encodeQueryComponent(scope2)}'));
      });
      test('should skip scope when not defined', () {
        final handler = createLoginHandler(OidcParams(scopes: null));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), isNot(contains('scope=')));
      });
      test('should skip scope when empty', () {
        final handler = createLoginHandler(OidcParams(scopes: const []));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), isNot(contains('scope=')));
      });
    });
    group('login_hint', () {
      test('should add optional login_hint when defined', () {
        const hint = 'someuser@localhost';
        final handler = createLoginHandler(OidcParams(loginHint: hint));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), contains('login_hint=${Uri.encodeQueryComponent(hint)}'));
      });
      test('should skip login_hint when value is empty', () {
        const hint = '';
        final handler = createLoginHandler(OidcParams(loginHint: hint));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), isNot(contains('login_hint=')));
      });
      test('should skip login_hint when value is blank', () {
        const hint = ' ';
        final handler = createLoginHandler(OidcParams(loginHint: hint));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), isNot(contains('login_hint=')));
      });
      test('should skip login_hint when value is null', () {
        const hint = null;
        final handler = createLoginHandler(OidcParams(loginHint: hint));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), isNot(contains('login_hint=')));
      });
    });
    group('prompt', () {
      test('should add optional prompt when defined', () {
        const prompt = 'create';
        final handler = createLoginHandler(OidcParams(prompt: prompt));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), contains('prompt=${Uri.encodeQueryComponent(prompt)}'));
      });
      test('should skip prompt when value is empty', () {
        const prompt = '';
        final handler = createLoginHandler(OidcParams(prompt: prompt));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), isNot(contains('prompt=')));
      });
      test('should skip prompt when value is blank', () {
        const prompt = ' ';
        final handler = createLoginHandler(OidcParams(prompt: prompt));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), isNot(contains('prompt=')));
      });
      test('should skip prompt when value is null', () {
        const prompt = null;
        final handler = createLoginHandler(OidcParams(prompt: prompt));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), isNot(contains('prompt=')));
      });
    });
    group('audience', () {
      test('should add optional audience when defined 1 value', () {
        const aud1 = 'http://localhost/aud1';
        final handler = createLoginHandler(OidcParams(audiences: [aud1]));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), contains('audience=${Uri.encodeQueryComponent(aud1)}'));
      });
      test('should add optional audience when defined multiple value', () {
        const aud1 = 'http://localhost/aud1';
        const aud2 = 'http://localhost/aud2';
        final handler = createLoginHandler(OidcParams(audiences: [aud1, aud2]));

        final uri = handler.generateAuthorizationUri();

        expect(
            uri.toString(), contains('audience=${Uri.encodeQueryComponent(aud1)}+${Uri.encodeQueryComponent(aud2)}'));
      });
      test('should skip audience when not defined', () {
        final handler = createLoginHandler(OidcParams(audiences: null));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), isNot(contains('audience')));
      });
      test('should skip audience when empty', () {
        final handler = createLoginHandler(OidcParams(audiences: const []));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), isNot(contains('audience')));
      });
      test('should skip audience when value is blank', () {
        final handler = createLoginHandler(OidcParams(audiences: const [' ']));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), isNot(contains('audience')));
      });
    });
    group('acr_values', () {
      test('should add optional acr_values when defined 1 value', () {
        const acr1 = 'acr1';
        final handler = createLoginHandler(OidcParams(acrValues: [acr1]));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), contains('acr_values=${Uri.encodeQueryComponent(acr1)}'));
      });
      test('should add optional acr_values when defined multiple value', () {
        const acr1 = 'acr1';
        const acr2 = 'acr2/';
        final handler = createLoginHandler(OidcParams(acrValues: [acr1, acr2]));

        final uri = handler.generateAuthorizationUri();

        expect(
            uri.toString(), contains('acr_values=${Uri.encodeQueryComponent(acr1)}+${Uri.encodeQueryComponent(acr2)}'));
      });
      test('should skip acr_values when not defined', () {
        final handler = createLoginHandler(OidcParams(acrValues: null));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), isNot(contains('acr_values')));
      });
      test('should skip acr_values when empty', () {
        final handler = createLoginHandler(OidcParams(acrValues: const []));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), isNot(contains('acr_values')));
      });
      test('should skip acr_values when value is blank', () {
        final handler = createLoginHandler(OidcParams(acrValues: const [' ']));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), isNot(contains('acr_values')));
      });
    });
    group('ui_locales', () {
      test('should add optional ui_locales when defined 1 value', () {
        const locale = 'hu-HU';
        final handler = createLoginHandler(OidcParams(uiLocales: [locale]));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), contains('ui_locales=${Uri.encodeQueryComponent(locale)}'));
      });
      test('should add optional ui_locales when defined multiple value', () {
        const locale1 = 'acr1';
        const locale2 = 'acr2/';
        final handler = createLoginHandler(OidcParams(uiLocales: [locale1, locale2]));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(),
            contains('ui_locales=${Uri.encodeQueryComponent(locale1)}+${Uri.encodeQueryComponent(locale2)}'));
      });
      test('should fall back to default when uiLocales is empty', () {
        final handler = createLoginHandler(OidcParams(uiLocales: const []));

        final uri = handler.generateAuthorizationUri();

        expect(uri.toString(), contains('ui_locales=en-US'));
      });
    });
    group('tenant configuration', () {
      test('should fill in params from tenant configurations', () {
        final handler = createLoginHandler(OidcParams());
        final url = handler.generateAuthorizationUri().toString();

        expect(url, contains('client_id=test-client-id'));
        expect(url, contains('redirect_uri=${Uri.encodeQueryComponent('local-test://some-host/login')}'));
        expect(url, contains('response_type=code'));
        expect(url, contains('response_mode=query'));
        expect(url, contains('code_challenge_method=S256'));
      });
    });
  });
}

final fakeConfig = TenantConfiguration(
  issuer: 'http://localhost',
  clientId: 'test-client-id',
  redirectUri: 'local-test://some-host/login',
  postLogoutUri: 'local-test://some-host/logout',
  scopes: [],
);
