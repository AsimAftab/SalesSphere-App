import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/sites/models/sites.model.dart';
import 'package:sales_sphere/features/sites/vm/site_options.vm.dart';
import 'package:uuid/uuid.dart';

part 'site_interest_selector.g.dart';

/// Data class to hold selected brands and siteContacts for a category
@immutable
class SiteSelectionData {
  final Set<String> brands;
  final Set<SiteTechnician> siteContacts;

  const SiteSelectionData({
    this.brands = const {},
    this.siteContacts = const {},
  });

  SiteSelectionData copyWith({
    Set<String>? brands,
    Set<SiteTechnician>? siteContacts,
  }) {
    return SiteSelectionData(
      brands: brands ?? this.brands,
      siteContacts: siteContacts ?? this.siteContacts,
    );
  }

  bool get isEmpty => brands.isEmpty && siteContacts.isEmpty;

  bool get isNotEmpty => !isEmpty;
}

/// Site Interest Selector Widget
/// Compact view with chips + bottom sheet for selection
/// Supports category/brand/siteContact selection with "Add New" functionality
class SiteInterestSelector extends ConsumerStatefulWidget {
  /// Initially selected interests (for edit mode)
  final List<SiteInterest> initiallySelected;

  /// Callback when selection changes
  final Function(List<SiteInterest>) onChanged;

  /// Whether the selector is enabled (allows modification)
  final bool enabled;

  const SiteInterestSelector({
    super.key,
    this.initiallySelected = const [],
    required this.onChanged,
    this.enabled = true,
  });

  @override
  ConsumerState<SiteInterestSelector> createState() =>
      _SiteInterestSelectorState();
}

class _SiteInterestSelectorState extends ConsumerState<SiteInterestSelector> {
  // Track selected data per category (categoryName -> SiteSelectionData)
  final Map<String, SiteSelectionData> _selectedData = {};

  @override
  void initState() {
    super.initState();
    _initializeSelectedData();
  }

