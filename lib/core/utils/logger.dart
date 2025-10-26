import 'package:logger/logger.dart';

/// Global logger instance used throughout the application.
///
/// Configured with a PrettyPrinter for readable console output.
/// Can be customized further (e.g., different levels for debug/release).
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1, // Number of method calls to be displayed
    errorMethodCount: 5, // Number of method calls if stacktrace is provided
    lineLength: 120, // Width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print an emoji for each log message
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,

  ),
  // Example: Filter logs based on build mode
  // filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
  // Example: Output logs to a file in release mode
  // output: kReleaseMode ? FileOutput(...) : ConsoleOutput(),
);
class AppLogger {
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void t(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.t(message, error: error, stackTrace: stackTrace);
  }
}