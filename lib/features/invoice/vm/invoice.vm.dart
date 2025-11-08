import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/invoice.models.dart';
import '../../../core/network_layer/dio_client.dart';
import '../../../core/network_layer/api_endpoints.dart';
import '../../../core/utils/logger.dart';

part 'invoice.vm.g.dart';

// ========================================
// INVOICE HISTORY PROVIDER (Fetch from API)
// ========================================
@riverpod
class InvoiceHistory extends _$InvoiceHistory {
  @override
  Future<List<InvoiceHistoryItem>> build() async {
    return fetchInvoiceHistory();
  }

  /// Fetch invoice history from API
  Future<List<InvoiceHistoryItem>> fetchInvoiceHistory() async {
    try {
      final dio = ref.read(dioClientProvider);

      AppLogger.d('Fetching invoice history...');

      final response = await dio.get(ApiEndpoints.invoices);

      AppLogger.d('Invoice history response: ${response.data}');

      // Parse response data - handle both String and Map
      final Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data as String) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response type: ${response.data.runtimeType}');
      }

      final historyResponse = InvoiceHistoryResponse.fromJson(responseData);

      AppLogger.d('Fetched ${historyResponse.count} invoices');

      return historyResponse.data;
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching invoice history: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Refresh invoice history
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchInvoiceHistory());
  }

  /// Add invoice to history (optimistic update)
  void addInvoiceOptimistic(InvoiceHistoryItem item) {
    state.whenData((invoices) {
      state = AsyncValue.data([item, ...invoices]);
    });
  }
}

// ========================================
// FETCH INVOICE DETAILS PROVIDER
// ========================================
@riverpod
class FetchInvoiceDetails extends _$FetchInvoiceDetails {
  @override
  FutureOr<InvoiceDetailsData?> build(String invoiceId) async {
    // Auto-fetch when provider is created
    return fetchInvoiceDetails(invoiceId);
  }

  /// Fetch specific invoice details from API
  Future<InvoiceDetailsData> fetchInvoiceDetails(String invoiceId) async {
    try {
      final dio = ref.read(dioClientProvider);

      AppLogger.d('Fetching invoice details for ID: $invoiceId');

      final response = await dio.get(ApiEndpoints.invoiceById(invoiceId));

      AppLogger.d('Invoice details response: ${response.data}');

      // Parse response data - handle both String and Map
      final Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data as String) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response type: ${response.data.runtimeType}');
      }

      final detailsResponse = FetchInvoiceDetailsResponse.fromJson(responseData);

      AppLogger.d('Fetched invoice: ${detailsResponse.data.invoiceNumber}');

      return detailsResponse.data;
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching invoice details: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Refresh invoice details
  Future<void> refresh(String invoiceId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchInvoiceDetails(invoiceId));
  }
}

// Provider to generate unique invoice number (optional - server generates it)
@riverpod
String generateInvoiceNumber(Ref ref) {
  final now = DateTime.now();
  final invoicesAsync = ref.watch(invoiceHistoryProvider);
  final count = invoicesAsync.maybeWhen(
    data: (invoices) => invoices.length + 1,
    orElse: () => 1,
  );
  return 'INV-${now.year}-${count.toString().padLeft(4, '0')}';
}

// ========================================
// CREATE INVOICE PROVIDER
// ========================================
@riverpod
class CreateInvoice extends _$CreateInvoice {
  @override
  FutureOr<CreateInvoiceResponse?> build() {
    return null;
  }

  /// Create a new invoice via API
  Future<CreateInvoiceResponse> createInvoice({
    required String partyId,
    required DateTime expectedDeliveryDate,
    required double discount,
    required List<CreateInvoiceItemRequest> items,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final dio = ref.read(dioClientProvider);

      // Format date as YYYY-MM-DD
      final formattedDate = expectedDeliveryDate.toIso8601String().split('T')[0];

      final request = CreateInvoiceRequest(
        partyId: partyId,
        expectedDeliveryDate: formattedDate,
        discount: discount,
        items: items,
      );

      AppLogger.d('Creating invoice with request: ${request.toJson()}');

      final response = await dio.post(
        ApiEndpoints.invoices,
        data: request.toJson(),
      );

      AppLogger.d('Invoice created successfully: ${response.data}');
      AppLogger.d('Response data type: ${response.data.runtimeType}');

      // Parse response data - handle both String and Map
      final Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data as String) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response type: ${response.data.runtimeType}');
      }

      final invoiceResponse = CreateInvoiceResponse.fromJson(responseData);

      // Add to invoice history (optimistic update)
      if (invoiceResponse.success) {
        final historyItem = InvoiceHistoryItem(
          id: invoiceResponse.data.id ?? '',
          partyName: invoiceResponse.data.partyName,
          invoiceNumber: invoiceResponse.data.invoiceNumber,
          expectedDeliveryDate: invoiceResponse.data.expectedDeliveryDate,
          totalAmount: invoiceResponse.data.total ??
              invoiceResponse.data.items.fold<double>(0.0, (sum, item) => sum + item.total),
          status: invoiceResponse.data.status ?? OrderStatus.pending,
          createdAt: invoiceResponse.data.createdAt ?? DateTime.now().toIso8601String(),
        );
        ref.read(invoiceHistoryProvider.notifier).addInvoiceOptimistic(historyItem);
      }

      return invoiceResponse;
    });

    // If there's an error, rethrow it
    if (state.hasError) {
      throw state.error!;
    }

    return state.value!;
  }
}
