import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network_layer/api_endpoints.dart';
import '../../../core/network_layer/dio_client.dart';
import '../../../core/utils/logger.dart';
import '../models/invoice.models.dart';

part 'invoice.vm.g.dart';

// ========================================
// INVOICE HISTORY PROVIDER (Fetch from API)
// ========================================
@riverpod
class InvoiceHistory extends _$InvoiceHistory {
  bool _isFetching = false;

  @override
  Future<List<InvoiceHistoryItem>> build() async {
    // Keep alive for 60 seconds (prevents disposal on tab switch)
    final link = ref.keepAlive();
    Timer(const Duration(seconds: 60), () {
      link.close();
    });

    // Fetch invoice history - Global wrapper handles connectivity
    return fetchInvoiceHistory();
  }

  /// Fetch invoice history from API
  Future<List<InvoiceHistoryItem>> fetchInvoiceHistory() async {
    // Guard: prevent concurrent fetches
    if (_isFetching) {
      AppLogger.w('⚠️ Already fetching invoices, skipping duplicate request');
      throw Exception('Fetch already in progress');
    }

    _isFetching = true;
    try {
      final dio = ref.read(dioClientProvider);

      AppLogger.d('Fetching invoice history...');

      final response = await dio.get(ApiEndpoints.invoices);

      AppLogger.d('Invoice history response: ${response.data}');

      // Parse response data - handle both String and Map
      final Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData =
            jsonDecode(response.data as String) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Unexpected response type: ${response.data.runtimeType}',
        );
      }

      final historyResponse = InvoiceHistoryResponse.fromJson(responseData);

      AppLogger.d('Fetched ${historyResponse.count} invoices');

      return historyResponse.data;
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching invoice history: $e\n$stackTrace');
      rethrow;
    } finally {
      _isFetching = false;
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
    // ConnectivityInterceptor handles offline state
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
        responseData =
            jsonDecode(response.data as String) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Unexpected response type: ${response.data.runtimeType}',
        );
      }

      final detailsResponse = FetchInvoiceDetailsResponse.fromJson(
        responseData,
      );

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
      final formattedDate = expectedDeliveryDate.toIso8601String().split(
        'T',
      )[0];

      final request = CreateInvoiceRequest(
        partyId: partyId,
        expectedDeliveryDate: formattedDate,
        discount: discount,
        items: items,
      );

      AppLogger.d('Creating invoice with request: ${request.toJson()}');

      final response = await dio.post(
        ApiEndpoints.createInvoice,
        data: request.toJson(),
      );

      AppLogger.d('Invoice created successfully: ${response.data}');
      AppLogger.d('Response data type: ${response.data.runtimeType}');

      // Parse response data - handle both String and Map
      final Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData =
            jsonDecode(response.data as String) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Unexpected response type: ${response.data.runtimeType}',
        );
      }

      final invoiceResponse = CreateInvoiceResponse.fromJson(responseData);

      // Check if response indicates an error
      if (invoiceResponse.status == 'error' ||
          invoiceResponse.success == false) {
        final errorMessage =
            invoiceResponse.message ?? 'Failed to create invoice';
        AppLogger.e('Invoice creation failed: $errorMessage');
        throw Exception(errorMessage);
      }

      // Check if data is null
      if (invoiceResponse.data == null) {
        AppLogger.e('Invoice creation failed: No data in response');
        throw Exception('No data in response');
      }

      // Add to invoice history (optimistic update)
      if (invoiceResponse.success == true) {
        final historyItem = InvoiceHistoryItem(
          id: invoiceResponse.data!.id ?? '',
          partyName: invoiceResponse.data!.partyName,
          invoiceNumber: invoiceResponse.data!.invoiceNumber,
          expectedDeliveryDate: invoiceResponse.data!.expectedDeliveryDate,
          totalAmount:
              invoiceResponse.data!.total ??
              invoiceResponse.data!.items.fold<double>(
                0.0,
                (sum, item) => sum + item.total,
              ),
          status: invoiceResponse.data!.status ?? OrderStatus.pending,
          createdAt:
              invoiceResponse.data!.createdAt ??
              DateTime.now().toIso8601String(),
        );
        ref
            .read(invoiceHistoryProvider.notifier)
            .addInvoiceOptimistic(historyItem);
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

// ========================================
// CREATE ESTIMATE PROVIDER
// ========================================
@riverpod
class CreateEstimate extends _$CreateEstimate {
  @override
  FutureOr<CreateEstimateResponse?> build() {
    return null;
  }

  /// Create a new estimate via API
  Future<CreateEstimateResponse> createEstimate({
    required String partyId,
    required double discount,
    required List<CreateEstimateItemRequest> items,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final dio = ref.read(dioClientProvider);

      final request = CreateEstimateRequest(
        partyId: partyId,
        discount: discount,
        items: items,
      );

      AppLogger.d('Creating estimate with request: ${request.toJson()}');

      final response = await dio.post(
        ApiEndpoints.createEstimate,
        data: request.toJson(),
      );

      AppLogger.d('Estimate created successfully: ${response.data}');
      AppLogger.d('Response data type: ${response.data.runtimeType}');

      // Parse response data - handle both String and Map
      final Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData =
            jsonDecode(response.data as String) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Unexpected response type: ${response.data.runtimeType}',
        );
      }

      final estimateResponse = CreateEstimateResponse.fromJson(responseData);

      // Check if response indicates an error
      if (estimateResponse.status == 'error' ||
          estimateResponse.success == false) {
        final errorMessage =
            estimateResponse.message ?? 'Failed to create estimate';
        AppLogger.e('Estimate creation failed: $errorMessage');
        throw Exception(errorMessage);
      }

      // Check if data is null
      if (estimateResponse.data == null) {
        AppLogger.e('Estimate creation failed: No data in response');
        throw Exception('No data in response');
      }

      return estimateResponse;
    });

    // If there's an error, rethrow it
    if (state.hasError) {
      throw state.error!;
    }

    return state.value!;
  }
}

