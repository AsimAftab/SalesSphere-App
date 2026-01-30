import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/google_places_service.dart';
import 'package:sales_sphere/core/services/location_service.dart';
import 'package:sales_sphere/features/parties/models/parties.model.dart';
import 'package:sales_sphere/features/parties/vm/add_party.vm.dart';
import 'package:sales_sphere/features/parties/vm/party_image.vm.dart';
import 'package:sales_sphere/features/parties/vm/party_types.vm.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/location_picker_widget.dart';
import 'package:sales_sphere/widget/primary_image_picker.dart';

import '../../../core/utils/logger.dart';

// Constant for "Add New..." option in party type dropdown
const String _kAddNewPartyType = '__add_new_party_type__';

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
  late TextEditingController _newPartyTypeController;

  // Party type selection
  String? _selectedPartyType;

  // Whether to show the "Add New Party Type" text field
  bool _showNewPartyTypeField = false;

  // Image selection
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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
    _newPartyTypeController = TextEditingController();
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
    _newPartyTypeController.dispose();
    super.dispose();
  }

  // Pick image from gallery or camera
  Future<void> _pickImage() async {
    try {
      await showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () async {
                    context.pop();
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1920,
                      maxHeight: 1080,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImage = image;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () async {
                    context.pop();
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1920,
                      maxHeight: 1080,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImage = image;
                      });
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      AppLogger.e('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Remove selected image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
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
        // Use new party type from text field if "Add New" was selected
        final partyTypeToSend = _selectedPartyType == _kAddNewPartyType
            ? (_newPartyTypeController.text.trim().isEmpty
                    ? null
                    : _newPartyTypeController.text.trim())
            : _selectedPartyType;

        final createRequest = CreatePartyRequest(
          partyName: _nameController.text.trim(),
          ownerName: _ownerNameController.text.trim(),
          dateJoined: _dateJoinedController.text.trim().isEmpty
              ? DateFormat('yyyy-MM-dd').format(DateTime.now())
              : _dateJoinedController.text.trim(),
          panVatNumber: _panVatController.text.trim(),
          partyType: partyTypeToSend,
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
        final createdParty = await vm.createParty(createRequest);

        // Upload image if selected
        if (_selectedImage != null && mounted) {
          try {
            final imageVm = ref.read(partyImageViewModelProvider.notifier);
            await imageVm.uploadImage(
              partyId: createdParty.id,
              imageFile: File(_selectedImage!.path),
            );
            AppLogger.i('✅ Party image uploaded successfully');
          } catch (e) {
            AppLogger.e('❌ Error uploading party image: $e');
            // Don't fail the whole operation if image upload fails
          }
        }

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
                    color: Colors.white.withValues(alpha: 0.8),
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

                      // Party Type Dropdown
                      _PartyTypeDropdown(
                        partyTypesAsync: ref.watch(partyTypesViewModelProvider),
                        selectedType: _selectedPartyType,
                        onTypeSelected: (type) {
                          setState(() {
                            _selectedPartyType = type;
                            _showNewPartyTypeField = (type == _kAddNewPartyType);
                          });
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Show text field when "Add New..." is selected
                      if (_showNewPartyTypeField)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PrimaryTextField(
                              hintText: "Enter New Party Type",
                              controller: _newPartyTypeController,
                              prefixIcon: Icons.edit_outlined,
                              hasFocusBorder: true,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (_showNewPartyTypeField &&
                                    (value == null || value.trim().isEmpty)) {
                                  return 'Please enter a party type';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ),

                      PrimaryTextField(
                        hintText: "Notes",
                        controller: _notesController,
                        prefixIcon: Icons.note_outlined,
                        hasFocusBorder: true,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                      ),
                      SizedBox(height: 20.h),

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
                      SizedBox(height: 16.h),

                      // Party Image Section
                      PrimaryImagePicker(
                        images: _selectedImage != null ? [_selectedImage!] : [],
                        maxImages: 1,
                        label: 'Party Image (Optional)',
                        onPick: _pickImage,
                        onRemove: (index) => _removeImage(),
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

// Custom widget for Party Type Dropdown with "Add New..." option
class _PartyTypeDropdown extends ConsumerWidget {
  final AsyncValue<List<PartyType>> partyTypesAsync;
  final String? selectedType;
  final ValueChanged<String?> onTypeSelected;

  const _PartyTypeDropdown({
    required this.partyTypesAsync,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return partyTypesAsync.when(
      data: (partyTypes) {
        // Add "Add New..." option at the beginning
        final displayValue = selectedType == _kAddNewPartyType
            ? 'Add New...'
            : selectedType;

        return InkWell(
          onTap: () => _showPartyTypeBottomSheet(context, partyTypes),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(
                  selectedType == _kAddNewPartyType
                      ? Icons.add_circle_outline
                      : Icons.category_outlined,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    displayValue ?? 'Party Type (Optional)',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color: selectedType != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Center(
          child: SizedBox(
            width: 16.w,
            height: 16.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
      error: (_, __) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.error, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Failed to load party types',
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

  Future<void> _showPartyTypeBottomSheet(
    BuildContext context,
    List<PartyType> partyTypes,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PartyTypeBottomSheet(
        partyTypes: partyTypes,
        selectedType: selectedType,
      ),
    );

    if (selected != null) {
      onTypeSelected(selected.isEmpty ? null : selected);
    }
  }
}

class _PartyTypeBottomSheet extends StatelessWidget {
  final List<PartyType> partyTypes;
  final String? selectedType;

  const _PartyTypeBottomSheet({
    required this.partyTypes,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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

          // Header
          Row(
            children: [
              Icon(
                Icons.category_outlined,
                color: AppColors.primary,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Select Party Type',
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
            'Choose an existing type or create a new one',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 20.h),

          // Clear selection option
          if (selectedType != null && selectedType!.isNotEmpty)
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              leading: Icon(
                Icons.clear,
                color: Colors.red.shade400,
                size: 20.sp,
              ),
              title: Text(
                'Clear selection',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                  color: Colors.red.shade400,
                ),
              ),
              onTap: () => Navigator.pop(context, ''),
            ),

          // "Add New..." option at the top
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            tileColor: selectedType == _kAddNewPartyType
                ? AppColors.primary.withValues(alpha: 0.1)
                : null,
            leading: Icon(
              selectedType == _kAddNewPartyType
                  ? Icons.check_circle
                  : Icons.add_circle_outline,
              color: selectedType == _kAddNewPartyType
                  ? AppColors.primary
                  : AppColors.success,
              size: 20.sp,
            ),
            title: Text(
              'Add New...',
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: 'Poppins',
                fontWeight: selectedType == _kAddNewPartyType
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: selectedType == _kAddNewPartyType
                    ? AppColors.primary
                    : AppColors.success,
              ),
            ),
            onTap: () => Navigator.pop(context, _kAddNewPartyType),
          ),

          Divider(height: 16.h),

          // List of existing party types
          Text(
            'Existing Types',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 8.h),

          ListView.builder(
            shrinkWrap: true,
            itemCount: partyTypes.length,
            itemBuilder: (context, index) {
              final type = partyTypes[index];
              final isSelected = selectedType == type.name;

              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                tileColor: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : null,
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  size: 20.sp,
                ),
                title: Text(
                  type.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Poppins',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : Colors.grey.shade800,
                  ),
                ),
                onTap: () => Navigator.pop(context, type.name),
              );
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
