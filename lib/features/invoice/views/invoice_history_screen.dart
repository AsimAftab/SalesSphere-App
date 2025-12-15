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

class InvoiceHistoryScreen extends ConsumerWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoiceHistoryProvider);

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
          'Invoice History',
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
            onPressed: () => ref.invalidate(invoiceHistoryProvider),
          ),
        ],
      ),
      body: invoicesAsync.when(
        data: (invoices) => invoices.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(invoiceHistoryProvider);
                },
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: invoices.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    return _buildInvoiceCard(context, ref, invoice);
                  },
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                'Failed to load invoices',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => ref.invalidate(invoiceHistoryProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Invoice History',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Generated invoices will appear here',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, WidgetRef ref, InvoiceHistoryItem invoice) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final deliveryDate = invoice.expectedDeliveryDate != null 
        ? DateTime.parse(invoice.expectedDeliveryDate!)
        : null;
    final createdDate = DateTime.parse(invoice.createdAt);

    return GestureDetector(
      onTap: () {
        // Show elegant preview bottom sheet
        _showInvoicePreview(context, ref, invoice);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row - Invoice Number and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Invoice Number
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      invoice.invoiceNumber ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: invoice.status.backgroundColor,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: invoice.status.color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          invoice.status.icon,
                          size: 14.sp,
                          color: invoice.status.color,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          invoice.status.displayName,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: invoice.status.color,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Customer Name
              Row(
                children: [
                  Icon(
                    Icons.business_rounded,
                    size: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      invoice.partyName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF202020),
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Timestamps and Amount Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Created Date & Time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14.sp,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            dateFormat.format(createdDate),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Padding(
                        padding: EdgeInsets.only(left: 18.w),
                        child: Text(
                          timeFormat.format(createdDate),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Total Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        '₹${invoice.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Divider
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Divider(
                  color: Colors.grey.shade200,
                  height: 1,
                ),
              ),

              // Footer - Items count, Delivery date, and Download button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            deliveryDate != null 
                                ? 'Delivery: ${dateFormat.format(deliveryDate)}'
                                : 'Delivery: Not set',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                              fontFamily: 'Poppins',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // PDF Download Button
                  GestureDetector(
                    onTap: () => _downloadInvoicePdf(context, ref, invoice.id, invoice.invoiceNumber ?? 'Invoice'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.description_rounded,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'PDF',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadInvoicePdf(
    BuildContext context,
    WidgetRef ref,
    String invoiceId,
    String invoiceNumber,
  ) async {
    bool dialogShown = false;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16.h),
                  Text(
                    'Generating PDF...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      dialogShown = true;

      AppLogger.d('Fetching invoice details for: $invoiceId');

      // Fetch invoice details
      final detailsAsync = await ref.read(fetchInvoiceDetailsProvider(invoiceId).future);

      if (detailsAsync == null) {
        throw Exception('Invoice details not found');
      }

      AppLogger.d('Generating PDF for invoice: $invoiceNumber');

      // Generate PDF
      final file = await InvoicePdfService.generateInvoicePdf(detailsAsync);

      AppLogger.d('PDF generated successfully: ${file.path}');

      // Close loading dialog using root navigator
      if (dialogShown && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogShown = false;
      }

      AppLogger.d('Dialog closed');

      // Show success message with option to open
      if (context.mounted) {
        // Extract user-friendly display path
        String displayPath;
        if (file.path.contains('/Download/SalesSphere/')) {
          displayPath = 'Downloads/SalesSphere/Invoices';
        } else if (file.path.contains('/SalesSphere/')) {
          final pathParts = file.path.split('/');
          final salesSphereIndex = pathParts.indexWhere((part) => part == 'SalesSphere');
          displayPath = salesSphereIndex != -1
              ? pathParts.sublist(salesSphereIndex).join('/')
              : file.path;
        } else {
          displayPath = file.path;
        }

        SnackbarUtils.showSuccess(
          context,
          'Invoice saved to $displayPath',
          duration: const Duration(seconds: 5),
        );

        // Automatically attempt to open the PDF
        try {
          final result = await OpenFile.open(file.path);

          // If opening failed, show the full file path
          if (result.type != ResultType.done && context.mounted) {
            SnackbarUtils.showWarning(
              context,
              'Could not open PDF. Location: ${file.path}',
              duration: const Duration(seconds: 6),
            );
          }
        } catch (e) {
          AppLogger.e('Error opening PDF: $e');
          if (context.mounted) {
            SnackbarUtils.showWarning(
              context,
              'Could not open PDF. Location: ${file.path}',
              duration: const Duration(seconds: 6),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error in _downloadInvoicePdf: $e\n$stackTrace');

      // Close loading dialog if open
      if (dialogShown && context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
          AppLogger.d('Error dialog closed');
        } catch (popError) {
          AppLogger.e('Error closing dialog: $popError');
        }
      }

      // Show error message
      if (context.mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to generate PDF: ${e.toString()}',
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  void _showInvoicePreview(BuildContext context, WidgetRef ref, InvoiceHistoryItem invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvoicePreviewSheet(invoiceId: invoice.id, invoice: invoice, ref: ref),
    );
  }
}

// Elegant Invoice Preview Bottom Sheet
class InvoicePreviewSheet extends ConsumerWidget {
  final String invoiceId;
  final InvoiceHistoryItem invoice;
  final WidgetRef ref;

  const InvoicePreviewSheet({
    super.key,
    required this.invoiceId,
    required this.invoice,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final invoiceDetailsAsync = ref.watch(fetchInvoiceDetailsProvider(invoiceId));
    final deliveryDate = invoice.expectedDeliveryDate != null 
        ? DateTime.parse(invoice.expectedDeliveryDate!)
        : null;
    final createdDate = DateTime.parse(invoice.createdAt);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.all(20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invoice Preview',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF202020),
                    fontFamily: 'Poppins',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 24.sp),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          // Content
          Expanded(
            child: invoiceDetailsAsync.when(
              data: (details) => details == null
                  ? const Center(child: Text('Invoice details not found'))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Invoice Number and Date
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  invoice.invoiceNumber ?? 'Invoice',
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                // Status Badge
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: invoice.status.backgroundColor,
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: invoice.status.color.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        invoice.status.icon,
                                        size: 18.sp,
                                        color: invoice.status.color,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        invoice.status.displayName,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: invoice.status.color,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Created: ${dateFormat.format(createdDate)} at ${timeFormat.format(createdDate)}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // Organization & Party Details Row
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  'From',
                                  Icons.business,
                                  details.organizationName,
                                  details.organizationPhone,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildInfoCard(
                                  'To',
                                  Icons.person,
                                  details.partyName,
                                  details.partyOwnerName,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          // Full Address Details
                          _buildAddressSection(
                            'Organization Address',
                            details.organizationAddress,
                            details.organizationPanVatNumber,
                          ),

                          SizedBox(height: 12.h),

                          _buildAddressSection(
                            'Party Address',
                            details.partyAddress,
                            details.partyPanVatNumber,
                          ),

                          SizedBox(height: 16.h),

                          // Delivery Date Card
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.withValues(alpha: 0.1),
                                  Colors.orange.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    Icons.local_shipping,
                                    color: Colors.orange.shade700,
                                    size: 24.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Expected Delivery',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey.shade600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        deliveryDate != null
                                            ? DateFormat('EEEE, MMMM dd, yyyy').format(deliveryDate)
                                            : 'Not set',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.orange.shade700,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // Items Section
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Row(
                                    children: [
                                      Icon(Icons.inventory_2_rounded, size: 20.sp, color: AppColors.primary),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Items (${details.items.length})',
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
                                Divider(height: 1, color: Colors.grey.shade300),
                                Padding(
                                  padding: EdgeInsets.all(12.w),
                                  child: Column(
                                    children: details.items.map((item) => _buildItemRow(item)).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // Pricing Summary
                          _buildPricingSection(details),

                          SizedBox(height: 24.h),

                          // Download PDF Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await _downloadPdf(context, details, invoice.invoiceNumber ?? 'Invoice');
                              },
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
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text(
                        'Failed to load details',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(fetchInvoiceDetailsProvider(invoiceId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(
    BuildContext context,
    InvoiceDetailsData details,
    String invoiceNumber,
  ) async {
    bool dialogShown = false;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16.h),
                  Text(
                    'Generating PDF...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      dialogShown = true;

      AppLogger.d('Starting PDF generation for: $invoiceNumber');

      // Generate PDF
      final file = await InvoicePdfService.generateInvoicePdf(details);

      AppLogger.d('PDF generated successfully: ${file.path}');

      // Close loading dialog using root navigator
      if (dialogShown && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogShown = false;
      }

      AppLogger.d('Dialog closed');

      // Close preview sheet
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      AppLogger.d('Preview sheet closed');

      // Show success message with option to open
      if (context.mounted) {
        // Extract user-friendly display path
        String displayPath;
        if (file.path.contains('/Download/SalesSphere/')) {
          displayPath = 'Downloads/SalesSphere/Invoices';
        } else if (file.path.contains('/SalesSphere/')) {
          final pathParts = file.path.split('/');
          final salesSphereIndex = pathParts.indexWhere((part) => part == 'SalesSphere');
          displayPath = salesSphereIndex != -1
              ? pathParts.sublist(salesSphereIndex).join('/')
              : file.path;
        } else {
          displayPath = file.path;
        }

        SnackbarUtils.showSuccess(
          context,
          'Invoice saved to $displayPath',
          duration: const Duration(seconds: 5),
        );

        // Automatically attempt to open the PDF
        try {
          final result = await OpenFile.open(file.path);

          // If opening failed, show the full file path
          if (result.type != ResultType.done && context.mounted) {
            SnackbarUtils.showWarning(
              context,
              'Could not open PDF. Location: ${file.path}',
              duration: const Duration(seconds: 6),
            );
          }
        } catch (e) {
          AppLogger.e('Error opening PDF: $e');
          if (context.mounted) {
            SnackbarUtils.showWarning(
              context,
              'Could not open PDF. Location: ${file.path}',
              duration: const Duration(seconds: 6),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error in _downloadPdf: $e\n$stackTrace');

      // Close loading dialog if open
      if (dialogShown && context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
          AppLogger.d('Error dialog closed');
        } catch (popError) {
          AppLogger.e('Error closing dialog: $popError');
        }
      }

      // Show error message
      if (context.mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to generate PDF: ${e.toString()}',
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  Widget _buildInfoCard(String label, IconData icon, String name, String subtitle) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            name,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF202020),
              fontFamily: 'Poppins',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
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
    );
  }

  Widget _buildAddressSection(String title, String address, String panVat) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.grey.shade600),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF202020),
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.badge_outlined, size: 14.sp, color: Colors.grey.shade600),
              SizedBox(width: 6.w),
              Text(
                'PAN/VAT: $panVat',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade700,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(InvoiceDetailsData details) {
    final subtotal = details.items.fold<double>(0.0, (sum, item) => sum + item.total);

    // Backend now sends discount as a percentage (0-100)
    final discountPercent = details.discount ?? 0.0;

    // Use discountAmount from backend if available, otherwise calculate it
    // Backend calculates: discountAmount = (subtotal * discount) / 100
    final discountAmount = details.discountAmount ?? (subtotal * discountPercent / 100);

    final total = details.totalAmount ?? (subtotal - discountAmount);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.payments_rounded, size: 20.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                'Pricing Summary',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF202020),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildPriceRow('Subtotal', subtotal, isSubtotal: true),
          if (discountPercent > 0) ...[
            SizedBox(height: 12.h),
            _buildPriceRow(
              'Discount (${discountPercent.toStringAsFixed(1)}%)',
              -discountAmount,
              isDiscount: true,
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Divider(color: AppColors.primary.withValues(alpha: 0.2), thickness: 1.5),
          ),
          _buildPriceRow('Total Amount', total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildItemRow(InvoiceItemData item) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF202020),
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Qty: ${item.quantity} × ₹${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${item.total.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isSubtotal = false, bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isDiscount ? Colors.green.shade700 : const Color(0xFF202020),
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          '₹${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isTotal
                ? AppColors.primary
                : isDiscount
                    ? Colors.green.shade700
                    : const Color(0xFF202020),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}
