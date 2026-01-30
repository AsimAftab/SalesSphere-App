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

/// Data class to hold selected brands and technicians for a category
@immutable
class SiteSelectionData {
  final Set<String> brands;
  final Set<SiteTechnician> technicians;

  const SiteSelectionData({
    this.brands = const {},
    this.technicians = const {},
  });

  SiteSelectionData copyWith({
    Set<String>? brands,
    Set<SiteTechnician>? technicians,
  }) {
    return SiteSelectionData(
      brands: brands ?? this.brands,
      technicians: technicians ?? this.technicians,
    );
  }

  bool get isEmpty => brands.isEmpty && technicians.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

/// Site Interest Selector Widget
/// Compact view with chips + bottom sheet for selection
/// Supports category/brand/technician selection with "Add New" functionality
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
        technicians: interest.technicians.toSet(),
      );
    }
  }

  void _removeBrand(String categoryName, String brand) {
    setState(() {
      final current = _selectedData[categoryName];
      if (current != null) {
        final newBrands = Set<String>.from(current.brands)..remove(brand);
        if (newBrands.isEmpty && current.technicians.isEmpty) {
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
        technicians: entry.value.technicians.toList(),
      );
    }).toList();

    widget.onChanged(interests);
  }

  void _openSelectionBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, SiteSelectionData>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SiteInterestBottomSheet(
        initiallySelected: Map.from(_selectedData),
      ),
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
    return _selectedData.values.where((data) => data.isNotEmpty).length;
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

        // Add only brand chips (technicians shown inside modify selection only)
        for (final brand in data.brands) {
          chips.add(_BrandChip(
            category: categoryName,
            brand: brand,
            onRemove: widget.enabled
                ? () => _removeBrand(categoryName, brand)
                : null,
          ));
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

  // Custom technicians added to ANY category ( categoryName => Set<technicians> )
  final Map<String, Set<SiteTechnician>> _customTechnicians = {};

  @override
  void initState() {
    super.initState();
    _selectedData = Map.from(widget.initiallySelected);
    // Expand categories that have selections
    _expandedCategories.addAll(_selectedData.keys);
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _AddCategoryDialog(
        controller: controller,
        onSave: () {
          final categoryName = controller.text.trim();
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
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _AddBrandDialog(
        categoryName: categoryName,
        controller: controller,
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

  void _showAddTechnicianDialog(String categoryName) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => _AddTechnicianDialog(
        categoryName: categoryName,
        nameController: nameController,
        phoneController: phoneController,
        onSave: (technician) {
          setState(() {
            // Add to custom technicians for this category
            _customTechnicians.putIfAbsent(categoryName, () => {});
            _customTechnicians[categoryName]!.add(technician);

            // Also add to selected data so it's checked by default
            final current = _selectedData[categoryName];
            final newTechnicians =
                Set<SiteTechnician>.from(current?.technicians ?? {})
                  ..add(technician);
            _selectedData[categoryName] =
                (current ?? const SiteSelectionData()).copyWith(
              technicians: newTechnicians,
            );
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
        if (newBrands.isEmpty && current.technicians.isEmpty) {
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

  void _toggleTechnician(String categoryName, SiteTechnician technician) {
    setState(() {
      final current = _selectedData[categoryName] ?? const SiteSelectionData();
      final newTechnicians = Set<SiteTechnician>.from(current.technicians);

      // Find existing technician by name and phone (ignoring _id)
      final existingTech = newTechnicians.firstWhere(
        (t) => t.name == technician.name && t.phone == technician.phone,
        orElse: () => technician,
      );

      if (newTechnicians.contains(existingTech)) {
        newTechnicians.remove(existingTech);
        if (current.brands.isEmpty && newTechnicians.isEmpty) {
          _selectedData.remove(categoryName);
          _expandedCategories.remove(categoryName);
          return;
        }
      } else {
        newTechnicians.add(technician);
      }

      _selectedData[categoryName] =
          current.copyWith(technicians: newTechnicians);
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
    return data.brands.length + data.technicians.length;
  }

  bool _isBrandSelected(String categoryName, String brand) {
    return _selectedData[categoryName]?.brands.contains(brand) ?? false;
  }

  bool _isTechnicianSelected(String categoryName, SiteTechnician technician) {
    final selectedTechs = _selectedData[categoryName]?.technicians;
    if (selectedTechs == null) return false;
    // Compare by name and phone only, ignoring _id field which may differ
    return selectedTechs.any((t) =>
        t.name == technician.name && t.phone == technician.phone);
  }

  void _applySelection() {
    context.pop(_selectedData);
  }

  int _getTotalSelectionCount() {
    // Count only categories that have any selections
    return _selectedData.values.where((data) => data.isNotEmpty).length;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(siteCategoriesProvider);

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
                      .where((customName) =>
                          categories.every((c) => c.name != customName))
                      .map((customName) => SiteCategory(
                            id: const Uuid().v4(),
                            name: customName,
                            brands: _customCategories[customName]?.toList() ?? [],
                            technicians: [],
                            organizationId: '',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          )),
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
                  itemCount: allCategories.length + 1, // +1 for "Add New Category"
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
              loading: () => Center(
                child: CircularProgressIndicator(color: AppColors.primary),
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
                      style: TextStyle(fontSize: 16.sp, color: AppColors.error),
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
    return InkWell(
      onTap: _showAddCategoryDialog,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12.r),
          color: AppColors.primary.withValues(alpha: 0.03),
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
              'Add New Category',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
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
      if (_customBrands.containsKey(category.name)) ..._customBrands[category.name]!,
    }.toList();

    // Get all technicians: original category technicians + custom added technicians
    final allTechnicians = {
      ...category.technicians,
      if (_customTechnicians.containsKey(category.name))
        ..._customTechnicians[category.name]!,
    }.toList();

    // Total count for display
    final totalItemsCount = allBrands.length + allTechnicians.length;

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
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
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
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
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
                  padding:
                      EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
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
                      Icon(
                        Icons.add,
                        color: AppColors.primary,
                        size: 16.sp,
                      ),
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

            // Technicians section
            if (allTechnicians.isNotEmpty || true) ...[
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.engineering,
                      size: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Technicians',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (allTechnicians.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    'No technicians available',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.greyMedium,
                    ),
                  ),
                )
              else
                ...allTechnicians.map((tech) {
                  final isSelected =
                      _isTechnicianSelected(category.name, tech);
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      tech.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
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
                    onChanged: (_) => _toggleTechnician(category.name, tech),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.secondary,
                    checkColor: Colors.white,
                    dense: true,
                  );
                }),
              // Add Technician button
              InkWell(
                onTap: () => _showAddTechnicianDialog(category.name),
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  margin: EdgeInsets.only(top: 4.h),
                  padding:
                      EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: (AppColors.secondary)
                          .withValues(alpha: 0.3),
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
                        'Add Technician',
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
// ADD CATEGORY DIALOG
// ============================================================================

class _AddCategoryDialog extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSave;

  const _AddCategoryDialog({
    required this.controller,
    required this.onSave,
  });

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (widget.controller.text.trim().isNotEmpty) {
      widget.onSave();
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add New Category',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Category Name',
              hintText: 'e.g., Security Systems',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
            ),
            onSubmitted: (_) => _handleSave(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Add',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ADD BRAND DIALOG
// ============================================================================

class _AddBrandDialog extends StatefulWidget {
  final String categoryName;
  final TextEditingController controller;
  final Function(String) onSave;

  const _AddBrandDialog({
    required this.categoryName,
    required this.controller,
    required this.onSave,
  });

  @override
  State<_AddBrandDialog> createState() => _AddBrandDialogState();
}

class _AddBrandDialogState extends State<_AddBrandDialog> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (widget.controller.text.trim().isNotEmpty) {
      widget.onSave(widget.controller.text.trim());
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Brand to ${widget.categoryName}',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Brand Name',
              hintText: 'e.g., Hikvision',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
            ),
            onSubmitted: (_) => _handleSave(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Add',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ADD TECHNICIAN DIALOG
// ============================================================================

class _AddTechnicianDialog extends StatefulWidget {
  final String categoryName;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final Function(SiteTechnician) onSave;

  const _AddTechnicianDialog({
    required this.categoryName,
    required this.nameController,
    required this.phoneController,
    required this.onSave,
  });

  @override
  State<_AddTechnicianDialog> createState() => _AddTechnicianDialogState();
}

class _AddTechnicianDialogState extends State<_AddTechnicianDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    widget.nameController.dispose();
    widget.phoneController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final technician = SiteTechnician(
        name: widget.nameController.text.trim(),
        phone: widget.phoneController.text.trim(),
      );
      widget.onSave(technician);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Technician to ${widget.categoryName}',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: widget.nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Technician Name',
                hintText: 'e.g., Ramesh Tech',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).nextFocus();
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter technician name';
                }
                return null;
              },
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: widget.phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'e.g., 98765123456',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSave(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                if (value.trim().length < 10) {
                  return 'Phone number must be at least 10 digits';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Add',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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
