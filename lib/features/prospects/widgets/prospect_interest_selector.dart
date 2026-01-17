import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/features/prospects/models/prospect_interest.model.dart';

part 'prospect_interest_selector.g.dart';

/// Prospect Interest Selector Widget
/// Compact view with chips + bottom sheet for selection
class ProspectInterestSelector extends ConsumerStatefulWidget {
  /// Initially selected interests (for edit mode)
  final List<ProspectInterest> initiallySelected;

  /// Callback when selection changes
  final Function(List<ProspectInterest>) onChanged;

  /// Whether the selector is enabled (allows modification)
  final bool enabled;

  const ProspectInterestSelector({
    super.key,
    this.initiallySelected = const [],
    required this.onChanged,
    this.enabled = true,
  });

  @override
  ConsumerState<ProspectInterestSelector> createState() =>
      _ProspectInterestSelectorState();
}

class _ProspectInterestSelectorState
    extends ConsumerState<ProspectInterestSelector> {
  // Track selected brands per category (categoryName -> Set of selected brands)
  final Map<String, Set<String>> _selectedBrands = {};

  @override
  void initState() {
    super.initState();
    _initializeSelectedBrands();
  }

  @override
  void didUpdateWidget(ProspectInterestSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallySelected != widget.initiallySelected) {
      _initializeSelectedBrands();
    }
  }

  void _initializeSelectedBrands() {
    _selectedBrands.clear();
    for (final interest in widget.initiallySelected) {
      _selectedBrands[interest.category] = interest.brands.toSet();
    }
  }

  void _removeBrand(String categoryName, String brand) {
    setState(() {
      if (_selectedBrands.containsKey(categoryName)) {
        _selectedBrands[categoryName]!.remove(brand);
        if (_selectedBrands[categoryName]!.isEmpty) {
          _selectedBrands.remove(categoryName);
        }
      }
      _notifyChanges();
    });
  }

  void _removeCategory(String categoryName) {
    setState(() {
      _selectedBrands.remove(categoryName);
      _notifyChanges();
    });
  }

  void _notifyChanges() {
    final interests = _selectedBrands.entries.map((entry) {
      return ProspectInterest(
        category: entry.key,
        brands: entry.value.toList(),
      );
    }).toList();

    widget.onChanged(interests);
  }

  void _openSelectionBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, Set<String>>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProspectInterestBottomSheet(
        initiallySelected: Map.from(_selectedBrands),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedBrands.clear();
        _selectedBrands.addAll(result);
        _notifyChanges();
      });
    }
  }

  int _getTotalSelectionCount() {
    return _selectedBrands.values.fold(0, (sum, brands) => sum + brands.length);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prospect Interests (Optional)',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            if (_getTotalSelectionCount() > 0)
              Text(
                '${_getTotalSelectionCount()} selected',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),

        // Selection display area
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyLight),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: [
              // Selected chips or empty state
              if (_selectedBrands.isEmpty)
                _buildEmptyState()
              else
                _buildSelectedChips(),

              SizedBox(height: 8.h),

              // Add button (only show when enabled)
              if (widget.enabled)
                InkWell(
                  onTap: _openSelectionBottomSheet,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _selectedBrands.isEmpty
                              ? 'Select Interests'
                              : 'Modify Selection',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.greyMedium,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            'No interests selected',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedChips() {
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: _selectedBrands.entries.expand((entry) {
        final categoryName = entry.key;
        final brands = entry.value;

        return brands.map((brand) {
          return _BrandChip(
            category: categoryName,
            brand: brand,
            onRemove: widget.enabled ? () => _removeBrand(categoryName, brand) : null,
          );
        });
      }).toList(),
    );
  }
}

// ============================================================================
// BRAND CHIP WIDGET
// ============================================================================

class _BrandChip extends StatelessWidget {
  final String category;
  final String brand;
  final VoidCallback? onRemove;

