import 'dart:io';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'expense_claim_edit.vm.g.dart';

// ============================================================================
// EXPENSE CLAIM EDIT VIEW MODEL
// Handles: Update expense claim with optional image
// Uses Riverpod 3.0 best practices with auto-dispose and ref.mounted checks
// ============================================================================

@riverpod
class ExpenseClaimEditViewModel extends _$ExpenseClaimEditViewModel {
  Object? _link;

  @override
  void build() {
    ref.onDispose(() {
      if (_link != null) {
        (_link as dynamic).close();
      }
      AppLogger.d('🧹 ExpenseClaimEditViewModel disposed');
    });
  }

  /// Keep provider alive for multi-step operations
  void _keepAlive() {
    _link ??= ref.keepAlive();
  }

  /// Release the keep alive after operations complete
  void _release() {
    if (_link != null) {
      (_link as dynamic).close();
      _link = null;
    }
  }

  /// Update Expense Claim
  Future<void> updateExpenseClaim({
    required String claimId,
    required String title,
    required double amount,
    required String category,
    required String date,
    String? partyId,
    String? description,
  }) async {
    _keepAlive();

    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('📝 Updating expense claim: $claimId');

      // Build request body
      final requestBody = {
        'title': title,
        'amount': amount,
        'claimType': category,
        'date': date,
        if (partyId != null) 'partyId': partyId,
        if (description != null && description.isNotEmpty)
          'description': description,
      };

      // Send PUT request
      final response = await dio.put(
        ApiEndpoints.updateExpenseClaim(claimId),
        data: requestBody,
      );

      if (response.statusCode == 200) {
        AppLogger.i('✅ Expense claim updated successfully');
        _release();
      } else {
        _release();
        throw Exception('Failed to update claim: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _release();
      AppLogger.e('❌ Dio error updating expense claim: ${e.message}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      _release();
      AppLogger.e('❌ Error updating expense claim: $e');
      AppLogger.e('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Upload or replace receipt image
  Future<void> uploadImage({
    required String claimId,
    required File imageFile,
  }) async {
    try {
      AppLogger.i('📸 Uploading receipt image for claim: $claimId');

      final dio = ref.read(dioClientProvider);

      // Create multipart form data
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      // Upload to endpoint
      final response = await dio.post(
        '${ApiEndpoints.expenseClaimById(claimId)}/upload-image',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('✅ Receipt image uploaded successfully');
      } else {
        throw Exception('Failed to upload image: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error uploading image: ${e.message}');
      throw Exception(_handleDioError(e));
    } catch (e) {
      AppLogger.e('❌ Error uploading image: $e');
      rethrow;
    } finally {
      _release();
    }
  }

  /// Delete receipt image
  Future<void> deleteImage({
    required String claimId,
  }) async {
    try {
      AppLogger.i('🗑️ Deleting receipt image for claim: $claimId');

      final dio = ref.read(dioClientProvider);

      final response = await dio.delete(
        '${ApiEndpoints.expenseClaimById(claimId)}/delete-image',
      );

      if (response.statusCode == 200) {
        AppLogger.i('✅ Receipt image deleted successfully');
      } else {
        throw Exception('Failed to delete image: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error deleting image: ${e.message}');
      throw Exception(_handleDioError(e));
    } catch (e) {
      AppLogger.e('❌ Error deleting image: $e');
      rethrow;
    }
  }

  /// Handle Dio errors with user-friendly messages
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) {
          return e.response?.data['message'] ?? 'Invalid request data';
        } else if (statusCode == 401) {
          return 'Session expired. Please login again.';
        } else if (statusCode == 404) {
          return 'Expense claim not found';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return e.response?.data['message'] ?? 'Request failed';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return 'No internet connection';
        }
        return 'An unexpected error occurred';
      default:
        return 'Network error occurred';
    }
  }
}
