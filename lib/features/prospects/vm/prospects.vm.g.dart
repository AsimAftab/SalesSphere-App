// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prospects.vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Main Prospects ViewModel - Manages all prospects

@ProviderFor(ProspectViewModel)
const prospectViewModelProvider = ProspectViewModelProvider._();

/// Main Prospects ViewModel - Manages all prospects
final class ProspectViewModelProvider
    extends $AsyncNotifierProvider<ProspectViewModel, List<Prospects>> {
  /// Main Prospects ViewModel - Manages all prospects
  const ProspectViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'prospectViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$prospectViewModelHash();

  @$internal
  @override
  ProspectViewModel create() => ProspectViewModel();
}

String _$prospectViewModelHash() => r'1538ca7e6adb7e6752587123d908f22890132419';

/// Main Prospects ViewModel - Manages all prospects

abstract class _$ProspectViewModel extends $AsyncNotifier<List<Prospects>> {
  FutureOr<List<Prospects>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Prospects>>, List<Prospects>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Prospects>>, List<Prospects>>,
              AsyncValue<List<Prospects>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Search Query Provider

@ProviderFor(ProspectSearchQuery)
const prospectSearchQueryProvider = ProspectSearchQueryProvider._();

/// Search Query Provider
final class ProspectSearchQueryProvider
    extends $NotifierProvider<ProspectSearchQuery, String> {
  /// Search Query Provider
  const ProspectSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'prospectSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$prospectSearchQueryHash();

  @$internal
  @override
  ProspectSearchQuery create() => ProspectSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$prospectSearchQueryHash() =>
    r'f6b4ea1b70da6359e4ffe2ad38dda6513e518b96';

/// Search Query Provider

abstract class _$ProspectSearchQuery extends $Notifier<String> {
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

/// Provider for Searched/Filtered Prospects

@ProviderFor(SearchedProspects)
const searchedProspectsProvider = SearchedProspectsProvider._();

/// Provider for Searched/Filtered Prospects
final class SearchedProspectsProvider
    extends $AsyncNotifierProvider<SearchedProspects, List<Prospects>> {
  /// Provider for Searched/Filtered Prospects
  const SearchedProspectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchedProspectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchedProspectsHash();

  @$internal
  @override
  SearchedProspects create() => SearchedProspects();
}

String _$searchedProspectsHash() => r'83ad6c93384820b896faf24040814f7d166903c6';

/// Provider for Searched/Filtered Prospects

abstract class _$SearchedProspects extends $AsyncNotifier<List<Prospects>> {
  FutureOr<List<Prospects>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Prospects>>, List<Prospects>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Prospects>>, List<Prospects>>,
              AsyncValue<List<Prospects>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Prospect Count Provider

@ProviderFor(prospectCount)
const prospectCountProvider = ProspectCountProvider._();

/// Prospect Count Provider

final class ProspectCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Prospect Count Provider
  const ProspectCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'prospectCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$prospectCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return prospectCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$prospectCountHash() => r'da6327dfb7f5162f30f9ef0dec5a3a689c8d8921';
