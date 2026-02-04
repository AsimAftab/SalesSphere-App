import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/google_places_service.dart';
import 'package:sales_sphere/core/utils/snackbar_utils.dart';
import 'package:sales_sphere/core/services/location_service.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/widget/location_picker_widget.dart';
import 'package:sales_sphere/features/miscellaneous/models/miscellaneous.model.dart';
import 'package:sales_sphere/features/miscellaneous/vm/miscellaneous_add.vm.dart';
import 'package:sales_sphere/features/miscellaneous/vm/miscellaneous_list.vm.dart';

final googlePlacesServiceProvider = Provider<GooglePlacesService>((ref) {
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  return GooglePlacesService(apiKey: apiKey);
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class AddMiscellaneousWorkScreen extends ConsumerStatefulWidget {
  const AddMiscellaneousWorkScreen({super.key});

  @override
  ConsumerState<AddMiscellaneousWorkScreen> createState() =>
      _AddMiscellaneousWorkScreenState();
}

class _AddMiscellaneousWorkScreenState
    extends ConsumerState<AddMiscellaneousWorkScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _natureOfWorkController;
  late TextEditingController _assignedByController;
  late TextEditingController _workDateController;
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  // Date
  DateTime _selectedDate = DateTime.now();

  // Image Picking
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  // Local loading state to cover work creation + image upload
  bool _isSubmitting = false;

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
    _natureOfWorkController = TextEditingController();
    _assignedByController = TextEditingController();
    _workDateController = TextEditingController();
    _addressController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
  }

  @override
  void dispose() {
    _natureOfWorkController.dispose();
    _assignedByController.dispose();
    _workDateController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // IMAGE PICKER LOGIC
  // ---------------------------------------------------------------------------
  Future<void> _pickImage() async {
    if (_isSubmitting) return;
    if (_selectedImages.length >= 2) {
      SnackbarUtils.showError(context, "Maximum 2 images allowed");
      return;
    }

    try {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 70);
                    if (image != null) _addImage(image);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);
                    if (image != null) _addImage(image);
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _addImage(XFile image) {
    setState(() {
      _selectedImages.add(image);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // ---------------------------------------------------------------------------
  // SUBMIT LOGIC
  // ---------------------------------------------------------------------------
  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_addressController.text
          .trim()
          .isEmpty) {
        SnackbarUtils.showError(context, 'Please enter an address');
        return;
      }

      if (_latitudeController.text.isEmpty ||
          _longitudeController.text.isEmpty) {
        SnackbarUtils.showError(context, 'Please select a location on map');
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        // Show Loading
        if (mounted) {
          SnackbarUtils.showInfo(
            context,
            'Submitting work...',
            duration: const Duration(seconds: 30),
          );
        }

        // Parse date from controller and format as YYYY-MM-DD
        DateTime dateToSubmit = _selectedDate;
        if (_workDateController.text.isNotEmpty) {
          try {
            dateToSubmit = DateFormat('dd MMM yyyy').parse(_workDateController.text);
          } catch (e) {
            dateToSubmit = _selectedDate;
          }
        }
        final formattedDate = '${dateToSubmit.year}-${dateToSubmit.month
            .toString().padLeft(2, '0')}-${dateToSubmit.day.toString().padLeft(
            2, '0')}';

        final request = CreateMiscellaneousWorkRequest(
          natureOfWork: _natureOfWorkController.text.trim(),
          assignedBy: _assignedByController.text.trim(),
          address: _addressController.text.trim(),
          latitude: double.parse(_latitudeController.text),
          longitude: double.parse(_longitudeController.text),
          workDate: formattedDate,
        );

        final vm = ref.read(miscellaneousAddViewModelProvider.notifier);
        final workId = await vm.createWork(request: request);

        // Upload images if any
        if (_selectedImages.isNotEmpty) {
          if (mounted) {
            SnackbarUtils.showInfo(
              context,
              'Uploading ${_selectedImages.length} image(s)...',
              duration: const Duration(seconds: 30),
            );
          }

          for (int i = 0; i < _selectedImages.length; i++) {
            final isLastImage = (i == _selectedImages.length - 1);
            await vm.uploadImage(
              workId: workId,
              imageFile: File(_selectedImages[i].path),
              imageNumber: i + 1,
              isLastImage: isLastImage,
            );
          }
        } else {
          // No images to upload, release the provider manually
          // Just invalidate to trigger cleanup
          ref.invalidate(miscellaneousAddViewModelProvider);
        }

        if (mounted) {
          SnackbarUtils.showSuccess(context, 'Work submitted successfully!');
          // Refresh the list screen
          ref.invalidate(miscellaneousListViewModelProvider);
          context.pop(); // Go back
        }
      } catch (e) {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            e.toString().replaceAll('Exception: ', ''),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
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
        title: Text(
          "Add Miscellaneous Work",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isSubmitting ? null : () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16.h),
          // White Card Container
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
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      // Nature of Work
                      PrimaryTextField(
                        label: const Text("Nature of Work"),
                        hintText: "Enter nature of work",
                        controller: _natureOfWorkController,
                        prefixIcon: Icons.work_outline,
                        hasFocusBorder: true,
                        enabled: !_isSubmitting,
                        validator: (value) =>
                        (value == null || value
                            .trim()
                            .isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      SizedBox(height: 16.h),

                      // Assigned By
                      PrimaryTextField(
                        label: const Text("Assigned By"),
                        hintText: "Enter assigned by",
                        controller: _assignedByController,
                        prefixIcon: Icons.person_outline,
                        hasFocusBorder: true,
                        enabled: !_isSubmitting,
                        validator: (value) =>
                        (value == null || value
                            .trim()
                            .isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      SizedBox(height: 16.h),

                      // Work Date Picker
                      CustomDatePicker(
                        hintText: "Work Date",
                        controller: _workDateController,
                        prefixIcon: Icons.event_outlined,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        enabled: !_isSubmitting,
                        validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Work date required'
                            : null,
                      ),
                      SizedBox(height: 16.h),

                      // Location Picker
                      LocationPickerWidget(
                        addressController: _addressController,
                        latitudeController: _latitudeController,
                        longitudeController: _longitudeController,
                        initialLocation: _defaultLocation,
                        placesService: ref.read(googlePlacesServiceProvider),
                        locationService: ref.read(locationServiceProvider),
                        enabled: !_isSubmitting,
                        addressValidator: (value) =>
                        (value == null || value
                            .trim()
                            .isEmpty)
                            ? 'Address required'
                            : null,
                        onLocationSelected: (location, address) {
                          if (mounted) {
                            setState(() {
                              _addressController.text = address;
                              _latitudeController.text =
                                  location.latitude.toStringAsFixed(6);
                              _longitudeController.text =
                                  location.longitude.toStringAsFixed(6);
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
                      ),
                      SizedBox(height: 16.h),

                      // Image Picker Section
                      Text(
                        "Images (Max 2 images allowed)",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      IgnorePointer(
                        ignoring: _isSubmitting,
                        child: Opacity(
                          opacity: _isSubmitting ? 0.6 : 1.0,
                          child: _buildImageUploadArea(),
                        ),
                      ),

                      SizedBox(height: 80.h), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Button
          Container(
            padding: EdgeInsets.fromLTRB(
              16.w,
              16.h,
              16.w,
              MediaQuery
                  .of(context)
                  .padding
                  .bottom + 16.h,
            ),
            color: Colors.white,
            child: PrimaryButton(
              label: _isSubmitting ? "Submitting..." : "Submit",
              onPressed: _isSubmitting ? null : _handleSubmit,
              size: ButtonSize.medium,
              isLoading: _isSubmitting,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Image Area
  Widget _buildImageUploadArea() {
    return Column(
      children: [
        // Show selected images first
        if (_selectedImages.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: GestureDetector(
                  onTap: () {
                    // Show preview dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          child: InteractiveViewer(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.file(File(_selectedImages[index].path)),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          File(_selectedImages[index].path),
                          width: double.infinity,
                          height: 200.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 8.h,
                        right: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.zoom_in, color: Colors.white, size: 16.sp),
                              SizedBox(width: 4.w),
                              Text(
                                'Tap to preview',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        // Upload button
        if (_selectedImages.length < 2)
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 120.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: Colors.grey.shade400, size: 40.sp),
                  SizedBox(height: 8.h),
                  Text(
                    "Tap to add image",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12.sp,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
