import 'dart:io';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'expense_claim_add.vm.g.dart';

@riverpod
class ExpenseClaimAddViewModel extends _$ExpenseClaimAddViewModel {
  // Use Object? to hold the keepAlive link
  Object? _link;

  @override
  void build() {
    ref.onDispose(() {
      _closeLink();
      AppLogger.d('🧹 ExpenseClaimAddViewModel disposed');
    });
  }

  void _keepAlive() {
    _link ??= ref.keepAlive();
  }

  void _closeLink() {
    if (_link != null) {
      (_link as dynamic).close();
      _link = null;
    }
  }

  /// Create Expense Claim
  Future<String> createExpenseClaim({
    required String title,
    required double amount,
    required String category,
    required String incurredDate,
    String? partyId,
    String? description,
  }) async {
    _keepAlive();

    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('📝 Creating expense claim: $title');

      final requestBody = {
        'title': title,
        'amount': amount,
        'incurredDate': incurredDate,
        'category': category,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        if (partyId != null) 'party': partyId,
      };

      final response = await dio.post(
        ApiEndpoints.createExpenseClaim,
        data: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('✅ Expense claim created successfully');
        // Handle variations in API response structure
        final data = response.data;
        if (data is Map && data.containsKey('data')) {
          return data['data']['_id'] as String;
        }
        throw Exception('Invalid API response format');
      } else {
        throw Exception('Failed to submit claim: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error creating expense claim: ${e.message}');
      throw Exception(_handleDioError(e));
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error creating expense claim: $e');
      AppLogger.e('Stack trace: $stackTrace');
      rethrow;
    } finally {
      // If we are NOT uploading an image next (logic handled in UI),
      // strict clean up happens on dispose, but we can't close link here
      // because the UI might call uploadReceipt immediately after.
    }
  }

  /// Upload receipt image to expense claim
  Future<String> uploadReceipt({
    required String claimId,
    required File imageFile,
  }) async {
    // Ensure link is alive (in case this is called independently)
    _keepAlive();

    try {
      AppLogger.i('📸 Uploading receipt image for claim: $claimId');

      final dio = ref.read(dioClientProvider);

      // Fix: robust filename extraction
      String fileName = imageFile.path.split('/').last;

      final formData = FormData.fromMap({
        'receipt': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        ApiEndpoints.uploadExpenseClaimReceipt(claimId),
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('✅ Receipt image uploaded successfully');
        final data = response.data;
        if (data is Map && data.containsKey('data')) {
          return data['data']['receipt'] ?? '';
        }
        return '';
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
      // Release the link now that the entire flow is done
      _closeLink();
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Check internet connection.';
      case DioExceptionType.badResponse:
        // Optimization: Safe parsing of response data
        final data = e.response?.data;
        if (data != null && data is Map && data.containsKey('message')) {
          return data['message'];
        }
        return e.response?.statusMessage ?? 'Request failed';
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
