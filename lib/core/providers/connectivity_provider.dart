import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'connectivity_provider.g.dart';

/// Connectivity Stream Provider
/// Listens to real-time connectivity changes
@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connectivity(ref) {
  final connectivityService = Connectivity();

  // Listen to connectivity changes
  return connectivityService.onConnectivityChanged.map((results) {
    // Log connectivity changes
    if (results.contains(ConnectivityResult.none)) {
      AppLogger.w('📡 No internet connection');
    } else if (results.contains(ConnectivityResult.wifi)) {
      AppLogger.i('📡 Connected via WiFi');
    } else if (results.contains(ConnectivityResult.mobile)) {
      AppLogger.i('📡 Connected via Mobile Data');
    } else if (results.contains(ConnectivityResult.ethernet)) {
      AppLogger.i('📡 Connected via Ethernet');
    }

    return results;
  });
}

/// Check if device has internet connectivity
/// Returns true if connected (wifi, mobile, ethernet, etc.)
@riverpod
class HasConnectivity extends _$HasConnectivity {
  @override
  bool build() {
    final connectivityAsync = ref.watch(connectivityProvider);

    return connectivityAsync.when(
      data: (results) => !results.contains(ConnectivityResult.none),
      loading: () => true, // Assume connected while checking
      error: (_, __) => true, // Assume connected on error
    );
  }
}

/// One-time connectivity check
/// Use this for initial app startup validation
@riverpod
Future<bool> checkInitialConnectivity(ref) async {
  try {
    final connectivityService = Connectivity();
    final results = await connectivityService.checkConnectivity();

    final isConnected = !results.contains(ConnectivityResult.none);

    if (isConnected) {
      AppLogger.i('✅ Initial connectivity check: Connected');
    } else {
      AppLogger.w('⚠️ Initial connectivity check: No connection');
    }

    return isConnected;
  } catch (e) {
    AppLogger.e('❌ Failed to check connectivity', e);
    // Return true on error to allow app to proceed
    return true;
  }
}
