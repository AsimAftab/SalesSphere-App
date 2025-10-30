// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_new_party.vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddPartyViewModel)
const addPartyViewModelProvider = AddPartyViewModelProvider._();

final class AddPartyViewModelProvider
    extends $AsyncNotifierProvider<AddPartyViewModel, AddPartyResponse?> {
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

String _$addPartyViewModelHash() => r'94cb74cf87ce0e0ac85902c629d165acd5bb4ca3';

abstract class _$AddPartyViewModel extends $AsyncNotifier<AddPartyResponse?> {
  FutureOr<AddPartyResponse?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<AddPartyResponse?>, AddPartyResponse?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AddPartyResponse?>, AddPartyResponse?>,
              AsyncValue<AddPartyResponse?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
