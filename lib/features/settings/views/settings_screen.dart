import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';

import '../../../widget/settings_tile.dart';
import '../vm/settings.vm.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
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
              Container(height: 120.h, color: Colors.transparent),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // --- Reusable Tiles ---
                    SettingsTile(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      onTap: () {
                        context.push('/profile');
                      },
                    ),
                    SettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () {
                        context.push('/settings/change-password');
                      },
                    ),
                    SizedBox(height: 40.h),
                    Text(
                      'Other Settings',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SettingsTile(
                      icon: Icons.info_outline,
                      title: 'About Sales Sphere',
                      onTap: () {
                        context.push('/about');
                      },
                    ),
                    SettingsTile(
                      icon: Icons.article_outlined,
                      title: 'Terms and Conditions',
                      onTap: () {
                        context.push('/terms-and-conditions');
                      },
                    ),
                    SettingsTile(
                      icon: Icons.logout,
                      title: 'Sign Out',
                      onTap: () async {
                        // Show confirmation dialog
                        final shouldSignOut = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text(
                              'Are you sure you want to sign out?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Sign Out'),
                              ),
                            ],
                          ),
                        );

                        if (shouldSignOut != true) return;
                        if (!context.mounted) return;

                        try {
                          // Perform sign out
                          await ref
                              .read(settingsViewModelProvider.notifier)
                              .signOut();

                          if (!context.mounted) return;

                          // Navigate to login screen
                          context.go('/');
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error signing out: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 80.h),
            ],
          ),
        ],
      ),
    );
  }
}
