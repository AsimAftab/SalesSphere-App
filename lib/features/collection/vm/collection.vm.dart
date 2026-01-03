import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import 'package:sales_sphere/features/collection/models/collection.model.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'collection.vm.g.dart';

@Riverpod(keepAlive: true)
class CollectionViewModel extends _$CollectionViewModel {
  List<CollectionListItem> _allCollections = [];

  @override
  FutureOr<List<CollectionListItem>> build() async {
    return _fetchCollections();
  }

  Future<List<CollectionListItem>> _fetchCollections() async {
    try {
      AppLogger.i('📝 Fetching collections');
      await Future.delayed(const Duration(milliseconds: 800));

      final mockData = [
        const CollectionApiData(
            id: '1',
            partyName: 'Party A',
            amount: 15000,
            collectionDate: '2024-12-28',
            paymentMode: 'Cash',
            remarks: 'Client Meeting Follow-up - Discussed new project requirements and timeline.'
        ),
        const CollectionApiData(
            id: '2',
            partyName: 'Party 2',
            amount: 8500,
            collectionDate: '2024-12-27',
            paymentMode: 'QR Pay',
            remarks: 'Product Feedback - Customer satisfied with service quality.'
        ),
        const CollectionApiData(
            id: '3',
            partyName: 'Party B',
            amount: 22000,
            collectionDate: '2024-12-26',
            paymentMode: 'Bank Transfer',
            remarks: 'Service Issue Report - Resolved technical issue with prompt support.'
        ),
        const CollectionApiData(
            id: '4',
            partyName: 'Party 4',
            amount: 5200,
            collectionDate: '2024-12-26',
            paymentMode: 'Cheque',
            remarks: 'Initial Contact - Prospective client interested in our services.'
        ),
      ];

      _allCollections = mockData.map((e) => CollectionListItem.fromApiData(e)).toList();
      return _allCollections;
    } catch (e) {
      AppLogger.e('❌ Error fetching collections: $e');
      rethrow;
    }
  }

  void addCollectionLocally(CollectionListItem newItem) {
    _allCollections = [newItem, ..._allCollections];
    state = AsyncValue.data(List.from(_allCollections));
    AppLogger.i('✅ Collection added locally');
  }

  /// FIXED: Added to handle updates from the Edit Screen locally
  void updateCollectionLocally(CollectionListItem updatedItem) {
    final index = _allCollections.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _allCollections[index] = updatedItem;
      state = AsyncValue.data(List.from(_allCollections));
      AppLogger.i('✅ Collection updated locally for ID: ${updatedItem.id}');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchCollections);
  }
}

@riverpod
class CollectionSearchQuery extends _$CollectionSearchQuery {
  @override
  String build() => '';
  void updateQuery(String query) => state = query;
}

@riverpod
Future<List<CollectionListItem>> searchedCollections(Ref ref) async {
  final query = ref.watch(collectionSearchQueryProvider).toLowerCase();
  final allCollections = await ref.watch(collectionViewModelProvider.future);

  if (query.isEmpty) return allCollections;

  return allCollections.where((c) =>
  c.partyName.toLowerCase().contains(query) ||
      c.paymentMode.toLowerCase().contains(query) ||
      (c.remarks?.toLowerCase().contains(query) ?? false)
  ).toList();
}