import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/collection/models/collection.model.dart';
import 'package:sales_sphere/features/collection/vm/collection.vm.dart';

part 'edit_collection.vm.g.dart';

@riverpod
class EditCollectionViewModel extends _$EditCollectionViewModel {
  Object? _link;

  @override
  void build() {
    ref.onDispose(() => _release());
  }

  void _keepAlive() => _link ??= ref.keepAlive();

  void _release() {
    if (_link != null) {
      (_link as dynamic).close();
      _link = null;
    }
  }

  /// MOCK IMPLEMENTATION: Simulates updating collection to bypass API errors
  Future<void> updateCollection({
    required String collectionId,
    required Map<String, dynamic> data,
  }) async {
    _keepAlive();
    try {
      AppLogger.i('🚀 MOCK: Updating collection: $collectionId');

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      if (!ref.mounted) return;

      // Create the updated object
      final updatedItem = CollectionListItem(
        id: collectionId,
        partyName: data['party'] ?? 'Updated Party',
        amount: data['amount'] as double,
        date: data['date'] ?? DateTime.now().toString(),
        paymentMode: data['paymentMode'] ?? 'Cash',
        remarks: data['description'],
      );

      // Push change to the main list provider
      ref.read(collectionViewModelProvider.notifier).updateCollectionLocally(updatedItem);

      AppLogger.i('✅ MOCK: Update successful in local state');
    } catch (e) {
      AppLogger.e('❌ MOCK Update Error: $e');
      rethrow;
    } finally {
      _release();
    }
  }

  /// MOCK IMPLEMENTATION: Simulates image update
  Future<void> uploadCollectionImages(String collectionId, List<File> images) async {
    try {
      AppLogger.i('📸 MOCK: Simulating image replacement for: $collectionId');
      await Future.delayed(const Duration(milliseconds: 500));
      if (ref.mounted) AppLogger.i('✅ MOCK: Image upload complete');
    } catch (e) {
      AppLogger.e('❌ MOCK Image Error: $e');
      rethrow;
    }
  }
}