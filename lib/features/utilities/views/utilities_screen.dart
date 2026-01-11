import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/constants/module_config.dart';
import 'package:sales_sphere/core/providers/user_controller.dart';
import 'package:sales_sphere/core/providers/permission_controller.dart';
import 'package:sales_sphere/widget/utility_card.dart';

/// Typed configuration class for utility cards
class UtilityCardConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String routePath;

  const UtilityCardConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.routePath,
  });
}

class UtilitiesScreen extends ConsumerWidget {
  const UtilitiesScreen({super.key});

  String _getInitials(String name) {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) {
      return trimmedName[0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final permissionController = ref.watch(permissionControllerProvider);

    // Get enabled utility modules using helper
    final enabledUtilityModules = ModuleConfig.getEnabledModules(
      ModuleConfig.utilityModules,
      permissionController.isModuleEnabled,
    );

    // Check if any utilities are enabled
    final anyUtilityEnabled = enabledUtilityModules.isNotEmpty;

    // Cache avatar URL for null safety
    final avatarUrl = user?.avatarUrl;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Utilities',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Access additional field tools and actions',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.pushNamed('profile'),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textOrange,
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26.r,
                        backgroundColor: AppColors.primary,
                        backgroundImage: avatarUrl != null
                            ? NetworkImage(avatarUrl)
                            : null,
                        child: avatarUrl == null
                            ? Text(
                                _getInitials(user?.name ?? 'User'),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textWhite,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Show empty state if no utilities are enabled
              if (!anyUtilityEnabled)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48.h),
                    child: Column(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 48.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No utilities available',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Upgrade your plan to access more features',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 32.h),
                        // Settings card shown even when no utilities enabled
                        // Wrap in SizedBox to provide height constraints
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 40.w - 16.w) / 2,
                          height: ((MediaQuery.of(context).size.width - 40.w - 16.w) / 2) / 0.99,
                          child: _buildSettingsCard(),
                        ),
                      ],
                    ),
                  ),
                ),

              // Show grid with utilities + Settings card at the end
              if (anyUtilityEnabled)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 0.99,
                  // Add all utility modules + Settings card
                  children: [
                    ...enabledUtilityModules.map((moduleId) => RepaintBoundary(
                          child: _buildUtilityCard(moduleId),
                        )),
                    // Settings card as last item in grid
                    RepaintBoundary(child: _buildSettingsCard()),
                  ],
                ),

              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUtilityCard(String moduleId) {
    final config = _getUtilityCardConfig(moduleId);
    return UtilityCard(
      title: config.title,
      subtitle: config.subtitle,
      icon: config.icon,
      iconColor: config.color,
      routePath: config.routePath,
    );
  }

  Widget _buildSettingsCard() {
    return const UtilityCard(
      title: 'Settings',
      subtitle: 'Manage app preferences and account',
      icon: Icons.settings_rounded,
      iconColor: Color(0xFF607D8B),
      routePath: '/settings',
    );
  }

  UtilityCardConfig _getUtilityCardConfig(String moduleId) {
    switch (moduleId) {
      case 'attendance':
        return const UtilityCardConfig(
          title: 'Attendance',
          subtitle: 'Mark and track daily attendance',
          icon: Icons.calendar_month_rounded,
          color: Color(0xFF00ACC1),
          routePath: '/attendance',
        );
      case 'leaves':
        return const UtilityCardConfig(
          title: 'Leave Request',
          subtitle: 'Apply for leaves and track approval status',
          icon: Icons.event_busy_rounded,
          color: Color(0xFF303F9F),
          routePath: '/leave-requests',
        );
      case 'odometer':
        return const UtilityCardConfig(
          title: 'Odometer',
          subtitle: 'Track travel distance during field visits',
          icon: Icons.speed_rounded,
          color: Color(0xFF448AFF),
          routePath: '/odometer',
        );
      case 'expenses':
        return const UtilityCardConfig(
          title: 'Expense Claims',
          subtitle: 'Submit and manage expense claims',
          icon: Icons.currency_rupee_rounded,
          color: Color(0xFF00C853),
          routePath: '/expense-claims',
        );
      case 'notes':
        return const UtilityCardConfig(
          title: 'Notes',
          subtitle: 'Log discussions, feedback & issues',
          icon: Icons.chat_bubble_outline_rounded,
          color: Color(0xFFFF5252),
          routePath: '/notes',
        );
      case 'collections':
        return const UtilityCardConfig(
          title: 'Collection',
          subtitle: 'Record payments collected from parties',
          icon: Icons.account_balance_wallet_rounded,
          color: Color(0xFF26A69A),
          routePath: '/collections',
        );
      case 'tourPlan':
        return const UtilityCardConfig(
          title: 'Tour Plan',
          subtitle: 'Plan and manage daily field visits',
          icon: Icons.navigation_outlined,
          color: Color(0xFFFF9100),
          routePath: '/tour-plans',
        );
      case 'miscellaneousWork':
        return const UtilityCardConfig(
          title: 'Miscellaneous Work',
          subtitle: 'Log unplanned field tasks and assignments',
          icon: Icons.work_outline_rounded,
          color: Color(0xFF7C4DFF),
          routePath: '/miscellaneous-work',
        );
      default:
        return const UtilityCardConfig(
          title: 'Unknown',
          subtitle: 'Access this feature',
          icon: Icons.apps,
          color: Colors.grey,
          routePath: '/',
        );
    }
  }
}
