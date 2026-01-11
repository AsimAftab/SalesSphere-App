import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection.model.freezed.dart';
part 'collection.model.g.dart';

// ============================================================================
// API Response Models
// ============================================================================

/// Bank name object from utils/bank-names endpoint
@freezed
abstract class BankName with _$BankName {
  const factory BankName({
    @JsonKey(name: '_id') required String id,
    required String name,
  }) = _BankName;

  factory BankName.fromJson(Map<String, dynamic> json) =>
      _$BankNameFromJson(json);
}

/// API Response wrapper for bank names endpoint
@freezed
abstract class BankNamesApiResponse with _$BankNamesApiResponse {
  const factory BankNamesApiResponse({
    required bool success,
    required int count,
    required List<BankName> data,
  }) = _BankNamesApiResponse;

  factory BankNamesApiResponse.fromJson(Map<String, dynamic> json) =>
      _$BankNamesApiResponseFromJson(json);
}

/// Party object nested in collection data
@freezed
abstract class CollectionParty with _$CollectionParty {
  const factory CollectionParty({
    @JsonKey(name: '_id') required String id,
    required String partyName,
    required String ownerName,
  }) = _CollectionParty;

  factory CollectionParty.fromJson(Map<String, dynamic> json) =>
      _$CollectionPartyFromJson(json);
}

/// CreatedBy object in collection details
@freezed
abstract class CreatedBy with _$CreatedBy {
  const factory CreatedBy({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String email,
  }) = _CreatedBy;

  factory CreatedBy.fromJson(Map<String, dynamic> json) =>
      _$CreatedByFromJson(json);
}

/// API Response wrapper for collections list endpoint
@freezed
abstract class CollectionApiResponse with _$CollectionApiResponse {
  const factory CollectionApiResponse({
    required bool success,
    required int count,
    required List<CollectionApiData> data,
  }) = _CollectionApiResponse;

  factory CollectionApiResponse.fromJson(Map<String, dynamic> json) =>
      _$CollectionApiResponseFromJson(json);
}

/// Individual collection data from API (list view)
@freezed
abstract class CollectionApiData with _$CollectionApiData {
  const factory CollectionApiData({
    @JsonKey(name: '_id') required String id,
    required CollectionParty party,
    @JsonKey(name: 'amountReceived') required double amountReceived,
    @JsonKey(name: 'receivedDate') required String receivedDate,
    required String description,
    @JsonKey(name: 'paymentMethod') required String paymentMethod,
    String? bankName,
    String? chequeNumber,
    String? chequeDate,
    String? chequeStatus,
    required List<String> images,
    String? organizationId,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
  }) = _CollectionApiData;

  factory CollectionApiData.fromJson(Map<String, dynamic> json) =>
      _$CollectionApiDataFromJson(json);
}

/// API Response wrapper for single collection details endpoint
@freezed
abstract class CollectionDetailApiResponse with _$CollectionDetailApiResponse {
  const factory CollectionDetailApiResponse({
    required bool success,
    required CollectionDetailApiData data,
  }) = _CollectionDetailApiResponse;

  factory CollectionDetailApiResponse.fromJson(Map<String, dynamic> json) =>
      _$CollectionDetailApiResponseFromJson(json);
}

/// Full collection data from API (details view)
@freezed
abstract class CollectionDetailApiData with _$CollectionDetailApiData {
  const factory CollectionDetailApiData({
    @JsonKey(name: '_id') required String id,
    required CollectionParty party,
    @JsonKey(name: 'amountReceived') required double amountReceived,
    @JsonKey(name: 'receivedDate') required String receivedDate,
    required String description,
    @JsonKey(name: 'paymentMethod') required String paymentMethod,
    String? bankName,
    String? chequeNumber,
    String? chequeDate,
    String? chequeStatus,
    required List<String> images,
    String? organizationId,
    CreatedBy? createdBy,
    String? createdAt,
    String? updatedAt,
  }) = _CollectionDetailApiData;

  factory CollectionDetailApiData.fromJson(Map<String, dynamic> json) =>
      _$CollectionDetailApiDataFromJson(json);
}

// ============================================================================
// Request Models
// ============================================================================

/// Create collection request model for POST /api/v1/collections
@freezed
abstract class AddCollectionRequest with _$AddCollectionRequest {
  const factory AddCollectionRequest({
    required String partyId,
    required double amountReceived,
    required String receivedDate,
    required String paymentMethod,
    String? bankName,
    String? chequeNumber,
    String? chequeDate,
    String? chequeStatus,
    String? description,
    List<String>? images,
  }) = _AddCollectionRequest;

