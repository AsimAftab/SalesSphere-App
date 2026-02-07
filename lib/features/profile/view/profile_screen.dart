import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/settings/vm/settings.vm.dart';

import '../models/profile.model.dart';
import '../vm/profile.vm.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 24.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 18.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 24.w),
            child: IconButton(
              icon: Icon(Icons.logout, color: AppColors.error, size: 24.sp),
              onPressed: () => _handleLogout(context),
            ),
          ),
        ],
      ),
      body: profileState.when(
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Text(
                'Profile not found',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),
            );
          }
          return _buildProfileContent(context, ref, profile);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
              SizedBox(height: 16.h),
              Text(
                'Error loading profile',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(profileViewModelProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          children: [
            // Profile Avatar Section
            _buildProfileAvatar(context, ref, profile),
            SizedBox(height: 24.h),

            // Stats Cards Row
            _buildStatsCards(profile),
            SizedBox(height: 24.h),

            // Personal Information Section
            _buildPersonalInformation(context, profile),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
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
      await ref.read(settingsViewModelProvider.notifier).signOut();
      if (!context.mounted) return;
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
  }

  /// Profile Avatar with Camera Button
  Widget _buildProfileAvatar(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) {
    return Column(
      children: [
        Stack(
          children: [
            // Avatar Circle - Tappable for preview
            GestureDetector(
              onTap: () => _showAvatarPreview(context, profile),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.textOrange, width: 3.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  width: 112.w,
                  height: 112.h,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: profile.avatarUrl != null
                        ? _buildProfileImage(profile.avatarUrl!, profile.name)
                        : _buildAvatarFallback(profile.name),
                  ),
                ),
              ),
            ),

            // Camera Button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showImageSourceDialog(context, ref),
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.w),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Name
        Text(
          profile.name,
          style: TextStyle(
            fontSize: 20.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),

        // Role
        Text(
          profile.displayRole,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Avatar Fallback (Initials)
  Widget _buildAvatarFallback(String name) {
    // Split name and filter out empty parts
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();

    // Get first character of first 2 parts
    String initials = 'U'; // Default fallback
    if (parts.isNotEmpty) {
      initials = parts.take(2).map((e) => e[0]).join().toUpperCase();
    }

    return Container(
      color: AppColors.primary,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 40.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Build Profile Image (handles both local files and network URLs)
  Widget _buildProfileImage(String imageUrl, String fallbackName) {
    // Check if it's a local file path
    final isLocalFile =
        !imageUrl.startsWith('http://') &&
        !imageUrl.startsWith('https://') &&
        File(imageUrl).existsSync();

    if (isLocalFile) {
      // Display local file
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          AppLogger.e('Error loading local image', error);
          return _buildAvatarFallback(fallbackName);
        },
      );
    } else {
      // Display network image
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          AppLogger.e('Error loading network image', error);
          return _buildAvatarFallback(fallbackName);
        },
      );
    }
  }

  /// Stats Cards Row
  /// Shows attendance percentage and orders count for current month
  Widget _buildStatsCards(Profile profile) {
    // Get attendance percentage from API data
    final attendancePercentage =
        profile.currentMonthAttendance?.attendancePercentage ?? '0';
    final ordersCount = profile.currentMonthInvoiceCount ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            value: '$attendancePercentage%',
            label: 'Attendance',
            valueColor: AppColors.success,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            value: ordersCount.toString(),
            label: 'Orders',
            valueColor: AppColors.warning,
          ),
        ),
      ],
    );
  }

  /// Single Stat Card
  Widget _buildStatCard({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Personal Information Section
  Widget _buildPersonalInformation(BuildContext context, Profile profile) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Info Rows
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Full Name',
            value: profile.name,
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.wc_outlined,
            label: 'Gender',
            value: profile.gender ?? 'Not specified',
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: profile.phone ?? 'Not specified',
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email Address',
            value: profile.email,
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'Age',
            value: profile.age != null
                ? '${profile.age} years'
                : 'Not specified',
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.flag_outlined,
            label: 'Citizenship Number',
            value: profile.citizenshipNumber ?? 'Not specified',
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.receipt_long_outlined,
            label: 'PAN Number',
            value: profile.panNumber ?? 'Not specified',
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: profile.address ?? 'Not specified',
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.cake_outlined,
            label: 'Date of Birth',
            value: profile.dateOfBirth != null
                ? DateFormat('MMM dd, yyyy').format(profile.dateOfBirth!)
                : 'Not specified',
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date Joined',
            value: profile.dateJoined != null
                ? DateFormat('MMM dd, yyyy').format(profile.dateJoined!)
                : 'Not specified',
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.work_outline,
            label: 'Role',
            value: profile.displayRole,
          ),
        ],
      ),
    );
  }

  /// Info Row
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value.isNotEmpty ? value : 'Not specified',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: value.isNotEmpty
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Show Avatar Preview Dialog
  void _showAvatarPreview(BuildContext context, Profile profile) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Avatar preview
            Hero(
              tag: 'profile_avatar',
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.textOrange, width: 4.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Container(
                  width: 268.w,
                  height: 268.w,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: profile.avatarUrl != null
                        ? _buildProfileImage(profile.avatarUrl!, profile.name)
                        : _buildAvatarFallback(profile.name),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // Name
            Text(
              profile.name,
              style: TextStyle(
                fontSize: 22.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            // Role
            Text(
              profile.displayRole,
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show Image Source Dialog (Camera or Gallery)
  void _showImageSourceDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Image Source',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                title: Text(
                  'Camera',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ref, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                title: Text(
                  'Gallery',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ref, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pick Image from Camera or Gallery
  Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        AppLogger.i('Image picked: ${image.path}');

        // Show loading indicator
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  const Text('Uploading image...'),
                ],
              ),
              backgroundColor: AppColors.info,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Upload image to server
        final bool success = await ref
            .read(profileViewModelProvider.notifier)
            .uploadProfileImage(image.path);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Profile image updated successfully!'
                    : 'Failed to update profile image',
              ),
              backgroundColor: success ? AppColors.success : AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.e('Error picking image', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error picking image. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
