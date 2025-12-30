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
    String? title,
    double? amount,
    String? category,
    String? incurredDate,
    String? party,
    String? description,
  }) async {
    _keepAlive();

    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('📝 Updating expense claim: $claimId');

      // Build request body (any field can be updated)
      final requestBody = <String, dynamic>{};
      
      if (title != null) requestBody['title'] = title;
      if (amount != null) requestBody['amount'] = amount;
      if (category != null) requestBody['category'] = category;
      if (incurredDate != null) requestBody['incurredDate'] = incurredDate;
      if (party != null) requestBody['party'] = party;
      if (description != null && description.isNotEmpty) {
        requestBody['description'] = description;
      }

      AppLogger.d('Request body: $requestBody');

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
  Future<String> uploadReceipt({
    required String claimId,
    required File imageFile,
  }) async {
    try {
      AppLogger.i('📸 Uploading receipt image for claim: $claimId');

      final dio = ref.read(dioClientProvider);

      // Create multipart form data with key 'receipt'
      final formData = FormData.fromMap({
        'receipt': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split(Platform.pathSeparator).last,
        ),
      });

      // Upload to receipt endpoint (POST updates existing receipt)
      final response = await dio.post(
        ApiEndpoints.uploadExpenseClaimReceipt(claimId),
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('✅ Receipt image uploaded successfully');
        final receiptUrl = response.data['data']['receipt'] as String;
        return receiptUrl;
      } else {
        throw Exception('Failed to upload receipt: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error uploading receipt: ${e.message}');
      throw Exception(_handleDioError(e));
    } catch (e) {
      AppLogger.e('❌ Error uploading receipt: $e');
      rethrow;
    } finally {
      _release();
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
