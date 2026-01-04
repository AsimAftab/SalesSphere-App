import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/app_colors.dart';

/// Custom Dropdown TextField Component
/// A beautiful dropdown that matches PrimaryTextField styling
class CustomDropdownTextField<T> extends StatefulWidget {
  final String hintText;
  final T? value;
  final List<DropdownItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final IconData? prefixIcon;

  const CustomDropdownTextField({
    super.key,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.value,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  State<CustomDropdownTextField<T>> createState() => _CustomDropdownTextFieldState<T>();
}

class _CustomDropdownTextFieldState<T> extends State<CustomDropdownTextField<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;
  String? _validatorError;

  @override
  void dispose() {
    _hideDropdown();
    super.dispose();
  }

  void _hideDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      setState(() => _isDropdownOpen = false);
    }
  }

  void _showDropdown() {
    if (!widget.enabled) return;
    
    _hideDropdown();
    setState(() => _isDropdownOpen = true);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _hideDropdown,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: MediaQuery.of(context).size.width - 48.w,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, 68.h),
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.white,
                child: Container(
                  constraints: BoxConstraints(maxHeight: 350.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    separatorBuilder: (context, index) => 
                        Divider(height: 1, color: Colors.grey.shade50),
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final isSelected = widget.value == item.value;

                      return ListTile(
                        dense: true,
                        leading: item.icon != null
                            ? (item.icon is IconData
                                ? Icon(
                                    item.icon as IconData,
                                    color: Colors.grey.shade600,
                                    size: 20.sp,
                                  )
                                : Text(
                                    item.icon as String,
                                    style: TextStyle(fontSize: 20.sp),
                                  ))
                            : null,
                        title: Text(
                          item.label,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: AppColors.secondary, size: 20.sp)
                            : null,
                        onTap: () {
                          widget.onChanged(item.value);
                          // Clear error on selection
                          if (_validatorError != null) {
                            setState(() {
                              _validatorError = null;
                            });
                          }
                          _hideDropdown();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  DropdownItem<T>? get _selectedItem {
    try {
      return widget.items.firstWhere((item) => item.value == widget.value);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled;
    final shouldShowGreyStyle = !isEnabled;
    final selectedItem = _selectedItem;
    final hasError = _validatorError != null && _validatorError!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: isEnabled ? _showDropdown : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: hasError
                    ? AppColors.error.withValues(alpha: 0.05)
                    : (shouldShowGreyStyle
                        ? Colors.grey.shade100
                        : AppColors.surface),
                border: Border.all(
                  color: hasError
                      ? AppColors.error
                      : (_isDropdownOpen
                          ? AppColors.secondary
                          : (shouldShowGreyStyle
                              ? AppColors.border.withValues(alpha: 0.2)
                              : AppColors.border)),
                  width: _isDropdownOpen ? 2 : 1.5,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  if (selectedItem?.icon != null)
                    Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: selectedItem!.icon is IconData
                          ? Icon(
                              selectedItem.icon as IconData,
                              color: hasError
                                  ? AppColors.error
                                  : (shouldShowGreyStyle
                                      ? AppColors.textSecondary.withValues(alpha: 0.4)
                                      : AppColors.textSecondary),
                              size: 20.sp,
                            )
                          : Text(
                              selectedItem.icon as String,
                              style: TextStyle(fontSize: 20.sp),
                            ),
                    )
                  else if (widget.prefixIcon != null)
                    Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: Icon(
                        widget.prefixIcon,
                        color: hasError
                            ? AppColors.error
                            : (shouldShowGreyStyle
                                ? AppColors.textSecondary.withValues(alpha: 0.4)
                                : AppColors.textSecondary),
                        size: 20.sp,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      selectedItem?.label ?? widget.hintText,
                      style: TextStyle(
                        color: selectedItem != null
                            ? (shouldShowGreyStyle
                                ? AppColors.textSecondary.withValues(alpha: 0.6)
                                : AppColors.textPrimary)
                            : (shouldShowGreyStyle
                                ? AppColors.textHint.withValues(alpha: 0.5)
                                : AppColors.textHint),
                        fontFamily: 'Poppins',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (isEnabled)
                    Icon(
                      _isDropdownOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: hasError
                          ? AppColors.error
                          : Colors.grey.shade400,
                      size: 20.sp,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(left: 16.w, top: 6.h),
            child: Text(
              _validatorError!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12.sp,
                fontFamily: 'Poppins',
              ),
            ),
          ),
      ],
    );
  }

  String? validate() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.value);
      setState(() {
        _validatorError = error;
      });
      return error;
    }
    return null;
  }
}

/// Dropdown Item Model
class DropdownItem<T> {
  final T value;
  final String label;
  final dynamic icon; // Can be IconData or String (emoji)

  const DropdownItem({
    required this.value,
    required this.label,
    this.icon,
  });
}
