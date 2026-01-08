import 'package:strivacity_flutter/src/logging.dart';

/// NOOP logger for tests
class TestLogging implements Logging {
  @override
  void debug(String body, [Object? exception, StackTrace? stackTrace]) {}

  @override
  void error(String body, [Object? exception, StackTrace? stackTrace]) {}

  @override
  void info(String body, [Object? exception, StackTrace? stackTrace]) {}

  @override
  void warn(String body, [Object? exception, StackTrace? stackTrace]) {}
}
