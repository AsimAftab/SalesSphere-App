// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Theme Notifier - Manages theme switching

@ProviderFor(ThemeNotifier)
const themeProvider = ThemeNotifierProvider._();

/// Theme Notifier - Manages theme switching
final class ThemeNotifierProvider
    extends $NotifierProvider<ThemeNotifier, ThemeModeOption> {
  /// Theme Notifier - Manages theme switching
  const ThemeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeNotifierHash();

  @$internal
  @override
  ThemeNotifier create() => ThemeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeModeOption value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeModeOption>(value),
    );
  }
}

String _$themeNotifierHash() => r'e01d7c6c6e0ce75734b83d00c52e4bfb8670e2c9';

/// Theme Notifier - Manages theme switching

abstract class _$ThemeNotifier extends $Notifier<ThemeModeOption> {
  ThemeModeOption build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ThemeModeOption, ThemeModeOption>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeModeOption, ThemeModeOption>,
              ThemeModeOption,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
