import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/collection/models/collection.model.dart';
import 'package:sales_sphere/features/collection/vm/collection.vm.dart';

part 'add_collection.vm.g.dart';

@riverpod
class AddCollectionViewModel extends _$AddCollectionViewModel {
  Object? _link;

  @override
  void build() {
    ref.onDispose(() => _closeLink());
  }

  void _keepAlive() => _link ??= ref.keepAlive();

  void _closeLink() {
    if (_link != null) {
      (_link as dynamic).close();
      _link = null;
    }
  }

  Future<String> submitCollection({
    required Map<String, dynamic> data,
    List<String>? images,
  }) async {
    _keepAlive();
    try {
      AppLogger.i('🚀 MOCK: Submitting Collection');
      await Future.delayed(const Duration(seconds: 1));

      if (!ref.mounted) return '';

      final String mockId = DateTime.now().millisecondsSinceEpoch.toString();

      final newItem = CollectionListItem(
        id: mockId,
        partyName: data['party'] ?? 'Mock Party',
        amount: data['amount'] as double,
        date: data['date'] ?? DateTime.now().toString(),
        paymentMode: data['paymentMode'] ?? 'Cash',
        remarks: data['description'],
        imagePaths: images,
      );

      ref.read(collectionViewModelProvider.notifier).addCollectionLocally(newItem);
      return mockId;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadCollectionImages(String id, List<File> images) async {
    try {
      AppLogger.i('📸 MOCK: Uploading images for ID: $id');
      await Future.delayed(const Duration(milliseconds: 500));
      if (ref.mounted) AppLogger.i('✅ MOCK: Upload complete');
    } finally {
      if (ref.mounted) _closeLink();
    }
  }
}