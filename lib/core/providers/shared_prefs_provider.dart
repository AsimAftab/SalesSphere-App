import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_prefs_provider.g.dart';

@riverpod
SharedPreferences sharedPrefs(Ref ref) {
  // This provider is designed to be overridden in main.dart
  // It will throw an error if not overridden.
  throw UnimplementedError(
    'sharedPrefsProvider was not overridden. '
        'Ensure you are overriding it in your ProviderScope in main.dart',
  );
}