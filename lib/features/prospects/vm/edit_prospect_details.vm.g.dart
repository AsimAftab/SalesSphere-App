// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_prospect_details.vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(prospectById)
const prospectByIdProvider = ProspectByIdFamily._();

final class ProspectByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProspectDetails?>,
          ProspectDetails?,
          FutureOr<ProspectDetails?>
        >
    with $FutureModifier<ProspectDetails?>, $FutureProvider<ProspectDetails?> {
  const ProspectByIdProvider._({
    required ProspectByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'prospectByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$prospectByIdHash();

  @override
  String toString() {
    return r'prospectByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ProspectDetails?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProspectDetails?> create(Ref ref) {
    final argument = this.argument as String;
    return prospectById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProspectByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$prospectByIdHash() => r'395691dc51f1f4d72d8873a2183f2735eab8dd0f';

final class ProspectByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ProspectDetails?>, String> {
  const ProspectByIdFamily._()
    : super(
        retry: null,
        name: r'prospectByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProspectByIdProvider call(String prospectId) =>
      ProspectByIdProvider._(argument: prospectId, from: this);

  @override
  String toString() => r'prospectByIdProvider';
}
