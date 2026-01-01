import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/features/catalog/models/catalog.models.dart';

part 'order_controller.g.dart';

/// Simple data class to hold order item information
class OrderItemData {
  final CatalogItem product;
  int quantity;
  double setPrice; // User can edit this price

  OrderItemData({
    required this.product,
    required this.quantity,
    required this.setPrice,
  });

  /// Get the default price from the catalog product
  double get defaultPrice => product.price ?? 0.0;

  /// Calculate subtotal (quantity × set price)
  double get subtotal => quantity * setPrice;

  /// Check if price was modified from default
  bool get isPriceModified => setPrice != defaultPrice;

  /// Create a copy with updated values
  OrderItemData copyWith({
    CatalogItem? product,
    int? quantity,
    double? setPrice,
  }) {
    return OrderItemData(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      setPrice: setPrice ?? this.setPrice,
    );
  }
}

/// Order Controller - Manages cart/invoice items
/// Keeps order in memory during session, cleared after invoice generation
@Riverpod(keepAlive: true)
class OrderController extends _$OrderController {
  @override
  Map<String, OrderItemData> build() => {};

  /// Add item to order or update quantity if already exists
  void addItem(CatalogItem item, int quantity) {
    if (quantity <= 0) return;

    final currentOrder = Map<String, OrderItemData>.from(state);

    if (currentOrder.containsKey(item.id)) {
      // Update existing item quantity
      final existingItem = currentOrder[item.id]!;
      currentOrder[item.id] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Add new item with default price as set price
      currentOrder[item.id] = OrderItemData(
        product: item,
        quantity: quantity,
        setPrice: item.price ?? 0.0, // Start with default price
      );
    }

    state = currentOrder;
  }

  /// Update quantity for a specific item
  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }

    final currentOrder = Map<String, OrderItemData>.from(state);
    if (currentOrder.containsKey(productId)) {
      currentOrder[productId] = currentOrder[productId]!.copyWith(
        quantity: newQuantity,
      );
      state = currentOrder;
    }
  }

  /// Set quantity for a specific item (allows 0, used for editing)
  void setQuantity(String productId, int newQuantity) {
    if (newQuantity < 0) return;

    final currentOrder = Map<String, OrderItemData>.from(state);
    if (currentOrder.containsKey(productId)) {
      currentOrder[productId] = currentOrder[productId]!.copyWith(
        quantity: newQuantity,
      );
      state = currentOrder;
    }
  }

  /// Update set price for a specific item (user override)
  void updateSetPrice(String productId, double newPrice) {
    if (newPrice < 0) return;

    final currentOrder = Map<String, OrderItemData>.from(state);
    if (currentOrder.containsKey(productId)) {
      currentOrder[productId] = currentOrder[productId]!.copyWith(
        setPrice: newPrice,
      );
      state = currentOrder;
    }
  }

  /// Remove item from order
  void removeItem(String productId) {
    final currentOrder = Map<String, OrderItemData>.from(state);
    currentOrder.remove(productId);
    state = currentOrder;
  }

  /// Clear all items from order (call after invoice generation)
  void clearOrder() {
    state = {};
  }

  /// Get total cost of all items in order
  double getTotalCost() {
    return state.values.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Get total quantity of all items
  int getTotalItemCount() {
    return state.values.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Get quantity for a specific product (used in catalog to show selected qty)
  int getProductQuantity(String productId) {
    return state[productId]?.quantity ?? 0;
  }

  /// Check if order has any items
  bool get hasItems => state.isNotEmpty;

  /// Get list of all order items
  List<OrderItemData> get orderItems => state.values.toList();
}
