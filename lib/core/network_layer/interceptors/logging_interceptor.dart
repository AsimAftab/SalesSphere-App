import 'dart:convert';
import 'package:dio/dio.dart';
import '../../utils/logger.dart';

/// Logging Interceptor
/// Logs all HTTP requests, responses, and errors for debugging
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.i('╔══════════════════════════════════════════════════════════════');
    AppLogger.i('║ 📤 REQUEST');
    AppLogger.i('╠══════════════════════════════════════════════════════════════');
    AppLogger.i('║ Method: ${options.method}');
    AppLogger.i('║ URL: ${options.uri}');
    AppLogger.i('║ Headers:');
    options.headers.forEach((key, value) {
      // Hide sensitive headers
      if (key.toLowerCase() == 'authorization') {
        AppLogger.i('║   $key: Bearer ***');
      } else {
        AppLogger.i('║   $key: $value');
      }
    });

    if (options.queryParameters.isNotEmpty) {
      AppLogger.i('║ Query Parameters:');
      options.queryParameters.forEach((key, value) {
        AppLogger.i('║   $key: $value');
      });
    }

    if (options.data != null) {
      AppLogger.i('║ Body:');
      try {
        final prettyJson = _prettyPrintJson(options.data);
        prettyJson.split('\n').forEach((line) {
          AppLogger.i('║   $line');
        });
      } catch (e) {
        AppLogger.i('║   ${options.data}');
      }
    }

    AppLogger.i('╚══════════════════════════════════════════════════════════════');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.i('╔══════════════════════════════════════════════════════════════');
    AppLogger.i('║ 📥 RESPONSE');
    AppLogger.i('╠══════════════════════════════════════════════════════════════');
    AppLogger.i('║ Status Code: ${response.statusCode} ${response.statusMessage}');
    AppLogger.i('║ URL: ${response.requestOptions.uri}');

    if (response.headers.map.isNotEmpty) {
      AppLogger.i('║ Headers:');
      response.headers.map.forEach((key, value) {
        AppLogger.i('║   $key: ${value.join(', ')}');
      });
    }

    if (response.data != null) {
      AppLogger.i('║ Body:');
      try {
        final prettyJson = _prettyPrintJson(response.data);
        final lines = prettyJson.split('\n');

        // Limit response logging to first 50 lines to avoid console spam
        final maxLines = 50;
        if (lines.length > maxLines) {
          lines.take(maxLines).forEach((line) {
            AppLogger.i('║   $line');
          });
          AppLogger.i('║   ... (${lines.length - maxLines} more lines)');
        } else {
          lines.forEach((line) {
            AppLogger.i('║   $line');
          });
        }
      } catch (e) {
        AppLogger.i('║   ${response.data}');
      }
    }

    AppLogger.i('╚══════════════════════════════════════════════════════════════');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.e('╔══════════════════════════════════════════════════════════════');
    AppLogger.e('║ ❌ ERROR');
    AppLogger.e('╠══════════════════════════════════════════════════════════════');
    AppLogger.e('║ Type: ${err.type}');
    AppLogger.e('║ Message: ${err.message}');
    AppLogger.e('║ URL: ${err.requestOptions.uri}');

    if (err.response != null) {
      AppLogger.e('║ Status Code: ${err.response?.statusCode}');
      AppLogger.e('║ Status Message: ${err.response?.statusMessage}');

      if (err.response?.data != null) {
        AppLogger.e('║ Error Data:');
        try {
          final prettyJson = _prettyPrintJson(err.response?.data);
          prettyJson.split('\n').forEach((line) {
            AppLogger.e('║   $line');
          });
        } catch (e) {
          AppLogger.e('║   ${err.response?.data}');
        }
      }
    }

    if (err.stackTrace != null) {
      AppLogger.e('║ Stack Trace:');
      final stackLines = err.stackTrace.toString().split('\n').take(5);
      stackLines.forEach((line) {
        AppLogger.e('║   $line');
      });
    }

    AppLogger.e('╚══════════════════════════════════════════════════════════════');

    handler.next(err);
  }

  /// Pretty print JSON for better readability
  String _prettyPrintJson(dynamic data) {
    try {
      if (data is String) {
        // Try to parse string as JSON
        try {
          final decoded = jsonDecode(data);
          return const JsonEncoder.withIndent('  ').convert(decoded);
        } catch (e) {
          return data;
        }
      } else if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      } else {
        return data.toString();
      }
    } catch (e) {
      return data.toString();
    }
  }
}
