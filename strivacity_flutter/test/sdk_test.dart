import 'package:flutter_test/flutter_test.dart';
import 'package:strivacity_flutter/strivacity_flutter.dart';

class MockSDKStorage extends SDKStorage {
  @override
  Future<void> clear() {
    return Future.value();
  }

  @override
  Future<String?> get(String key) {
    return Future.value(null);
  }

  @override
  Future<void> put(String key, String value) {
    return Future.value();
  }

  @override
  Future<void> remove(String key) {
    return Future.value();
  }
}

void main() {
  late StrivacitySDK sdk;
  late MockSDKStorage mockStorage;
  late TenantConfiguration tenantConfiguration;

  setUp(() {
    mockStorage = MockSDKStorage();
    tenantConfiguration = TenantConfiguration(
      issuer: 'https://example.com',
      clientId: 'client_id',
      redirectUri: 'https://example.com/redirect',
      postLogoutUri: 'https://example.com/logout',
      scopes: ['openid', 'profile', 'email'],
    );
    sdk = StrivacitySDK(
      tenantConfiguration: tenantConfiguration,
      storage: mockStorage,
    );
  });

  test('SDK initializes correctly', () async {
    expectLater(await sdk.isAuthenticated, false);
    expect(sdk.tenantConfiguration.issuer, Uri.parse('https://example.com'));
    expect(sdk.tenantConfiguration.clientId, 'client_id');
    expect(sdk.tenantConfiguration.redirectUri, Uri.parse('https://example.com/redirect'));
    expect(sdk.tenantConfiguration.postLogoutUri, Uri.parse('https://example.com/logout'));
  });
}
