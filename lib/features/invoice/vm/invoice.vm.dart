import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/invoice.models.dart';

part 'invoice.vm.g.dart';

// ViewModel to manage invoice history (in-memory for now, will be replaced with API)
@riverpod
class InvoiceHistory extends _$InvoiceHistory {
  @override
  List<Invoice> build() {
    // Return mock data for demonstration
    return _generateMockInvoices();
  }

  // Add a new invoice to history
  void addInvoice(Invoice invoice) {
    state = [invoice, ...state];
  }

  // Clear all invoices
  void clearHistory() {
    state = [];
  }

  // Generate mock invoices for demo
  List<Invoice> _generateMockInvoices() {
    final now = DateTime.now();
    return [
      Invoice(
        id: 'INV-001',
        invoiceNumber: 'INV-2025-001',
        partyId: 'party-1',
        partyName: 'ABC Tiles Ltd',
        ownerName: 'Rajesh Kumar',
        deliveryDate: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 2)),
        subtotal: 15000.0,
        discountPercentage: 10.0,
        discountAmount: 1500.0,
        total: 13500.0,
        status: OrderStatus.inProgress,
        items: [
          const InvoiceItem(
            productId: 'prod-1',
            productName: 'Ceramic Floor Tiles',
            quantity: 100,
            unitPrice: 120.0,
            subtotal: 12000.0,
          ),
          const InvoiceItem(
            productId: 'prod-2',
            productName: 'Wall Tiles Premium',
            quantity: 50,
            unitPrice: 60.0,
            subtotal: 3000.0,
          ),
        ],
      ),
      Invoice(
        id: 'INV-002',
        invoiceNumber: 'INV-2025-002',
        partyId: 'party-2',
        partyName: 'XYZ Constructions',
        ownerName: 'Amit Sharma',
        deliveryDate: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 5)),
        subtotal: 25000.0,
        discountPercentage: 5.0,
        discountAmount: 1250.0,
        total: 23750.0,
        status: OrderStatus.inTransit,
        items: [
          const InvoiceItem(
            productId: 'prod-3',
            productName: 'Porcelain Tiles',
            quantity: 200,
            unitPrice: 100.0,
            subtotal: 20000.0,
          ),
          const InvoiceItem(
            productId: 'prod-4',
            productName: 'Adhesive Kit',
            quantity: 50,
            unitPrice: 100.0,
            subtotal: 5000.0,
          ),
        ],
      ),
      Invoice(
        id: 'INV-003',
        invoiceNumber: 'INV-2025-003',
        partyId: 'party-3',
        partyName: 'Marble Palace',
        ownerName: 'Vikram Singh',
        deliveryDate: now.add(const Duration(days: 10)),
        createdAt: now.subtract(const Duration(days: 10)),
        subtotal: 50000.0,
        discountPercentage: 0.0,
        discountAmount: 0.0,
        total: 50000.0,
        status: OrderStatus.completed,
        items: [
          const InvoiceItem(
            productId: 'prod-5',
            productName: 'Italian Marble Tiles',
            quantity: 150,
            unitPrice: 250.0,
            subtotal: 37500.0,
          ),
          const InvoiceItem(
            productId: 'prod-6',
            productName: 'Granite Tiles',
            quantity: 100,
            unitPrice: 125.0,
            subtotal: 12500.0,
          ),
        ],
      ),
      Invoice(
        id: 'INV-004',
        invoiceNumber: 'INV-2025-004',
        partyId: 'party-4',
        partyName: 'Premium Interiors',
        ownerName: 'Priya Mehta',
        deliveryDate: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 15)),
        subtotal: 18000.0,
        discountPercentage: 0.0,
        discountAmount: 0.0,
        total: 18000.0,
        status: OrderStatus.rejected,
        items: [
          const InvoiceItem(
            productId: 'prod-7',
            productName: 'Designer Tiles',
            quantity: 120,
            unitPrice: 150.0,
            subtotal: 18000.0,
          ),
        ],
      ),
    ];
  }
}

// Provider to generate unique invoice number
@riverpod
String generateInvoiceNumber(Ref ref) {
  final now = DateTime.now();
  final invoices = ref.watch(invoiceHistoryProvider);
  final count = invoices.length + 1;
  return 'INV-${now.year}-${count.toString().padLeft(3, '0')}';
}
