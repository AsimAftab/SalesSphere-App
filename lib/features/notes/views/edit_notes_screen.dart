import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/features/notes/vm/notes.vm.dart';
import 'package:sales_sphere/features/notes/vm/edit_notes.vm.dart';
import 'package:sales_sphere/features/notes/models/notes.model.dart';

class EditNoteScreen extends ConsumerStatefulWidget {
  final String noteId;

  const EditNoteScreen({
    super.key,
    required this.noteId,
  });

  @override
  ConsumerState<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends ConsumerState<EditNoteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  // Selection state
  String? _selectedPartyId;
  String? _selectedProspectId;
  String? _selectedSiteId;

  // Image Picking
  final ImagePicker _picker = ImagePicker();
  final List<File> _newImages = [];
  bool _isDataLoaded = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  /// Prefills data from the Mock List in NotesViewModel
  void _prefillMockData(List<NoteListItem> allNotes) {
    if (_isDataLoaded) return;

    final note = allNotes.firstWhere(
          (n) => n.id == widget.noteId,
      orElse: () => const NoteListItem(id: '', title: '', name: '', date: ''),
    );

    if (note.id.isNotEmpty) {
      _titleController.text = note.title;
      _descriptionController.text = note.content ?? "";

      // logic to pre-select based on note.name from mock data
      if (note.name.contains('Party')) _selectedPartyId = note.name;
      if (note.name.contains('Prospect')) _selectedProspectId = note.name;
      if (note.name.contains('Office') || note.name.contains('Site')) _selectedSiteId = note.name;

      _isDataLoaded = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleEditMode() => setState(() => _isEditMode = !_isEditMode);

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final vm = ref.read(editNoteViewModelProvider.notifier);

        await vm.updateNote(
          noteId: widget.noteId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          partyId: _selectedPartyId,
          prospectId: _selectedProspectId,
          siteId: _selectedSiteId,
        );

        if (_newImages.isNotEmpty) {
          await vm.uploadNoteImages(widget.noteId, _newImages);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          ref.invalidate(notesViewModelProvider);
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesViewModelProvider);
    notesAsync.whenData((notes) => _prefillMockData(notes));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Details",
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
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
                setState(() => _isEditMode = false);
                _isDataLoaded = false;
                notesAsync.whenData((notes) => _prefillMockData(notes));
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.error, fontSize: 14.sp),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: SvgPicture.asset(
              'assets/images/corner_bubble.svg',
              fit: BoxFit.cover,
              height: 180.h,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Padding(
                    padding: EdgeInsets.only(top: 100.h, bottom: 16.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PrimaryTextField(
                                  controller: _titleController,
                                  hintText: "Title",
                                  prefixIcon: Icons.title,
                                  enabled: _isEditMode,
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                                SizedBox(height: 16.h),
                                _buildDropdown(
                                  "Party Name",
                                  _selectedPartyId,
                                  Icons.people_outline,
                                      () => setState(() => _selectedPartyId = "Mock Party A"),
                                ),
                                SizedBox(height: 16.h),
                                _buildDropdown(
                                  "Prospect Name",
                                  _selectedProspectId,
                                  Icons.person_search,
                                      () => setState(() => _selectedProspectId = "Mock Prospect B"),
                                ),
                                SizedBox(height: 16.h),
                                _buildDropdown(
                                  "Sites Name",
                                  _selectedSiteId,
                                  Icons.location_city,
                                      () => setState(() => _selectedSiteId = "Mock Site C"),
                                ),
                                SizedBox(height: 16.h),
                                PrimaryTextField(
                                  controller: _descriptionController,
                                  hintText: "Description",
                                  prefixIcon: Icons.description_outlined,
                                  enabled: _isEditMode,
                                  minLines: 1,
                                  maxLines: 5,
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                                SizedBox(height: 24.h),
                                _buildImageSection(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: PrimaryButton(
                  label: _isEditMode ? "Save Changes" : "Edit Detail",
                  onPressed: _isEditMode ? _handleSubmit : _toggleEditMode,
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

  Widget _buildDropdown(String label, String? value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isEditMode ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: _isEditMode ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _isEditMode ? AppColors.border : AppColors.border.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                value ?? label,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: value == null ? AppColors.textHint : AppColors.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            if (_isEditMode)
              Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Note Images (Optional)",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 8.h),
        if (_newImages.isEmpty)
          GestureDetector(
            onTap: _isEditMode ? () async {
              final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
              if (image != null) setState(() => _newImages.add(File(image.path)));
            } : null,
            child: Container(
              height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 40.sp, color: Colors.grey.shade400),
                  SizedBox(height: 8.h),
                  Text(
                    "Tap to add images",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: _newImages.map((file) => Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.file(file, width: 100.w, height: 100.h, fit: BoxFit.cover),
                ),
                if (_isEditMode)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _newImages.remove(file)),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            )).toList(),
          ),
      ],
    );
  }
}