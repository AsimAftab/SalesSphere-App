import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/network_exceptions.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/collection/models/collection.model.dart';

part 'collection.vm.g.dart';

@riverpod
class CollectionViewModel extends _$CollectionViewModel {
  List<CollectionListItem> _allCollections = [];

  @override
  FutureOr<List<CollectionListItem>> build() async {
    return _fetchCollections();
  }

  Future<List<CollectionListItem>> _fetchCollections() async {
    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiEndpoints.myCollections);

      final apiResponse = CollectionApiResponse.fromJson(response.data);

      if (apiResponse.success) {
        AppLogger.i('Fetched ${apiResponse.count} collections');
        _allCollections = apiResponse.data
            .map((e) => CollectionListItem.fromApiData(e))
            .toList();
        return _allCollections;
      } else {
        throw Exception('Failed to fetch collections');
      }
    } on DioException catch (e) {
      AppLogger.e('Failed to fetch collections', e);
      if (e.error is NetworkException) {
        throw Exception((e.error as NetworkException).userFriendlyMessage);
      }
      throw Exception('Failed to fetch collections');
    }
  }

  void addCollectionLocally(CollectionListItem newItem) {
    _allCollections = [newItem, ..._allCollections];
    state = AsyncValue.data(List.from(_allCollections));
    AppLogger.i('Collection added locally');
  }

  /// Update collection locally from edit screen
  void updateCollectionLocally(CollectionListItem updatedItem) {
    final index = _allCollections.indexWhere(
      (item) => item.id == updatedItem.id,
    );
    if (index != -1) {
      _allCollections[index] = updatedItem;
      state = AsyncValue.data(List.from(_allCollections));
      AppLogger.i('Collection updated locally for ID: ${updatedItem.id}');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final collections = await _fetchCollections();
      state = AsyncValue.data(collections);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
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

  return allCollections
      .where(
        (c) =>
            c.partyName.toLowerCase().contains(query) ||
            c.paymentMode.toLowerCase().contains(query) ||
            (c.remarks?.toLowerCase().contains(query) ?? false),
      )
      .toList();
}
