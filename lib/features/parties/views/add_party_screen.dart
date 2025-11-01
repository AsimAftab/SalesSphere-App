import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/google_places_service.dart';
import 'package:sales_sphere/core/services/location_service.dart';
import 'package:sales_sphere/features/parties/vm/add_party.vm.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/widget/location_picker_widget.dart';
import 'package:sales_sphere/features/parties/models/parties.model.dart';
import 'package:intl/intl.dart';

// Google Places service provider
final googlePlacesServiceProvider = Provider<GooglePlacesService>((ref) {
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  return GooglePlacesService(apiKey: apiKey);
});

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class AddPartyScreen extends ConsumerStatefulWidget {
  const AddPartyScreen({super.key});

  @override
  ConsumerState<AddPartyScreen> createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends ConsumerState<AddPartyScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _panVatController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  late TextEditingController _dateJoinedController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

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
    _ownerNameController = TextEditingController();
    _panVatController = TextEditingController();
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
    _ownerNameController.dispose();
    _panVatController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _dateJoinedController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  // Save party via API
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text('Creating party...'),
                ],
              ),
              duration: Duration(seconds: 30),
              backgroundColor: AppColors.primary,
            ),
          );
        }

        // Create request object
        final createRequest = CreatePartyRequest(
          partyName: _nameController.text.trim(),
          ownerName: _ownerNameController.text.trim(),
          dateJoined: _dateJoinedController.text.trim().isEmpty
              ? DateFormat('yyyy-MM-dd').format(DateTime.now())
              : _dateJoinedController.text.trim(),
          panVatNumber: _panVatController.text.trim(),
          contact: CreatePartyContact(
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
          ),
          location: CreatePartyLocation(
            address: _addressController.text.trim(),
            latitude: double.parse(_latitudeController.text.trim()),
            longitude: double.parse(_longitudeController.text.trim()),
          ),
          description: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        // Call API
        final vm = ref.read(addPartyViewModelProvider.notifier);
        await vm.createParty(createRequest);

        if (mounted) {
          // Close loading
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

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
                          'Party created successfully',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
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
              duration: Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.all(16.w),
              elevation: 6,
            ),
          );

          // Navigate back to parties list
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
                      color: Colors.white.withOpacity(0.2),
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
                            color: Colors.white.withOpacity(0.9),
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
              duration: Duration(seconds: 4),
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
                  "New member in the Family",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  "Add New Party",
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
                    color: Colors.black.withOpacity(0.1),
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
                      // Party Name
                      PrimaryTextField(
                        hintText: "Party Name",
                        controller: _nameController,
                        prefixIcon: Icons.business_outlined,
                        hasFocusBorder: true,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Party name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Owner Name
                      PrimaryTextField(
                        hintText: "Owner Name",
                        controller: _ownerNameController,
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

                      // PAN/VAT Number
                      PrimaryTextField(
                        hintText: "PAN/VAT Number (Max 14 characters)",
                        controller: _panVatController,
                        prefixIcon: Icons.receipt_long_outlined,
                        hasFocusBorder: true,
                        textInputAction: TextInputAction.next,
                        maxLength: 14,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'PAN/VAT number is required';
                          }
                          if (value.trim().length > 14) {
                            return 'PAN/VAT number cannot exceed 14 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Phone
                      PrimaryTextField(
                        hintText: "Phone Number (10 digits)",
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
                          // Remove any spaces or special characters for validation
                          final cleanedValue = value.replaceAll(
                            RegExp(r'[^\d]'),
                            '',
                          );
                          if (cleanedValue.length != 10) {
                            return 'Phone number must be exactly 10 digits';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Email
                      PrimaryTextField(
                        hintText: "Email Address",
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        hasFocusBorder: true,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),

                      // Date Joined
                      CustomDatePicker(
                        hintText: "Date Joined",
                        controller: _dateJoinedController,
                        prefixIcon: Icons.date_range_outlined,
                        enabled: true,
                      ),
                      SizedBox(height: 16.h),
                      PrimaryTextField(
                        hintText: "Notes",
                        controller: _notesController,
                        prefixIcon: Icons.note_outlined,
                        hasFocusBorder: true,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                      ),
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
                            return 'Address is required';
                          }
                          return null;
                        },
                        onLocationSelected: (location, address) {
                          // Optional callback if needed
                          if (mounted) {
                            setState(() {
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
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: PrimaryButton(
              label: 'Add Party',
              onPressed: _handleSave,
              leadingIcon: Icons.add_circle_outline,
              size: ButtonSize.medium,
            ),
          ),
        ],
      ),
    );
  }
}
