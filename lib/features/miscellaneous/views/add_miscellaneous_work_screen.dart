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
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  
  // Date
  DateTime _selectedDate = DateTime.now();

  // Image Picking
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

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
    _addressController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
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
  // IMAGE PICKER LOGIC
  // ---------------------------------------------------------------------------
  Future<void> _pickImage() async {
    if (_selectedImages.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 2 images allowed")),
      );
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

      try {
        // Show Loading
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Submitting work...'),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 30),
            ),
          );
        }

        // Format date as YYYY-MM-DD
        final formattedDate = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

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
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Uploading ${_selectedImages.length} image(s)...'),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 30),
              ),
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
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Work submitted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          // Refresh the list screen
          ref.invalidate(miscellaneousListViewModelProvider);
          context.pop(); // Go back
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
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

                      // Image Picker Section
                      Text(
                        "Images (Max 2 images)",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _buildImageUploadArea(),

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
              MediaQuery.of(context).padding.bottom + 16.h,
            ),
            color: Colors.white,
            child: PrimaryButton(
              label: 'Submit',
              onPressed: _handleSubmit,
              size: ButtonSize.medium,
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
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    color: Colors.grey, size: 32.sp),
                SizedBox(height: 8.h),
                Text(
                  "Upload Image (${_selectedImages.length}/2)",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(height: 12.h),
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 12.w),
                      width: 100.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        image: DecorationImage(
                          image: FileImage(File(_selectedImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: CircleAvatar(
                          radius: 12.r,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close,
                              color: Colors.white, size: 16.sp),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
