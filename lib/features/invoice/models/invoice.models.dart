import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'invoice.models.freezed.dart';
part 'invoice.models.g.dart';

// ========================================
// ORDER STATUS ENUM
// ========================================
enum OrderStatus {
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('in_transit')
  inTransit,
  @JsonValue('completed')
  completed,
  @JsonValue('rejected')
  rejected,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
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
    @Default(OrderStatus.inProgress) OrderStatus status,
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
