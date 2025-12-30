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
      AppLogger.i('📝 Returning mock expense claims data');

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Return mock data
      final mockClaims = [
        ExpenseClaimDetails(
          id: '1',
          claimType: 'Travel',
          amount: 1500.00,
          date: '2024-01-15',
          status: 'Pending',
          description: 'Client meeting in Mumbai - Train tickets',
          receiptUrl: null,
        ),
        ExpenseClaimDetails(
          id: '2',
          claimType: 'Food',
          amount: 850.50,
          date: '2024-01-16',
          status: 'Approved',
          description: 'Business lunch with client',
          receiptUrl: 'https://example.com/receipt2.jpg',
        ),
        ExpenseClaimDetails(
          id: '3',
          claimType: 'Fuel',
          amount: 2500.00,
          date: '2024-01-17',
          status: 'Pending',
          description: 'Field visit to 5 locations',
          receiptUrl: null,
        ),
        ExpenseClaimDetails(
          id: '4',
          claimType: 'Accommodation',
          amount: 3500.00,
          date: '2024-01-18',
          status: 'Approved',
          description: 'Overnight stay for client presentation',
          receiptUrl: 'https://example.com/receipt4.jpg',
        ),
        ExpenseClaimDetails(
          id: '5',
          claimType: 'Miscellaneous',
          amount: 450.00,
          date: '2024-01-19',
          status: 'Rejected',
          description: 'Office supplies for presentation',
          receiptUrl: null,
        ),
        ExpenseClaimDetails(
          id: '6',
          claimType: 'Travel',
          amount: 5200.00,
          date: '2024-01-20',
          status: 'Pending',
          description: 'Flight tickets to Delhi for conference',
          receiptUrl: 'https://example.com/receipt6.jpg',
        ),
        ExpenseClaimDetails(
          id: '7',
          claimType: 'Food',
          amount: 1200.00,
          date: '2024-01-21',
          status: 'Approved',
          description: 'Team dinner after successful deal closure',
          receiptUrl: null,
        ),
        ExpenseClaimDetails(
          id: '8',
          claimType: 'Fuel',
          amount: 1800.00,
          date: '2024-01-22',
          status: 'Pending',
          description: 'Weekly field visits - full tank refill',
          receiptUrl: 'https://example.com/receipt8.jpg',
        ),
      ];

      AppLogger.i('✅ Returned ${mockClaims.length} mock expense claims');
      return mockClaims;

      // TODO: Replace with real API call when backend is ready
      // final dio = ref.read(dioClientProvider);
      // final response = await dio.get(ApiEndpoints.expenseClaims);
      // if (response.statusCode == 200) {
      //   final apiResponse = ExpenseClaimsApiResponse.fromJson(response.data);
      //   return apiResponse.data.map((apiData) {
      //     return ExpenseClaimDetails(
      //       id: apiData.id,
      //       claimType: apiData.claimType,
      //       amount: apiData.amount,
      //       date: apiData.date,
      //       status: apiData.status,
      //       description: apiData.description,
      //       receiptUrl: apiData.receiptUrl,
      //     );
      //   }).toList();
      // } else {
      //   throw Exception('Failed to fetch expense claims: ${response.statusMessage}');
      // }
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
