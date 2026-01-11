import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection.model.freezed.dart';

part 'collection.model.g.dart';

// ============================================================================
// API Response Models
// ============================================================================

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
    required String partyName,
    required double amount,
    @JsonKey(name: 'collectionDate') required String collectionDate,
    required String paymentMode,
    String? remarks,
    String? createdAt,
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
    required String partyName,
    required double amount,
    @JsonKey(name: 'collectionDate') required String date,
    required String paymentMode,
    String? bankName,
    String? chequeNumber,
    String? chequeDate,
    String? chequeStatus,
    String? description,
    List<String>? images,
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
    required String paymentMode,
    String? bankName,
    String? chequeNumber,
    String? chequeDate,
    String? chequeStatus,
    String? description,
  }) = _AddCollectionRequest;

  factory AddCollectionRequest.fromJson(Map<String, dynamic> json) =>
      _$AddCollectionRequestFromJson(json);
}

/// Update collection request model for PUT /api/v1/collections/:id
@freezed
abstract class UpdateCollectionRequest with _$UpdateCollectionRequest {
  const factory UpdateCollectionRequest({
    required double amount,
    required String date,
    required String paymentMode,
    String? bankName,
    String? chequeNumber,
    String? chequeDate,
    String? chequeStatus,
    String? description,
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
    required String partyName,
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
    return CollectionListItem(
      id: apiData.id,
      partyName: apiData.partyName,
      amount: apiData.amount,
      date: apiData.collectionDate,
      paymentMode: apiData.paymentMode,
      remarks: apiData.remarks,
      imagePaths: null,
      bankName: null,
      chequeNumber: null,
      chequeDate: null,
      chequeStatus: null,
    );
  }
}

enum PaymentMode {
  cash('Cash', Icons.money_outlined),
  cheque('Cheque', Icons.account_balance_wallet_outlined),
  bankTransfer('Bank Transfer', Icons.account_balance_outlined),
  qrPay('QR Pay', Icons.qr_code_scanner_outlined);

  final String label;
  final IconData icon;

  const PaymentMode(this.label, this.icon);

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

