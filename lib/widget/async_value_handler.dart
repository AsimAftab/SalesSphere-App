import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_sphere/core/network_layer/network_exceptions.dart';
import 'package:sales_sphere/widget/permission_denied_widget.dart';

/// Global AsyncValue handler that automatically shows permission denied screen
/// for 403 errors across all features
class AsyncValueHandler<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace stackTrace)? error;
  final String? featureName;
  final VoidCallback? onRetry;

  const AsyncValueHandler({
    super.key,
    required this.asyncValue,
    required this.data,
    this.loading,
    this.error,
    this.featureName,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: data,
      loading: loading ?? () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) {
        // Check if error is permission denied (403)
        if (_isPermissionDenied(e)) {
          final networkException = _extractNetworkException(e);
          return PermissionDeniedWidget(
            feature: featureName,
            message: networkException?.message,
            onRetry: onRetry,
          );
        }

        // Use custom error handler if provided
        if (error != null) {
          return error!(e, stack);
        }

        // Default generic error screen
        return _buildGenericError(e);
      },
    );
  }

  /// Check if error is a 403 permission denied error
  bool _isPermissionDenied(Object error) {
    // Direct NetworkException
    if (error is NetworkException && error.statusCode == 403) {
      return true;
    }

    // DioException wrapping NetworkException
    if (error is Exception) {
      final errorStr = error.toString();
      // Check if it's wrapped in DioException
      return errorStr.contains('403') || 
             errorStr.contains('Forbidden') ||
             errorStr.contains('FEATURE_ACCESS_DENIED');
    }

    return false;
  }

  /// Extract NetworkException from error
  NetworkException? _extractNetworkException(Object error) {
    if (error is NetworkException) {
      return error;
    }
    // Try to extract from wrapped exception
    return null;
  }

  /// Build generic error widget
  Widget _buildGenericError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
