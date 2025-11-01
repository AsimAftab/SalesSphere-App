import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sales_sphere/core/utils/date_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/google_places_service.dart';
import 'package:sales_sphere/core/services/location_service.dart';
import 'package:sales_sphere/core/utils/field_validators.dart';
import 'package:sales_sphere/features/parties/models/parties.model.dart';
import 'package:sales_sphere/features/parties/vm/edit_party.vm.dart';
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
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentParty == null) return;

      final vm = ref.read(editPartyViewModelProvider.notifier);

      final updatedParty = _currentParty!.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        panVatNumber: _panVatNumberController.text.trim(),
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
                                    color: AppColors.primary.withValues(alpha: 0.7), // Kept
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
                              // Optional: Update latitude/longitude when location is selected
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
                            textInputAction: TextInputAction.newline,
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