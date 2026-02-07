import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/network_exceptions.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/collection/models/collection.model.dart';
import 'package:sales_sphere/features/collection/vm/collection.vm.dart';

part 'edit_collection.vm.g.dart';

@riverpod
class EditCollectionViewModel extends _$EditCollectionViewModel {
  @override
  FutureOr<void> build() => null;

  /// Fetch collection details by ID
  Future<CollectionDetailApiData> fetchCollectionDetails(
    String collectionId,
  ) async {
    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiEndpoints.collectionById(collectionId));

      final apiResponse = CollectionDetailApiResponse.fromJson(response.data);

      if (apiResponse.success) {
        AppLogger.i('Fetched collection details: ${apiResponse.data.id}');
        return apiResponse.data;
      } else {
        throw Exception('Failed to fetch collection details');
      }
    } on DioException catch (e) {
      AppLogger.e('Failed to fetch collection details', e);
      if (e.error is NetworkException) {
        throw Exception((e.error as NetworkException).userFriendlyMessage);
      }
      throw Exception('Failed to fetch collection details');
    }
  }

  /// Update collection via PUT
  Future<CollectionDetailApiData> updateCollection({
    required String collectionId,
    required double amountReceived,
    required String receivedDate,
    required String paymentMethod,
    String? bankName,
    String? chequeNumber,
    String? chequeDate,
    String? chequeStatus,
    String? description,
    List<String>? images,
  }) async {
    state = const AsyncLoading();

    try {
      final dio = ref.read(dioClientProvider);

      final request = UpdateCollectionRequest(
        amountReceived: amountReceived,
        receivedDate: receivedDate,
        paymentMethod: paymentMethod,
        bankName: bankName,
        chequeNumber: chequeNumber,
        chequeDate: chequeDate,
        chequeStatus: chequeStatus,
        description: description,
        images: images,
      );

      final response = await dio.put(
        ApiEndpoints.updateCollection(collectionId),
        data: request.toJson(),
      );

      final apiResponse = CollectionDetailApiResponse.fromJson(response.data);

      if (apiResponse.success) {
        AppLogger.i('Collection updated successfully: ${apiResponse.data.id}');
        if (ref.mounted) {
          state = const AsyncData(null);
        }
        // Update main list locally
        _updateMainList(apiResponse.data);
        return apiResponse.data;
      } else {
        final errorMsg = 'Failed to update collection';
        if (ref.mounted) {
          state = AsyncError(errorMsg, StackTrace.current);
        }
        throw Exception(errorMsg);
      }
    } on DioException catch (e, stack) {
      AppLogger.e('Failed to update collection', e, stack);

      String errorMessage = 'Failed to update collection';
      if (e.error is NetworkException) {
        final error = e.error as NetworkException;
        errorMessage = error.userFriendlyMessage;
      }

      if (ref.mounted) {
        state = AsyncError(errorMessage, stack);
      }
      throw Exception(errorMessage);
    } catch (e, stack) {
      AppLogger.e('Unexpected error updating collection', e, stack);
      if (ref.mounted) {
        state = AsyncError(e.toString(), stack);
      }
      rethrow;
    }
  }

  /// Update the main collection list with updated data
  void _updateMainList(CollectionDetailApiData data) {
    // Check if provider is still mounted before updating
    if (!ref.mounted) return;

    // Convert CollectionDetailApiData to CollectionListItem
    final listItem = CollectionListItem(
      id: data.id,
      partyId: data.party.id,
      partyName: data.party.partyName,
      ownerName: data.party.ownerName,
      amount: data.amountReceived,
      date: data.receivedDate,
      paymentMode: _mapPaymentMethodToLabel(data.paymentMethod),
      remarks: data.description,
      imagePaths: data.images,
      bankName: data.bankName,
      chequeNumber: data.chequeNumber,
      chequeDate: data.chequeDate,
      chequeStatus: data.chequeStatus,
    );

    ref
        .read(collectionViewModelProvider.notifier)
        .updateCollectionLocally(listItem);
  }

  /// Maps API payment method values to UI display labels
  String _mapPaymentMethodToLabel(String apiValue) {
    switch (apiValue) {
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'cash':
        return 'Cash';
      case 'cheque':
        return 'Cheque';
      case 'qr':
        return 'QR Pay';
      default:
        return apiValue;
    }
  }

  /// MOCK: Upload images to collection (separate endpoint, not implemented yet)
  Future<void> uploadCollectionImages(
    String collectionId,
    List<File> images,
  ) async {
    try {
      AppLogger.i('Uploading images for collection: $collectionId');
      await Future.delayed(const Duration(milliseconds: 500));
      if (ref.mounted) AppLogger.i('Image upload complete');
    } catch (e) {
      AppLogger.e('Image upload error: $e');
      rethrow;
    }
  }
}
