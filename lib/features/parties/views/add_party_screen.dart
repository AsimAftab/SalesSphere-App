import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/google_places_service.dart';
import 'package:sales_sphere/core/services/location_service.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/features/parties/models/parties.model.dart';
import 'package:sales_sphere/features/parties/vm/edit_party.vm.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

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

  // Location state
  LatLng? _selectedLocation;
  List<PlacePrediction> _addressSuggestions = [];
  bool _isSearching = false;
  Timer? _debounce;

  // Default location (Bangalore, India)
  final LatLng _defaultLocation = const LatLng(13.1349646, 77.5668106);

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _selectedLocation = _defaultLocation;
    // Set today's date


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
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // Search address with debounce using Google Places
  void _onAddressChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      _isSearching = true;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length >= 2) {
        final placesService = ref.read(googlePlacesServiceProvider);
        final suggestions = await placesService.getAutocompletePredictions(
          query,
          location: _selectedLocation ?? _defaultLocation,
        );

        if (mounted) {
          setState(() {
            _addressSuggestions = suggestions;
            _isSearching = false;
          });
        }
      } else {
        setState(() {
          _addressSuggestions = [];
          _isSearching = false;
        });
      }
    });
  }

  // Select address from Google Places suggestions
  void _selectAddress(PlacePrediction suggestion) async {
    setState(() {
      _isSearching = true;
      _addressSuggestions = [];
    });

    // Fetch place details to get exact coordinates
    final placesService = ref.read(googlePlacesServiceProvider);
    final placeDetails = await placesService.getPlaceDetails(suggestion.placeId);

    if (placeDetails != null && mounted) {
      setState(() {
        _addressController.text = placeDetails.formattedAddress;
        _selectedLocation = placeDetails.location;
        _isSearching = false;

        // Update lat/long controllers
        _latitudeController.text = placeDetails.location.latitude.toStringAsFixed(6);
        _longitudeController.text = placeDetails.location.longitude.toStringAsFixed(6);

        // Update marker
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('selected_location'),
            position: placeDetails.location,
            infoWindow: InfoWindow(
              title: placeDetails.name,
              snippet: placeDetails.formattedAddress,
            ),
          ),
        );
      });

      // Move camera to selected location with smooth animation
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: placeDetails.location, zoom: 17.0),
        ),
      );
    } else if (mounted) {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not fetch location details'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Handle map tap for pinpointing
  void _onMapTap(LatLng location) async {
    setState(() {
      _selectedLocation = location;

      // Update lat/long controllers
      _latitudeController.text = location.latitude.toStringAsFixed(6);
      _longitudeController.text = location.longitude.toStringAsFixed(6);

      // Update marker
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: location,
          infoWindow: const InfoWindow(title: 'Selected Location'),
        ),
      );
    });

    // Reverse geocode to get address using geocoding package
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        final addressParts = [
          place.name,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((part) => part != null && part.isNotEmpty).join(', ');

        setState(() {
          _addressController.text = addressParts;
        });
      }
    } catch (e) {
      // Silent fail - user can still use the coordinates
    }
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    try {
      final locationService = ref.read(locationServiceProvider);

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
                Text('Getting your location...'),
              ],
            ),
            duration: Duration(seconds: 10),
            backgroundColor: AppColors.primary,
          ),
        );
      }

      final location = await locationService.getCurrentLocation();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (location != null) {
        setState(() {
          _selectedLocation = location;
          _latitudeController.text = location.latitude.toStringAsFixed(6);
          _longitudeController.text = location.longitude.toStringAsFixed(6);

          // Update marker
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('selected_location'),
              position: location,
              infoWindow: const InfoWindow(title: 'Your Location'),
            ),
          );
        });

        // Move camera to current location
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: location, zoom: 16.0),
          ),
        );

        // Get address from coordinates using geocoding package
        try {
          final placemarks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );

          if (placemarks.isNotEmpty && mounted) {
            final place = placemarks.first;
            final addressParts = [
              place.name,
              place.subLocality,
              place.locality,
              place.administrativeArea,
              place.country,
            ].where((part) => part != null && part.isNotEmpty).join(', ');

            setState(() {
              _addressController.text = addressParts;
            });
          }
        } catch (e) {
          // Silent fail - coordinates are still set
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text('Location found!'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              margin: EdgeInsets.all(16.w),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text('Could not get location. Please check permissions and GPS.'),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              margin: EdgeInsets.all(16.w),
              duration: Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () async {
                  await locationService.openAppSettings();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    }
  }

  // Save party via API
  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12.w),
                Expanded(child: Text('Please select a location on the map')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
        final createRequest = UpdatePartyRequest(
          partyName: _nameController.text.trim(),
          ownerName: _ownerNameController.text.trim(),
          panVatNumber: _panVatController.text.trim(),
          contact: UpdatePartyContact(
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
          ),
          location: UpdatePartyLocation(
            address: _addressController.text.trim(),
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
          ),
          description: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        // Call API
        final vm = ref.read(partyViewModelProvider.notifier);
        await vm.addParty(createRequest);

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
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.check_circle, color: Colors.white, size: 24.sp),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
                    child: Icon(Icons.error_outline, color: Colors.white, size: 24.sp),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
                        hintText: "PAN/VAT Number",
                        controller: _panVatController,
                        prefixIcon: Icons.receipt_long_outlined,
                        hasFocusBorder: true,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'PAN/VAT number is required';
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone number is required';
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

                      // Address Search with Suggestions
                      Column(
                        children: [
                          PrimaryTextField(
                            hintText: "Address",
                            controller: _addressController,
                            prefixIcon: Icons.location_on_outlined,
                            hasFocusBorder: true,
                            textInputAction: TextInputAction.next,
                            onChanged: _onAddressChanged,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Address is required';
                              }
                              return null;
                            },
                          ),

                          // Address Suggestions
                          if (_addressSuggestions.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(top: 8.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _addressSuggestions.length,
                                separatorBuilder: (context, index) => Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final suggestion = _addressSuggestions[index];
                                  return ListTile(
                                    leading: Icon(
                                      Icons.location_on,
                                      color: AppColors.primary,
                                      size: 20.sp,
                                    ),
                                    title: Text(
                                      suggestion.mainText,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: suggestion.secondaryText.isNotEmpty
                                        ? Text(
                                            suggestion.secondaryText,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey.shade600,
                                              fontFamily: 'Poppins',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : null,
                                    onTap: () => _selectAddress(suggestion),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Get Current Location Button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,

                          borderRadius: BorderRadius.circular(12.r),


                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _getCurrentLocation,
                            borderRadius: BorderRadius.circular(12.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.my_location,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    'Use My Current Location',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Map Section
                      Container(
                        height: 350.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: GoogleMap(
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                          },
                          initialCameraPosition: CameraPosition(
                            target: _defaultLocation,
                            zoom: 13.0,
                          ),
                          onTap: _onMapTap,
                          markers: _markers,
                          myLocationEnabled: false,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: true,
                          mapToolbarEnabled: false,
                          mapType: MapType.normal,
                          compassEnabled: true,
                          rotateGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                          scrollGesturesEnabled: true,
                          zoomGesturesEnabled: true,
                          minMaxZoomPreference: const MinMaxZoomPreference(5, 20),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 18.sp,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                'Drag & pinch to navigate the map. Tap anywhere to pinpoint exact location. Use +/- zoom controls for precision.',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.blue.shade900,
                                  fontFamily: 'Poppins',
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
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

                      // Notes
                      PrimaryTextField(
                        hintText: "Notes (Optional)",
                        controller: _notesController,
                        prefixIcon: Icons.note_outlined,
                        hasFocusBorder: true,
                        minLines: 3,
                        maxLines: 5,
                        textInputAction: TextInputAction.done,
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
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, MediaQuery.of(context).padding.bottom + 16.h),
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
