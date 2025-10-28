// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_init_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Auth Initialization Provider
/// Checks for stored token and user data on app startup

@ProviderFor(authInit)
const authInitProvider = AuthInitProvider._();

/// Auth Initialization Provider
/// Checks for stored token and user data on app startup

final class AuthInitProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Auth Initialization Provider
  /// Checks for stored token and user data on app startup
  const AuthInitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authInitProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authInitHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return authInit(ref);
  }
}

String _$authInitHash() => r'c682795a310ba5cf1cd05164228212eb9c0b2c5d';
