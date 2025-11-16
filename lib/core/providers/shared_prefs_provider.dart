import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_prefs_provider.g.dart';

/// Provides SharedPreferences instance
/// This is kept alive so SharedPreferences is initialized once and reused
@Riverpod(keepAlive: true)
SharedPreferences sharedPrefs(Ref ref) {
  throw UnimplementedError(
    'sharedPrefsProvider must be overridden with SharedPreferences.getInstance() in main.dart',
  );
}