// ========================================
// ESTIMATE HISTORY PROVIDER (Fetch from API)
// ========================================
@riverpod
class EstimateHistory extends _$EstimateHistory {
  bool _isFetching = false;

  @override
  Future<List<EstimateHistoryItem>> build() async {
    // Keep alive for 60 seconds (prevents disposal on tab switch)
    final link = ref.keepAlive();
    Timer(const Duration(seconds: 60), () {
      link.close();
    });

    // Fetch estimate history - Global wrapper handles connectivity
    return fetchEstimateHistory();
  }

  /// Fetch estimate history from API
  Future<List<EstimateHistoryItem>> fetchEstimateHistory() async {
    // Guard: prevent concurrent fetches
    if (_isFetching) {
      AppLogger.w('⚠️ Already fetching estimates, skipping duplicate request');
      throw Exception('Fetch already in progress');
    }

    _isFetching = true;
    try {
      final dio = ref.read(dioClientProvider);

      AppLogger.d('Fetching estimate history...');

      final response = await dio.get(ApiEndpoints.estimatesHistory);

      AppLogger.d('Estimate history response: ${response.data}');

      // Parse response data - handle both String and Map
      final Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData =
            jsonDecode(response.data as String) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Unexpected response type: ${response.data.runtimeType}',
        );
      }

      final historyResponse = EstimateHistoryResponse.fromJson(responseData);

      AppLogger.d('Fetched ${historyResponse.count} estimates');

      return historyResponse.data;
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching estimate history: $e\n$stackTrace');
      rethrow;
    } finally {
      _isFetching = false;
    }
  }

  /// Refresh estimate history
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchEstimateHistory());
  }

  /// Delete estimate by ID
  Future<void> deleteEstimate(String estimateId) async {
    try {
      final dio = ref.read(dioClientProvider);

      AppLogger.d('Deleting estimate with ID: $estimateId');

      final response = await dio.delete(
        ApiEndpoints.deleteEstimate(estimateId),
      );

      AppLogger.d('Delete estimate response: ${response.data}');

      // Optimistically remove from state
      state.whenData((estimates) {
        final updatedEstimates = estimates
            .where((e) => e.id != estimateId)
            .toList();
        state = AsyncValue.data(updatedEstimates);
      });

      AppLogger.i('✅ Estimate deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error deleting estimate: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Add estimate to history (optimistic update)
  void addEstimateOptimistic(EstimateHistoryItem item) {
    state.whenData((estimates) {
      state = AsyncValue.data([item, ...estimates]);
    });
  }
}

// ========================================
// FETCH ESTIMATE DETAILS PROVIDER
// ========================================
@riverpod
Future<InvoiceDetailsData?> fetchEstimateDetails(
  Ref ref,
  String estimateId,
) async {
  final dio = ref.read(dioClientProvider);

  try {
    AppLogger.d('Fetching estimate details for ID: $estimateId');

    final response = await dio.get(ApiEndpoints.estimateDetails(estimateId));

    AppLogger.d('Estimate details response: ${response.data}');

    // Parse response data - handle both String and Map
    final Map<String, dynamic> responseData;
    if (response.data is String) {
      responseData =
          jsonDecode(response.data as String) as Map<String, dynamic>;
    } else if (response.data is Map<String, dynamic>) {
      responseData = response.data as Map<String, dynamic>;
    } else {
      throw Exception('Unexpected response type: ${response.data.runtimeType}');
    }

    final detailsResponse = FetchInvoiceDetailsResponse.fromJson(responseData);

    AppLogger.d('Estimate details fetched successfully');

    return detailsResponse.data;
  } catch (e, stackTrace) {
    AppLogger.e('Error fetching estimate details: $e\n$stackTrace');
    rethrow;
  }
}

// ========================================
// CONVERT ESTIMATE TO INVOICE PROVIDER
// ========================================
@riverpod
class ConvertEstimate extends _$ConvertEstimate {
  @override
  FutureOr<ConvertEstimateResponse?> build() => null;

  Future<ConvertEstimateResponse> convertToInvoice(
    String estimateId,
    String expectedDeliveryDate,
  ) async {
    state = const AsyncValue.loading();

    try {
      final dio = ref.read(dioClientProvider);

      AppLogger.d('Converting estimate $estimateId to invoice...');

      final requestBody = ConvertEstimateRequest(
        expectedDeliveryDate: expectedDeliveryDate,
      ).toJson();

      final response = await dio.post(
        ApiEndpoints.convertEstimateToInvoice(estimateId),
        data: requestBody,
      );

      AppLogger.d('Convert estimate response: ${response.data}');

      // Parse response data
      final Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData =
            jsonDecode(response.data as String) as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Unexpected response type: ${response.data.runtimeType}',
        );
      }

      final convertResponse = ConvertEstimateResponse.fromJson(responseData);

      // Check if conversion was successful
      if (!convertResponse.success) {
        throw Exception(convertResponse.message);
      }

      // Only update state if still mounted
      if (ref.mounted) {
        state = AsyncValue.data(convertResponse);
      }

      AppLogger.d('✅ Estimate converted successfully');

      return convertResponse;
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error converting estimate: $e');

      // Only update state if still mounted
      if (ref.mounted) {
        state = AsyncValue.error(e, stackTrace);
      }

      rethrow;
    }
  }
}