  const _BrandChip({
    required this.category,
    required this.brand,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            brand,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            '($category)',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
            ),
          ),
          if (onRemove != null) ...[
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: onRemove,
              child: Padding(
                padding: EdgeInsets.only(left: 2.w),
                child: Icon(
                  Icons.close,
                  size: 14.sp,
                  color: AppColors.greyMedium,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// BOTTOM SHEET FOR SELECTION
// ============================================================================

class _ProspectInterestBottomSheet extends ConsumerStatefulWidget {
  final Map<String, Set<String>> initiallySelected;

  const _ProspectInterestBottomSheet({
    required this.initiallySelected,
  });

  @override
  ConsumerState<_ProspectInterestBottomSheet> createState() =>
      _ProspectInterestBottomSheetState();
}

class _ProspectInterestBottomSheetState
    extends ConsumerState<_ProspectInterestBottomSheet> {
  late Map<String, Set<String>> _selectedBrands;
  final Set<String> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _selectedBrands = Map.from(widget.initiallySelected);
    // Expand categories that have selections
    _expandedCategories.addAll(_selectedBrands.keys);
  }

  void _toggleBrand(String categoryName, String brand) {
    setState(() {
      if (!_selectedBrands.containsKey(categoryName)) {
        _selectedBrands[categoryName] = {};
      }

      if (_selectedBrands[categoryName]!.contains(brand)) {
        _selectedBrands[categoryName]!.remove(brand);
        if (_selectedBrands[categoryName]!.isEmpty) {
          _selectedBrands.remove(categoryName);
          _expandedCategories.remove(categoryName);
        }
      } else {
        _selectedBrands[categoryName]!.add(brand);
      }
    });
  }

  void _toggleCategory(String categoryName) {
    setState(() {
      if (_expandedCategories.contains(categoryName)) {
        _expandedCategories.remove(categoryName);
      } else {
        _expandedCategories.add(categoryName);
      }
    });
  }

  int _getSelectedCountForCategory(String categoryName) {
    return _selectedBrands[categoryName]?.length ?? 0;
  }

  bool _isBrandSelected(String categoryName, String brand) {
    return _selectedBrands[categoryName]?.contains(brand) ?? false;
  }

  void _applySelection() {
    Navigator.of(context).pop(_selectedBrands);
  }

  int _getTotalSelectionCount() {
    return _selectedBrands.values.fold(0, (sum, brands) => sum + brands.length);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(prospectCategoriesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.greyMedium,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Prospect Interests',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_getTotalSelectionCount() > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${_getTotalSelectionCount()} selected',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Categories list
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.greyMedium,
                          size: 48.sp,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No categories available',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final selectedCount = _getSelectedCountForCategory(
                      category.name,
                    );
                    final isExpanded =
                        _expandedCategories.contains(category.name);

                    return _buildCategoryCard(
                      category: category,
                      isExpanded: isExpanded,
                      selectedCount: selectedCount,
                    );
                  },
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
              error: (_, error) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48.sp,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load categories',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applySelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply Selection',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required ProspectCategory category,
    required bool isExpanded,
    required int selectedCount,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: selectedCount > 0
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.greyLight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        color: selectedCount > 0
            ? AppColors.primary.withOpacity(0.03)
            : Colors.white,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          childrenPadding: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            bottom: 12.h,
          ),
          onExpansionChanged: (_) => _toggleCategory(category.name),
          leading: Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: selectedCount > 0
                  ? AppColors.primary
                  : AppColors.greyLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                selectedCount.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: selectedCount > 0 ? Colors.white : AppColors.greyMedium,
                ),
              ),
            ),
          ),
          title: Text(
            category.name,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedCount == 0
                    ? '${category.brands.length} brands'
                    : '$selectedCount of ${category.brands.length}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.greyMedium,
                size: 20.sp,
              ),
            ],
          ),
          children: [
            ...category.brands.map((brand) {
              final isSelected = _isBrandSelected(category.name, brand);
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  brand,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                value: isSelected,
                onChanged: (_) => _toggleBrand(category.name, brand),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
                checkColor: Colors.white,
                dense: true,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PROVIDER FOR PROSPECT CATEGORIES
// ============================================================================

@riverpod
Future<List<ProspectCategory>> prospectCategories(Ref ref) async {
  final dio = ref.watch(dioClientProvider);
  final response = await dio.get(ApiEndpoints.prospectCategories);

  final data = ProspectCategoriesResponse.fromJson(response.data);
  return data.data;
}
