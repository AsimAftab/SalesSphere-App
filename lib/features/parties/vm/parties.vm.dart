import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/parties/models/parties.model.dart';
import 'package:sales_sphere/features/parties/vm/edit_party.vm.dart';

part 'parties.vm.g.dart';

// Search query provider
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

// Provider for searched/filtered parties
@riverpod
Future<List<PartyListItem>> searchedParties(Ref ref) async {
  final searchQuery = ref.watch(searchQueryProvider);
  final allParties = await ref.watch(partyViewModelProvider.future);
  final listItems = allParties
      .map((party) => PartyListItem.fromPartyDetails(party))
      .toList();

  if (searchQuery.isEmpty) return listItems;

  final lowerQuery = searchQuery.toLowerCase();
  return listItems.where((party) {
    return party.name.toLowerCase().contains(lowerQuery) ||
        party.ownerName.toLowerCase().contains(lowerQuery) ||
        (party.phoneNumber ?? '').contains(searchQuery) ||
        party.fullAddress.toLowerCase().contains(lowerQuery);
  }).toList();
}

// Provider to get total party count
@riverpod
int partyCount(Ref ref) {
  final partiesAsync = ref.watch(partyViewModelProvider);

  return partiesAsync.when(
    data: (parties) => parties.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

// Provider to get active party count
@riverpod
int activePartyCount(Ref ref) {
  final partiesAsync = ref.watch(partyViewModelProvider);

  return partiesAsync.when(
    data: (parties) => parties.where((p) => p.isActive).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}