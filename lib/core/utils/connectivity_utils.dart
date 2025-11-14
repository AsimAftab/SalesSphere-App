import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_sphere/core/providers/connectivity_provider.dart';
import 'package:sales_sphere/widget/no_internet_screen.dart';

/// Connectivity Utilities
/// Global connectivity management and helpers

/// Global Connectivity Wrapper
/// Shows NoInternetScreen overlay when offline on ALL pages
/// Auto-invalidates all providers when connectivity returns
class GlobalConnectivityWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final void Function(WidgetRef ref) onConnectivityRestored;

  const GlobalConnectivityWrapper({
    super.key,
    required this.child,
    required this.onConnectivityRestored,
  });

  @override
  ConsumerState<GlobalConnectivityWrapper> createState() =>
      _GlobalConnectivityWrapperState();
}

class _GlobalConnectivityWrapperState
    extends ConsumerState<GlobalConnectivityWrapper> {
  bool _wasOffline = false;

  @override
  Widget build(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return connectivityAsync.when(
      data: (results) {
        final isOffline = results.contains(ConnectivityResult.none);

        // Detect offline → online transition
        if (_wasOffline && !isOffline) {
          // Connectivity restored - invalidate ALL providers
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onConnectivityRestored(ref);
          });
        }

        _wasOffline = isOffline;

        // Show full-screen NoInternetScreen when offline
        if (isOffline) {
          return NoInternetScreen(
            onRetry: () {
              // Manual retry - check connectivity again
              ref.invalidate(connectivityProvider);
            },
          );
        }

        // Online - show normal app
        return widget.child;
      },
      loading: () => widget.child, // Show app while checking
      error: (_, __) => widget.child, // Show app on error
    );
  }
}
