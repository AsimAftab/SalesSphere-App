import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/constants/module_config.dart';
import 'package:sales_sphere/core/providers/permission_controller.dart';
import 'package:sales_sphere/core/utils/logger.dart';

/// Typed configuration class for directory module options
class DirectoryModuleConfig {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final String routePath;

  const DirectoryModuleConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.routePath,
  });
}

class DirectoryOptionsSheet extends ConsumerWidget {
  const DirectoryOptionsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionController = ref.watch(permissionControllerProvider);

    // Get enabled directory modules using helper
    final enabledDirectoryModules = ModuleConfig.getEnabledModules(
      ModuleConfig.directoryModules,
      permissionController.isModuleEnabled,
    );

    // If all directory options are disabled, show empty state
    if (enabledDirectoryModules.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(
                  Icons.folder_shared,
                  color: AppColors.secondary,
                  size: 28.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Directory',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.3)),

          SizedBox(height: 8.h),

          // Options - only show enabled modules (render dynamically)
          ...enabledDirectoryModules.map((moduleId) => _buildModuleOption(context, moduleId)),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  /// Builds empty state when no directory modules are enabled
  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Empty state content
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                Icon(
                  Icons.folder_off,
                  size: 48.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No Directory Options Available',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Contact your administrator to enable directory modules',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleOption(BuildContext context, String moduleId) {
    final config = _getModuleConfig(moduleId);
    return RepaintBoundary(
      child: _buildOption(
        context,
        icon: config.icon,
        title: config.title,
        subtitle: config.subtitle,
        gradient: config.gradient,
        onTap: () async {
          Navigator.pop(context);
          try {
            await context.push(config.routePath);
          } catch (e) {
            AppLogger.e('Navigation error: $e');
          }
        },
      ),
    );
  }

  DirectoryModuleConfig _getModuleConfig(String moduleId) {
    switch (moduleId) {
      case 'parties':
        return const DirectoryModuleConfig(
          icon: Icons.store,
          title: 'Parties',
          subtitle: 'Manage business partners',
          gradient: LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
          ),
          routePath: '/directory/party-list',
        );
      case 'prospects':
        return const DirectoryModuleConfig(
          icon: Icons.person_search,
          title: 'Prospects',
          subtitle: 'View potential customers',
          gradient: LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFEF6C00)],
          ),
          routePath: '/directory/prospects-list',
        );
      case 'sites':
        return const DirectoryModuleConfig(
          icon: Icons.location_city,
          title: 'Sites',
          subtitle: 'Manage business locations',
          gradient: LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
          ),
          routePath: '/directory/sites-list',
        );
      default:
        return const DirectoryModuleConfig(
          icon: Icons.folder,
          title: 'Directory',
          subtitle: 'View details',
          gradient: LinearGradient(
            colors: [Color(0xFFBDBDBD), Color(0xFF757575)],
          ),
          routePath: '/',
        );
    }
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the sheet
void showDirectoryOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const DirectoryOptionsSheet(),
  );
}
