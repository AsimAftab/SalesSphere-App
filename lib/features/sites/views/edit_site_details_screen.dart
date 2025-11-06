

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sales_sphere/core/utils/date_formatter.dart';
import 'package:sales_sphere/features/sites/models/sites.model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/google_places_service.dart';
import 'package:sales_sphere/core/services/location_service.dart';
import 'package:sales_sphere/core/utils/field_validators.dart';
import 'package:sales_sphere/features/sites/vm/edit_site_details.vm.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/location_picker_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Google Places service provider
final googlePlacesServiceProvider = Provider<GooglePlacesService>((ref) {
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  return GooglePlacesService(apiKey: apiKey);
});

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class EditSiteDetailsScreen extends ConsumerStatefulWidget {
  final String siteId;

  const EditSiteDetailsScreen({
    super.key,
    required this.siteId,
  });

  @override
  ConsumerState<EditSiteDetailsScreen> createState() => _EditSiteDetailsScreenState();
}

class _EditSiteDetailsScreenState extends ConsumerState<EditSiteDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditMode = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _managerNameController;
  late TextEditingController _fullAddressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _notesController;
  late TextEditingController _dateJoinedController;

  SiteDetails? _currentSite;
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
    _managerNameController = TextEditingController();
    _fullAddressController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _notesController = TextEditingController();
    _dateJoinedController = TextEditingController();
  }

  void _populateFields(SiteDetails site) {
    if (!mounted) return;
    setState(() {
      _currentSite = site;
      _nameController.text = site.name;
      _phoneController.text = site.phoneNumber;
      _emailController.text = site.email ?? '';
      _managerNameController.text = site.managerName;
      _fullAddressController.text = site.fullAddress;
      _latitudeController.text = site.latitude?.toString() ?? '';
      _longitudeController.text = site.longitude?.toString() ?? '';
      _notesController.text = site.notes ?? '';
      _dateJoinedController.text = DateFormatter.formatDateOnly(site.dateJoined);

      if (site.latitude != null && site.longitude != null) {
        _initialLocation = LatLng(site.latitude!, site.longitude!);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _managerNameController.dispose();
    _fullAddressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();
    _dateJoinedController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentSite == null) return;

      final updatedSite = _currentSite!.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        managerName: _managerNameController.text.trim(),
        fullAddress: _fullAddressController.text.trim(),
        latitude: double.tryParse(_latitudeController.text.trim()),
        longitude: double.tryParse(_longitudeController.text.trim()),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      try {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text('Updating site details...'),
                ],
              ),
              duration: Duration(seconds: 30),
              backgroundColor: AppColors.primary,
            ),
          );
        }

        await updateSite(ref, updatedSite);

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          setState(() {
            _isEditMode = false;
            _currentSite = updatedSite;
          });

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
                          'Site details updated successfully',
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

          ref.invalidate(siteByIdProvider(widget.siteId));

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              final refreshedSiteAsync = ref.read(siteByIdProvider(widget.siteId));
              refreshedSiteAsync.whenData((refreshedSite) {
                if (refreshedSite != null && mounted) {
                  _populateFields(refreshedSite);
                }
              });
            }
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
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

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _openGoogleMaps(SiteDetails site) async {
    Uri? url;

    if (site.latitude != null && site.longitude != null) {
      url = Uri(
        scheme: 'geo',
        path: '0,0',
        queryParameters: {'q': '${site.latitude},${site.longitude}'},
      );
    } else if (site.fullAddress.isNotEmpty) {
      url = Uri(
        scheme: 'geo',
        path: '0,0',
        queryParameters: {'q': site.fullAddress},
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

  void _navigateToSiteImages() {
    context.pushNamed(
      'sites_images_screen',
      pathParameters: {'siteId': widget.siteId},
      extra: _currentSite?.name ?? 'Site Images',
    );
  }

  // Helper method for the UI
  Widget _buildPageContent(SiteDetails? site) {
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
                            _nameController.text.isEmpty ? "Site Name" : _nameController.text,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textdark,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 8.h),
                          InkWell(
                            onTap: site == null ? null : () => _openGoogleMaps(site),
                            borderRadius: BorderRadius.circular(8.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14.sp,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      _fullAddressController.text.isEmpty
                                          ? 'No address set'
                                          : _fullAddressController.text,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.open_in_new,
                                    size: 13.sp,
                                    color: AppColors.primary.withValues(alpha: 0.7),
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
                      'Site Details',
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
                            hintText: "Manager Name",
                            controller: _managerNameController,
                            prefixIcon: Icons.person_outline,
                            hasFocusBorder: true,
                            enabled: _isEditMode,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Manager name is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          PrimaryTextField(
                            hintText: "Phone/Mobile Number",
                            controller: _phoneController,
                            prefixIcon: Icons.phone_outlined,
                            hasFocusBorder: true,
                            enabled: _isEditMode,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            maxLength: 10,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone number is required';
                              }
                              return FieldValidators.validatePhone(value);
                            },
                          ),
                          SizedBox(height: 16.h),
                          PrimaryTextField(
                            hintText: "Email Address (Optional)",
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
                            hintText: "Notes (Optional)",
                            controller: _notesController,
                            prefixIcon: Icons.note_outlined,
                            hasFocusBorder: true,
                            enabled: _isEditMode,
                            minLines: 1,
                            maxLines: 5,
                            textInputAction: TextInputAction.newline,
                          ),
                          SizedBox(height: 16.h),

                          // Location Picker with Google Maps
                          LocationPickerWidget(
                            addressController: _fullAddressController,
                            latitudeController: _latitudeController,
                            longitudeController: _longitudeController,
                            initialLocation: _initialLocation,
                            placesService: ref.read(googlePlacesServiceProvider),
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
                                  _latitudeController.text = location.latitude.toStringAsFixed(6);
                                  _longitudeController.text = location.longitude.toStringAsFixed(6);
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
                            hintText: "Latitude (Auto-generated)",
                            controller: _latitudeController,
                            prefixIcon: Icons.explore_outlined,
                            hasFocusBorder: true,
                            enabled: false,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 16.h),

                          // Longitude (Non-editable)
                          PrimaryTextField(
                            hintText: "Longitude (Auto-generated)",
                            controller: _longitudeController,
                            prefixIcon: Icons.explore_outlined,
                            hasFocusBorder: true,
                            enabled: false,
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 16.h),

                          PrimaryTextField(
                            hintText: "Date Joined",
                            controller: _dateJoinedController,
                            prefixIcon: Icons.date_range_outlined,
                            hasFocusBorder: true,
                            enabled: false,
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
          ),
        ),

        // OPTIMIZED DUAL BUTTON BAR - Applies Table Values
        Container(
          padding: EdgeInsets.fromLTRB(
            10.w,
            12.h,
            10.w,
            MediaQuery.of(context).padding.bottom + 12.h,
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
          child: Row(
            children: [
              // Edit/Save Button (Left)
              Expanded(
                child: PrimaryButton(
                  onPressed: _isEditMode ? _handleSave : (site == null ? null : _toggleEditMode),
                  leadingIcon: _isEditMode ? Icons.check_rounded : Icons.edit_outlined,
                  label: _isEditMode ? 'Save Changes' : 'Edit Detail',
                  size: ButtonSize.medium,
                  isDisabled: site == null,
                  customFontSize: 14.sp,
                  customIconSize: 14.sp,
                  customPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                ),
              ),
              SizedBox(width: 6.w),
              // View Images Button (Right)
              Expanded(
                child: PrimaryButton(
                  onPressed: site == null ? null : _navigateToSiteImages,
                  leadingIcon: Icons.photo_library_outlined,
                  label: 'View Images',
                  size: ButtonSize.medium,
                  isDisabled: site == null,
                  customFontSize: 14.sp,
                  customIconSize: 14.sp,
                  customPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
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
    final siteAsync = ref.watch(siteByIdProvider(widget.siteId));

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
                  if (_currentSite != null) {
                    _populateFields(_currentSite!);
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

          siteAsync.when(
            data: (site) {
              if (site == null) {
                return Center(
                  child: Text(
                    'Site not found',
                    style: TextStyle(fontSize: 16.sp, color: AppColors.textdark),
                  ),
                );
              }

              // Populate fields when data is first loaded or changes
              if (_currentSite == null || _currentSite!.id != site.id) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _populateFields(site);
                  }
                });
              }

              return _buildPageContent(site);
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
                  Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
                  SizedBox(height: 16.h),
                  Text(
                    'Failed to load site details',
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
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
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