import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/google_places_service.dart';
import 'package:sales_sphere/core/services/location_service.dart';
import 'dart:async';

/// Reusable Location Picker Widget with Google Maps
/// Supports: Address search, Current location, Map tap selection
/// Includes: Address TextField with autocomplete
class LocationPickerWidget extends StatefulWidget {
  final TextEditingController addressController;
  final TextEditingController? latitudeController;
  final TextEditingController? longitudeController;
  final LatLng? initialLocation;
  final GooglePlacesService placesService;
  final LocationService locationService;
  final Function(LatLng location, String address)? onLocationSelected;
  final bool enabled;
  final String? Function(String?)? addressValidator;

  const LocationPickerWidget({
    super.key,
    required this.addressController,
    this.latitudeController,
    this.longitudeController,
    this.initialLocation,
    required this.placesService,
    required this.locationService,
    this.onLocationSelected,
    this.enabled = true,
    this.addressValidator,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng? _selectedLocation;
  List<PlacePrediction> _addressSuggestions = [];
  Timer? _debounce;
  String? _fullFormattedAddress; // Store full address separately

  // Default location (Bangalore, India)
  final LatLng _defaultLocation = const LatLng(13.1349646, 77.5668106);

  @override
  void initState() {
    super.initState();
    _initializeLocation(widget.initialLocation, updateControllers: false);
  }

  @override
  void didUpdateWidget(covariant LocationPickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if initialLocation changed from null to a valid value
    // This handles the case when parent widget loads data asynchronously
    if (widget.initialLocation != null && oldWidget.initialLocation == null) {
      // Defer updates to after the current build frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _initializeLocation(widget.initialLocation, updateControllers: false);
        // Move camera to the new location
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: widget.initialLocation!, zoom: 15.0),
          ),
        );
      });
    }
  }

  void _initializeLocation(LatLng? location, {bool updateControllers = false}) {
    setState(() {
      _selectedLocation = location ?? _defaultLocation;

      // Set initial marker if location exists
      _markers.clear();
      if (_selectedLocation != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('selected_location'),
            position: _selectedLocation!,
            infoWindow: const InfoWindow(title: 'Selected Location'),
          ),
        );
      }
    });

    // Only update controllers if explicitly requested (avoids triggering Form rebuild during build)
    if (updateControllers &&
        widget.latitudeController != null &&
        widget.longitudeController != null &&
        location != null) {
      widget.latitudeController!.text = _selectedLocation!.latitude
          .toStringAsFixed(6);
      widget.longitudeController!.text = _selectedLocation!.longitude
          .toStringAsFixed(6);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // Search address with debounce using Google Places
  void _onAddressChanged(String query) {
    if (!widget.enabled) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length >= 2) {
        final suggestions = await widget.placesService
            .getAutocompletePredictions(
              query,
              location: _selectedLocation ?? _defaultLocation,
            );

        if (mounted) {
          setState(() {
            _addressSuggestions = suggestions;
          });
        }
      } else {
        setState(() {
          _addressSuggestions = [];
        });
      }
    });
  }

  // Select address from Google Places suggestions
  void _selectAddress(PlacePrediction suggestion) async {
    setState(() {
      _addressSuggestions = [];
    });

    // Fetch place details to get exact coordinates
    final placeDetails = await widget.placesService.getPlaceDetails(
      suggestion.placeId,
    );

    if (placeDetails != null && mounted) {
      // Set only the place name in the search field
      widget.addressController.text = suggestion.mainText;

      // Store full formatted address separately for display below map
      _updateLocation(
        placeDetails.location,
        placeDetails.formattedAddress,
        placeName: placeDetails.name ?? suggestion.mainText,
      );

      // Move camera to selected location with smooth animation
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: placeDetails.location, zoom: 17.0),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not fetch location details'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Handle map tap for pinpointing
  void _onMapTap(LatLng location) async {
    if (!widget.enabled) return;

    // Reverse geocode to get address using geocoding package
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;

        // Extract place name for search field
        final placeName =
            place.name ??
            place.street ??
            place.subLocality ??
            place.locality ??
            'Selected Location';

        // Build comprehensive address with all available components
        // Build comprehensive address ensuring placeName (landmark/institution) comes first
        // Build comprehensive address ensuring placeName (landmark/institution) comes first
        final List<String?> addressParts = [
          if (placeName != null && placeName.isNotEmpty) placeName,
          place.street,
          place.subThoroughfare,
          place.thoroughfare,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ];

        final fullAddress = addressParts
            .where((part) => part != null && part!.isNotEmpty)
            .join(', ');

        // Update location: place name in search field, full address below map
        _updateLocation(location, fullAddress, placeName: placeName);
      } else {
        // If no address found, still update location with coordinates only
        _updateLocation(location, null);
      }
    } catch (e) {
      // If geocoding fails, still update location with coordinates only
      _updateLocation(location, null);
    }
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    if (!widget.enabled) return;

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
                const Text('Getting your location...'),
              ],
            ),
            duration: const Duration(seconds: 10),
            backgroundColor: AppColors.primary,
          ),
        );
      }

      final location = await widget.locationService.getCurrentLocation();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (location != null) {
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

            // Extract place name for search field
            final placeName =
                place.name ??
                place.street ??
                place.subLocality ??
                place.locality ??
                'Current Location';

            // Build comprehensive address with all available components
            final fullAddress = [
              place.name, // Place/landmark name (e.g., "BMSIT College")
              place.street, // Street name
              place.subThoroughfare, // Street number
              place.thoroughfare, // Street name (alternative)
              place.subLocality, // Sub-locality
              place.locality, // City/Town
              place.subAdministrativeArea, // Sub-district/Taluk
              place.administrativeArea, // State/Province
              place.postalCode, // Postal/ZIP code
              place.country, // Country
            ].where((part) => part != null && part.isNotEmpty).join(', ');

            // Update location: place name in search field, full address below map
            _updateLocation(location, fullAddress, placeName: placeName);
          } else {
            // If no address found, still update location with coordinates only
            _updateLocation(location, null);
          }
        } catch (e) {
          // If geocoding fails, still update location with coordinates only
          _updateLocation(location, null);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                  SizedBox(width: 12.w),
                  const Text('Location found!'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.all(16.w),
              duration: const Duration(seconds: 2),
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
                  const Expanded(
                    child: Text(
                      'Could not get location. Please check permissions and GPS.',
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.all(16.w),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () async {
                  await widget.locationService.openAppSettings();
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    }
  }

  // Helper method to update location
  void _updateLocation(LatLng location, String? address, {String? placeName}) {
    setState(() {
      _selectedLocation = location;

      String? formattedAddress;

      if (placeName != null && placeName.isNotEmpty) {
        if (address != null && address.isNotEmpty) {
          // Remove duplicate placeName (case-insensitive check)
          if (address.toLowerCase().startsWith(placeName.toLowerCase())) {
            formattedAddress = address;
          } else {
            formattedAddress = '$placeName, $address';
          }
        } else {
          formattedAddress = placeName;
        }
      } else {
        formattedAddress = address;
      }

      // ✅ Handle duplicate Plus Codes like "4HP8+2RJ, 4HP8+2RJ"
      if (formattedAddress != null && formattedAddress.isNotEmpty) {
        final parts = formattedAddress.split(',').map((e) => e.trim()).toList();

        // Remove consecutive or duplicate identical parts
        final uniqueParts = <String>[];
        for (final part in parts) {
          if (part.isNotEmpty && !uniqueParts.contains(part)) {
            uniqueParts.add(part);
          }
        }

        formattedAddress = uniqueParts.join(', ');
      }

      _fullFormattedAddress = formattedAddress;

      // ✅ Keep the text field simple
      if (placeName != null && placeName.isNotEmpty) {
        widget.addressController.text = placeName;
      } else if (address != null && address.isNotEmpty) {
        widget.addressController.text = address;
      }

      // ✅ Update lat/long controllers
      if (widget.latitudeController != null && widget.longitudeController != null) {
        widget.latitudeController!.text = location.latitude.toStringAsFixed(6);
        widget.longitudeController!.text = location.longitude.toStringAsFixed(6);
      }

      // ✅ Update map marker
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: location,
          infoWindow: InfoWindow(
            title: placeName ?? address ?? 'Selected Location',
          ),
        ),
      );
    });

    // ✅ Notify parent with the clean, non-duplicated address
    if (_fullFormattedAddress != null && _fullFormattedAddress!.isNotEmpty) {
      widget.onLocationSelected?.call(location, _fullFormattedAddress!);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address TextField with Search
        TextFormField(
          controller: widget.addressController,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: 'Search address...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: widget.addressController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.addressController.clear();
                      setState(() {
                        _addressSuggestions = [];
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.secondary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300,width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.secondary, width: 2),
            ),
            filled: true,
            fillColor: widget.enabled ? Colors.white : Colors.grey.shade100,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
          style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
          maxLines: 1,
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            if (widget.enabled) {
              _onAddressChanged(value);
            }
          },
          validator: widget.addressValidator,
        ),
        SizedBox(height: 16.h),

        // Address Suggestions (show immediately after address field)
        if (_addressSuggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _addressSuggestions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
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

        // Get Current Location Button
        if (widget.enabled)
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
                  padding: EdgeInsets.symmetric(
                    vertical: 14.h,
                    horizontal: 16.w,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.my_location, color: Colors.white, size: 20.sp),
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
              target: _selectedLocation ?? _defaultLocation,
              zoom: 13.0,
            ),
            onTap: widget.enabled ? _onMapTap : null,
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

        // Full Address Display (shown below map)
        if (_fullFormattedAddress != null && _fullFormattedAddress!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.green.shade700,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Full Address',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade900,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  _fullFormattedAddress!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.green.shade900,
                    fontFamily: 'Poppins',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        if (_fullFormattedAddress != null && _fullFormattedAddress!.isNotEmpty)
          SizedBox(height: 12.h),

        // Map Instructions
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
                  widget.enabled
                      ? 'Drag & pinch to navigate the map. Tap anywhere to pinpoint exact location. Use +/- zoom controls for precision.'
                      : 'View current location on map. Enable edit mode to change location.',
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
      ],
    );
  }

  // Public method to allow parent to trigger address search
  void searchAddress(String query) {
    _onAddressChanged(query);
  }
}
