class OIDCError implements Exception {
  final String error;
  final String errorDescription;

  OIDCError(this.error, this.errorDescription);

  @override
  String toString() {
    return '$error - $errorDescription';
  }
}

class FallbackError implements Exception {
  final Uri? uri;

  FallbackError([this.uri]);
}
