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

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'History',
          style: TextStyle(
            fontSize: 18.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Invoices'),
            Tab(text: 'Estimates'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 24.sp),
            onPressed: () {
              if (_tabController.index == 0) {
                ref.invalidate(invoiceHistoryProvider);
              } else {
                ref.invalidate(estimateHistoryProvider);
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInvoiceHistoryTab(),
          _buildEstimateHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildInvoiceHistoryTab() {
    final invoicesAsync = ref.watch(invoiceHistoryProvider);

    return invoicesAsync.when(
      data: (invoices) => invoices.isEmpty
          ? _buildEmptyState('No invoices yet', 'Start creating invoices to see them here')
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
      error: (error, stack) => _buildErrorState(error, () => ref.invalidate(invoiceHistoryProvider)),
    );
  }

  Widget _buildEstimateHistoryTab() {
    final estimatesAsync = ref.watch(estimateHistoryProvider);

    return estimatesAsync.when(
      data: (estimates) => estimates.isEmpty
          ? _buildEmptyState('No estimates yet', 'Start creating estimates to see them here')
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(estimateHistoryProvider);
              },
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: estimates.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final estimate = estimates[index];
                  return _buildEstimateCard(context, ref, estimate);
                },
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error, () => ref.invalidate(estimateHistoryProvider)),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, WidgetRef ref, InvoiceHistoryItem invoice) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final createdDate = DateTime.parse(invoice.createdAt);

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            context.push('/invoice/details/${invoice.id}');
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.partyName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade900,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          if (invoice.invoiceNumber != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              invoice.invoiceNumber!,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.primary,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _buildStatusChip(invoice.status),
                  ],
                ),
                SizedBox(height: 12.h),
                Divider(height: 1, color: Colors.grey.shade200),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 4.h),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Created',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          dateFormat.format(createdDate),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (invoice.expectedDeliveryDate != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.local_shipping_outlined, size: 14.sp, color: Colors.grey.shade600),
                      SizedBox(width: 6.w),
                      Text(
                        'Delivery: ${dateFormat.format(DateTime.parse(invoice.expectedDeliveryDate!))}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadInvoice(ref, invoice),
                        icon: Icon(Icons.download_rounded, size: 16.sp),
                        label: Text(
                          'Download PDF',
                          style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/invoice/details/${invoice.id}'),
                        icon: Icon(Icons.visibility_rounded, size: 16.sp),
                        label: Text(
                          'View Details',
                          style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEstimateCard(BuildContext context, WidgetRef ref, EstimateHistoryItem estimate) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final createdDate = DateTime.parse(estimate.createdAt);

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            context.push('/estimate/details/${estimate.id}');
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            estimate.partyName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade900,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            estimate.estimateNumber,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.orange.shade700,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        'ESTIMATE',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Divider(height: 1, color: Colors.grey.shade200),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '₹${estimate.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange.shade700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Created',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          dateFormat.format(createdDate),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadEstimate(ref, estimate),
                        icon: Icon(Icons.download_rounded, size: 16.sp),
                        label: Text(
                          'Download PDF',
                          style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange.shade700,
                          side: BorderSide(color: Colors.orange.shade700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push('/estimate/details/${estimate.id}');
                        },
                        icon: Icon(Icons.visibility_rounded, size: 16.sp),
                        label: Text(
                          'View Details',
                          style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12.sp, color: status.color),
          SizedBox(width: 4.w),
          Text(
            status.displayName.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: status.color,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 80.sp, color: Colors.grey.shade300),
            SizedBox(height: 24.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
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
              'Failed to load data',
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

  Future<void> _downloadInvoice(WidgetRef ref, InvoiceHistoryItem invoice) async {
    try {
      SnackbarUtils.showInfo(context, 'Generating PDF...');

      final invoiceDetails = await ref.read(fetchInvoiceDetailsProvider(invoice.id).future);
      
      if (invoiceDetails == null) {
        throw Exception('Invoice details not found');
      }
      
      final pdfFile = await InvoicePdfService.generateInvoicePdf(invoiceDetails);

      if (!mounted) return;

      SnackbarUtils.showSuccess(context, 'PDF saved to Downloads');

      final result = await OpenFile.open(pdfFile.path);
      AppLogger.d('Open file result: ${result.type} - ${result.message}');
    } catch (e) {
      AppLogger.e('Error generating PDF: $e');
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Failed to generate PDF: ${e.toString()}');
    }
  }

  Future<void> _downloadEstimate(WidgetRef ref, EstimateHistoryItem estimate) async {
    try {
      SnackbarUtils.showInfo(context, 'Generating PDF...');

      final estimateDetails = await ref.read(fetchEstimateDetailsProvider(estimate.id).future);
      
      if (estimateDetails == null) {
        throw Exception('Estimate details not found');
      }
      
      final pdfFile = await InvoicePdfService.generateInvoicePdf(estimateDetails);

      if (!mounted) return;

      SnackbarUtils.showSuccess(context, 'PDF saved to Downloads');

      final result = await OpenFile.open(pdfFile.path);
      AppLogger.d('Open file result: ${result.type} - ${result.message}');
    } catch (e) {
      AppLogger.e('Error generating PDF: $e');
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Failed to generate PDF: ${e.toString()}');
    }
  }
}
