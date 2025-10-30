// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_list.vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoryItemListViewModel)
const categoryItemListViewModelProvider = CategoryItemListViewModelFamily._();

final class CategoryItemListViewModelProvider
    extends
        $AsyncNotifierProvider<CategoryItemListViewModel, List<CatalogItem>> {
  const CategoryItemListViewModelProvider._({
    required CategoryItemListViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryItemListViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryItemListViewModelHash();

  @override
  String toString() {
    return r'categoryItemListViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CategoryItemListViewModel create() => CategoryItemListViewModel();

  @override
  bool operator ==(Object other) {
    return other is CategoryItemListViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryItemListViewModelHash() =>
    r'cbbda722dc5b8c2113ba3dd1893b7e5de1cace39';

final class CategoryItemListViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          CategoryItemListViewModel,
          AsyncValue<List<CatalogItem>>,
          List<CatalogItem>,
          FutureOr<List<CatalogItem>>,
          String
        > {
  const CategoryItemListViewModelFamily._()
    : super(
        retry: null,
        name: r'categoryItemListViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryItemListViewModelProvider call(String categoryId) =>
      CategoryItemListViewModelProvider._(argument: categoryId, from: this);

  @override
  String toString() => r'categoryItemListViewModelProvider';
}

abstract class _$CategoryItemListViewModel
    extends $AsyncNotifier<List<CatalogItem>> {
  late final _$args = ref.$arg as String;
  String get categoryId => _$args;

  FutureOr<List<CatalogItem>> build(String categoryId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<List<CatalogItem>>, List<CatalogItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CatalogItem>>, List<CatalogItem>>,
              AsyncValue<List<CatalogItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// --- Search Query Provider ---

@ProviderFor(ItemListSearchQuery)
const itemListSearchQueryProvider = ItemListSearchQueryProvider._();

/// --- Search Query Provider ---
final class ItemListSearchQueryProvider
    extends $NotifierProvider<ItemListSearchQuery, String> {
  /// --- Search Query Provider ---
  const ItemListSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemListSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemListSearchQueryHash();

  @$internal
  @override
  ItemListSearchQuery create() => ItemListSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$itemListSearchQueryHash() =>
    r'48d09d1104df510f9c3acd42350f450ac6b3b6da';

/// --- Search Query Provider ---

abstract class _$ItemListSearchQuery extends $Notifier<String> {
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

/// --- Filtered / Searched Items Provider ---

@ProviderFor(searchedCategoryItems)
const searchedCategoryItemsProvider = SearchedCategoryItemsFamily._();

/// --- Filtered / Searched Items Provider ---

final class SearchedCategoryItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CatalogItem>>,
          List<CatalogItem>,
          FutureOr<List<CatalogItem>>
        >
    with
        $FutureModifier<List<CatalogItem>>,
        $FutureProvider<List<CatalogItem>> {
  /// --- Filtered / Searched Items Provider ---
  const SearchedCategoryItemsProvider._({
    required SearchedCategoryItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchedCategoryItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchedCategoryItemsHash();

  @override
  String toString() {
    return r'searchedCategoryItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CatalogItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CatalogItem>> create(Ref ref) {
    final argument = this.argument as String;
    return searchedCategoryItems(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchedCategoryItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchedCategoryItemsHash() =>
    r'd7004624b1b1ff146f9ad164cb1b06fbf7d5f715';

/// --- Filtered / Searched Items Provider ---

final class SearchedCategoryItemsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CatalogItem>>, String> {
  const SearchedCategoryItemsFamily._()
    : super(
        retry: null,
        name: r'searchedCategoryItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// --- Filtered / Searched Items Provider ---

  SearchedCategoryItemsProvider call(String categoryId) =>
      SearchedCategoryItemsProvider._(argument: categoryId, from: this);

  @override
  String toString() => r'searchedCategoryItemsProvider';
}
