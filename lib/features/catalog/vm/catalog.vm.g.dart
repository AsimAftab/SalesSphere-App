// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog.vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CatalogViewModel)
const catalogViewModelProvider = CatalogViewModelProvider._();

final class CatalogViewModelProvider
    extends $AsyncNotifierProvider<CatalogViewModel, List<CatalogCategory>> {
  const CatalogViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogViewModelHash();

  @$internal
  @override
  CatalogViewModel create() => CatalogViewModel();
}

String _$catalogViewModelHash() => r'2b5180a1f23bce69cc5e57878f60f6b5c339740d';

abstract class _$CatalogViewModel
    extends $AsyncNotifier<List<CatalogCategory>> {
  FutureOr<List<CatalogCategory>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<CatalogCategory>>, List<CatalogCategory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<CatalogCategory>>,
                List<CatalogCategory>
              >,
              AsyncValue<List<CatalogCategory>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CatalogSearchQuery)
const catalogSearchQueryProvider = CatalogSearchQueryProvider._();

final class CatalogSearchQueryProvider
    extends $NotifierProvider<CatalogSearchQuery, String> {
  const CatalogSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogSearchQueryHash();

  @$internal
  @override
  CatalogSearchQuery create() => CatalogSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$catalogSearchQueryHash() =>
    r'fbe6655aba412cbda953356b77e26739ca7ea78e';

abstract class _$CatalogSearchQuery extends $Notifier<String> {
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

@ProviderFor(searchedCategories)
const searchedCategoriesProvider = SearchedCategoriesProvider._();

final class SearchedCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CatalogCategory>>,
          List<CatalogCategory>,
          FutureOr<List<CatalogCategory>>
        >
    with
        $FutureModifier<List<CatalogCategory>>,
        $FutureProvider<List<CatalogCategory>> {
  const SearchedCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchedCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchedCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<CatalogCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CatalogCategory>> create(Ref ref) {
    return searchedCategories(ref);
  }
}

String _$searchedCategoriesHash() =>
    r'bcc6da5159489086fb3327493fb0ccfa590b5432';
