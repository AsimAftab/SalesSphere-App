// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parties.vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PartiesViewModel)
const partiesViewModelProvider = PartiesViewModelProvider._();

final class PartiesViewModelProvider
    extends $AsyncNotifierProvider<PartiesViewModel, List<PartyDetails>> {
  const PartiesViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partiesViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partiesViewModelHash();

  @$internal
  @override
  PartiesViewModel create() => PartiesViewModel();
}

String _$partiesViewModelHash() => r'51c52cffc9b277016da3349cbb960bce9b067097';

abstract class _$PartiesViewModel extends $AsyncNotifier<List<PartyDetails>> {
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

@ProviderFor(SearchQuery)
const searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  const SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'5cfb8bc058f64b12d9a61421526a8ea7b414d4fa';

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(searchedParties)
const searchedPartiesProvider = SearchedPartiesProvider._();

final class SearchedPartiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PartyListItem>>,
          List<PartyListItem>,
          FutureOr<List<PartyListItem>>
        >
    with
        $FutureModifier<List<PartyListItem>>,
        $FutureProvider<List<PartyListItem>> {
  const SearchedPartiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchedPartiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchedPartiesHash();

  @$internal
  @override
  $FutureProviderElement<List<PartyListItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PartyListItem>> create(Ref ref) {
    return searchedParties(ref);
  }
}

String _$searchedPartiesHash() => r'88de13b320b37140e93cc3f7bc8762f30d732382';

@ProviderFor(partyCount)
const partyCountProvider = PartyCountProvider._();

final class PartyCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  const PartyCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partyCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partyCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return partyCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$partyCountHash() => r'9e7d229b6650890b4e9ec2470daf22dd4f0b857c';

@ProviderFor(activePartyCount)
const activePartyCountProvider = ActivePartyCountProvider._();

final class ActivePartyCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  const ActivePartyCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activePartyCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activePartyCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return activePartyCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$activePartyCountHash() => r'314144fd7cfe92c7d0009324d1fcdbd5221eb9c1';
