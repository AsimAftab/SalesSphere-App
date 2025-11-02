// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password.vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ForgotPasswordViewModel)
const forgotPasswordViewModelProvider = ForgotPasswordViewModelProvider._();

final class ForgotPasswordViewModelProvider
    extends
        $AsyncNotifierProvider<
          ForgotPasswordViewModel,
          ForgotPasswordResponse?
        > {
  const ForgotPasswordViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forgotPasswordViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forgotPasswordViewModelHash();

  @$internal
  @override
  ForgotPasswordViewModel create() => ForgotPasswordViewModel();
}

String _$forgotPasswordViewModelHash() =>
    r'78b65c47562962ae65dcc58cab38506136768c2b';

abstract class _$ForgotPasswordViewModel
    extends $AsyncNotifier<ForgotPasswordResponse?> {
  FutureOr<ForgotPasswordResponse?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ForgotPasswordResponse?>,
              ForgotPasswordResponse?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ForgotPasswordResponse?>,
                ForgotPasswordResponse?
              >,
              AsyncValue<ForgotPasswordResponse?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
