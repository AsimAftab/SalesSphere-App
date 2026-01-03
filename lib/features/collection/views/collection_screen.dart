import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/collection/models/collection.model.dart';
import 'package:sales_sphere/features/collection/vm/collection.vm.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  void _navigateToAddCollection() {
    context.push('/add-collection');
  }

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(searchedCollectionsProvider);
    final searchQuery = ref.watch(collectionSearchQueryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textdark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Collection',
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
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
              SizedBox(height: 110.h),

              // --- SEARCH BAR ---
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => ref.read(collectionSearchQueryProvider.notifier).updateQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search collection',
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
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),

              // --- FILTER SECTION (Matched to Notes Screen) ---
              _buildFilterDropdown(),

              SizedBox(height: 12.h),

              Expanded(
                child: collectionsAsync.when(
                  data: (items) {
                    final displayList = _applyFilter(items);
                    return RefreshIndicator(
                      onRefresh: () => ref.read(collectionViewModelProvider.notifier).refresh(),
                      color: AppColors.primary,
                      child: displayList.isEmpty
                          ? _buildEmptyState(searchQuery)
                          : ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                        itemCount: displayList.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          final item = displayList[index];

                          return GestureDetector(
                            onTap: () {
                              // Navigates to the edit screen
                              context.push('/edit-collection/${item.id}');
                            },
                            child: _buildCollectionCard(item),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => Skeletonizer(
                    enabled: true,
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                      itemCount: 5,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (_, __) => Container(
                        height: 150.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigateToAddCollection();
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: Text(
          'Add Collection',
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

  Widget _buildFilterDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        // Matches the primary-tinted border from Expense screen
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _activeFilter,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 24.sp),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontFamily: 'Poppins',
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                items: [
                  _buildFilterItem('All', Icons.list, AppColors.textdark),
                  _buildFilterItem('Cash', Icons.money, Colors.green),
                  _buildFilterItem('QR Pay', Icons.qr_code_scanner, Colors.blue),
                  _buildFilterItem('Bank Transfer', Icons.account_balance, Colors.orange),
                  _buildFilterItem('Cheque', Icons.article_outlined, Colors.purple),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _activeFilter = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to keep dropdown items consistent
  DropdownMenuItem<String> _buildFilterItem(String value, IconData icon, Color iconColor) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: iconColor),
          SizedBox(width: 8.w),
          Text(value == 'All' ? 'All Collections' : value),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(CollectionListItem item) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people_outline, size: 18.sp, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Text(item.partyName, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                ],
              ),
              Text(
                '₹${NumberFormat('#,##,###').format(item.amount)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.green.shade700,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _infoRow(Icons.calendar_today_outlined, _formatDate(item.date)),
          SizedBox(height: 6.h),
          _infoRow(Icons.account_balance_wallet_outlined, item.paymentMode),
          if (item.remarks != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Divider(color: Colors.grey.shade100),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.description_outlined, size: 16.sp, color: Colors.grey.shade400),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    item.remarks!,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, height: 1.4, fontFamily: 'Poppins'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey.shade400),
        SizedBox(width: 8.w),
        Text(text, style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600, fontFamily: 'Poppins')),
      ],
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            query.isEmpty ? 'No collections found' : 'No results for "$query"',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600, fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }

  List<CollectionListItem> _applyFilter(List<CollectionListItem> items) {
    if (_activeFilter == 'All') return items;
    return items.where((element) => element.paymentMode == _activeFilter).toList();
  }
}