  @override
  void didUpdateWidget(SiteInterestSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallySelected != widget.initiallySelected) {
      _initializeSelectedData();
    }
  }

  void _initializeSelectedData() {
    _selectedData.clear();
    for (final interest in widget.initiallySelected) {
      _selectedData[interest.category] = SiteSelectionData(
        brands: interest.brands.toSet(),
        siteContacts: interest.technicians.toSet(),
      );
    }
  }

  void _removeBrand(String categoryName, String brand) {
    setState(() {
      final current = _selectedData[categoryName];
      if (current != null) {
        final newBrands = Set<String>.from(current.brands)
          ..remove(brand);
        if (newBrands.isEmpty && current.siteContacts.isEmpty) {
          _selectedData.remove(categoryName);
        } else {
          _selectedData[categoryName] = current.copyWith(brands: newBrands);
        }
      }
      _notifyChanges();
    });
  }

  void _notifyChanges() {
    final interests = _selectedData.entries.map((entry) {
      return SiteInterest(
        category: entry.key,
        brands: entry.value.brands.toList(),
        technicians: entry.value.siteContacts.toList(),
      );
    }).toList();

    widget.onChanged(interests);
  }

  void _openSelectionBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, SiteSelectionData>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _SiteInterestBottomSheet(initiallySelected: Map.from(_selectedData)),
    );

    if (result != null) {
      setState(() {
        _selectedData.clear();
        _selectedData.addAll(result);
        _notifyChanges();
      });
    }
  }

  int _getTotalSelectionCount() {
    // Count only categories that have any selections
    return _selectedData.values
        .where((data) => data.isNotEmpty)
        .length;
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
              'Site Interests (Optional)',
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
              if (_selectedData.isEmpty)
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
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
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
                          _selectedData.isEmpty
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
          Icon(Icons.info_outline, color: AppColors.greyMedium, size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            'No interests selected',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedChips() {
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: _selectedData.entries.expand((entry) {
        final categoryName = entry.key;
        final data = entry.value;
        final chips = <Widget>[];

        // Add only brand chips (siteContacts shown inside modify selection only)
        for (final brand in data.brands) {
          chips.add(
            _BrandChip(
              category: categoryName,
              brand: brand,
              onRemove: widget.enabled
                  ? () => _removeBrand(categoryName, brand)
                  : null,
            ),
          );
        }

        return chips;
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
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
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
            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
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

class _SiteInterestBottomSheet extends ConsumerStatefulWidget {
  final Map<String, SiteSelectionData> initiallySelected;

  const _SiteInterestBottomSheet({required this.initiallySelected});

  @override
  ConsumerState<_SiteInterestBottomSheet> createState() =>
      _SiteInterestBottomSheetState();
}

class _SiteInterestBottomSheetState
    extends ConsumerState<_SiteInterestBottomSheet> {
  late Map<String, SiteSelectionData> _selectedData;
  final Set<String> _expandedCategories = {};

  // Custom categories added by user ( categoryName => Set<brands> )
  final Map<String, Set<String>> _customCategories = {};

  // Custom brands added to ANY category ( categoryName => Set<brands> )
  final Map<String, Set<String>> _customBrands = {};

  // Custom siteContacts added to ANY category ( categoryName => Set<siteContacts> )
  final Map<String, Set<SiteTechnician>> _customSiteContacts = {};

  @override
  void initState() {
    super.initState();
    _selectedData = Map.from(widget.initiallySelected);
    // Expand categories that have selections
    _expandedCategories.addAll(_selectedData.keys);
  }

  void _showAddCategoryDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) =>
          _AddCategoryBottomSheet(
            onSave: (categoryName) {
              if (categoryName.isNotEmpty) {
                setState(() {
                  _customCategories.putIfAbsent(categoryName, () => {});
                  _expandedCategories.add(categoryName);
                });
              }
            },
          ),
    );
  }

  void _showAddBrandDialog(String categoryName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) =>
          _AddBrandBottomSheet(
            categoryName: categoryName,
            onSave: (brandName) {
              final brand = brandName.trim();
              if (brand.isNotEmpty) {
                setState(() {
                  // Add to custom brands for this category
                  _customBrands.putIfAbsent(categoryName, () => {});
                  _customBrands[categoryName]!.add(brand);

                  // Also add to selected data so it's checked by default
                  final current = _selectedData[categoryName];
                  final newBrands = Set<String>.from(current?.brands ?? {})
                    ..add(brand);
                  _selectedData[categoryName] =
                      (current ?? const SiteSelectionData()).copyWith(
                        brands: newBrands,
                      );
                });
              }
            },
          ),
    );
  }

  void _showAddSiteContactDialog(String categoryName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) =>
          _AddSiteContactBottomSheet(
            categoryName: categoryName,
            onSave: (siteContact) {
              setState(() {
                // Add to custom siteContacts for this category
                _customSiteContacts.putIfAbsent(categoryName, () => {});
                _customSiteContacts[categoryName]!.add(siteContact);

                // Also add to selected data so it's checked by default
                final current = _selectedData[categoryName];
                final newSiteContacts = Set<SiteTechnician>.from(
                  current?.siteContacts ?? {},
                )
                  ..add(siteContact);
                _selectedData[categoryName] =
                    (current ?? const SiteSelectionData())
                        .copyWith(siteContacts: newSiteContacts);
              });
            },
          ),
    );
  }

  void _toggleBrand(String categoryName, String brand) {
    setState(() {
      final current = _selectedData[categoryName] ?? const SiteSelectionData();
      final newBrands = Set<String>.from(current.brands);

      if (newBrands.contains(brand)) {
        newBrands.remove(brand);
        if (newBrands.isEmpty && current.siteContacts.isEmpty) {
          _selectedData.remove(categoryName);
          _expandedCategories.remove(categoryName);
          return;
        }
      } else {
        newBrands.add(brand);
      }

      _selectedData[categoryName] = current.copyWith(brands: newBrands);
    });
  }

  void _toggleSiteContact(String categoryName, SiteTechnician siteContact) {
    setState(() {
      final current = _selectedData[categoryName] ?? const SiteSelectionData();
      final newSiteContacts = Set<SiteTechnician>.from(current.siteContacts);

      // Find existing siteContact by name and phone (ignoring _id)
      final existingTech = newSiteContacts.firstWhere(
            (t) => t.name == siteContact.name && t.phone == siteContact.phone,
        orElse: () => siteContact,
      );

      if (newSiteContacts.contains(existingTech)) {
        newSiteContacts.remove(existingTech);
        if (current.brands.isEmpty && newSiteContacts.isEmpty) {
          _selectedData.remove(categoryName);
          _expandedCategories.remove(categoryName);
          return;
        }
      } else {
        newSiteContacts.add(siteContact);
      }

      _selectedData[categoryName] = current.copyWith(
        siteContacts: newSiteContacts,
      );
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
    final data = _selectedData[categoryName];
    if (data == null) return 0;
    return data.brands.length + data.siteContacts.length;
  }

  bool _isBrandSelected(String categoryName, String brand) {
    return _selectedData[categoryName]?.brands.contains(brand) ?? false;
  }

  bool _isSiteContactSelected(String categoryName, SiteTechnician siteContact) {
    final selectedTechs = _selectedData[categoryName]?.siteContacts;
    if (selectedTechs == null) return false;
    // Compare by name and phone only, ignoring _id field which may differ
    return selectedTechs.any(
          (t) => t.name == siteContact.name && t.phone == siteContact.phone,
    );
  }

  void _applySelection() {
    context.pop(_selectedData);
  }

  int _getTotalSelectionCount() {
    // Count only categories that have any selections
    return _selectedData.values
        .where((data) => data.isNotEmpty)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(siteCategoriesProvider);

    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height * 0.75,
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
                  'Select Site Interests',
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
                      color: AppColors.primary.withValues(alpha: 0.1),
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
                // Combine API categories with custom categories
                final allCategories = [
                  ...categories,
                  // Add custom categories that aren't in API response
                  ..._customCategories.keys
                      .where(
                        (customName) =>
                        categories.every((c) => c.name != customName),
                  )
                      .map(
                        (customName) =>
                        SiteCategory(
                          id: const Uuid().v4(),
                          name: customName,
                          brands: _customCategories[customName]?.toList() ?? [],
                          technicians: [],
                          organizationId: '',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                  ),
                ];

                if (allCategories.isEmpty) {
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
                  itemCount: allCategories.length + 1,
                  // +1 for "Add New Category"
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    // Add New Category button at the top
                    if (index == 0) {
                      return _buildAddNewCategoryCard();
                    }

                    // Adjust index for actual categories
                    final categoryIndex = index - 1;
                    final category = allCategories[categoryIndex];
                    final selectedCount = _getSelectedCountForCategory(
                      category.name,
                    );
                    final isExpanded = _expandedCategories.contains(
                      category.name,
                    );

                    return _buildCategoryCard(
                      category: category,
                      isExpanded: isExpanded,
                      selectedCount: selectedCount,
                    );
                  },
                );
              },
              loading: () =>
                  Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
              error: (_, error) =>
                  Center(
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
                              fontSize: 16.sp, color: AppColors.error),
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

  Widget _buildAddNewCategoryCard() {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showAddCategoryDialog,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
                SizedBox(width: 10.w),
                Text(
                  'Add New Category',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required SiteCategory category,
    required bool isExpanded,
    required int selectedCount,
  }) {
    // Check if this is a custom category
    final isCustomCategory = _customCategories.containsKey(category.name);

    // Get all brands: original category brands + custom added brands
    final allBrands = {
      ...category.brands,
      if (_customBrands.containsKey(category.name))
        ..._customBrands[category.name]!,
    }.toList();

    // Get all siteContacts: original category siteContacts + custom added siteContacts
    final allSiteContacts = {
      ...category.technicians,
      if (_customSiteContacts.containsKey(category.name))
        ..._customSiteContacts[category.name]!,
    }.toList();

    // Total count for display
    final totalItemsCount = allBrands.length + allSiteContacts.length;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: selectedCount > 0
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.greyLight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        color: selectedCount > 0
            ? AppColors.primary.withValues(alpha: 0.03)
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
                  color: selectedCount > 0
                      ? Colors.white
                      : AppColors.greyMedium,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isCustomCategory) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Custom',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedCount == 0
                    ? '$totalItemsCount items'
                    : '$selectedCount of $totalItemsCount',
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
            // Brands section
            if (allBrands.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  'Brands',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ...allBrands.map((brand) {
                final isSelected = _isBrandSelected(category.name, brand);
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    brand,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                  value: isSelected,
                  onChanged: (_) => _toggleBrand(category.name, brand),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                  checkColor: Colors.white,
                  dense: true,
                );
              }),
              // Add Brand button
              InkWell(
                onTap: () => _showAddBrandDialog(category.name),
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  margin: EdgeInsets.only(top: 4.h),
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 12.w,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: AppColors.primary, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(
                        'Add Brand',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Site Contacts section
            if (allSiteContacts.isNotEmpty || true) ...[
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.contact_page,
                      size: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Site Contacts',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (allSiteContacts.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    'No site contacts available',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.greyMedium,
                    ),
                  ),
                )
              else
                ...allSiteContacts.map((tech) {
                  final isSelected = _isSiteContactSelected(
                      category.name, tech);
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      tech.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      tech.phone,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: isSelected,
                    onChanged: (_) => _toggleSiteContact(category.name, tech),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.secondary,
                    checkColor: Colors.white,
                    dense: true,
                  );
                }),
              // Add Site Contact button
              InkWell(
                onTap: () => _showAddSiteContactDialog(category.name),
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  margin: EdgeInsets.only(top: 4.h),
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 12.w,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: (AppColors.secondary).withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add,
                        color: AppColors.secondary,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Add Site Contact',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ADD CATEGORY BOTTOM SHEET
// ============================================================================

class _AddCategoryBottomSheet extends StatefulWidget {
  final Function(String) onSave;

  const _AddCategoryBottomSheet({required this.onSave});

  @override
  State<_AddCategoryBottomSheet> createState() =>
      _AddCategoryBottomSheetState();
}

class _AddCategoryBottomSheetState extends State<_AddCategoryBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    _controller.removeListener(_validateInput);
    _controller.dispose();
    _isValidNotifier.dispose();
    super.dispose();
  }

  void _validateInput() {
    _isValidNotifier.value = _controller.text
        .trim()
        .isNotEmpty;
  }

  void _handleSave() {
    if (_isValidNotifier.value) {
      widget.onSave(_controller.text.trim());
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery
        .of(context)
        .viewInsets
        .bottom;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                RepaintBoundary(
                  child: Container(
                    margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.greyMedium,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),

                // Header
                RepaintBoundary(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 12.h),
                    child: Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.category_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add New Category',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                'Enter category name below',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // Input field
                RepaintBoundary(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: 'Poppins',
                      ),
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        hintText: 'e.g., Security Systems',
                        labelStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15.sp,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                            color: AppColors.greyLight.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        prefixIcon: Icon(
                          Icons.label_outline_rounded,
                          color: AppColors.primary,
                          size: 22.sp,
                        ),
                      ),
                      onSubmitted: (_) => _handleSave(),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Action buttons
                RepaintBoundary(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              side: BorderSide(
                                color: AppColors.greyLight.withValues(
                                    alpha: 0.8),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _isValidNotifier,
                            builder: (context, isValid, child) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                height: 52.h,
                                decoration: BoxDecoration(
                                  color: isValid ? AppColors.primary : Colors
                                      .grey.shade300,
                                  borderRadius: BorderRadius.circular(14.r),
                                  boxShadow: isValid
                                      ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                      : null,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: isValid ? _handleSave : null,
                                    borderRadius: BorderRadius.circular(14.r),
                                    child: Center(
                                      child: Text(
                                        'Add Category',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ADD BRAND BOTTOM SHEET
// ============================================================================

class _AddBrandBottomSheet extends StatefulWidget {
  final String categoryName;
  final Function(String) onSave;

  const _AddBrandBottomSheet({
    required this.categoryName,
    required this.onSave,
  });

  @override
  State<_AddBrandBottomSheet> createState() => _AddBrandBottomSheetState();
}

class _AddBrandBottomSheetState extends State<_AddBrandBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    _controller.removeListener(_validateInput);
    _controller.dispose();
    _isValidNotifier.dispose();
    super.dispose();
  }

  void _validateInput() {
    _isValidNotifier.value = _controller.text
        .trim()
        .isNotEmpty;
  }

  void _handleSave() {
    if (_isValidNotifier.value) {
      widget.onSave(_controller.text.trim());
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery
        .of(context)
        .viewInsets
        .bottom;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                RepaintBoundary(
                  child: Container(
                    margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.greyMedium,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),

                // Header
                RepaintBoundary(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 12.h),
                    child: Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.branding_watermark_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Brand',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                'To: ${widget.categoryName}',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // Input field
                RepaintBoundary(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: 'Poppins',
                      ),
                      decoration: InputDecoration(
                        labelText: 'Brand Name',
                        hintText: 'e.g., Hikvision',
                        labelStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15.sp,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                            color: AppColors.greyLight.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        prefixIcon: Icon(
                          Icons.label_outline_rounded,
                          color: AppColors.primary,
                          size: 22.sp,
                        ),
                      ),
                      onSubmitted: (_) => _handleSave(),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Action buttons
                RepaintBoundary(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              side: BorderSide(
                                color: AppColors.greyLight.withValues(
                                    alpha: 0.8),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _isValidNotifier,
                            builder: (context, isValid, child) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                height: 52.h,
                                decoration: BoxDecoration(
                                  color: isValid ? AppColors.primary : Colors
                                      .grey.shade300,
                                  borderRadius: BorderRadius.circular(14.r),
                                  boxShadow: isValid
                                      ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                      : null,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: isValid ? _handleSave : null,
                                    borderRadius: BorderRadius.circular(14.r),
                                    child: Center(
                                      child: Text(
                                        'Add Brand',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ADD SITE CONTACT BOTTOM SHEET
// ============================================================================

class _AddSiteContactBottomSheet extends StatefulWidget {
  final String categoryName;
  final Function(SiteTechnician) onSave;

  const _AddSiteContactBottomSheet({
    required this.categoryName,
    required this.onSave,
  });

  @override
  State<_AddSiteContactBottomSheet> createState() =>
      _AddSiteContactBottomSheetState();
}

class _AddSiteContactBottomSheetState
    extends State<_AddSiteContactBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isValidNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateInput);
    _phoneController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateInput);
    _phoneController.removeListener(_validateInput);
    _nameController.dispose();
    _phoneController.dispose();
    _isValidNotifier.dispose();
    super.dispose();
  }

  void _validateInput() {
    final nameValid = _nameController.text
        .trim()
        .isNotEmpty;
    final phoneValid = _phoneController.text
        .trim()
        .length == 10;
    _isValidNotifier.value = nameValid && phoneValid;
  }

  void _handleSave() {
    if (_isValidNotifier.value) {
      final siteContact = SiteTechnician(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      widget.onSave(siteContact);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery
        .of(context)
        .viewInsets
        .bottom;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  RepaintBoundary(
                    child: Container(
                      margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.greyMedium,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  // Header
                  RepaintBoundary(
                    child: Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.contact_page_rounded,
                              color: Colors.white,
                              size: 22.sp,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add Site Contact',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  'To: ${widget.categoryName}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Name input field
                  RepaintBoundary(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: TextFormField(
                        controller: _nameController,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Poppins',
                        ),
                        decoration: InputDecoration(
                          labelText: 'Site Contact Name',
                          hintText: 'e.g., Ramesh Tech',
                          labelStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15.sp,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: BorderSide(
                              color: AppColors.greyLight.withValues(alpha: 0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primary,
                            size: 22.sp,
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).nextFocus();
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Phone input field
                  RepaintBoundary(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Poppins',
                        ),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'e.g., 9876512345',
                          counterText: '',
                          labelStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15.sp,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: BorderSide(
                              color: AppColors.greyLight.withValues(alpha: 0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: AppColors.primary,
                            size: 22.sp,
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleSave(),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Action buttons
                  RepaintBoundary(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                side: BorderSide(
                                  color: AppColors.greyLight.withValues(
                                      alpha: 0.8),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            flex: 2,
                            child: ValueListenableBuilder<bool>(
                              valueListenable: _isValidNotifier,
                              builder: (context, isValid, child) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  height: 52.h,
                                  decoration: BoxDecoration(
                                    color: isValid
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(14.r),
                                    boxShadow: isValid
                                        ? [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                        : null,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: isValid ? _handleSave : null,
                                      borderRadius: BorderRadius.circular(14.r),
                                      child: Center(
                                        child: Text(
                                          'Add Site Contact',
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PROVIDER FOR SITE CATEGORIES
// ============================================================================

@riverpod
Future<List<SiteCategory>> siteCategories(Ref ref) async {
  return ref.watch(siteCategoriesViewModelProvider.future);
}