  factory AddCollectionRequest.fromJson(Map<String, dynamic> json) =>
      _$AddCollectionRequestFromJson(json);
}

/// Update collection request model for PUT /api/v1/collections/:id
/// Note: Only fields that need to be updated should be provided
@freezed
abstract class UpdateCollectionRequest with _$UpdateCollectionRequest {
  const factory UpdateCollectionRequest({
    required double amountReceived,
    required String receivedDate,
    required String paymentMethod,
    @JsonKey(includeIfNull: false) String? bankName,
    @JsonKey(includeIfNull: false) String? chequeNumber,
    @JsonKey(includeIfNull: false) String? chequeDate,
    @JsonKey(includeIfNull: false) String? chequeStatus,
    @JsonKey(includeIfNull: false) String? description,
    @JsonKey(includeIfNull: false) List<String>? images,
  }) = _UpdateCollectionRequest;

  factory UpdateCollectionRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCollectionRequestFromJson(json);
}

/// General API Response for simple success/message responses (Add/Update)
@freezed
abstract class AddCollectionApiResponse with _$AddCollectionApiResponse {
  const factory AddCollectionApiResponse({
    required bool success,
    required String message,
    @JsonKey(name: 'data') Map<String, dynamic>? data,
  }) = _AddCollectionApiResponse;

  factory AddCollectionApiResponse.fromJson(Map<String, dynamic> json) =>
      _$AddCollectionApiResponseFromJson(json);
}

// ============================================================================
// App Models
// ============================================================================

/// Lightweight model for collection list display in UI
@freezed
abstract class CollectionListItem with _$CollectionListItem {
  const factory CollectionListItem({
    required String id,
    required String partyId,
    required String partyName,
    required String ownerName,
    required double amount,
    required String date,
    required String paymentMode,
    String? remarks,
    List<String>? imagePaths,
    String? bankName,
    String? chequeNumber,
    String? chequeDate,
    String? chequeStatus,
  }) = _CollectionListItem;

  factory CollectionListItem.fromApiData(CollectionApiData apiData) {
    // Map API payment method value to display label for UI filter compatibility
    final paymentModeLabel = _mapPaymentMethodToLabel(apiData.paymentMethod);

    return CollectionListItem(
      id: apiData.id,
      partyId: apiData.party.id,
      partyName: apiData.party.partyName,
      ownerName: apiData.party.ownerName,
      amount: apiData.amountReceived,
      date: apiData.receivedDate,
      paymentMode: paymentModeLabel,
      remarks: apiData.description,
      imagePaths: apiData.images,
      bankName: apiData.bankName,
      chequeNumber: apiData.chequeNumber,
      chequeDate: apiData.chequeDate,
      chequeStatus: apiData.chequeStatus,
    );
  }

  /// Maps API payment method values to UI display labels
  /// API: 'bank_transfer' -> UI: 'Bank Transfer'
  /// API: 'cash' -> UI: 'Cash'
  /// API: 'cheque' -> UI: 'Cheque'
  /// API: 'qr' -> UI: 'QR Pay'
  static String _mapPaymentMethodToLabel(String apiValue) {
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
}

enum PaymentMode {
  cash('Cash', 'cash', Icons.money_outlined),
  cheque('Cheque', 'cheque', Icons.account_balance_wallet_outlined),
  bankTransfer(
    'Bank Transfer',
    'bank_transfer',
    Icons.account_balance_outlined,
  ),
  qrPay('QR Pay', 'qr', Icons.qr_code_scanner_outlined);

  final String label;
  final String apiValue;
  final IconData icon;

  const PaymentMode(this.label, this.apiValue, this.icon);

  /// Find enum by API value (e.g., 'bank_transfer' -> bankTransfer)
  static PaymentMode? fromApiValue(String? apiValue) {
    if (apiValue == null) return null;
    return PaymentMode.values.firstWhere(
      (e) => e.apiValue == apiValue,
      orElse: () => PaymentMode.cash,
    );
  }

  /// Find enum by display label (e.g., 'Bank Transfer' -> bankTransfer)
  static PaymentMode? fromLabel(String? label) {
    if (label == null) return null;
    return PaymentMode.values.firstWhere(
      (e) => e.label == label,
      orElse: () => PaymentMode.cash,
    );
  }
}

enum ChequeStatus {
  pending('Pending', Icons.hourglass_empty_outlined),
  deposited('Deposited', Icons.file_upload_outlined),
  cleared('Cleared', Icons.check_circle_outline),
  bounced('Bounced', Icons.error_outline);

  final String label;
  final IconData icon;

  const ChequeStatus(this.label, this.icon);
}
