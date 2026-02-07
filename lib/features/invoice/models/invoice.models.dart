import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice.models.freezed.dart';
part 'invoice.models.g.dart';

// ========================================
// ORDER STATUS ENUM
// ========================================
enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in progress')
  inProgress,
  @JsonValue('in transit')
  inTransit,
  @JsonValue('completed')
  completed,
  @JsonValue('rejected')
  rejected,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFF9E9E9E); // Gray
      case OrderStatus.inProgress:
        return const Color(0xFF2196F3); // Blue
      case OrderStatus.inTransit:
        return const Color(0xFFFFA726); // Yellow/Orange
      case OrderStatus.completed:
        return const Color(0xFF4CAF50); // Green
      case OrderStatus.rejected:
        return const Color(0xFFF44336); // Red
    }
  }

  Color get backgroundColor {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFF5F5F5); // Light Gray
      case OrderStatus.inProgress:
        return const Color(0xFFE3F2FD); // Light Blue
      case OrderStatus.inTransit:
        return const Color(0xFFFFF3E0); // Light Orange
      case OrderStatus.completed:
        return const Color(0xFFE8F5E9); // Light Green
      case OrderStatus.rejected:
        return const Color(0xFFFFEBEE); // Light Red
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.pending_outlined;
      case OrderStatus.inProgress:
        return Icons.hourglass_empty_rounded;
      case OrderStatus.inTransit:
        return Icons.local_shipping_rounded;
      case OrderStatus.completed:
        return Icons.check_circle_rounded;
      case OrderStatus.rejected:
        return Icons.cancel_rounded;
    }
  }
}

// ========================================
// INVOICE MODEL
// ========================================
@freezed
abstract class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    required String invoiceNumber,
    required String partyId,
    required String partyName,
    required String ownerName,
    required DateTime deliveryDate,
    required DateTime createdAt,
    required double subtotal,
    required double discountPercentage,
    required double discountAmount,
    required double total,
    required List<InvoiceItem> items,
    @Default(OrderStatus.pending) OrderStatus status,
    String? pdfPath, // Path to saved PDF file
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
}

// ========================================
// INVOICE ITEM MODEL
// ========================================
@freezed
abstract class InvoiceItem with _$InvoiceItem {
  const factory InvoiceItem({
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required double subtotal,
    String? imageAssetPath,
  }) = _InvoiceItem;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(json);
}

// ========================================
// CREATE INVOICE REQUEST MODEL
// ========================================
@freezed
abstract class CreateInvoiceRequest with _$CreateInvoiceRequest {
  const factory CreateInvoiceRequest({
    required String partyId,
    required String expectedDeliveryDate,
    required double discount,
    required List<CreateInvoiceItemRequest> items,
  }) = _CreateInvoiceRequest;

  factory CreateInvoiceRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateInvoiceRequestFromJson(json);
}

@freezed
abstract class CreateInvoiceItemRequest with _$CreateInvoiceItemRequest {
  const factory CreateInvoiceItemRequest({
    required String productId,
    required int quantity,
    required double price,
    @Default(0.0) double discount,
  }) = _CreateInvoiceItemRequest;

  factory CreateInvoiceItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateInvoiceItemRequestFromJson(json);
}

// ========================================
// CREATE INVOICE RESPONSE MODEL
// ========================================
@freezed
abstract class CreateInvoiceResponse with _$CreateInvoiceResponse {
  const factory CreateInvoiceResponse({
    bool? success,
    InvoiceData? data,
    String? status,
    String? message,
  }) = _CreateInvoiceResponse;

  factory CreateInvoiceResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateInvoiceResponseFromJson(json);
}

@freezed
abstract class InvoiceData with _$InvoiceData {
  const factory InvoiceData({
    required String party,
    required String organizationName,
    required String organizationPanVatNumber,
    required String organizationAddress,
    required String organizationPhone,
    required String partyName,
    required String partyOwnerName,
    required String partyAddress,
    required String partyPanVatNumber,
    required String invoiceNumber,
    required String expectedDeliveryDate,
    required List<InvoiceItemData> items,
    double? subtotal,
    double? discount,
    double? discountAmount,
    double? total,
    String? id,
    String? createdAt,
    String? updatedAt,
    OrderStatus? status,
  }) = _InvoiceData;

  factory InvoiceData.fromJson(Map<String, dynamic> json) =>
      _$InvoiceDataFromJson(json);
}

@freezed
abstract class InvoiceItemData with _$InvoiceItemData {
  const factory InvoiceItemData({
    required String productId,
    required String productName,
    required double price,
    required int quantity,
    required double total,
    @Default(0.0) double discount,
  }) = _InvoiceItemData;

  factory InvoiceItemData.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemDataFromJson(json);
}

// ========================================
// INVOICE HISTORY LIST RESPONSE MODEL
// ========================================
@freezed
abstract class InvoiceHistoryResponse with _$InvoiceHistoryResponse {
  const factory InvoiceHistoryResponse({
    @Default(true) bool success,
    required int count,
    required List<InvoiceHistoryItem> data,
  }) = _InvoiceHistoryResponse;

  factory InvoiceHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$InvoiceHistoryResponseFromJson(json);
}

@freezed
abstract class InvoiceHistoryItem with _$InvoiceHistoryItem {
  const factory InvoiceHistoryItem({
    @JsonKey(name: '_id') required String id,
    required String partyName,
    String? invoiceNumber,
    String? expectedDeliveryDate,
    required double totalAmount,
    required OrderStatus status,
    required String createdAt,
  }) = _InvoiceHistoryItem;

