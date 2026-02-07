import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';

/// Reusable Generic Async Dropdown Component
///
/// A specialized dropdown for selecting items from an async data source.
/// Uses a bottom sheet modal for selection and handles all loading/error/empty states.
/// Design matches PrimaryTextField styling.
///
/// Usage for Sub-Organization:
/// ```dart
/// PrimaryAsyncDropdown<SubOrganization>(
///   itemsAsync: ref.watch(subOrganizationsViewModelProvider),
///   initialValue: _selectedSubOrganization,
///   onChanged: (value) => setState(() => _selectedSubOrganization = value),
///   enabled: _isEditMode,
///   itemLabel: (item) => item.name,
///   hintText: 'Select sub-organization (Optional)',
///   prefixIcon: Icons.business_outlined,
///   title: 'Select Sub-Organization',
/// )
/// ```
///
/// Usage for Party Type:
/// ```dart
/// PrimaryAsyncDropdown<PartyType>(
///   itemsAsync: ref.watch(partyTypesViewModelProvider),
///   initialValue: _selectedPartyType,
///   onChanged: (value) => setState(() => _selectedPartyType = value),
///   itemLabel: (item) => item.name,
///   hintText: 'Party Type',
///   prefixIcon: Icons.category_outlined,
///   title: 'Select Party Type',
/// )
/// ```
class PrimaryAsyncDropdown<T> extends ConsumerWidget {
  /// The async data containing the list of items
  final AsyncValue<List<T>> itemsAsync;

  /// Currently selected value (the name/string of the selected item)
  final String? initialValue;

  /// Callback when selection changes
  final ValueChanged<String?> onChanged;

  /// Whether the dropdown is enabled for selection
  final bool enabled;

  /// Extract the display label from item
  final String Function(T) itemLabel;

  /// Hint text when nothing is selected
  final String hintText;

  /// Prefix icon
  final IconData prefixIcon;

  /// Title for the bottom sheet
  final String title;

  /// Optional subtitle for the bottom sheet
  final String? subtitle;

  const PrimaryAsyncDropdown({
    super.key,
    required this.itemsAsync,
    this.initialValue,
    required this.onChanged,
    this.enabled = true,
    required this.itemLabel,
    required this.hintText,
    required this.prefixIcon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return itemsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildEmptyState();
        }
        return _buildDropdown(context, items);
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(),
    );
  }

  /// Build empty state when no items available
  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'No items available',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Center(
        child: SizedBox(
          width: 16.w,
          height: 16.h,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Failed to load data',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.error,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the main dropdown field
  Widget _buildDropdown(BuildContext context, List<T> items) {
    final hasSelection = initialValue != null && initialValue!.isNotEmpty;
    final shouldShowGreyStyle = !enabled;

    return InkWell(
      onTap: enabled ? () => _showBottomSheet(context, items) : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          // Grey background when disabled, surface when enabled
          color: shouldShowGreyStyle ? Colors.grey.shade100 : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            // Very light border when disabled, normal border when enabled
            color: shouldShowGreyStyle
                ? AppColors.border.withValues(alpha: 0.2)
                : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              prefixIcon,
              // Grey icon when disabled
              color: shouldShowGreyStyle
                  ? AppColors.textSecondary.withValues(alpha: 0.4)
                  : AppColors.textSecondary,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                initialValue ?? hintText,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  // Grey text when disabled, normal when enabled
                  color: hasSelection
                      ? (shouldShowGreyStyle
                            ? AppColors.textSecondary.withValues(alpha: 0.6)
                            : AppColors.textPrimary)
                      : (shouldShowGreyStyle
                            ? AppColors.textHint.withValues(alpha: 0.5)
                            : AppColors.textHint),
                ),
              ),
            ),
            Icon(
              enabled ? Icons.keyboard_arrow_down_rounded : Icons.lock_outline,
              color: shouldShowGreyStyle
                  ? AppColors.textSecondary.withValues(alpha: 0.4)
                  : AppColors.textSecondary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  /// Show the bottom sheet selection modal
  Future<void> _showBottomSheet(BuildContext context, List<T> items) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PrimaryAsyncDropdownBottomSheet<T>(
        items: items,
        initialValue: initialValue,
        itemLabel: itemLabel,
        title: title,
        subtitle: subtitle,
        prefixIcon: prefixIcon,
      ),
    );

    if (selected != null) {
      // Empty string means clear selection
      onChanged(selected.isEmpty ? null : selected);
    }
  }
}

/// Bottom sheet modal for item selection
class _PrimaryAsyncDropdownBottomSheet<T> extends StatelessWidget {
  final List<T> items;
  final String? initialValue;
  final String Function(T) itemLabel;
  final String title;
  final String? subtitle;
  final IconData prefixIcon;

  const _PrimaryAsyncDropdownBottomSheet({
    required this.items,
    this.initialValue,
    required this.itemLabel,
    required this.title,
    this.subtitle,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.only(
        top: 20.h,
        left: 20.w,
        right: 20.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Header
          Row(
            children: [
              Icon(prefixIcon, color: AppColors.primary, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
          SizedBox(height: 20.h),

          // Clear selection option
          if (initialValue != null && initialValue!.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 4.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              leading: Icon(
                Icons.clear,
                color: Colors.red.shade400,
                size: 20.sp,
              ),
              title: Text(
                'Clear selection',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                  color: Colors.red.shade400,
                ),
              ),
              onTap: () => Navigator.pop(context, ''),
            ),

          // List of items
          ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final itemLabelValue = itemLabel(item);
              final isSelected = initialValue == itemLabelValue;

              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 4.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                tileColor: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : null,
                leading: Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  size: 20.sp,
                ),
                title: Text(
                  itemLabelValue,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Poppins',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade800,
                  ),
                ),
                onTap: () => Navigator.pop(context, itemLabelValue),
              );
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
