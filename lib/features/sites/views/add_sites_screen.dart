import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/google_places_service.dart';
import 'package:sales_sphere/core/services/location_service.dart';
import 'package:sales_sphere/core/utils/field_validators.dart';
import 'package:sales_sphere/features/sites/models/sites.model.dart';
import 'package:sales_sphere/features/sites/vm/add_sites.vm.dart';
import 'package:sales_sphere/features/sites/vm/site_options.vm.dart';
import 'package:sales_sphere/features/sites/vm/sites.vm.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/location_picker_widget.dart';

// Google Places service provider
final googlePlacesServiceProvider = Provider<GooglePlacesService>((ref) {
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  return GooglePlacesService(apiKey: apiKey);
});

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class AddSitesScreen extends ConsumerStatefulWidget {
  const AddSitesScreen({super.key});

  @override
  ConsumerState<AddSitesScreen> createState() => _AddSitesScreenState();
}

class _AddSitesScreenState extends ConsumerState<AddSitesScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _managerNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  late TextEditingController _dateJoinedController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  // New fields for sub-organization and site interests
  String? _selectedSubOrganization;
  final List<SiteInterest> _selectedSiteInterests = [];

  // Default location (Bangalore, India)
  final LatLng _defaultLocation = const LatLng(13.1349646, 77.5668106);

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Set default lat/long
    _latitudeController.text = _defaultLocation.latitude.toStringAsFixed(6);
    _longitudeController.text = _defaultLocation.longitude.toStringAsFixed(6);
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _managerNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _notesController = TextEditingController();
    _dateJoinedController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _managerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _dateJoinedController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  // Save site (API Integration)
  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate latitude and longitude are set
      if (_latitudeController.text.trim().isEmpty ||
          _longitudeController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12.w),
                const Expanded(
                  child: Text('Please select a location on the map'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
        return;
      }

      try {
        // Show loading
        if (mounted) {
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
                  SizedBox(width: 16.w),
                  const Text('Creating site...'),
                ],
              ),
              duration: const Duration(seconds: 30),
              backgroundColor: AppColors.primary,
            ),
          );
        }

        // Create request object
        final createRequest = CreateSiteRequest(
          siteName: _nameController.text.trim(),
          ownerName: _managerNameController.text.trim(),
          subOrganization: _selectedSubOrganization,
          dateJoined: _dateJoinedController.text.trim().isEmpty
              ? DateFormat('yyyy-MM-dd').format(DateTime.now())
              : _dateJoinedController.text.trim(),
          contact: CreateSiteContact(
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
          ),
          location: CreateSiteLocation(
            address: _addressController.text.trim(),
            latitude: double.parse(_latitudeController.text.trim()),
            longitude: double.parse(_longitudeController.text.trim()),
          ),
          description: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          siteInterest: _selectedSiteInterests,
        );

        // Call ViewModel and wait for completion
        final vm = ref.read(addSiteViewModelProvider.notifier);
        final createdSite = await vm.createSite(createRequest);

        if (mounted) {
          // Close loading
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ref.read(siteViewModelProvider.notifier).addSite(createdSite);

          // Show success
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
                          'Site created successfully',
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

          // Navigate back AFTER adding to list
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          // Close loading
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // Show error
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
                          'Failed',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Custom Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 0.h, 24.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "New Site Incoming",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  "Add New Site",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // White Card with Form
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.r),
                  topRight: Radius.circular(32.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Site Name
                      PrimaryTextField(
                        hintText: "Site Name",
                        controller: _nameController,
                        prefixIcon: Icons.business_outlined,
                        hasFocusBorder: true,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Site name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Owner Name
                      PrimaryTextField(
                        hintText: "Owner Name",
                        controller: _managerNameController,
                        prefixIcon: Icons.person_outline,
                        hasFocusBorder: true,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Owner name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Phone
                      PrimaryTextField(
                        hintText: "Phone Number",
                        controller: _phoneController,
                        prefixIcon: Icons.phone_outlined,
                        hasFocusBorder: true,
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

                      // Email
                      PrimaryTextField(
                        hintText: "Email Address (Optional)",
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        hasFocusBorder: true,
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

                      // Sub-Organization Dropdown
                      _buildSubOrganizationDropdown(),
                      SizedBox(height: 16.h),

                      // Date Joined
                      CustomDatePicker(
                        hintText: "Date Joined",
                        controller: _dateJoinedController,
                        prefixIcon: Icons.date_range_outlined,
                        enabled: true,
                      ),
                      SizedBox(height: 16.h),

                      // Notes
                      PrimaryTextField(
                        hintText: "Notes (Optional)",
                        controller: _notesController,
                        prefixIcon: Icons.note_outlined,
                        hasFocusBorder: true,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                      ),
                      SizedBox(height: 16.h),

                      // Site Interests Section
                      _buildSiteInterestsSection(),
                      SizedBox(height: 16.h),

                      // Location Picker with Google Maps (includes address search)
                      LocationPickerWidget(
                        addressController: _addressController,
                        latitudeController: _latitudeController,
                        longitudeController: _longitudeController,
                        initialLocation: _defaultLocation,
                        placesService: ref.read(googlePlacesServiceProvider),
                        locationService: ref.read(locationServiceProvider),
                        enabled: true,
                        addressValidator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full address is required';
                          }
                          return null;
                        },
                        onLocationSelected: (location, address) {
                          // Store full formatted address and coordinates
                          if (mounted) {
                            setState(() {
                              // Store the full formatted address for backend
                              _addressController.text = address;
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
                        hintText: "Latitude (Auto-generated)",
                        controller: _latitudeController,
                        prefixIcon: Icons.explore_outlined,
                        hasFocusBorder: true,
                        enabled: false,
                      ),
                      SizedBox(height: 16.h),

                      // Longitude (Non-editable)
                      PrimaryTextField(
                        hintText: "Longitude (Auto-generated)",
                        controller: _longitudeController,
                        prefixIcon: Icons.explore_outlined,
                        hasFocusBorder: true,
                        enabled: false,
                      ),

                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Sticky Bottom Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              16.w,
              16.h,
              16.w,
              MediaQuery.of(context).padding.bottom + 16.h,
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
            child: PrimaryButton(
              label: 'Add Site',
              onPressed: _handleSave,
              leadingIcon: Icons.add_circle_outline,
              size: ButtonSize.medium,
            ),
          ),
        ],
      ),
    );
  }

  // Build Sub-Organization Dropdown
  Widget _buildSubOrganizationDropdown() {
    final subOrgsAsync = ref.watch(subOrganizationsViewModelProvider);
    return subOrgsAsync.when(
      data: (subOrganizations) {
        if (subOrganizations.isEmpty) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey.shade400,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'No sub-organizations available',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return InkWell(
          onTap: () async {
            // Show custom bottom sheet
            final selected = await showModalBottomSheet<String>(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                padding: EdgeInsets.only(
                  top: 20.h,
                  left: 20.w,
                  right: 20.w,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Title
                    Row(
                      children: [
                        Icon(Icons.business_outlined, color: AppColors.primary, size: 24.sp),
                        SizedBox(width: 12.w),
                        Text(
                          'Select Sub-Organization',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Optional - Choose if applicable',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Clear option
                    if (_selectedSubOrganization != null)
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        leading: Icon(Icons.clear, color: Colors.red.shade400, size: 20.sp),
                        title: Text(
                          'Clear selection',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Poppins',
                            color: Colors.red.shade400,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context, '');
                        },
                      ),
                    // List
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: subOrganizations.length,
                      itemBuilder: (context, index) {
                        final subOrg = subOrganizations[index];
                        final isSelected = _selectedSubOrganization == subOrg.name;
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
                          leading: Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isSelected ? AppColors.primary : Colors.grey.shade400,
                            size: 20.sp,
                          ),
                          title: Text(
                            subOrg.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Poppins',
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? AppColors.primary : Colors.grey.shade800,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context, subOrg.name);
                          },
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
            if (selected != null) {
              setState(() {
                _selectedSubOrganization = selected.isEmpty ? null : selected;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: _selectedSubOrganization == null
                    ? Colors.grey.shade300
                    : AppColors.primary.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  color: _selectedSubOrganization == null
                      ? Colors.grey.shade400
                      : AppColors.primary,
                  size: 22.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _selectedSubOrganization ?? 'Select sub-organization (Optional)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                      color: _selectedSubOrganization == null
                          ? Colors.grey.shade500
                          : Colors.grey.shade800,
                      fontWeight: _selectedSubOrganization == null
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey.shade400,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      error: (error, stack) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Failed to load sub-organizations',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.error,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Site Interests Section
  Widget _buildSiteInterestsSection() {
    final categoriesAsync = ref.watch(siteCategoriesViewModelProvider);
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Site Interests (Optional)',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 12.h),
            ...categories.map((category) {
              final isSelected = _selectedSiteInterests.any(
                (interest) => interest.category == category.name,
              );
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : Colors.grey.shade300,
                  ),
                ),
                child: InkWell(
                  onTap: () => setState(() {
                    if (isSelected) {
                      _selectedSiteInterests.removeWhere(
                        (interest) => interest.category == category.name,
                      );
                    } else {
                      _selectedSiteInterests.add(
                        SiteInterest(
                          category: category.name,
                          brands: category.brands,
                          technicians: category.technicians,
                        ),
                      );
                    }
                  }),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade400,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              if (category.brands.isNotEmpty) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  'Brands: ' + category.brands.join(', '),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
