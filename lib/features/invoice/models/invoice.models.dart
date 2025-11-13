import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

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
    required bool success,
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
    required String invoiceNumber,
    required String expectedDeliveryDate,
    required double totalAmount,
    required OrderStatus status,
    required String createdAt,
  }) = _InvoiceHistoryItem;

  factory InvoiceHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceHistoryItemFromJson(json);
}

// ========================================
// FETCH INVOICE DETAILS RESPONSE MODEL
// ========================================
@freezed
abstract class FetchInvoiceDetailsResponse with _$FetchInvoiceDetailsResponse {
  const factory FetchInvoiceDetailsResponse({
    required bool success,
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
    required String invoiceNumber,
    required String expectedDeliveryDate,
    required List<InvoiceItemData> items,
    required OrderStatus status,
    required String createdAt,
    double? totalAmount,
    double? discount,
    double? discountAmount,
    String? updatedAt,
  }) = _InvoiceDetailsData;

  factory InvoiceDetailsData.fromJson(Map<String, dynamic> json) =>
      _$InvoiceDetailsDataFromJson(json);
}
