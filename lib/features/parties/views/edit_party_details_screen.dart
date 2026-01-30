import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_sphere/core/utils/date_formatter.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/google_places_service.dart';
import 'package:sales_sphere/core/services/location_service.dart';
import 'package:sales_sphere/core/utils/field_validators.dart';
import 'package:sales_sphere/features/parties/models/parties.model.dart';
import 'package:sales_sphere/features/parties/vm/edit_party.vm.dart';
import 'package:sales_sphere/features/parties/vm/party_types.vm.dart';
import 'package:sales_sphere/features/parties/vm/party_image.vm.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/location_picker_widget.dart';
import 'package:sales_sphere/widget/primary_image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

class EditPartyDetailsScreen extends ConsumerStatefulWidget {
  final String partyId;

  const EditPartyDetailsScreen({
    super.key,
    required this.partyId,
  });

  @override
  ConsumerState<EditPartyDetailsScreen> createState() => _EditPartyDetailsScreenState();
}

class _EditPartyDetailsScreenState extends ConsumerState<EditPartyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditMode = false;

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
  late TextEditingController _newPartyTypeController;

  // Party type selection
  String? _selectedPartyType;

  // Whether to show the "Add New Party Type" text field
  bool _showNewPartyTypeField = false;

  // Image selection
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  PartyDetails? _currentParty;
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
    _newPartyTypeController = TextEditingController();
  }

  void _populateFields(PartyDetails party) {
    if (!mounted) return;
    setState(() {
      _currentParty = party;
      _nameController.text = party.name;
      _phoneController.text = party.phoneNumber;
      _emailController.text = party.email ?? '';
      _ownerNameController.text = party.ownerName;
      _panVatNumberController.text = party.panVatNumber;
      _fullAddressController.text = party.fullAddress;
      _latitudeController.text = party.latitude?.toString() ?? '';
      _longitudeController.text = party.longitude?.toString() ?? '';
      _notesController.text = party.notes ?? '';
      _dateJoinedController.text = DateFormatter.formatDateOnly(party.dateJoined);
      _selectedPartyType = party.partyType;
      _showNewPartyTypeField = false; // Reset when populating
      _newPartyTypeController.clear(); // Clear the new party type controller

      // Set initial location for map if coordinates exist
      if (party.latitude != null && party.longitude != null) {
        _initialLocation = LatLng(party.latitude!, party.longitude!);
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

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentParty == null) return;

      // Use new party type from text field if "Add New" was selected
      final partyTypeToSend = _selectedPartyType == _kAddNewPartyType
          ? (_newPartyTypeController.text.trim().isEmpty
                  ? null
                  : _newPartyTypeController.text.trim())
          : _selectedPartyType;

      final vm = ref.read(editPartyViewModelProvider.notifier);

      final updatedParty = _currentParty!.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        panVatNumber: _panVatNumberController.text.trim(),
        partyType: partyTypeToSend,
        fullAddress: _fullAddressController.text.trim(),
        latitude: double.tryParse(_latitudeController.text.trim()),
        longitude: double.tryParse(_longitudeController.text.trim()),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      try {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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
                  Text('Updating party details...'),
                ],
              ),
              duration: Duration(seconds: 30),
              backgroundColor: AppColors.primary,
            ),
          );
        }

        // Call API to update party
        await vm.updateParty(updatedParty);

        // Upload new image if selected
        if (_selectedImage != null && mounted) {
          try {
            final imageVm = ref.read(partyImageViewModelProvider.notifier);
            await imageVm.uploadImage(
              partyId: updatedParty.id,
              imageFile: File(_selectedImage!.path),
            );
            AppLogger.i('✅ Party image uploaded successfully');
            // Update the party with new image URL (will be fetched on reload)
            _selectedImage = null;
          } catch (e) {
            AppLogger.e('❌ Error uploading party image: $e');
            // Don't fail the whole operation if image upload fails
          }
        }

        if (mounted) {
          // Close loading snackbar
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          setState(() {
            _isEditMode = false;
            _currentParty = updatedParty;
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
                          'Party details updated successfully',
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

          // Refresh the party details from API to ensure data is synced
          ref.invalidate(partyByIdProvider(widget.partyId));

          // Wait a moment for the provider to refresh, then repopulate fields
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              final refreshedPartyAsync = ref.read(partyByIdProvider(widget.partyId));
              refreshedPartyAsync.whenData((refreshedParty) {
                if (refreshedParty != null && mounted) {
                  _populateFields(refreshedParty);
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

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _openGoogleMaps(PartyDetails party) async {
    Uri? url;

    if (party.latitude != null && party.longitude != null) {
      url = Uri(
        scheme: 'geo',
        path: '0,0',
        queryParameters: {'q': '${party.latitude},${party.longitude}'},
      );
    } else if (party.fullAddress.isNotEmpty) {
      url = Uri(
        scheme: 'geo',
        path: '0,0',
        queryParameters: {'q': party.fullAddress},
      );
    }

    if (url != null) {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not open maps. Is Google Maps installed?'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No address or coordinates to show'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  // --- CREATE A NEW HELPER METHOD for the UI ---
  Widget _buildPageContent(PartyDetails? party) {
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
                            // Use placeholder if controller is empty (i.e., loading)
                            _nameController.text.isEmpty ? "Party Name" : _nameController.text,
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
                            onTap: party == null ? null : () => _openGoogleMaps(party),
                            borderRadius: BorderRadius.circular(8.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center, // ✅ Center vertically
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 2.h), // ✅ small visual tweak
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
                                        height: 1.4, // ✅ gives better line spacing
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
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
                          )


                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Party Details',
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
                            color: Colors.black.withValues(alpha:0.04), // Kept
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          PrimaryTextField(
                            hintText: "Owner Name",
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
                            hintText: "PAN/VAT Number",
                            controller: _panVatNumberController,
                            prefixIcon: Icons.receipt_long_outlined,
                            hasFocusBorder: true,
                            enabled: _isEditMode,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'PAN/VAT number is required';
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone number is required';
                              }
                              return FieldValidators.validatePhone(value);
                            },
                          ),
                          SizedBox(height: 16.h),
                          PrimaryTextField(
                            hintText: "Email Address",
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
                          SizedBox(height: 16.h,),

                          // Party Type Dropdown
                          if (_selectedPartyType != null || _isEditMode)
                            _PartyTypeDropdown(
                              partyTypesAsync: ref.watch(partyTypesViewModelProvider),
                              selectedType: _selectedPartyType,
                              onTypeSelected: (type) {
                                setState(() {
                                  _selectedPartyType = type;
                                  _showNewPartyTypeField = (type == _kAddNewPartyType);
                                });
                              },
                              enabled: _isEditMode,
                            ),
                          if (_selectedPartyType != null || _isEditMode)
                            SizedBox(height: 16.h),

                          // Show text field when "Add New..." is selected
                          if (_showNewPartyTypeField && _isEditMode)
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
                            enabled: _isEditMode,
                            minLines: 1,
                            maxLines: 5,
                            textInputAction: TextInputAction.newline,
                          ),
                          SizedBox(height: 16.h),

                          // Location Picker with Google Maps (includes address search)
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
                              // Store full formatted address and coordinates
                              if (mounted) {
                                setState(() {
                                  // Store the full formatted address for backend
                                  _fullAddressController.text = address;
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
                            textInputAction: TextInputAction.newline,
                          ),

                          // Party Image Section
                          PrimaryImagePicker(
                            images: _selectedImage != null ? [_selectedImage!] : [],
                            networkImageUrl: _currentParty?.imageUrl,
                            maxImages: 1,
                            label: 'Party Image',
                            enabled: _isEditMode,
                            onPick: _pickImage,
                            onRemove: (index) => _removeImage(),
                            onReplace: _pickImage,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, MediaQuery.of(context).padding.bottom + 16.h),
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
              : PrimaryButton(
            label: 'Edit Detail',
            // Disable button if 'party' is null (loading)
            onPressed: party == null ? null : _toggleEditMode,
            leadingIcon: Icons.edit_outlined,
            size: ButtonSize.medium,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final partyAsync = ref.watch(partyByIdProvider(widget.partyId));

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
                  if (_currentParty != null) {
                    _populateFields(_currentParty!);
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

          // --- 3. UPDATED .when() BLOCK ---
          partyAsync.when(
            data: (party) {
              if (party == null) {
                return Center(
                  child: Text(
                    'Party not found',
                    style: TextStyle(fontSize: 16.sp, color: AppColors.textdark),
                  ),
                );
              }

              // Populate fields when data is first loaded or changes
              if (_currentParty == null || _currentParty!.id != party.id) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _populateFields(party);
                  }
                });
              }

              // Build the real UI
              return _buildPageContent(party);
            },
            loading: () {
              // Build the skeleton UI
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
                    'Failed to load party details',
                    style: TextStyle(fontSize: 16.sp, color: AppColors.textdark, fontWeight: FontWeight.w500),
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

// Custom widget for Party Type Dropdown with "Add New..." option
class _PartyTypeDropdown extends ConsumerWidget {
  final AsyncValue<List<PartyType>> partyTypesAsync;
  final String? selectedType;
  final ValueChanged<String?> onTypeSelected;
  final bool enabled;

  const _PartyTypeDropdown({
    required this.partyTypesAsync,
    required this.selectedType,
    required this.onTypeSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return partyTypesAsync.when(
      data: (partyTypes) {
        // Add "Add New..." option
        final displayValue = selectedType == _kAddNewPartyType
            ? 'Add New...'
            : selectedType;

        final shouldShowGreyStyle = !enabled;

        return InkWell(
          onTap: enabled ? () => _showPartyTypeBottomSheet(context, partyTypes) : null,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: shouldShowGreyStyle
                  ? Colors.grey.shade100
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: shouldShowGreyStyle
                    ? AppColors.border.withValues(alpha: 0.2)
                    : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selectedType == _kAddNewPartyType
                      ? Icons.add_circle_outline
                      : Icons.category_outlined,
                  color: shouldShowGreyStyle
                      ? AppColors.textSecondary.withValues(alpha: 0.4)
                      : AppColors.textSecondary,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    displayValue ?? 'Party Type',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color: selectedType != null
                          ? (shouldShowGreyStyle
                              ? AppColors.textSecondary.withValues(alpha: 0.6)
                              : AppColors.textPrimary)
                          : (shouldShowGreyStyle
                              ? AppColors.textHint.withValues(alpha: 0.5)
                              : AppColors.textHint),
                    ),
                  ),
                ),
                Icon(
                  enabled
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.lock_outline,
                  color: shouldShowGreyStyle
                      ? AppColors.textSecondary.withValues(alpha: 0.4)
                      : AppColors.textSecondary,
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