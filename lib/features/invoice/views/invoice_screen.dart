import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/parties/models/parties.model.dart';
import 'package:sales_sphere/features/parties/vm/parties.vm.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/core/providers/order_controller.dart';

class InvoiceScreen extends ConsumerStatefulWidget {
  const InvoiceScreen({super.key});

  @override
  ConsumerState<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends ConsumerState<InvoiceScreen> {
  PartyDetails? selectedParty;
  final TextEditingController _partySearchController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _deliveryDateController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(); // Empty by default
  final FocusNode _partySearchFocusNode = FocusNode();
  bool _showPartyDropdown = false;
  String _searchQuery = '';
  double _discountPercentage = 0.0;

  // Map to store TextEditingControllers for each product's set price
  final Map<String, TextEditingController> _priceControllers = {};

  // Map to store TextEditingControllers for each product's quantity
  final Map<String, TextEditingController> _quantityControllers = {};

  @override
  void initState() {
    super.initState();
    _partySearchFocusNode.addListener(() {
      setState(() {
        _showPartyDropdown = _partySearchFocusNode.hasFocus;
      });
    });

    // Listen to delivery date changes to update button state
    _deliveryDateController.addListener(() {
      setState(() {
        // Just trigger rebuild when date changes
      });
    });
  }

  @override
  void dispose() {
    _partySearchController.dispose();
    _ownerNameController.dispose();
    _deliveryDateController.dispose();
    _discountController.dispose();
    _partySearchFocusNode.dispose();
    // Dispose all price controllers
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    // Dispose all quantity controllers
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Get or create a TextEditingController for a product's set price
  TextEditingController _getPriceController(String productId, double initialPrice) {
    if (!_priceControllers.containsKey(productId)) {
      _priceControllers[productId] = TextEditingController(
        text: initialPrice.toStringAsFixed(2),
      );
    }
    return _priceControllers[productId]!;
  }

  // Get or create a TextEditingController for a product's quantity
  TextEditingController _getQuantityController(String productId, int initialQuantity) {
    if (!_quantityControllers.containsKey(productId)) {
      _quantityControllers[productId] = TextEditingController(
        text: initialQuantity.toString(),
      );
    }
    return _quantityControllers[productId]!;
  }

  void _selectParty(PartyDetails party) {
    setState(() {
      selectedParty = party;
      _partySearchController.text = party.name;
      _ownerNameController.text = party.ownerName;
      _searchQuery = party.name;
      _showPartyDropdown = false;
    });
    _partySearchFocusNode.unfocus();
  }

  void _clearPartySelection() {
    setState(() {
      selectedParty = null;
      _partySearchController.clear();
      _ownerNameController.clear();
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partiesViewModelProvider);
    final orderController = ref.watch(orderControllerProvider);
    final orderItems = orderController.values.toList();
    final subtotalCost = ref.read(orderControllerProvider.notifier).getTotalCost();

    // Calculate discount amount and final total
    final discountAmount = subtotalCost * (_discountPercentage / 100);
    final totalCost = subtotalCost - discountAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header with enhanced design
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF202020),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (orderItems.isNotEmpty)
                        Text(
                          '${orderItems.length} ${orderItems.length == 1 ? 'item' : 'items'} • ₹${totalCost.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),

                    // Party Details Card
                    _buildSectionCard(
                      title: 'Party Details',
                      icon: Icons.business_rounded,
                      child: Column(
                        children: [
                          // Party Name Search Field with Inline Dropdown
                          partiesAsync.when(
                            data: (parties) {
                              return _buildInlinePartySearchField(parties);
                            },
                            loading: () => _buildInlinePartySearchField([]),
                            error: (error, stack) => _buildInlinePartySearchField([]),
                          ),

                          SizedBox(height: 16.h),

                          // Owner Name (Auto-populated, read-only)
                          PrimaryTextField(
                            hintText: 'Owner Name',
                            controller: _ownerNameController,
                            prefixIcon: Icons.person_outline,
                            enabled: false,
                          ),

                          SizedBox(height: 16.h),

                          // Expected Delivery Date
                          CustomDatePicker(
                            hintText: 'Expected Delivery Date',
                            controller: _deliveryDateController,
                            prefixIcon: Icons.local_shipping_rounded,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            initialDate: DateTime.now().add(const Duration(days: 7)),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Order Items Section
                    _buildSectionHeader('Order Items', orderItems.length),

                    SizedBox(height: 12.h),

                    // Order Items or Enhanced Empty State
                    if (orderItems.isEmpty)
                      _buildEnhancedEmptyState()
                    else
                      ...orderItems.map((orderItemData) => _buildEnhancedOrderItemRow(orderItemData)),

                    if (orderItems.isNotEmpty) SizedBox(height: 16.h),

                    // Pricing Card
                    if (orderItems.isNotEmpty)
                      _buildSectionCard(
                        title: 'Pricing',
                        icon: Icons.payments_rounded,
                        child: Column(
                          children: [
                            // Discount Field
                            Container(
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Discount (%)',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF202020),
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100.w,
                                    child: TextFormField(
                                      controller: _discountController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          borderSide: const BorderSide(color: Colors.grey),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          borderSide: BorderSide(color: AppColors.primary),
                                        ),
                                        suffixText: '%',
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          final parsedValue = double.tryParse(value) ?? 0.0;
                                          _discountPercentage = parsedValue.clamp(0.0, 100.0);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Cost Breakdown
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.05),
                                    AppColors.primary.withValues(alpha: 0.02),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Subtotal',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF202020),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      Text(
                                        '₹${subtotalCost.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF202020),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_discountPercentage > 0) ...[
                                    SizedBox(height: 12.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Discount ($_discountPercentage%)',
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.green.shade700,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          '-₹${discountAmount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade700,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  SizedBox(height: 12.h),
                                  Divider(color: AppColors.primary.withValues(alpha: 0.3)),
                                  SizedBox(height: 12.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF202020),
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      Text(
                                        '₹${totalCost.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 24.h),

                    // Generate Invoice Button
                    Builder(
                      builder: (context) {
                        final canGenerate = selectedParty != null &&
                            _deliveryDateController.text.isNotEmpty &&
                            orderItems.isNotEmpty;
                        return PrimaryButton(
                          label: 'Generate Invoice',
                          onPressed: canGenerate
                              ? () {
                            // TODO: Implement actual invoice generation API call
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Invoice generated for ${selectedParty!.name} with ${orderItems.length} items!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Clear the order after invoice generation
                            ref.read(orderControllerProvider.notifier).clearOrder();

                            // Clear form fields
                            setState(() {
                              selectedParty = null;
                              _partySearchController.clear();
                              _ownerNameController.clear();
                              _deliveryDateController.clear();
                              _searchQuery = '';
                              // Clear price controllers
                              for (var controller in _priceControllers.values) {
                                controller.dispose();
                              }
                              _priceControllers.clear();
                              // Clear quantity controllers
                              for (var controller in _quantityControllers.values) {
                                controller.dispose();
                              }
                              _quantityControllers.clear();
                            });
                          }
                              : null,
                          size: ButtonSize.large,
                        );
                      },
                    ),

                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to catalog page
          context.goNamed('catalog');
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: Icon(Icons.add_shopping_cart_rounded, size: 20.sp),
        label: Text(
          'Add Items',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  // Enhanced Section Card Widget
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF202020),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
            child: child,
          ),
        ],
      ),
    );
  }

  // Enhanced Section Header
  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.shopping_bag_rounded,
                color: AppColors.primary,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF202020),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        if (count > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$count ${count == 1 ? 'item' : 'items'}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontFamily: 'Poppins',
              ),
            ),
          ),
      ],
    );
  }

  // Enhanced Empty State with Illustration
  Widget _buildEnhancedEmptyState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Custom illustration using stacked containers
          Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
              // Cart icon with items
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 50.sp,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'No Items Added Yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF202020),
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start building your invoice by adding\nproducts from the catalog',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              fontFamily: 'Poppins',
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          // Quick action button
          OutlinedButton.icon(
            onPressed: () {
              context.goNamed('catalog');
            },
            icon: Icon(Icons.add_rounded, size: 18.sp),
            label: Text(
              'Browse Catalog',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary, width: 1.5),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Order Item Row with Product Thumbnail
  Widget _buildEnhancedOrderItemRow(OrderItemData orderItemData) {
    final product = orderItemData.product;
    final priceController = _getPriceController(product.id, orderItemData.setPrice);
    final quantityController = _getQuantityController(product.id, orderItemData.quantity);
    final isPriceModified = orderItemData.isPriceModified;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Product Header with Thumbnail
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // Product Thumbnail
                GestureDetector(
                  onTap: () {
                    context.pushNamed(
                      'catalog_item_details',
                      pathParameters: {
                        'categoryId': product.categoryId,
                        'itemId': product.id,
                      },
                    );
                  },
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: product.imageAssetPath != null
                          ? Image.asset(
                        product.imageAssetPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.inventory_2_rounded,
                            color: Colors.grey.shade400,
                            size: 30.sp,
                          );
                        },
                      )
                          : Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.grey.shade400,
                        size: 30.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(
                            'catalog_item_details',
                            pathParameters: {
                              'categoryId': product.categoryId,
                              'itemId': product.id,
                            },
                          );
                        },
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF202020),
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 4.h,
                        children: [
                          // List Price (Default Price)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                color: Colors.blue.shade200,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_offer_outlined,
                                  size: 10.sp,
                                  color: Colors.blue.shade700,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'List: ₹${orderItemData.defaultPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.blue.shade700,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isPriceModified)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_rounded,
                                    size: 10.sp,
                                    color: Colors.orange.shade700,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Modified',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.orange.shade700,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Delete Bin Button
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade400,
                    size: 22.sp,
                  ),
                  onPressed: () {
                    ref.read(orderControllerProvider.notifier).removeItem(product.id);
                    _priceControllers[product.id]?.dispose();
                    _priceControllers.remove(product.id);
                    _quantityControllers[product.id]?.dispose();
                    _quantityControllers.remove(product.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} removed'),
                        backgroundColor: Colors.red.shade400,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          // Quantity, Prices, and Subtotal
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: [
                // Qty and Sale Price
                Row(
                  children: [
                    // Quantity
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          SizedBox(
                            height: 40.h,
                            child: TextFormField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textdark,
                                fontFamily: 'Poppins',
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
                              onChanged: (value) {
                                final newQty = int.tryParse(value);
                                if (newQty != null && newQty > 0) {
                                  final stockQty = product.quantity ?? 0;
                                  if (newQty <= stockQty) {
                                    ref.read(orderControllerProvider.notifier).updateQuantity(product.id, newQty);
                                  } else {
                                    quantityController.text = stockQty.toString();
                                    quantityController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: quantityController.text.length),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Only $stockQty units available in stock'),
                                        backgroundColor: Colors.orange,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } else if (value.isEmpty || newQty == 0) {
                                  ref.read(orderControllerProvider.notifier).removeItem(product.id);
                                  _quantityControllers[product.id]?.dispose();
                                  _quantityControllers.remove(product.id);
                                  _priceControllers[product.id]?.dispose();
                                  _priceControllers.remove(product.id);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // Sale Price (formerly Set Price)
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sale Price (per unit)',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          SizedBox(
                            height: 40.h,
                            child: TextFormField(
                              controller: priceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                fontFamily: 'Poppins',
                              ),
                              decoration: InputDecoration(
                                prefixText: '₹ ',
                                prefixStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                  fontFamily: 'Poppins',
                                ),
                                filled: true,
                                fillColor: AppColors.primary.withValues(alpha: 0.05),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
                              onChanged: (value) {
                                final newPrice = double.tryParse(value);
                                if (newPrice != null && newPrice >= 0) {
                                  ref.read(orderControllerProvider.notifier).updateSetPrice(product.id, newPrice);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Subtotal
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.08),
                        AppColors.primary.withValues(alpha: 0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        '₹${orderItemData.subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlinePartySearchField(List<PartyDetails> parties) {
    final filteredParties = _searchQuery.isEmpty
        ? parties
        : parties.where((party) {
      final query = _searchQuery.toLowerCase();
      return party.name.toLowerCase().contains(query) ||
          party.ownerName.toLowerCase().contains(query) ||
          party.fullAddress.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        // Search TextField
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextFormField(
            controller: _partySearchController,
            focusNode: _partySearchFocusNode,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _showPartyDropdown = true;
                if (value.isEmpty) {
                  selectedParty = null;
                  _ownerNameController.clear();
                }
              });
            },
            onTap: () {
              setState(() {
                _showPartyDropdown = true;
              });
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              hintText: 'Party Name',
              hintStyle: TextStyle(
                color: AppColors.textHint,
                fontSize: 14.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                Icons.business_outlined,
                color: AppColors.textSecondary,
                size: 20.sp,
              ),
              suffixIcon: _partySearchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.grey.shade600,
                  size: 20.sp,
                ),
                onPressed: _clearPartySelection,
              )
                  : Icon(
                _showPartyDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
                size: 20.sp,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: AppColors.border,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: AppColors.border,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),

        // Dropdown List
        if (_showPartyDropdown && parties.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            constraints: BoxConstraints(maxHeight: 200.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: filteredParties.isEmpty
                ? Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'No parties found',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              itemCount: filteredParties.length,
              itemBuilder: (context, index) {
                final party = filteredParties[index];
                return InkWell(
                  onTap: () => _selectParty(party),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: index < filteredParties.length - 1
                            ? BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        )
                            : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18.r,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.business,
                            color: AppColors.primary,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                party.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                party.fullAddress,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}