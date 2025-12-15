import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/core/utils/snackbar_utils.dart';
import '../models/invoice.models.dart';
import '../vm/invoice.vm.dart';
import '../services/invoice_pdf_service.dart';

class InvoiceDetailsScreen extends ConsumerWidget {
  final String invoiceId;

  const InvoiceDetailsScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceDetailsAsync = ref.watch(fetchInvoiceDetailsProvider(invoiceId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Invoice Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 24.sp),
            onPressed: () => ref.invalidate(fetchInvoiceDetailsProvider(invoiceId)),
          ),
        ],
      ),
      body: invoiceDetailsAsync.when(
        data: (invoice) {
          if (invoice == null) {
            return _buildNotFound();
          }
          return _buildInvoiceDetails(context, ref, invoice);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error, () {
          ref.invalidate(fetchInvoiceDetailsProvider(invoiceId));
        }),
      ),
    );
  }

  Widget _buildInvoiceDetails(BuildContext context, WidgetRef ref, InvoiceDetailsData invoice) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final createdDate = DateTime.parse(invoice.createdAt);
    final deliveryDate = invoice.expectedDeliveryDate != null
        ? DateTime.parse(invoice.expectedDeliveryDate!)
        : null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.isEstimate == true ? 'ESTIMATE' : 'INVOICE',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    fontFamily: 'Poppins',
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  invoice.invoiceNumber ?? 'N/A',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Created',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white70,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          dateFormat.format(createdDate),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    if (deliveryDate != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Delivery',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white70,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            dateFormat.format(deliveryDate),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: invoice.status.backgroundColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: invoice.status.color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(invoice.status.icon, size: 18.sp, color: invoice.status.color),
                SizedBox(width: 8.w),
                Text(
                  'Status: ${invoice.status.displayName}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: invoice.status.color,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Organization Details
          _buildSectionCard(
            title: 'From',
            children: [
              _buildInfoRow('Organization', invoice.organizationName),
              _buildInfoRow('PAN/VAT', invoice.organizationPanVatNumber),
              _buildInfoRow('Phone', invoice.organizationPhone),
              _buildInfoRow('Address', invoice.organizationAddress),
            ],
          ),

          SizedBox(height: 16.h),

          // Party Details
          _buildSectionCard(
            title: 'To',
            children: [
              _buildInfoRow('Party Name', invoice.partyName),
              _buildInfoRow('Owner', invoice.partyOwnerName),
              _buildInfoRow('PAN/VAT', invoice.partyPanVatNumber),
              if (invoice.partyAddress.isNotEmpty)
                _buildInfoRow('Address', invoice.partyAddress),
            ],
          ),

          SizedBox(height: 16.h),

          // Items Section
          _buildSectionCard(
            title: 'Items (${invoice.items.length})',
            children: [
              ...invoice.items.map((item) => _buildItemCard(item)),
            ],
          ),

          SizedBox(height: 16.h),

          // Totals Card
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (invoice.subtotal != null) ...[
                  _buildTotalRow('Subtotal', invoice.subtotal!, false),
                  SizedBox(height: 8.h),
                ],
                if (invoice.discount != null && invoice.discount! > 0) ...[
                  _buildTotalRow('Discount (${invoice.discount!.toStringAsFixed(1)}%)', 
                      (invoice.subtotal ?? 0) * invoice.discount! / 100, false, isDiscount: true),
                  SizedBox(height: 8.h),
                ],
                Divider(color: Colors.grey.shade300),
                SizedBox(height: 8.h),
                _buildTotalRow('Total Amount', invoice.totalAmount ?? 0, true),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Download PDF Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _downloadPdf(context, ref, invoice),
              icon: Icon(Icons.download_rounded, size: 20.sp),
              label: Text(
                'Download PDF',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 2,
              ),
            ),
          ),

          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade900,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(InvoiceItemData item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              Text(
                '₹${item.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildItemDetail('Qty', item.quantity.toString()),
              SizedBox(width: 16.w),
              _buildItemDetail('Price', '₹${item.price.toStringAsFixed(2)}'),
              if (item.discount > 0) ...[
                SizedBox(width: 16.w),
                _buildItemDetail('Discount', '${item.discount.toStringAsFixed(1)}%'),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetail(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, bool isFinal, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isFinal ? 16.sp : 14.sp,
            fontWeight: isFinal ? FontWeight.w700 : FontWeight.w500,
            color: isFinal ? Colors.grey.shade900 : Colors.grey.shade700,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isFinal ? 18.sp : 14.sp,
            fontWeight: isFinal ? FontWeight.w700 : FontWeight.w600,
            color: isFinal ? AppColors.primary : (isDiscount ? Colors.red : Colors.grey.shade900),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80.sp, color: Colors.grey.shade300),
            SizedBox(height: 24.h),
            Text(
              'Invoice Not Found',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'The requested invoice could not be found',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              'Failed to load invoice',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context, WidgetRef ref, InvoiceDetailsData invoice) async {
    try {
      SnackbarUtils.showInfo(context, 'Generating PDF...');

      final pdfFile = await InvoicePdfService.generateInvoicePdf(invoice);

      if (!context.mounted) return;

      SnackbarUtils.showSuccess(context, 'PDF saved to Downloads');

      final result = await OpenFile.open(pdfFile.path);
      AppLogger.d('Open file result: ${result.type} - ${result.message}');
    } catch (e) {
      AppLogger.e('Error generating PDF: $e');
      if (!context.mounted) return;
      SnackbarUtils.showError(context, 'Failed to generate PDF: ${e.toString()}');
    }
  }
}
