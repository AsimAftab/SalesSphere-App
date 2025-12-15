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

class EstimateDetailsScreen extends ConsumerWidget {
  final String estimateId;

  const EstimateDetailsScreen({
    super.key,
    required this.estimateId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimateDetailsAsync = ref.watch(fetchEstimateDetailsProvider(estimateId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Estimate Details',
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
            onPressed: () => ref.invalidate(fetchEstimateDetailsProvider(estimateId)),
          ),
        ],
      ),
      body: estimateDetailsAsync.when(
        data: (estimate) {
          if (estimate == null) {
            return _buildNotFound();
          }
          return _buildEstimateDetails(context, ref, estimate);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error, () {
          ref.invalidate(fetchEstimateDetailsProvider(estimateId));
        }),
      ),
    );
  }

  Widget _buildEstimateDetails(BuildContext context, WidgetRef ref, InvoiceDetailsData estimate) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final createdDate = DateTime.parse(estimate.createdAt);

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
                colors: [Colors.orange.shade700, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade700.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long_outlined, color: Colors.white70, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'ESTIMATE',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  estimate.estimateNumber ?? 'N/A',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 16.h),
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
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Organization Details
          _buildSectionCard(
            title: 'From',
            icon: Icons.business_rounded,
            children: [
              _buildInfoRow('Organization', estimate.organizationName),
              _buildInfoRow('PAN/VAT', estimate.organizationPanVatNumber),
              _buildInfoRow('Phone', estimate.organizationPhone),
              _buildInfoRow('Address', estimate.organizationAddress),
            ],
          ),

          SizedBox(height: 16.h),

          // Party Details
          _buildSectionCard(
            title: 'To',
            icon: Icons.person_outline_rounded,
            children: [
              _buildInfoRow('Party Name', estimate.partyName),
              _buildInfoRow('Owner', estimate.partyOwnerName),
              _buildInfoRow('PAN/VAT', estimate.partyPanVatNumber),
              if (estimate.partyAddress.isNotEmpty)
                _buildInfoRow('Address', estimate.partyAddress),
            ],
          ),

          SizedBox(height: 16.h),

          // Items Section
          _buildSectionCard(
            title: 'Items (${estimate.items.length})',
            icon: Icons.inventory_2_outlined,
            children: [
              ...estimate.items.map((item) => _buildItemCard(item)),
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
                if (estimate.subtotal != null) ...[
                  _buildTotalRow('Subtotal', estimate.subtotal!, false),
                  SizedBox(height: 8.h),
                ],
                if (estimate.discount != null && estimate.discount! > 0) ...[
                  _buildTotalRow('Discount (${estimate.discount!.toStringAsFixed(1)}%)', 
                      (estimate.subtotal ?? 0) * estimate.discount! / 100, false, isDiscount: true),
                  SizedBox(height: 8.h),
                ],
                Divider(color: Colors.grey.shade300),
                SizedBox(height: 8.h),
                _buildTotalRow('Total Amount', estimate.totalAmount ?? 0, true),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Convert to Invoice Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showConvertDialog(context, ref, estimate),
              icon: Icon(Icons.transform_rounded, size: 20.sp),
              label: Text(
                'Convert to Invoice',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 2,
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Download PDF Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _downloadPdf(context, ref, estimate),
              icon: Icon(Icons.download_rounded, size: 20.sp, color: Colors.orange.shade700),
              label: Text(
                'Download PDF',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.orange.shade700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                side: BorderSide(color: Colors.orange.shade700, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
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
          Row(
            children: [
              Icon(icon, size: 18.sp, color: Colors.orange.shade700),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade700,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
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
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.orange.shade200),
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
                  color: Colors.orange.shade700,
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
            color: isFinal ? Colors.orange.shade700 : (isDiscount ? Colors.red : Colors.grey.shade900),
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
              'Estimate Not Found',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'The requested estimate could not be found',
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
              'Failed to load estimate',
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
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context, WidgetRef ref, InvoiceDetailsData estimate) async {
    try {
      SnackbarUtils.showInfo(context, 'Generating PDF...');

      final pdfFile = await InvoicePdfService.generateInvoicePdf(estimate);

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

  void _showConvertDialog(BuildContext parentContext, WidgetRef ref, InvoiceDetailsData estimate) {
    DateTime? selectedDate;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              Icon(Icons.transform_rounded, color: Colors.green.shade600, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'Convert to Invoice',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select expected delivery date:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 16.h),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Colors.green.shade600,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20.sp, color: Colors.grey.shade600),
                      SizedBox(width: 12.w),
                      Text(
                        selectedDate != null
                            ? DateFormat('dd MMM yyyy').format(selectedDate!)
                            : 'Select date',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Poppins',
                          color: selectedDate != null ? Colors.black87 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: selectedDate == null
                  ? null
                  : () {
                      final date = selectedDate!;
                      Navigator.of(context).pop();
                      _convertToInvoice(parentContext, ref, estimate.id, date);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Convert',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _convertToInvoice(
    BuildContext context,
    WidgetRef ref,
    String estimateId,
    DateTime expectedDate,
  ) async {
    try {
      // Show loading
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Converting to invoice...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Format date as ISO 8601 string (YYYY-MM-DD)
      final formattedDate = DateFormat('yyyy-MM-dd').format(expectedDate);

      final response = await ref.read(convertEstimateProvider.notifier).convertToInvoice(
            estimateId,
            formattedDate,
          );

      // Capture the message before navigation (provider might get disposed)
      final successMessage = response.message;

      if (!context.mounted) {
        AppLogger.w('⚠️ Context not mounted after conversion, cannot navigate');
        return;
      }

      AppLogger.d('📍 Navigating back to history screen...');

      // Invalidate histories to refresh
      ref.invalidate(estimateHistoryProvider);
      ref.invalidate(invoiceHistoryProvider);

      // Navigate back to history screen
      context.go('/invoice/history');
      
      // Show success message after navigation
      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    } catch (e) {
      AppLogger.e('Error converting estimate: $e');
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to convert: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
