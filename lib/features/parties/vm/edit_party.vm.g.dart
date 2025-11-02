// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_party.vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EditPartyViewModel)
const editPartyViewModelProvider = EditPartyViewModelProvider._();

final class EditPartyViewModelProvider
    extends $AsyncNotifierProvider<EditPartyViewModel, void> {
  const EditPartyViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editPartyViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editPartyViewModelHash();

  @$internal
  @override
  EditPartyViewModel create() => EditPartyViewModel();
}

String _$editPartyViewModelHash() =>
    r'c43d0b4b078cc191b402db3a5ee790bf4e27974a';

abstract class _$EditPartyViewModel extends $AsyncNotifier<void> {
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

@ProviderFor(partyById)
const partyByIdProvider = PartyByIdFamily._();

final class PartyByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<PartyDetails?>,
          PartyDetails?,
          FutureOr<PartyDetails?>
        >
    with $FutureModifier<PartyDetails?>, $FutureProvider<PartyDetails?> {
  const PartyByIdProvider._({
    required PartyByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'partyByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$partyByIdHash();

  @override
  String toString() {
    return r'partyByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PartyDetails?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PartyDetails?> create(Ref ref) {
    final argument = this.argument as String;
    return partyById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PartyByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$partyByIdHash() => r'7f2dccbc54b8d1c1eacab4a8eba884e371c9f673';

final class PartyByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PartyDetails?>, String> {
  const PartyByIdFamily._()
    : super(
        retry: null,
        name: r'partyByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PartyByIdProvider call(String partyId) =>
      PartyByIdProvider._(argument: partyId, from: this);

  @override
  String toString() => r'partyByIdProvider';
}