  factory InvoiceHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceHistoryItemFromJson(json);
}

// ========================================
// ESTIMATE HISTORY LIST RESPONSE MODEL
// ========================================
@freezed
abstract class EstimateHistoryResponse with _$EstimateHistoryResponse {
  const factory EstimateHistoryResponse({
    @Default(true) bool success,
    required int count,
    required List<EstimateHistoryItem> data,
  }) = _EstimateHistoryResponse;

  factory EstimateHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$EstimateHistoryResponseFromJson(json);
}

@freezed
abstract class EstimateHistoryItem with _$EstimateHistoryItem {
  const factory EstimateHistoryItem({
    @JsonKey(name: '_id') required String id,
    required String partyName,
    required String estimateNumber,
    required double totalAmount,
    required String createdAt,
  }) = _EstimateHistoryItem;

  factory EstimateHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$EstimateHistoryItemFromJson(json);
}

// ========================================
// FETCH INVOICE DETAILS RESPONSE MODEL
// ========================================
@freezed
abstract class FetchInvoiceDetailsResponse with _$FetchInvoiceDetailsResponse {
  const factory FetchInvoiceDetailsResponse({
    @Default(true) bool success,
    required InvoiceDetailsData data,
  }) = _FetchInvoiceDetailsResponse;

  factory FetchInvoiceDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$FetchInvoiceDetailsResponseFromJson(json);
}

@freezed
abstract class InvoiceDetailsData with _$InvoiceDetailsData {
  const factory InvoiceDetailsData({
    @JsonKey(name: '_id') required String id,
    required String party,
    required String organizationName,
    required String organizationPanVatNumber,
    required String organizationAddress,
    required String organizationPhone,
    required String partyName,
    required String partyOwnerName,
    required String partyAddress,
    required String partyPanVatNumber,
    required List<InvoiceItemData> items,
    required OrderStatus status,
    required String createdAt,
    String? invoiceNumber,
    String? estimateNumber,
    String? expectedDeliveryDate,
    bool? isEstimate,
    double? subtotal,
    double? totalAmount,
    double? discount,
    double? discountAmount,
    String? updatedAt,
  }) = _InvoiceDetailsData;

  factory InvoiceDetailsData.fromJson(Map<String, dynamic> json) =>
      _$InvoiceDetailsDataFromJson(json);
}

// ========================================
// CONVERT ESTIMATE TO INVOICE MODELS
// ========================================
@freezed
abstract class ConvertEstimateRequest with _$ConvertEstimateRequest {
  const factory ConvertEstimateRequest({required String expectedDeliveryDate}) =
      _ConvertEstimateRequest;

  factory ConvertEstimateRequest.fromJson(Map<String, dynamic> json) =>
      _$ConvertEstimateRequestFromJson(json);
}

@freezed
abstract class ConvertEstimateResponse with _$ConvertEstimateResponse {
  const factory ConvertEstimateResponse({
    @Default(true) bool success,
    required String message,
    InvoiceDetailsData? data,
  }) = _ConvertEstimateResponse;

  factory ConvertEstimateResponse.fromJson(Map<String, dynamic> json) =>
      _$ConvertEstimateResponseFromJson(json);
}

// ========================================
// CREATE ESTIMATE REQUEST MODEL
// ========================================
@freezed
abstract class CreateEstimateRequest with _$CreateEstimateRequest {
  const factory CreateEstimateRequest({
    required String partyId,
    required double discount,
    required List<CreateEstimateItemRequest> items,
  }) = _CreateEstimateRequest;

  factory CreateEstimateRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateEstimateRequestFromJson(json);
}

@freezed
abstract class CreateEstimateItemRequest with _$CreateEstimateItemRequest {
  const factory CreateEstimateItemRequest({
    required String productId,
    required int quantity,
    required double price,
    @Default(0.0) double discount,
  }) = _CreateEstimateItemRequest;

  factory CreateEstimateItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateEstimateItemRequestFromJson(json);
}

// ========================================
// CREATE ESTIMATE RESPONSE MODEL
// ========================================
@freezed
abstract class CreateEstimateResponse with _$CreateEstimateResponse {
  const factory CreateEstimateResponse({
    bool? success,
    EstimateData? data,
    String? status,
    String? message,
  }) = _CreateEstimateResponse;

  factory CreateEstimateResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateEstimateResponseFromJson(json);
}

@freezed
abstract class EstimateData with _$EstimateData {
  const factory EstimateData({
    required String party,
    required String organizationName,
    required String organizationPanVatNumber,
    required String organizationAddress,
    required String organizationPhone,
    required String partyName,
    required String partyOwnerName,
    required String partyAddress,
    required String partyPanVatNumber,
    required bool isEstimate,
    required String estimateNumber,
    required List<EstimateItemData> items,
    double? subtotal,
    double? discount,
    double? totalAmount,
    OrderStatus? status,
    String? organizationId,
    String? createdBy,
    @JsonKey(name: '_id') String? id,
    String? createdAt,
    String? updatedAt,
  }) = _EstimateData;

  factory EstimateData.fromJson(Map<String, dynamic> json) =>
      _$EstimateDataFromJson(json);
}

@freezed
abstract class EstimateItemData with _$EstimateItemData {
  const factory EstimateItemData({
    required String productId,
    required String productName,
    required double price,
    required int quantity,
    required double discount,
    required double total,
  }) = _EstimateItemData;

  factory EstimateItemData.fromJson(Map<String, dynamic> json) =>
      _$EstimateItemDataFromJson(json);
}
