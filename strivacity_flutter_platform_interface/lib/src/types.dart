class TenantConfiguration {
  final Uri issuer;
  final String clientId;
  final Uri redirectUri;
  final Uri postLogoutUri;
  final List<String> scopes;

  TenantConfiguration({
    required dynamic issuer,
    required this.clientId,
    required dynamic redirectUri,
    required dynamic postLogoutUri,
    required this.scopes,
  })  : issuer = issuer is Uri ? issuer : Uri.parse(issuer),
        redirectUri = redirectUri is Uri ? redirectUri : Uri.parse(redirectUri),
        postLogoutUri = postLogoutUri is Uri ? postLogoutUri : Uri.parse(postLogoutUri);
}

abstract class SDKStorage {
  Future<void> put(String key, String value);
  Future<String?> get(String key);
  Future<void> remove(String key);
  Future<void> clear();
}
