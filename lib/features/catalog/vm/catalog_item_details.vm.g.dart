// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_item_details.vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(catalogItemDetails)
const catalogItemDetailsProvider = CatalogItemDetailsFamily._();

final class CatalogItemDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<CatalogItemDetails>,
          CatalogItemDetails,
          FutureOr<CatalogItemDetails>
        >
    with
        $FutureModifier<CatalogItemDetails>,
        $FutureProvider<CatalogItemDetails> {
  const CatalogItemDetailsProvider._({
    required CatalogItemDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'catalogItemDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$catalogItemDetailsHash();

  @override
  String toString() {
    return r'catalogItemDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CatalogItemDetails> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CatalogItemDetails> create(Ref ref) {
    final argument = this.argument as String;
    return catalogItemDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogItemDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$catalogItemDetailsHash() =>
    r'763271238a257b7a2b34b894d28e17feabf2f237';

final class CatalogItemDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CatalogItemDetails>, String> {
  const CatalogItemDetailsFamily._()
    : super(
        retry: null,
        name: r'catalogItemDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CatalogItemDetailsProvider call(String itemId) =>
      CatalogItemDetailsProvider._(argument: itemId, from: this);

  @override
  String toString() => r'catalogItemDetailsProvider';
}
