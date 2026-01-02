import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/features/notes/vm/add_notes.vm.dart';

class AddNotesScreen extends ConsumerStatefulWidget {
  const AddNotesScreen({super.key});

  @override
  ConsumerState<AddNotesScreen> createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends ConsumerState<AddNotesScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  String? _selectedPartyId;
  String? _selectedProspectId;
  String? _selectedSiteId;

  // Supports up to 2 images
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateSelection({String? party, String? prospect, String? site}) {
    setState(() {
      _selectedPartyId = party;
      _selectedProspectId = prospect;
      _selectedSiteId = site;
    });
  }

  // --- IMAGE PICKER LOGIC ---
  Future<void> _pickImage() async {
    if (_selectedImages.length >= 2) return;

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
                    context.pop();
                    final XFile? image = await _picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 70);
                    if (image != null) {
                      setState(() => _selectedImages.add(image));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () async {
                    context.pop();
                    final XFile? image = await _picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);
                    if (image != null) {
                      setState(() => _selectedImages.add(image));
                    }
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

  // --- IMAGE PREVIEW & ZOOM LOGIC ---
  void _showImagePreview(XFile imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16.w),
          child: Stack(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.file(File(imageFile.path), fit: BoxFit.contain),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                        color: Colors.black54, shape: BoxShape.circle),
                    child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedPartyId == null && _selectedProspectId == null && _selectedSiteId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select one: Party, Prospect, or Site')),
        );
        return;
      }

      try {
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saving note...'), duration: Duration(seconds: 1)),
        );

        final vm = ref.read(addNoteViewModelProvider.notifier);

        // Step 1: Create the note
        final noteId = await vm.createNote(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          partyId: _selectedPartyId,
          prospectId: _selectedProspectId,
          siteId: _selectedSiteId,
        );

        // Step 2: Upload images if any
        if (_selectedImages.isNotEmpty) {
          await vm.uploadNoteImages(
            noteId,
            _selectedImages.map((e) => File(e.path)).toList(),
          );
        }

        if (mounted) {
          // Step 3: Success feedback
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note added successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Step 4: Navigate back to the previous screen (Notes Screen)
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
        centerTitle: true,
        title: Text("Add Notes",
            style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          SizedBox(height: 20.h),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30.r), topRight: Radius.circular(30.r)),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimaryTextField(
                        controller: _titleController,
                        hintText: "Title",
                        prefixIcon: Icons.description_outlined,
                        hasFocusBorder: true,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      SizedBox(height: 16.h),

                      _buildSelectionDropdown(label: "Party Name", icon: Icons.people_outline, value: _selectedPartyId, onTap: () => _updateSelection(party: "P-123")),
                      SizedBox(height: 16.h),
                      _buildSelectionDropdown(label: "Prospect Name", icon: Icons.person_search_outlined, value: _selectedProspectId, onTap: () => _updateSelection(prospect: "PR-123")),
                      SizedBox(height: 16.h),
                      _buildSelectionDropdown(label: "Sites Name", icon: Icons.location_city_outlined, value: _selectedSiteId, onTap: () => _updateSelection(site: "S-123")),
                      SizedBox(height: 16.h),

                      PrimaryTextField(
                        hintText: "Description",
                        controller: _descriptionController,
                        prefixIcon: Icons.description_outlined,
                        hasFocusBorder: true,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),

                      // --- DYNAMIC IMAGE SECTION ---
                      Text("Upload Images (Optional)",
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600, fontFamily: 'Poppins')),
                      SizedBox(height: 8.h),
                      _buildImageSection(),

                      SizedBox(height: 30.h),
                      PrimaryButton(label: "Add Note", onPressed: _handleSubmit, width: double.infinity),
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

  Widget _buildImageSection() {
    return Column(
      children: [
        // List existing images
        if (_selectedImages.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildImageThumbnail(_selectedImages[index], index),
              );
            },
          ),

        // Show Upload button if less than 2 images
        if (_selectedImages.length < 2)
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 100.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 32.sp, color: Colors.grey.shade400),
                  SizedBox(height: 4.h),
                  Text("Tap to add note image (${_selectedImages.length}/2)",
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, fontFamily: 'Poppins')),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageThumbnail(XFile imageFile, int index) {
    return GestureDetector(
      onTap: () => _showImagePreview(imageFile),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(File(imageFile.path), width: double.infinity, height: 140.h, fit: BoxFit.cover),
          ),
          // Preview Tag
          Positioned(
            bottom: 8.h, right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20.r)),
              child: Row(
                children: [
                  Icon(Icons.zoom_in, color: Colors.white, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text('Preview', style: TextStyle(color: Colors.white, fontSize: 10.sp)),
                ],
              ),
            ),
          ),
          // Remove Button
          Positioned(
            top: 8.h, right: 8.w,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImages.removeAt(index)),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: Icon(Icons.close, color: Colors.white, size: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionDropdown({required String label, required IconData icon, String? value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
          color: value != null ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade500, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(child: Text(value ?? label,
                style: TextStyle(color: value != null ? Colors.black : Colors.grey.shade500, fontFamily: 'Poppins', fontSize: 14.sp))),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}