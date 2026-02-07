// lib/features/prospects/views/edit_prospect_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/google_places_service.dart';
import 'package:sales_sphere/core/services/location_service.dart';
import 'package:sales_sphere/core/utils/date_formatter.dart';
import 'package:sales_sphere/core/utils/field_validators.dart';
import 'package:sales_sphere/features/prospects/vm/edit_prospect_details.vm.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/location_picker_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/prospect_interest.model.dart';
import '../models/prospects.model.dart';
import '../views/prospect_images_screen.dart';
import '../vm/prospect_images.vm.dart';
import '../widgets/prospect_interest_selector.dart';

// Google Places service provider
final googlePlacesServiceProvider = Provider<GooglePlacesService>((ref) {
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  return GooglePlacesService(apiKey: apiKey);
});

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class EditProspectDetailsScreen extends ConsumerStatefulWidget {
  final String prospectId;

  const EditProspectDetailsScreen({super.key, required this.prospectId});

  @override
  ConsumerState<EditProspectDetailsScreen> createState() =>
      _EditProspectDetailsScreenState();
}

class _EditProspectDetailsScreenState
    extends ConsumerState<EditProspectDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditMode = false;

  // Prospect interests state
  List<ProspectInterest> _selectedInterests = [];

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _ownerNameController;
  late TextEditingController _panVatNumberController;
  late TextEditingController _fullAddressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _notesController;
  late TextEditingController _dateJoinedController;

  ProspectDetails? _currentProspect;
  LatLng? _initialLocation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _ownerNameController = TextEditingController();
    _panVatNumberController = TextEditingController();
    _fullAddressController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _notesController = TextEditingController();
    _dateJoinedController = TextEditingController();
  }

  void _populateFields(ProspectDetails prospect) {
    if (!mounted) return;
    setState(() {
      _currentProspect = prospect;
      _nameController.text = prospect.name;
      _phoneController.text = prospect.phoneNumber!;
      _emailController.text = prospect.email ?? '';
      _ownerNameController.text = prospect.ownerName;
      _panVatNumberController.text = prospect.panVatNumber ?? '';
      _fullAddressController.text = prospect.fullAddress;
      _latitudeController.text = prospect.latitude?.toString() ?? '';
      _longitudeController.text = prospect.longitude?.toString() ?? '';
      _notesController.text = prospect.notes ?? '';
      _dateJoinedController.text = DateFormatter.formatDateOnly(
        prospect.dateJoined,
      );

      // Initialize selected interests from prospect data
      _selectedInterests = prospect.prospectInterest ?? [];

      // Set initial location for map if coordinates exist
      if (prospect.latitude != null && prospect.longitude != null) {
        _initialLocation = LatLng(prospect.latitude!, prospect.longitude!);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ownerNameController.dispose();
    _panVatNumberController.dispose();
    _fullAddressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();
    _dateJoinedController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentProspect == null) return;

      final updatedProspect = _currentProspect!.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        panVatNumber: _panVatNumberController.text.trim().isEmpty
            ? null
            : _panVatNumberController.text.trim(),
        fullAddress: _fullAddressController.text.trim(),
        latitude: double.tryParse(_latitudeController.text.trim()),
        longitude: double.tryParse(_longitudeController.text.trim()),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        prospectInterest: _selectedInterests.isEmpty
            ? null
            : _selectedInterests,
        updatedAt: DateTime.now(),
      );

      try {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Updating prospect details...'),
                ],
              ),
              duration: const Duration(seconds: 30),
              backgroundColor: AppColors.primary,
            ),
          );
        }

        // Call ViewModel to update prospect via API
        await ref
            .read(editProspectViewModelProvider.notifier)
            .updateProspect(updatedProspect);

        if (mounted) {
          // Close loading snackbar
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          setState(() {
            _isEditMode = false;
            _currentProspect = updatedProspect;
          });

          // Show beautiful success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Success!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Prospect details updated successfully',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.sp,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.all(16.w),
              elevation: 6,
            ),
          );

          // Refresh the prospect details to ensure data is synced
          ref.invalidate(prospectByIdProvider(widget.prospectId));

          // Wait a moment for the provider to refresh, then repopulate fields
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              final refreshedProspectAsync = ref.read(
                prospectByIdProvider(widget.prospectId),
              );
              refreshedProspectAsync.whenData((refreshedProspect) {
                if (refreshedProspect != null && mounted) {
                  _populateFields(refreshedProspect);
                }
              });
            }
          });
        }
      } catch (e) {
        if (mounted) {
          // Close loading snackbar
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // Show beautiful error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Update Failed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          e.toString().replaceAll('Exception: ', ''),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.sp,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.all(16.w),
              elevation: 6,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleTransferToParty() async {
    if (_currentProspect == null) return;

    // Show confirmation dialog
    final shouldTransfer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Transfer to Party?',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        content: Text(
          'Are you sure you want to transfer "${_currentProspect!.name}" to a party? This action cannot be undone.',
          style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Transfer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldTransfer != true) return;

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                const Text('Transferring prospect to party...'),
              ],
            ),
            duration: const Duration(seconds: 30),
            backgroundColor: AppColors.primary,
          ),
        );
      }

      // Call ViewModel to transfer prospect to party
      final transferResponse = await ref
          .read(editProspectViewModelProvider.notifier)
          .transferProspectToParty(_currentProspect!.id);

      if (mounted) {
        // Close loading snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Show beautiful success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Success!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        transferResponse.message,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.sp,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
            elevation: 6,
          ),
        );

        // Navigate back to prospects screen after successful transfer
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // Close loading snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Show beautiful error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Transfer Failed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        e.toString().replaceAll('Exception: ', ''),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12.sp,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
            elevation: 6,
          ),
        );
      }
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _openGoogleMaps(ProspectDetails prospect) async {
    Uri? url;

    if (prospect.latitude != null && prospect.longitude != null) {
      url = Uri(
        scheme: 'geo',
        path: '0,0',
        queryParameters: {'q': '${prospect.latitude},${prospect.longitude}'},
      );
    } else if (prospect.fullAddress.isNotEmpty) {
      url = Uri(
        scheme: 'geo',
        path: '0,0',
        queryParameters: {'q': prospect.fullAddress},
      );
    }

    if (url != null) {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open maps. Is Google Maps installed?'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No address or coordinates to show'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  // Navigate to photo gallery screen
  void _navigateToPhotoGallery() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProspectImagesScreen(
          prospectId: widget.prospectId,
          prospectName: _nameController.text.isEmpty
              ? 'Prospect'
              : _nameController.text,
        ),
      ),
    );
  }

  // Photo Gallery Card Widget
  Widget _buildPhotoGalleryCard() {
    final imagesAsync = ref.watch(prospectImagesProvider(widget.prospectId));

    return GestureDetector(
      onTap: _navigateToPhotoGallery,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 18.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Photos',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textdark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                // Manage button with arrow
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      imagesAsync.when(
                        data: (images) {
                          return Text(
                            '${images.length}/5',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          );
                        },
                        loading: () => Text(
                          '...',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10.sp,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            imagesAsync.when(
              data: (images) {
                if (images.isEmpty) {
                  // Empty state - Add Photos button
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 20.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Add Photos',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Show thumbnails
                return Row(
                  children: [
                    // Thumbnails
                    Expanded(
                      child: SizedBox(
                        height: 60.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length > 3 ? 3 : images.length,
                          separatorBuilder: (_, __) => SizedBox(width: 8.w),
                          itemBuilder: (context, index) {
                            final image = images[index];
                            return Container(
                              width: 60.h,
                              height: 60.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: AppColors.greyLight,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7.r),
                                child: Image.network(
                                  image.imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 20.sp,
                                        color: Colors.grey.shade400,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // View All / Add More indicator
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Text(
                            images.length >= 5 ? 'Full' : 'Add',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            images.length >= 5 ? Icons.check : Icons.add,
                            size: 14.sp,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => Container(
                height: 60.h,
                decoration: BoxDecoration(
                  color: AppColors.greyLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              error: (_, __) => Container(
                height: 60.h,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Failed to load photos',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for the UI
  Widget _buildPageContent(ProspectDetails? prospect) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Padding(
              padding: EdgeInsets.only(top: 100.h, bottom: 16.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text.isEmpty
                                ? "Prospect Name"
                                : _nameController.text,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textdark,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 8.h),
                          InkWell(
                            // Disable tap if 'party' is null (loading)
                            onTap: prospect == null
                                ? null
                                : () => _openGoogleMaps(prospect),
                            borderRadius: BorderRadius.circular(8.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                // ✅ Center vertically
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 2.h),
                                    // ✅ small visual tweak
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      size: 14.sp,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),

                                  // ✅ Expanded so text wraps multiple lines neatly
                                  Expanded(
                                    child: Text(
                                      _fullAddressController.text.isEmpty
                                          ? 'No address set'
                                          : _fullAddressController.text,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                        height:
                                            1.4, // ✅ gives better line spacing
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),

                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.open_in_new,
                                    size: 13.sp,
                                    color: AppColors.primary.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    Text(
                      'Prospect Details',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textdark,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          PrimaryTextField(
                            label: const Text("Prospect Name"),
                            hintText: "Enter prospect name",
                            controller: _nameController,
                            prefixIcon: Icons.business_center_outlined,
                            hasFocusBorder: true,
                            enabled: _isEditMode,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Prospect name is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          PrimaryTextField(
                            label: const Text("Owner Name"),
                            hintText: "Enter owner name",
                            controller: _ownerNameController,
                            prefixIcon: Icons.person_outline,
                            hasFocusBorder: true,
                            enabled: _isEditMode,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Owner name is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          PrimaryTextField(
                            label: const Text("PAN/VAT Number"),
                            hintText: "Enter PAN/VAT number (optional)",
                            controller: _panVatNumberController,
                            prefixIcon: Icons.receipt_long_outlined,
                            hasFocusBorder: true,
                            enabled: _isEditMode,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              // ✅ OPTIONAL - No error if empty
                              if (value != null &&
                                  value.trim().isNotEmpty &&
                                  value.trim().length > 14) {
                                return 'PAN/VAT number cannot exceed 14 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          PrimaryTextField(
                            label: const Text("Phone Number"),
                            hintText: "Enter phone/mobile number",
                            controller: _phoneController,
                            prefixIcon: Icons.phone_outlined,
                            hasFocusBorder: true,
                            enabled: _isEditMode,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone number is required';
                              }
                              return FieldValidators.validatePhone(value);
                            },
                          ),
                          SizedBox(height: 16.h),
                          PrimaryTextField(
                            label: const Text("Email Address"),
                            hintText: "Enter email address (optional)",
                            controller: _emailController,
                            prefixIcon: Icons.email_outlined,
                            hasFocusBorder: true,
                            enabled: _isEditMode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty) {
                                return FieldValidators.validateEmail(value);
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          PrimaryTextField(
                            label: const Text("Notes"),
                            hintText: "Enter notes (optional)",
                            controller: _notesController,
                            prefixIcon: Icons.note_outlined,
                            hasFocusBorder: true,
                            enabled: _isEditMode,
                            minLines: 1,
                            maxLines: 5,
                            textInputAction: TextInputAction.newline,
                          ),
                          SizedBox(height: 16.h),

                          // Prospect Interests (Optional)
                          ProspectInterestSelector(
                            initiallySelected: _selectedInterests,
                            enabled: _isEditMode,
                            onChanged: (interests) {
                              if (mounted && _isEditMode) {
                                setState(() {
                                  _selectedInterests = interests;
                                });
                              }
                            },
                          ),
                          SizedBox(height: 16.h),

                          // Location Picker with Google Maps
                          LocationPickerWidget(
                            addressController: _fullAddressController,
                            latitudeController: _latitudeController,
                            longitudeController: _longitudeController,
                            initialLocation: _initialLocation,
                            placesService: ref.read(
                              googlePlacesServiceProvider,
                            ),
                            locationService: ref.read(locationServiceProvider),
                            enabled: _isEditMode,
                            addressValidator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Full address is required';
                              }
                              return null;
                            },
                            onLocationSelected: (location, address) {
                              if (mounted) {
                                setState(() {
                                  _fullAddressController.text = address;
                                  _latitudeController.text = location.latitude
                                      .toStringAsFixed(6);
                                  _longitudeController.text = location.longitude
                                      .toStringAsFixed(6);
                                });
                              }
                            },
                          ),
                          SizedBox(height: 16.h),

                          // Location Details Section
                          Text(
                            "Location Details (Auto-generated from map)",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Latitude (Non-editable)
                          PrimaryTextField(
                            label: const Text("Latitude"),
                            hintText: "Auto-generated from map",
                            controller: _latitudeController,
                            prefixIcon: Icons.explore_outlined,
                            hasFocusBorder: true,
                            enabled: false,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 16.h),

                          // Longitude (Non-editable)
                          PrimaryTextField(
                            label: const Text("Longitude"),
                            hintText: "Auto-generated from map",
                            controller: _longitudeController,
                            prefixIcon: Icons.explore_outlined,
                            hasFocusBorder: true,
                            enabled: false,
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 16.h),

                          PrimaryTextField(
                            label: const Text("Date Joined"),
                            hintText: "Date when prospect was added",
                            controller: _dateJoinedController,
                            prefixIcon: Icons.date_range_outlined,
                            hasFocusBorder: true,
                            enabled: false,
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Photo Gallery Card
                    _buildPhotoGalleryCard(),
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          constraints: BoxConstraints(minHeight: 90.h),
          padding: EdgeInsets.fromLTRB(
            16.w,
            20.h,
            16.w,
            MediaQuery.of(context).padding.bottom + 24.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: _isEditMode
              ? PrimaryButton(
                  label: 'Save Changes',
                  onPressed: _handleSave,
                  leadingIcon: Icons.check_rounded,
                  size: ButtonSize.medium,
                )
              : Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: PrimaryButton(
                        label: 'Edit Detail',
                        onPressed: prospect == null ? null : _toggleEditMode,
                        leadingIcon: Icons.edit_outlined,
                        size: ButtonSize.medium,
                        customFontSize: 14.sp,
                      ),
                    ),
                    SizedBox(width: 8.w), // Slightly safer gap
                    Flexible(
                      fit: FlexFit.tight,
                      child: PrimaryButton(
                        label: 'Transfer\nto Party',
                        onPressed: prospect == null
                            ? null
                            : _handleTransferToParty,
                        leadingIcon: Icons.swap_horiz_rounded,
                        size: ButtonSize.medium,
                        customPadding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        customFontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final prospectAsync = ref.watch(prospectByIdProvider(widget.prospectId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textdark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Details',
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          if (_isEditMode)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditMode = false;
                  if (_currentProspect != null) {
                    _populateFields(_currentProspect!);
                  }
                });
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
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

          prospectAsync.when(
            data: (prospect) {
              if (prospect == null) {
                return Center(
                  child: Text(
                    'Prospect not found',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textdark,
                    ),
                  ),
                );
              }

              // Populate fields when data is first loaded or changes
              if (_currentProspect == null ||
                  _currentProspect!.id != prospect.id) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _populateFields(prospect);
                  }
                });
              }

              return _buildPageContent(prospect);
            },
            loading: () {
              return Skeletonizer(
                enabled: true,
                child: _buildPageContent(null),
              );
            },
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
                    'Failed to load prospect details',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textdark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      error.toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
