import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/network_exceptions.dart';
import 'package:sales_sphere/core/utils/logger.dart';
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
      final dio = ref.read(dioClientProvider);
      AppLogger.i('🚀 Submitting Collection to API');

      // Prepare request body according to API schema
      final requestBody = {
        'party': data['party'],
        'amountReceived': data['amount'],
        'receivedDate': data['date'],
        'description': data['description'],
        'paymentMethod': data['paymentMode'],
        if (data['bankName'] != null) 'bankName': data['bankName'],
        if (data['chequeNumber'] != null) 'chequeNumber': data['chequeNumber'],
        if (data['chequeDate'] != null) 'chequeDate': data['chequeDate'],
        if (data['chequeStatus'] != null) 'chequeStatus': data['chequeStatus'],
      };

      AppLogger.d('Collection request body: $requestBody');

      final response = await dio.post(
        ApiEndpoints.createCollection,
        data: requestBody,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        AppLogger.i('✅ Collection created successfully');
        final responseData = response.data['data'];
        final collectionId = responseData['_id'] as String;

        // Upload images if provided
        if (images != null && images.isNotEmpty) {
          await uploadCollectionImages(collectionId, images);
        }

        // Invalidate collections list to refresh
        ref.invalidate(collectionViewModelProvider);

        return collectionId;
      } else {
        throw Exception(
          'Failed to create collection: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error creating collection', e);
      if (e.error is NetworkException) {
        throw Exception((e.error as NetworkException).userFriendlyMessage);
      }
      throw Exception('Failed to create collection: ${e.message}');
    } catch (e) {
      AppLogger.e('❌ Error creating collection: $e');
      rethrow;
    }
  }

  Future<void> uploadCollectionImages(
    String collectionId,
    List<String> imagePaths,
  ) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i(
        '📸 Uploading ${imagePaths.length} image(s) for collection: $collectionId',
      );

      for (int i = 0; i < imagePaths.length && i < 2; i++) {
        final imageFile = File(imagePaths[i]);
        final imageNumber = i + 1;

        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: 'collection_image_$imageNumber.jpg',
          ),
          'imageNumber': imageNumber,
        });

        AppLogger.d('Uploading image $imageNumber');

        final response = await dio.post(
          ApiEndpoints.uploadCollectionImage(collectionId),
          data: formData,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          AppLogger.i('✅ Image $imageNumber uploaded successfully');
        } else {
          AppLogger.w(
            '⚠️ Failed to upload image $imageNumber: ${response.statusMessage}',
          );
        }
      }

      AppLogger.i('✅ All collection images uploaded');
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error uploading collection images', e);
      if (e.error is NetworkException) {
        throw Exception((e.error as NetworkException).userFriendlyMessage);
      }
      throw Exception('Failed to upload images: ${e.message}');
    } catch (e) {
      AppLogger.e('❌ Error uploading collection images: $e');
      rethrow;
    } finally {
      if (ref.mounted) _closeLink();
    }
  }
}
