import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/services/google_places_service.dart';
import 'package:sales_sphere/core/services/location_service.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
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

  // Controllers
  late TextEditingController _natureOfWorkController;
  late TextEditingController _assignedByController;
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
    } else {
      _selectedDate = DateTime.now();
    }

    // Note: latitude and longitude are not in the list response
    // So we'll use default location or make them optional
    _defaultLocation = const LatLng(13.1349646, 77.5668106);
    _latitudeController.text = _defaultLocation.latitude.toStringAsFixed(6);
    _longitudeController.text = _defaultLocation.longitude.toStringAsFixed(6);
  }

  @override
  void dispose() {
    _natureOfWorkController.dispose();
    _assignedByController.dispose();
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

        // Step 1: Delete marked images
        if (_deletedImageNumbers.isNotEmpty) {
          for (final imageNumber in _deletedImageNumbers) {
            await vm.deleteImage(
              dio,
              workId: widget.workData.id,
              imageNumber: imageNumber,
            );
          }
        }

        // Step 2: Upload new images with correct imageNumbers
        if (_selectedImages.isNotEmpty) {
          final availableNumbers = _getAvailableImageNumbers();

          for (int i = 0; i < _selectedImages.length; i++) {
            final imageNumber = availableNumbers[i];
            
            await vm.uploadImage(
              dio,
              workId: widget.workData.id,
              imageFile: File(_selectedImages[i].path),
              imageNumber: imageNumber,
            );
          }
        }

        // Step 3: Update work data
        final updateRequest = CreateMiscellaneousWorkRequest(
          natureOfWork: _natureOfWorkController.text.trim(),
          address: _addressController.text.trim(),
          latitude: double.parse(_latitudeController.text),
          longitude: double.parse(_longitudeController.text),
          workDate: _selectedDate.toIso8601String().split('T')[0],
          assignedBy: _assignedByController.text.trim(),
        );

        await vm.updateWork(
          dio,
          workId: widget.workData.id,
          request: updateRequest,
        );

        // Close loading dialog
        if (mounted) {
          context.pop();
        }

        // Show success and go back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Work updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          // Refresh the list screen
          ref.invalidate(miscellaneousListViewModelProvider);
          context.pop(); // Go back
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

  // ---------------------------------------------------------------------------
  // DATE PICKER
  // ---------------------------------------------------------------------------
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textdark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Edit Miscellaneous Work',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
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
                      // Nature of Work
                      PrimaryTextField(
                        hintText: "Nature of Work",
                        controller: _natureOfWorkController,
                        prefixIcon: Icons.work_outline,
                        hasFocusBorder: true,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Required'
                                : null,
                      ),
                      SizedBox(height: 16.h),

                      // Assigned By
                      PrimaryTextField(
                        hintText: "Assigned By",
                        controller: _assignedByController,
                        prefixIcon: Icons.person_outline,
                        hasFocusBorder: true,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Required'
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
                        enabled: true,
                        addressValidator: (value) =>
                            (value == null || value.trim().isEmpty)
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

                      // Work Date Picker
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.grey.shade600,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Work Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textdark,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey.shade600,
                                size: 24.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Existing Images Section
                      if (widget.workData.images.isNotEmpty) ...[
                        Text(
                          "Existing Images (${widget.workData.images.length - _deletedImageNumbers.length}/${widget.workData.images.length})",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textdark,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          height: 100.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.workData.images.length,
                            separatorBuilder: (context, index) => SizedBox(width: 12.w),
                            itemBuilder: (context, index) {
                              final image = widget.workData.images[index];
                              final isDeleted = _deletedImageNumbers.contains(image.imageNumber);
                              
                              return Stack(
                                children: [
                                  Opacity(
                                    opacity: isDeleted ? 0.4 : 1.0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: Image.network(
                                        image.imageUrl,
                                        width: 100.w,
                                        height: 100.h,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 100.w,
                                            height: 100.h,
                                            color: Colors.grey.shade300,
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey.shade600,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  if (isDeleted)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12.r),
                                          color: Colors.black54,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.delete_outline,
                                            color: Colors.white,
                                            size: 32.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    top: 4.h,
                                    right: 4.w,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (isDeleted) {
                                          setState(() {
                                            _deletedImageNumbers.remove(image.imageNumber);
                                          });
                                        } else {
                                          _deleteExistingImage(image.imageNumber);
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4.w),
                                        decoration: BoxDecoration(
                                          color: isDeleted ? Colors.orange : Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isDeleted ? Icons.undo : Icons.delete,
                                          color: Colors.white,
                                          size: 16.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],

                      // Add New Images Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add New Images (${_getTotalImagesCount()}/2)",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textdark,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          if (_getTotalImagesCount() < 2)
                            IconButton(
                              icon: Icon(
                                Icons.add_photo_alternate,
                                color: const Color(0xFFFF9100),
                                size: 28.sp,
                              ),
                              onPressed: _pickImages,
                            ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Selected New Images Preview
                      if (_selectedImages.isNotEmpty)
                        SizedBox(
                          height: 100.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 12.w),
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Image.file(
                                      File(_selectedImages[index].path),
                                      width: 100.w,
                                      height: 100.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4.h,
                                    right: 4.w,
                                    child: GestureDetector(
                                      onTap: () => _removeNewImage(index),
                                      child: Container(
                                        padding: EdgeInsets.all(4.w),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                      SizedBox(height: 32.h),

                      // Update Button
                      CustomButton(
                        label: 'Update Work',
                        onPressed: _handleUpdate,
                        backgroundColor: const Color(0xFFFF9100),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
