import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/google_places_service.dart';
import 'package:sales_sphere/core/services/location_service.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/widget/location_picker_widget.dart';
import 'package:sales_sphere/features/miscellaneous/models/miscellaneous.model.dart';
import 'package:sales_sphere/features/miscellaneous/vm/miscellaneous_edit.vm.dart';
import 'package:sales_sphere/features/miscellaneous/vm/miscellaneous_list.vm.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';

final googlePlacesServiceProvider = Provider<GooglePlacesService>((ref) {
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  return GooglePlacesService(apiKey: apiKey);
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class EditMiscellaneousWorkScreen extends ConsumerStatefulWidget {
  final MiscWorkData workData;

  const EditMiscellaneousWorkScreen({
    super.key,
    required this.workData,
  });

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
  final ImagePicker _picker = ImagePicker();
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
      _workDateController.text = DateFormat('dd MMM yyyy').format(_selectedDate);
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
  void _deleteExistingImage(int imageNumber) {
    setState(() {
      _deletedImageNumbers.add(imageNumber);
    });
  }

  int _getTotalImagesCount() {
    final existingCount = widget.workData.images.length - _deletedImageNumbers.length;
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

  Future<void> _pickImages() async {
    final totalCount = _getTotalImagesCount();
    if (totalCount >= 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 2 images allowed'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final remaining = 2 - totalCount;
        setState(() {
          if (remaining > 0) {
            _selectedImages.addAll(images.take(remaining));
          }
        });

        if (images.length > remaining) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Maximum 2 images allowed. Selected first $remaining.'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // ---------------------------------------------------------------------------
  // SUBMIT LOGIC
  // ---------------------------------------------------------------------------
  Future<void> _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter an address')),
        );
        return;
      }

      if (_latitudeController.text.isEmpty || _longitudeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location on map')),
        );
        return;
      }

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete image $imageNumber')),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to upload image ${availableNumbers[i]}')),
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
            dateToSubmit = DateFormat('dd MMM yyyy').parse(_workDateController.text);
          } catch (e) {
            dateToSubmit = _selectedDate;
          }
        }
        final formattedDate = '${dateToSubmit.year}-${dateToSubmit.month.toString().padLeft(2, '0')}-${dateToSubmit.day.toString().padLeft(2, '0')}';

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Work updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          // Refresh the list screen
          ref.invalidate(miscellaneousListViewModelProvider);
        }
      } catch (e) {
        // Close loading dialog if open
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error,
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
              Container(
                height: 120.h,
                color: Colors.transparent,
              ),
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
                      // Nature of Work
                      PrimaryTextField(
                        hintText: "Nature of Work",
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
                        hintText: "Assigned By",
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
                        placesService: ref.read(googlePlacesServiceProvider),
                        locationService: ref.read(locationServiceProvider),
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

                      // Existing Images Section
                      if (widget.workData.images.isNotEmpty) ...[
                        Text(
                          "Images",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.workData.images.length,
                          itemBuilder: (context, index) {
                            final image = widget.workData.images[index];
                            final isDeleted = _deletedImageNumbers.contains(image.imageNumber);
                            
                            // Don't show deleted images
                            if (isDeleted) return const SizedBox.shrink();
                            
                            return Padding(
                              padding: EdgeInsets.only(bottom: 6.h),
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
                                            child: Image.network(image.imageUrl),
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
                                      child: Image.network(
                                        image.imageUrl,
                                        width: double.infinity,
                                        height: 200.h,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: double.infinity,
                                            height: 200.h,
                                            color: Colors.grey.shade300,
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey.shade600,
                                              size: 48.sp,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8.h,
                                      left: 8.w,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(20.r),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.touch_app, color: Colors.white, size: 14.sp),
                                            SizedBox(width: 4.w),
                                            Text(
                                              'Tap to preview',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11.sp,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (_isEditMode)
                                      Positioned(
                                        top: 8.h,
                                        right: 8.w,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _deletedImageNumbers.add(image.imageNumber);
                                            });
                                          },
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
                      ],

                      // Add New Images Section (only in edit mode)
                      if (_isEditMode) ...[
                        if (widget.workData.images.isEmpty)
                          Text(
                            "Images (Max 2 images allowed)",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        if (widget.workData.images.isEmpty)
                          SizedBox(height: 8.h),
                        
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
                                          onTap: () => _removeNewImage(index),
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
                        if (_getTotalImagesCount() < 2)
                          GestureDetector(
                            onTap: _pickImages,
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

                            SizedBox(height: 80.h),
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
                  leadingIcon: _isEditMode ? Icons.check_rounded : Icons.edit_outlined,
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
