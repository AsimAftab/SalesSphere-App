import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/expense-claim/vm/expense_claims.vm.dart';
import 'package:sales_sphere/features/expense-claim/models/expense_claim.model.dart';
import 'package:sales_sphere/widget/error_handler_widget.dart';
import 'package:intl/intl.dart';

enum ExpenseClaimFilter {
  all,
  pending,
  approved,
  rejected,
}

class ExpenseClaimsScreen extends ConsumerStatefulWidget {
  const ExpenseClaimsScreen({super.key});

  @override
  ConsumerState<ExpenseClaimsScreen> createState() =>
      _ExpenseClaimsScreenState();
}

class _ExpenseClaimsScreenState extends ConsumerState<ExpenseClaimsScreen> {
  final TextEditingController _searchController = TextEditingController();
  ExpenseClaimFilter _activeFilter = ExpenseClaimFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(expenseClaimSearchQueryProvider.notifier).updateQuery(query);
  }

  void _navigateToExpenseClaimDetails(String claimId) {
    context.pushNamed(
      'expense_claim_details',
      pathParameters: {'claimId': claimId},
    );
  }

  void _navigateToAddExpenseClaim() {
    context.push('/add-expense-claim');
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  String _formatAmount(double amount) {
    return '${amount.toStringAsFixed(2)}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(expenseClaimSearchQueryProvider);
    final searchedClaimsAsync = ref.watch(searchedExpenseClaimsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Expense Claims',
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/images/corner_bubble.svg',
              fit: BoxFit.cover,
              height: 180.h,
            ),
          ),
          Column(
            children: [
              Container(
                height: 120.h,
                color: Colors.transparent,
              ),
              // Search Bar Section
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search claims',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade400,
                      size: 20.sp,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey.shade400,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),

              // Filter Dropdown
              _buildFilterDropdown(),

              SizedBox(height: 12.h),

              // Expense Claims Header
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Claims',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textdark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              // Expense Claims List
              Expanded(
                child: searchedClaimsAsync.when(
                  data: (claims) {
                    // Apply filter
                    final filteredClaims = _applyFilter(claims);

                    if (filteredClaims.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await ref
                              .read(expenseClaimsViewModelProvider.notifier)
                              .refresh();
                        },
                        color: AppColors.primary,
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                          children: [
                            SizedBox(height: 100.h),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 64.sp,
                                    color: Colors.grey.shade400,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    searchQuery.isEmpty
                                        ? 'No expense claims found'
                                        : 'No results for "$searchQuery"',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey.shade600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Pull down to refresh',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade400,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(expenseClaimsViewModelProvider.notifier)
                            .refresh();
                      },
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                        itemCount: filteredClaims.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final claim = filteredClaims[index];
                          // ---------------------------------------------------
                          // NEW CARD DESIGN IMPLEMENTATION
                          // ---------------------------------------------------
                          return _buildExpenseClaimCard(claim);
                        },
                      ),
                    );
                  },
                  loading: () => Skeletonizer(
                    enabled: true,
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                      itemCount: 5,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        return Container(
                          height: 140.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        );
                      },
                    ),
                  ),
                  error: (error, stack) => ErrorHandlerConsumer(
                    error: error,
                    onRefresh: (ref) =>
                        ref.invalidate(expenseClaimsViewModelProvider),
                    title: 'Failed to load expense claims',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddExpenseClaim,
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: Icon(
          Icons.add,
          color: Colors.white,
          size: 20.sp,
        ),
        label: Text(
          'Add Claim',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NEW CARD WIDGET
  // ---------------------------------------------------------------------------
  Widget _buildExpenseClaimCard(ExpenseClaimListItem claim) {
    final statusColor = _getStatusColor(claim.status);

    return GestureDetector(
      onTap: () => _navigateToExpenseClaimDetails(claim.id),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Title and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    claim.title, // Display title from API
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textdark,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    claim.status.isNotEmpty
                        ? '${claim.status[0].toUpperCase()}${claim.status.substring(1)}'
                        : '',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Row 2: Amount
            Row(
              children: [
                Icon(
                  Icons.currency_rupee, // Using Rupee to match previous context
                  size: 18.sp,
                  color: Colors.grey.shade600,
                ),
                SizedBox(width: 8.w),
                Text(
                  _formatAmount(claim.amount),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Row 3: Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(width: 8.w),
                Text(
                  _formatDate(claim.date),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Row 4: Category (Tag)
            Row(
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 16.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(width: 8.w),
                Text(
                  claim.claimType,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<ExpenseClaimListItem> _applyFilter(List<ExpenseClaimListItem> claims) {
    switch (_activeFilter) {
      case ExpenseClaimFilter.all:
        return claims;
      case ExpenseClaimFilter.pending:
        return claims
            .where((claim) => claim.status.toLowerCase() == 'pending')
            .toList();
      case ExpenseClaimFilter.approved:
        return claims
            .where((claim) => claim.status.toLowerCase() == 'approved')
            .toList();
      case ExpenseClaimFilter.rejected:
        return claims
            .where((claim) => claim.status.toLowerCase() == 'rejected')
            .toList();
    }
  }

  Widget _buildFilterDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 20.sp, color: AppColors.primary),
          SizedBox(width: 12.w),
          Text(
            'Filter:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textdark,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ExpenseClaimFilter>(
                value: _activeFilter,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                items: [
                  DropdownMenuItem(
                    value: ExpenseClaimFilter.all,
                    child: Row(
                      children: [
                        Icon(Icons.list,
                            size: 18.sp, color: AppColors.textdark),
                        SizedBox(width: 8.w),
                        const Text('All Claims'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: ExpenseClaimFilter.pending,
                    child: Row(
                      children: [
                        Icon(Icons.pending,
                            size: 18.sp, color: Colors.orange),
                        SizedBox(width: 8.w),
                        const Text('Pending'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: ExpenseClaimFilter.approved,
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 18.sp, color: Colors.green),
                        SizedBox(width: 8.w),
                        const Text('Approved'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: ExpenseClaimFilter.rejected,
                    child: Row(
                      children: [
                        Icon(Icons.cancel, size: 18.sp, color: Colors.red),
                        SizedBox(width: 8.w),
                        const Text('Rejected'),
                      ],
                    ),
                  ),
                ],
                onChanged: (ExpenseClaimFilter? newFilter) {
                  if (newFilter != null) {
                    setState(() {
                      _activeFilter = newFilter;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}