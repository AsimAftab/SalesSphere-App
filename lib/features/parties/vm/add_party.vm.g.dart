// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_party.vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddPartyViewModel)
const addPartyViewModelProvider = AddPartyViewModelProvider._();

final class AddPartyViewModelProvider
    extends $AsyncNotifierProvider<AddPartyViewModel, void> {
  const AddPartyViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addPartyViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addPartyViewModelHash();

  @$internal
  @override
  AddPartyViewModel create() => AddPartyViewModel();
}

String _$addPartyViewModelHash() => r'543dd42682695cc0e78641e7d334355555fe0761';

abstract class _$AddPartyViewModel extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
