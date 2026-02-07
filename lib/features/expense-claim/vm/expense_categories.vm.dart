import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/expense-claim/models/expense_claim.model.dart';

part 'expense_categories.vm.g.dart';

// ============================================================================
// EXPENSE CATEGORIES VIEW MODEL
// Fetches expense claim categories from API
// ============================================================================

@riverpod
class ExpenseCategoriesViewModel extends _$ExpenseCategoriesViewModel {
  @override
  Future<List<ExpenseCategory>> build() async {
    return fetchCategories();
  }

  /// Fetch expense categories from API
  Future<List<ExpenseCategory>> fetchCategories() async {
    try {
      AppLogger.i('📋 Fetching expense categories');

      final dio = ref.read(dioClientProvider);

      final response = await dio.get(ApiEndpoints.expenseClaimCategories);

      if (response.statusCode == 200) {
        final apiResponse = ExpenseCategoriesApiResponse.fromJson(
          response.data,
        );
        AppLogger.i('✅ Fetched ${apiResponse.count} categories');
        return apiResponse.data;
      } else {
        throw Exception(
          'Failed to fetch categories: ${response.statusMessage}',
        );
      }
    } catch (e) {
      AppLogger.e('❌ Error fetching expense categories: $e');
      rethrow;
    }
  }

  /// Refresh categories
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchCategories());
  }
}
