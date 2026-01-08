import 'package:flutter/widgets.dart';

abstract interface class Logging {
  void debug(String body, [Object? exception, StackTrace? stackTrace]);

  void info(String body, [Object? exception, StackTrace? stackTrace]);

  void warn(String body, [Object? exception, StackTrace? stackTrace]);

  void error(String body, [Object? exception, StackTrace? stackTrace]);
}

final class DefaultLogging implements Logging {
  const DefaultLogging();
  @override
  void debug(String body, [Object? exception, StackTrace? stackTrace]) =>
      _present('DEBUG', body, exception, stackTrace);

  @override
  void info(String body, [Object? exception, StackTrace? stackTrace]) =>
      _present('INFO', body, exception, stackTrace);

  @override
  void warn(String body, [Object? exception, StackTrace? stackTrace]) =>
      _present('WARN', body, exception, stackTrace);

  @override
  void error(String body, [Object? exception, StackTrace? stackTrace]) =>
      _present('ERROR', body, exception, stackTrace);

  void _present(String level, String body,
      [Object? exception, StackTrace? stackTrace]) {
    debugPrint("[$level] $body");
    if (exception != null) {
      FlutterError.presentError(
          FlutterErrorDetails(exception: exception, stack: stackTrace));
    }
  }
}
