// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_prospect.vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddProspectViewModel)
const addProspectViewModelProvider = AddProspectViewModelProvider._();

final class AddProspectViewModelProvider
    extends $AsyncNotifierProvider<AddProspectViewModel, void> {
  const AddProspectViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addProspectViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addProspectViewModelHash();

  @$internal
  @override
  AddProspectViewModel create() => AddProspectViewModel();
}

String _$addProspectViewModelHash() =>
    r'8b77b918af82fc41c517daf6aba89dde5dce8433';

abstract class _$AddProspectViewModel extends $AsyncNotifier<void> {
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
