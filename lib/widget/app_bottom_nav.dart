import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/constants/module_config.dart';
import 'package:sales_sphere/core/providers/permission_controller.dart';

import 'directory_options_sheet.dart';

class AppBottomNav extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;
  final BuildContext parentContext;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(permissionControllerProvider);

    // Build visible navigation items dynamically
    final visibleNavItems = _buildVisibleNavItems(context, permissionState);

    return Container(
      height: 75.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Bottom Navigation Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                children: visibleNavItems,
              ),
            ),

            // Floating Invoice Button (only show if invoice or estimates enabled)
            if (permissionState.isModuleEnabled('invoices') ||
                permissionState.isModuleEnabled('estimates'))
              Positioned(
                top: -28.h,
                left: MediaQuery.of(context).size.width / 2 - 35.w,
                child: _buildFloatingInvoiceButton(permissionState),
              ),
          ],
        ),
      ),
    );
  }

  /// Build the list of visible navigation items with correct indices
  List<Widget> _buildVisibleNavItems(BuildContext context, PermissionState permissionState) {
    final items = <Widget>[];
    int logicalIndex = 0;

    // Helper to add a nav item
    void addItem(String moduleId, IconData icon, IconData activeIcon, String label, {bool isDirectory = false}) {
      // Always show if module is enabled OR if it's an always-available module (e.g., Home)
      if (permissionState.isModuleEnabled(moduleId) || ModuleConfig.isAlwaysAvailableModule(moduleId)) {
        items.add(_buildNavItem(context, logicalIndex, icon, activeIcon, label, isDirectory: isDirectory));
        logicalIndex++;
      }
    }

    // Home tab (always shown regardless of subscription) - index 0
    addItem('dashboard', Icons.home_outlined, Icons.home, 'Home');

    // Catalog tab - index 1
    addItem('products', Icons.shopping_bag_outlined, Icons.shopping_bag, 'Catalog');

    // Spacer for floating invoice button (if enabled) - Invoice button uses index 2
    if (permissionState.isModuleEnabled('invoices') || permissionState.isModuleEnabled('estimates')) {
      items.add(Expanded(child: SizedBox(height: 75.h)));
      // Spacer doesn't increment logicalIndex, but the next tab will be at index 3
      // since invoice "occupies" index 2 in the navigation
      logicalIndex = 3;
    }

    // Directory tab (show if any directory module enabled) - index 3
    if (ModuleConfig.isAnyModuleEnabled(ModuleConfig.directoryModules, permissionState.isModuleEnabled)) {
      items.add(_buildNavItem(context, logicalIndex, Icons.folder_shared_outlined, Icons.people, 'Directory', isDirectory: true));
      logicalIndex++;
    }

    // Utilities tab (show if any utility module enabled) - index 4
    if (ModuleConfig.isAnyModuleEnabled(ModuleConfig.utilityModules, permissionState.isModuleEnabled)) {
      items.add(_buildNavItem(context, logicalIndex, Icons.read_more_outlined, Icons.read_more, 'Utilities'));
      logicalIndex++;
    }

    return items;
  }

  // Responsive sizing based on screen height
  double _verticalPadding(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 700) return 3.h;  // Small screens (POCO X3 Pro, etc.)
    if (screenHeight < 850) return 5.h;  // Medium screens
    return 8.h;  // Large screens (OnePlus 12, etc.)
  }

  double _iconPadding(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 700) return 5.sp;
    if (screenHeight < 850) return 6.sp;
    return 8.sp;
  }

  double _iconSize(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 700) return 20.sp;
    if (screenHeight < 850) return 22.sp;
    return 24.sp;
  }

  double _spacing(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 700) return 2.h;
    if (screenHeight < 850) return 3.h;
    return 4.h;
  }

  double _fontSize(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 700) return 9.sp;
    return 10.sp;
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    IconData activeIcon,
    String label, {
    bool isDirectory = false,
  }) {
    final isActive = currentIndex == index;

    return Expanded(
      child: RepaintBoundary(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (isDirectory) {
                showDirectoryOptions(parentContext);
              } else {
                onTap(index);
              }
            },
            borderRadius: BorderRadius.circular(16.r),
            splashColor: AppColors.secondary.withValues(alpha: 0.1),
            highlightColor: AppColors.secondary.withValues(alpha: 0.05),
            child: Container(
              height: double.infinity,
              padding: EdgeInsets.symmetric(vertical: _verticalPadding(context)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.all(isActive ? _iconPadding(context) : 0),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.secondary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Semantics(
                      label: label,
                      selected: isActive,
                      button: true,
                      child: Icon(
                        isActive ? activeIcon : icon,
                        color: isActive
                            ? AppColors.secondary
                            : AppColors.textSecondary,
                        size: _iconSize(context),
                      ),
                    ),
                  ),
                  SizedBox(height: _spacing(context)),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontSize: _fontSize(context),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.2,
                      height: 1.0,
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaler: const TextScaler.linear(1.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingInvoiceButton(PermissionState permissionState) {
    // Calculate the correct invoice tab index dynamically based on enabled modules
    final invoiceIndex = _calculateInvoiceTabIndex(permissionState);

    return RepaintBoundary(
      child: Semantics(
        label: 'Invoice',
        button: true,
        child: GestureDetector(
          onTap: () => onTap(invoiceIndex),
          child: Container(
          width: 70.w,
          height: 70.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                spreadRadius: -4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description, color: Colors.white, size: 30.sp),
              SizedBox(height: 2.h),
              Text(
                'Invoice',
                style: TextStyle(
                  fontSize: 8.sp,
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

  /// Calculate the correct tab index for the invoice button based on enabled modules
  int _calculateInvoiceTabIndex(PermissionState permissionState) {
    // The Invoice button always uses index 2, which is the spacer position
    // between Catalog (index 1) and Directory (index 3)
    // This is a fixed index regardless of which other modules are enabled
    return 2;
  }
}
