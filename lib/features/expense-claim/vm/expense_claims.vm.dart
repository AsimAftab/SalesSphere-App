
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import 'package:sales_sphere/features/expense-claim/models/expense_claim.model.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'expense_claims.vm.g.dart';

// ============================================================================
// MAIN EXPENSE CLAIMS LIST VIEW MODEL
// Handles: Fetch all expense claims, Delete, Search, Filter, Refresh
// ============================================================================

@riverpod
class ExpenseClaimsViewModel extends _$ExpenseClaimsViewModel {
  bool _isFetching = false;

  @override
  FutureOr<List<ExpenseClaimDetails>> build() async {
    final link = ref.keepAlive();
    Timer(const Duration(seconds: 60), () {
      link.close();
    });

    return _fetchExpenseClaims();
  }

  Future<List<ExpenseClaimDetails>> _fetchExpenseClaims() async {
    if (_isFetching) {
      AppLogger.w(
          '⚠️ Already fetching expense claims, skipping duplicate request');
      throw Exception('Fetch already in progress');
    }

    _isFetching = true;
    try {
      AppLogger.i('📝 Fetching expense claims from API');
      
      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiEndpoints.expenseClaims);
      
      if (response.statusCode == 200) {
        final apiResponse = ExpenseClaimsApiResponse.fromJson(response.data);
        final claims = apiResponse.data.map((apiData) {
          return ExpenseClaimDetails(
            id: apiData.id,
            title: apiData.title,
            claimType: apiData.category.name,
            amount: apiData.amount,
            date: apiData.incurredDate,
            status: apiData.status,
            description: apiData.description,
            receiptUrl: null,
            createdAt: apiData.createdAt != null 
                ? DateTime.tryParse(apiData.createdAt!)
                : null,
          );
        }).toList();
        
        AppLogger.i('✅ Fetched ${claims.length} expense claims');
        return claims;
      } else {
        throw Exception('Failed to fetch expense claims: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error fetching expense claims: ${e.message}');
      rethrow;
    } catch (e) {
      AppLogger.e('❌ Error fetching expense claims: $e');
      rethrow;
    } finally {
      _isFetching = false;
    }
  }

  Future<void> deleteExpenseClaim(String id) async {
    try {
      final dio = ref.read(dioClientProvider);
      AppLogger.i('Deleting expense claim with ID: $id');

      final response = await dio.delete(ApiEndpoints.deleteExpenseClaim(id));

      if (response.statusCode == 200) {
        AppLogger.i('✅ Expense claim deleted successfully');

        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() async {
          final currentClaims = state.value ?? [];
          return currentClaims.where((c) => c.id != id).toList();
        });
      } else {
        throw Exception(
            'Failed to delete expense claim: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.e('❌ Dio error deleting expense claim: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      AppLogger.e('❌ Error deleting expense claim: $e');
      throw Exception('Failed to delete expense claim: $e');
    }
  }

  List<ExpenseClaimDetails> searchExpenseClaims(String query) {
    final claims = state.value ?? [];
    if (query.isEmpty) return claims;

    final lowerQuery = query.toLowerCase();
    return claims.where((claim) {
      return claim.claimType.toLowerCase().contains(lowerQuery) ||
          claim.status.toLowerCase().contains(lowerQuery) ||
          (claim.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          claim.amount.toString().contains(query);
    }).toList();
  }

  List<ExpenseClaimDetails> filterByStatus(String status) {
    final claims = state.value ?? [];
    return claims.where((claim) => claim.status == status).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchExpenseClaims);
  }
}

// ============================================================================
// SEARCH QUERY PROVIDER
// ============================================================================

@riverpod
class ExpenseClaimSearchQuery extends _$ExpenseClaimSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

// ============================================================================
// COMPUTED PROVIDERS
// ============================================================================

@riverpod
Future<List<ExpenseClaimListItem>> searchedExpenseClaims(Ref ref) async {
  final searchQuery = ref.watch(expenseClaimSearchQueryProvider);
  final allClaims = await ref.watch(expenseClaimsViewModelProvider.future);
  final listItems = allClaims
      .map((claim) => ExpenseClaimListItem.fromExpenseClaimDetails(claim))
      .toList();

  if (searchQuery.isEmpty) return listItems;

  final lowerQuery = searchQuery.toLowerCase();
  return listItems.where((claim) {
    return claim.claimType.toLowerCase().contains(lowerQuery) ||
        claim.status.toLowerCase().contains(lowerQuery) ||
        (claim.description?.toLowerCase().contains(lowerQuery) ?? false) ||
        claim.amount.toString().contains(searchQuery);
  }).toList();
}

@riverpod
int expenseClaimCount(Ref ref) {
  final claimsAsync = ref.watch(expenseClaimsViewModelProvider);

  return claimsAsync.when(
    data: (claims) => claims.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

@riverpod
int pendingExpenseClaimCount(Ref ref) {
  final claimsAsync = ref.watch(expenseClaimsViewModelProvider);

  return claimsAsync.when(
    data: (claims) =>
        claims.where((c) => c.status.toLowerCase() == 'pending').length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

@riverpod
int approvedExpenseClaimCount(Ref ref) {
  final claimsAsync = ref.watch(expenseClaimsViewModelProvider);

  return claimsAsync.when(
    data: (claims) =>
        claims.where((c) => c.status.toLowerCase() == 'approved').length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

// ============================================================================
// EXPENSE CLAIM BY ID PROVIDER
// Fetches a single expense claim by ID
// ============================================================================

@riverpod
Future<ExpenseClaimDetailApiData> expenseClaimById(
  Ref ref,
  String claimId,
) async {
  try {
    AppLogger.i('📝 Fetching expense claim by ID: $claimId');
    
    final dio = ref.read(dioClientProvider);
    final response = await dio.get(ApiEndpoints.expenseClaimById(claimId));
    
    if (response.statusCode == 200) {
      final apiResponse = ExpenseClaimDetailApiResponse.fromJson(response.data);
      AppLogger.i('✅ Fetched expense claim: ${apiResponse.data.title}');
      return apiResponse.data;
    } else {
      throw Exception('Failed to fetch expense claim');
    }
  } catch (e) {
    AppLogger.e('❌ Error fetching expense claim by ID: $e');
    rethrow;
  }
}
