import 'dart:convert';
import 'package:dio/dio.dart';
import '../../utils/logger.dart';

/// Colored + Unified Logging Interceptor
class LoggingInterceptor extends Interceptor {
  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _blue = '\x1B[34m';
  static const _magenta = '\x1B[35m';
  static const _cyan = '\x1B[36m';
  static const _white = '\x1B[37m';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer();

    buffer.writeln('$_cyan╔══════════════════════════════════════════════════════════════════════════════════════════╗$_reset');
    buffer.writeln('$_cyan║ 📤 REQUEST $_reset');
    buffer.writeln('$_cyan╠══════════════════════════════════════════════════════════════════════════════════════════╣$_reset');
    buffer.writeln('$_white║ ${options.method}  $_blue${options.uri}$_reset');
    buffer.writeln('$_white║ Headers:$_reset');

    options.headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization') {
        buffer.writeln('$_white║   $key: Bearer ***$_reset');
      } else {
        buffer.writeln('$_white║   $key: $value$_reset');
      }
    });

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('$_white║ Query Parameters:$_reset');
      options.queryParameters.forEach((key, value) {
        buffer.writeln('$_white║   $key: $value$_reset');
      });
    }

    if (options.data != null) {
      buffer.writeln('$_magenta║ Body:$_reset');
      final pretty = _prettyPrintJson(options.data);
      for (final line in pretty.split('\n')) {
        buffer.writeln('$_white║   $line$_reset');
      }
    }

    buffer.writeln('$_cyan╚══════════════════════════════════════════════════════════════════════════════════════════╝$_reset');

    // 🔥 Print once to keep the block together
    print(buffer.toString());

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final buffer = StringBuffer();
    final statusColor = (response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300 ? _green : _red;

    buffer.writeln('$_cyan╔══════════════════════════════════════════════════════════════════════════════════════════╗$_reset');
    buffer.writeln('$_cyan║ 📥 RESPONSE $_reset');
    buffer.writeln('$_cyan╠══════════════════════════════════════════════════════════════════════════════════════════╣$_reset');
    buffer.writeln('$_white║ ${response.requestOptions.method}  $_blue${response.requestOptions.uri}$_reset');
    buffer.writeln('$_white║ Status: $statusColor${response.statusCode} ${response.statusMessage ?? ''}$_reset');

    if (response.headers.map.isNotEmpty) {
      buffer.writeln('$_white║ Headers:$_reset');
      response.headers.map.forEach((key, value) {
        buffer.writeln('$_white║   $key: ${value.join(', ')}$_reset');
      });
    }

    if (response.data != null) {
      buffer.writeln('$_magenta║ Body:$_reset');
      final pretty = _prettyPrintJson(response.data);
      final lines = pretty.split('\n');
      final maxLines = 50;

      for (final line in lines.take(maxLines)) {
        buffer.writeln('$_white║   $line$_reset');
      }

      if (lines.length > maxLines) {
        buffer.writeln('$_yellow║   ... (${lines.length - maxLines} utilities lines)$_reset');
      }
    }

    buffer.writeln('$_cyan╚══════════════════════════════════════════════════════════════════════════════════════════╝$_reset');

    print(buffer.toString());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final buffer = StringBuffer();

    buffer.writeln('$_red╔══════════════════════════════════════════════════════════════════════════════════════════╗$_reset');
    buffer.writeln('$_red║ ❌ ERROR $_reset');
    buffer.writeln('$_red╠══════════════════════════════════════════════════════════════════════════════════════════╣$_reset');
    buffer.writeln('$_white║ Type: ${err.type}$_reset');
    buffer.writeln('$_white║ Message: ${err.message}$_reset');
    buffer.writeln('$_white║ URL: ${err.requestOptions.uri}$_reset');

    if (err.response != null) {
      buffer.writeln('$_white║ Status: ${err.response?.statusCode} ${err.response?.statusMessage ?? ''}$_reset');

      if (err.response?.data != null) {
        buffer.writeln('$_magenta║ Error Data:$_reset');
        final pretty = _prettyPrintJson(err.response?.data);
        for (final line in pretty.split('\n')) {
          buffer.writeln('$_white║   $line$_reset');
        }
      }
    }

    if (err.stackTrace != null) {
      buffer.writeln('$_yellow║ Stack Trace:$_reset');
      for (final line in err.stackTrace.toString().split('\n').take(5)) {
        buffer.writeln('$_white║   $line$_reset');
      }
    }

    buffer.writeln('$_red╚══════════════════════════════════════════════════════════════════════════════════════════╝$_reset');

    print(buffer.toString());
    handler.next(err);
  }

  /// Pretty print JSON for better readability
  String _prettyPrintJson(dynamic data) {
    try {
      if (data is String) {
        final decoded = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } else if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      } else {
        return data.toString();
      }
    } catch (_) {
      return data.toString();
    }
  }
}
