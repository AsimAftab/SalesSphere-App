import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/logger.dart';
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
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: AppColors.error,
              ),
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
      BuildContext context, WidgetRef ref, Profile profile) {
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

  /// Profile Avatar with Camera Button
  Widget _buildProfileAvatar(BuildContext context, WidgetRef ref, Profile profile) {
    return Column(
      children: [
        Stack(
          children: [
            // Avatar Circle
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: profile.profileImageUrl != null
                    ? _buildProfileImage(profile.profileImageUrl!, profile.fullName)
                    : _buildAvatarFallback(profile.fullName),
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
                    border: Border.all(
                      color: Colors.white,
                      width: 2.w,
                    ),
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
          profile.fullName,
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
          profile.role ?? 'Sales Representative',
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
    final isLocalFile = !imageUrl.startsWith('http://') &&
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
  Widget _buildStatsCards(Profile profile) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            value: profile.totalVisits.toString(),
            label: 'Visits',
            valueColor: AppColors.secondary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            value: '${profile.attendancePercentage.toStringAsFixed(0)}%',
            label: 'Attendance',
            valueColor: AppColors.success,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            value: profile.totalOrders.toString(),
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
            value: profile.fullName,
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.wc_outlined,
            label: 'Gender',
            value: profile.gender ?? 'N/A',
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: profile.phoneNumber,
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email Address',
            value: profile.email,
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.flag_outlined,
            label: 'Citizenship',
            value: profile.citizenship ?? 'N/A',
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.receipt_long_outlined,
            label: 'PAN Number',
            value: profile.panNumber ?? 'N/A',
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: profile.address,
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.cake_outlined,
            label: 'Date of Birth',
            value: profile.dateOfBirth != null
                ? DateFormat('MMM dd, yyyy').format(profile.dateOfBirth!)
                : 'N/A',
          ),
          SizedBox(height: 16.h),

          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date Joined',
            value: profile.dateJoined != null
                ? DateFormat('MMM dd, yyyy').format(profile.dateJoined!)
                : 'N/A',
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
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20.sp,
          ),
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
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
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
      BuildContext context, WidgetRef ref, ImageSource source) async {
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

        // TODO: Upload image to server and get URL
        // For now, just use the local file path
        final bool success = await ref
            .read(profileViewModelProvider.notifier)
            .updateProfileImage(image.path);

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
