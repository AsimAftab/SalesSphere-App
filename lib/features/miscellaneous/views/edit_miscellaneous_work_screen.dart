import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/snackbar_utils.dart';
import 'package:sales_sphere/core/services/google_places_service.dart';
import 'package:sales_sphere/core/services/location_service.dart';
import 'package:sales_sphere/features/miscellaneous/models/miscellaneous.model.dart';
import 'package:sales_sphere/features/miscellaneous/vm/miscellaneous_edit.vm.dart';
import 'package:sales_sphere/features/miscellaneous/vm/miscellaneous_list.vm.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/location_picker_widget.dart';
import 'package:sales_sphere/widget/primary_image_picker.dart';

final googlePlacesServiceProvider = Provider<GooglePlacesService>((ref) {
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  return GooglePlacesService(apiKey: apiKey);
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class EditMiscellaneousWorkScreen extends ConsumerStatefulWidget {
  final MiscWorkData workData;

  const EditMiscellaneousWorkScreen({super.key, required this.workData});

  @override
  ConsumerState<EditMiscellaneousWorkScreen> createState() =>
      _EditMiscellaneousWorkScreenState();
}

class _EditMiscellaneousWorkScreenState
    extends ConsumerState<EditMiscellaneousWorkScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isEditMode = false;

  // Controllers
  late TextEditingController _natureOfWorkController;
  late TextEditingController _assignedByController;
  late TextEditingController _workDateController;
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  // Date
  late DateTime _selectedDate;

  // Image Picking
  final List<XFile> _selectedImages = [];

  // Track deleted existing images
  final List<int> _deletedImageNumbers = [];

  late LatLng _defaultLocation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadExistingData();
  }

  void _initializeControllers() {
    _natureOfWorkController = TextEditingController();
    _assignedByController = TextEditingController();
    _workDateController = TextEditingController();
    _addressController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
  }

  void _loadExistingData() {
    // Load existing work data
    _natureOfWorkController.text = widget.workData.natureOfWork;
    _assignedByController.text = widget.workData.assignedBy;
    _addressController.text = widget.workData.address;

    // Parse work date
    if (widget.workData.workDate != null) {
      _selectedDate = DateTime.parse(widget.workData.workDate!);
      _workDateController.text = DateFormat(
        'dd MMM yyyy',
      ).format(_selectedDate);
    } else {
      _selectedDate = DateTime.now();
    }

    // Note: latitude and longitude are not in the list response
    // So we'll use default location or make them optional
    _defaultLocation = const LatLng(13.1349646, 77.5668106);
    _latitudeController.text = _defaultLocation.latitude.toStringAsFixed(6);
    _longitudeController.text = _defaultLocation.longitude.toStringAsFixed(6);
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
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
  // IMAGE MANAGEMENT
  // ---------------------------------------------------------------------------
  int _getTotalImagesCount() {
    final existingCount =
        widget.workData.images.length - _deletedImageNumbers.length;
    return existingCount + _selectedImages.length;
  }

  List<int> _getAvailableImageNumbers() {
    // Get all existing image numbers that are NOT deleted
    final existingNumbers = widget.workData.images
        .where((img) => !_deletedImageNumbers.contains(img.imageNumber))
        .map((img) => img.imageNumber)
        .toList();

    // Find available slots (1 or 2)
    final available = <int>[];
    for (int i = 1; i <= 2; i++) {
      if (!existingNumbers.contains(i)) {
        available.add(i);
      }
    }
    return available;
  }

  Future<void> _pickImage() async {
    if (_getTotalImagesCount() >= 2) return;

    try {
      final image = await showImagePickerSheet(context);
      if (image != null) {
        setState(() => _selectedImages.add(image));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // SUBMIT LOGIC
  // ---------------------------------------------------------------------------
  Future<void> _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_addressController.text.trim().isEmpty) {
        SnackbarUtils.showError(context, 'Please enter an address');
        return;
      }

      if (_latitudeController.text.isEmpty ||
          _longitudeController.text.isEmpty) {
        SnackbarUtils.showError(context, 'Please select a location on map');
        return;
      }

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      try {
        final vm = ref.read(miscellaneousEditViewModelProvider.notifier);
        final dio = ref.read(dioClientProvider);

        // Step 1: Delete marked images IN PARALLEL - continue even if some fail
        if (_deletedImageNumbers.isNotEmpty) {
          await Future.wait(
            _deletedImageNumbers.map((imageNumber) async {
              try {
                await vm.deleteImage(
                  dio,
                  workId: widget.workData.id,
                  imageNumber: imageNumber,
                );
              } catch (e) {
                // Log but continue with other operations
                if (mounted) {
                  SnackbarUtils.showError(
                    context,
                    'Failed to delete image $imageNumber',
                  );
                }
              }
            }),
            eagerError: false,
          );
        }

        // Step 2: Upload new images IN PARALLEL - continue even if some fail
        if (_selectedImages.isNotEmpty) {
          final availableNumbers = _getAvailableImageNumbers();

          await Future.wait(
            List.generate(_selectedImages.length, (i) async {
              try {
                await vm.uploadImage(
                  dio,
                  workId: widget.workData.id,
                  imageFile: File(_selectedImages[i].path),
                  imageNumber: availableNumbers[i],
                );
              } catch (e) {
                // Log but continue with other operations
                if (mounted) {
                  SnackbarUtils.showError(
                    context,
                    'Failed to upload image ${availableNumbers[i]}',
                  );
                }
              }
            }),
            eagerError: false,
          );
        }

        // Step 3: Update work data
        // Parse date from controller and format as YYYY-MM-DD
        DateTime dateToSubmit = _selectedDate;
        if (_workDateController.text.isNotEmpty) {
          try {
            dateToSubmit = DateFormat(
              'dd MMM yyyy',
            ).parse(_workDateController.text);
          } catch (e) {
            dateToSubmit = _selectedDate;
          }
        }
        final formattedDate =
            '${dateToSubmit.year}-${dateToSubmit.month.toString().padLeft(2, '0')}-${dateToSubmit.day.toString().padLeft(2, '0')}';

        final updateRequest = CreateMiscellaneousWorkRequest(
          natureOfWork: _natureOfWorkController.text.trim(),
          address: _addressController.text.trim(),
          latitude: double.parse(_latitudeController.text),
          longitude: double.parse(_longitudeController.text),
          workDate: formattedDate,
          assignedBy: _assignedByController.text.trim(),
        );

        await vm.updateWork(
          dio,
          workId: widget.workData.id,
          request: updateRequest,
        );

        // Close loading dialog if open
        if (mounted) {
          context.pop();
        }

        // Show success and go back
        if (mounted) {
          setState(() {
            _isEditMode = false;
          });
          SnackbarUtils.showSuccess(context, 'Work updated successfully');
          // Refresh the list screen
          ref.invalidate(miscellaneousListViewModelProvider);
        }
      } catch (e) {
        // Close loading dialog if open
        if (mounted) {
          context.pop();
          SnackbarUtils.showError(
            context,
            e.toString().replaceAll('Exception: ', ''),
          );
        }
      }
    }
  }

  Widget _buildImageSection() {
    final visibleExistingImages = widget.workData.images
        .where((img) => !_deletedImageNumbers.contains(img.imageNumber))
        .toList();
    final totalImages = visibleExistingImages.length + _selectedImages.length;

    if (visibleExistingImages.isEmpty &&
        _selectedImages.isEmpty &&
        !_isEditMode) {
      return Container(
        height: 80.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            "No images attached",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      );
    }

    return PrimaryImagePicker(
      images: _selectedImages,
      networkImageUrls:
          visibleExistingImages.map((e) => e.imageUrl).toList(),
      maxImages: 2,
      label: 'Images (Max 2)',
      enabled: _isEditMode,
      hintText: 'Tap to add image ($totalImages/2)',
      onPick: _pickImage,
      onRemove: (index) {
        if (!_isEditMode) return;
        setState(() => _selectedImages.removeAt(index));
      },
      onRemoveNetwork: (index) {
        if (!_isEditMode) return;
        final img = visibleExistingImages[index];
        setState(() => _deletedImageNumbers.add(img.imageNumber));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Details",
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 20.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textdark),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isEditMode)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditMode = false;
                  _selectedImages.clear();
                  _deletedImageNumbers.clear();
                  _loadExistingData(); // Reset data
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
          Column(
            children: [
              Container(height: 120.h, color: Colors.transparent),
              // White Card Container
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 100.h),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
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
                      child: Form(
                        key: _formKey,
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
                              enabled: _isEditMode,
                              validator: _isEditMode
                                  ? (value) =>
                                        (value == null || value.trim().isEmpty)
                                        ? 'Required'
                                        : null
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
                              enabled: _isEditMode,
                              validator: _isEditMode
                                  ? (value) =>
                                        (value == null || value.trim().isEmpty)
                                        ? 'Required'
                                        : null
                                  : null,
                            ),
                            SizedBox(height: 16.h),

                            // Work Date Picker
                            CustomDatePicker(
                              hintText: "Work Date",
                              controller: _workDateController,
                              prefixIcon: Icons.event_outlined,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              enabled: _isEditMode,
                              validator: _isEditMode
                                  ? (value) =>
                                        (value == null || value.trim().isEmpty)
                                        ? 'Work date required'
                                        : null
                                  : null,
                            ),
                            SizedBox(height: 16.h),

                            // Location Picker
                            LocationPickerWidget(
                              addressController: _addressController,
                              latitudeController: _latitudeController,
                              longitudeController: _longitudeController,
                              initialLocation: _defaultLocation,
                              placesService: ref.read(
                                googlePlacesServiceProvider,
                              ),
                              locationService: ref.read(
                                locationServiceProvider,
                              ),
                              enabled: _isEditMode,
                              addressValidator: _isEditMode
                                  ? (value) =>
                                        (value == null || value.trim().isEmpty)
                                        ? 'Address required'
                                        : null
                                  : null,
                              onLocationSelected: (location, address) {
                                if (mounted) {
                                  setState(() {
                                    _addressController.text = address;
                                    _latitudeController.text = location.latitude
                                        .toStringAsFixed(6);
                                    _longitudeController.text = location
                                        .longitude
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

                            // Image Section
                            _buildImageSection(),
                          ],
                        ),
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
                  label: _isEditMode ? 'Save Changes' : 'Edit Detail',
                  onPressed: _isEditMode ? _handleUpdate : _toggleEditMode,
                  leadingIcon: _isEditMode
                      ? Icons.check_rounded
                      : Icons.edit_outlined,
                  size: ButtonSize.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
