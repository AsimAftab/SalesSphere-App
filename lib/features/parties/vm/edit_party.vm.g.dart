// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_party.vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PartyViewModel)
const partyViewModelProvider = PartyViewModelProvider._();

final class PartyViewModelProvider
    extends $AsyncNotifierProvider<PartyViewModel, List<PartyDetails>> {
  const PartyViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyViewModelHash();

  @$internal
  @override
  PartyViewModel create() => PartyViewModel();
}

String _$partyViewModelHash() => r'80ea82f688e013b449c36d356f82bb63d42f54de';

abstract class _$PartyViewModel extends $AsyncNotifier<List<PartyDetails>> {
  FutureOr<List<PartyDetails>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<PartyDetails>>, List<PartyDetails>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PartyDetails>>, List<PartyDetails>>,
              AsyncValue<List<PartyDetails>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
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

String _$partyByIdHash() => r'ac45455d3fcb999b2ffd920205f5320414ee3d7c';

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
