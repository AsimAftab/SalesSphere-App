import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/providers/user_controller.dart';
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
    final user = ref.watch(userControllerProvider);


    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
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
                      backgroundImage: user?.avatarUrl != null
                          ? NetworkImage(user!.avatarUrl!)
                          : null,
                      child: user?.avatarUrl == null
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
                ],
              ),

              SizedBox(height: 20.h),

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
                icon: Icons.calendar_today_outlined,
                title: 'Attendance',
                onTap: () {
                  context.push('/attendance');
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
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );

                  if (shouldSignOut != true) return;
                  if (!context.mounted) return;

                  try {
                    // Perform sign out
                    await ref.read(settingsViewModelProvider.notifier).signOut();

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
      ),
    );
  }
}

String _getInitials(String name) {
  final trimmedName = name.trim();
  if (trimmedName.isNotEmpty) {
    return trimmedName[0].toUpperCase();
  }
  return 'U';
}
