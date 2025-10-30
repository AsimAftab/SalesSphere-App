// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parties.vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$searchedPartiesHash() => r'905a22c59d7ad8035362f1c27c4ad9a8aabcac1a';

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

String _$partyCountHash() => r'cf9080dec74addf9f58f50f54d87a4371afc7976';

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

String _$activePartyCountHash() => r'42f5be4250384142a858d0f6908c9af032c55a67';
