import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/snackbar_utils.dart';
import 'package:sales_sphere/features/notes/models/notes.model.dart';
import 'package:sales_sphere/features/notes/vm/edit_notes.vm.dart';
import 'package:sales_sphere/features/notes/vm/notes.vm.dart';
import 'package:sales_sphere/features/parties/vm/parties.vm.dart';
import 'package:sales_sphere/features/prospects/vm/prospects.vm.dart';
import 'package:sales_sphere/features/sites/vm/sites.vm.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/primary_image_picker.dart';

enum EntityType { party, prospect, site }

class EditNoteScreen extends ConsumerStatefulWidget {
  final String noteId;

  const EditNoteScreen({super.key, required this.noteId});

  @override
  ConsumerState<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends ConsumerState<EditNoteScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  EntityType? _selectedEntityType;
  String? _selectedEntityId;
  String? _selectedEntityName;

  final List<XFile> _newImages = [];
  List<NoteImage> _existingImages = [];
  final List<int> _imagesToDelete = []; // Track image numbers to delete

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isEditMode = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    // Defer the fetch to after the first frame when ref is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNoteDetails();
    });
  }

  Future<void> _fetchNoteDetails() async {
    try {
      final vm = ref.read(editNoteViewModelProvider.notifier);
      final noteData = await vm.fetchNoteDetails(widget.noteId);

      if (mounted) {
        setState(() {
          _titleController.text = noteData.title;
          _descriptionController.text = noteData.description;
          _existingImages = noteData.images;

          // Set entity type based on which is present
          if (noteData.party != null) {
            _selectedEntityType = EntityType.party;
            _selectedEntityId = noteData.party!.id;
            _selectedEntityName = noteData.party!.partyName;
          } else if (noteData.prospect != null) {
            _selectedEntityType = EntityType.prospect;
            _selectedEntityId = noteData.prospect!.id;
            _selectedEntityName = noteData.prospect!.name;
          } else if (noteData.site != null) {
            _selectedEntityType = EntityType.site;
            _selectedEntityId = noteData.site!.id;
            _selectedEntityName = noteData.site!.name;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleEditMode() => setState(() => _isEditMode = !_isEditMode);

  void _selectEntity(EntityType type, String id, String name) {
    setState(() {
      _selectedEntityType = type;
      _selectedEntityId = id;
      _selectedEntityName = name;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedEntityType = null;
      _selectedEntityId = null;
      _selectedEntityName = null;
    });
  }

  bool get _hasEntitySelected => _selectedEntityId != null;

  String? get _partyId =>
      _selectedEntityType == EntityType.party ? _selectedEntityId : null;

  String? get _prospectId =>
      _selectedEntityType == EntityType.prospect ? _selectedEntityId : null;

  String? get _siteId =>
      _selectedEntityType == EntityType.site ? _selectedEntityId : null;

  Future<void> _handleSubmit() async {
    if (!_hasEntitySelected) {
      SnackbarUtils.showError(
        context,
        'Please select a Party, Prospect, or Site',
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      try {
        final vm = ref.read(editNoteViewModelProvider.notifier);

        await vm.updateNote(
          noteId: widget.noteId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          partyId: _partyId,
          prospectId: _prospectId,
          siteId: _siteId,
        );

        // Delete marked images
        for (final imageNumber in _imagesToDelete) {
          await vm.deleteNoteImage(widget.noteId, imageNumber);
        }

        if (_newImages.isNotEmpty) {
          final Map<int, File> imagesToUpload = {};
          final usedIndices = _existingImages
              .where((img) => !_imagesToDelete.contains(img.imageNumber))
              .map((e) => e.imageNumber)
              .toSet();

          int currentImageIndex = 0;
          // Check slots 1-5 (UI limits to 2, but this is safer for future)
          for (int i = 1; i <= 5; i++) {
            if (currentImageIndex >= _newImages.length) break;
            if (!usedIndices.contains(i)) {
              imagesToUpload[i] = File(_newImages[currentImageIndex].path);
              currentImageIndex++;
            }
          }

          if (imagesToUpload.isNotEmpty) {
            await vm.uploadNoteImages(widget.noteId, imagesToUpload);
          } else {
            // No new images to upload, release the provider
            vm.release();
          }
        } else {
          // No new images at all, release the provider
          vm.release();
        }

        if (mounted) {
          SnackbarUtils.showSuccess(context, 'Note updated successfully!');
          ref.invalidate(notesViewModelProvider);
          context.pop(true);
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

  void _showEntitySelector(EntityType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Text(
                        'Select ${_getEntityTypeName(type)}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: _buildEntityList(type, scrollController)),
              ],
            );
          },
        );
      },
    );
  }

  String _getEntityTypeName(EntityType type) {
    switch (type) {
      case EntityType.party:
        return 'Party';
      case EntityType.prospect:
        return 'Prospect';
      case EntityType.site:
        return 'Site';
    }
  }

  IconData _getEntityIcon(EntityType type) {
    switch (type) {
      case EntityType.party:
        return Icons.store;
      case EntityType.prospect:
        return Icons.person_search;
      case EntityType.site:
        return Icons.location_city;
    }
  }

  Color _getEntityColor(EntityType type) {
    switch (type) {
      case EntityType.party:
        return AppColors.primary;
      case EntityType.prospect:
        return Colors.orange;
      case EntityType.site:
        return Colors.green;
    }
  }

  Widget _buildEntityList(EntityType type, ScrollController scrollController) {
    switch (type) {
      case EntityType.party:
        return Consumer(
          builder: (context, ref, _) {
            final partiesAsync = ref.watch(partiesViewModelProvider);
            return partiesAsync.when(
              data: (parties) {
                if (parties.isEmpty) {
                  return _buildEmptyState('No parties found');
                }
                return ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: parties.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final party = parties[index];
                    final isSelected =
                        _selectedEntityId == party.id &&
                        _selectedEntityType == EntityType.party;
                    return _buildListTile(
                      name: party.name,
                      subtitle: party.ownerName,
                      icon: Icons.store,
                      selectedColor: _getEntityColor(EntityType.party),
                      isSelected: isSelected,
                      onTap: () {
                        _selectEntity(EntityType.party, party.id, party.name);
                        context.pop();
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            );
          },
        );

      case EntityType.prospect:
        return Consumer(
          builder: (context, ref, _) {
            final prospectsAsync = ref.watch(prospectViewModelProvider);
            return prospectsAsync.when(
              data: (prospects) {
                if (prospects.isEmpty) {
                  return _buildEmptyState('No prospects found');
                }
                return ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: prospects.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final prospect = prospects[index];
                    final isSelected =
                        _selectedEntityId == prospect.id &&
                        _selectedEntityType == EntityType.prospect;
                    return _buildListTile(
                      name: prospect.name,
                      subtitle: prospect.ownerName,
                      icon: Icons.person_search,
                      selectedColor: _getEntityColor(EntityType.prospect),
                      isSelected: isSelected,
                      onTap: () {
                        _selectEntity(
                          EntityType.prospect,
                          prospect.id,
                          prospect.name,
                        );
                        context.pop();
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            );
          },
        );

      case EntityType.site:
        return Consumer(
          builder: (context, ref, _) {
            final sitesAsync = ref.watch(siteViewModelProvider);
            return sitesAsync.when(
              data: (sites) {
                if (sites.isEmpty) {
                  return _buildEmptyState('No sites found');
                }
                return ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: sites.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final site = sites[index];
                    final isSelected =
                        _selectedEntityId == site.id &&
                        _selectedEntityType == EntityType.site;
                    return _buildListTile(
                      name: site.name,
                      subtitle: site.location,
                      icon: Icons.location_city,
                      selectedColor: _getEntityColor(EntityType.site),
                      isSelected: isSelected,
                      onTap: () {
                        _selectEntity(EntityType.site, site.id, site.name);
                        context.pop();
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            );
          },
        );
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.grey,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String name,
    required String subtitle,
    required IconData icon,
    required Color selectedColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected ? selectedColor : Colors.grey.shade200,
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
          size: 20.sp,
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey,
          fontFamily: 'Poppins',
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: selectedColor)
          : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to keep it alive (prevent auto-dispose)
    ref.watch(editNoteViewModelProvider);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textdark),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textdark),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                _errorMessage!,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _fetchNoteDetails();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          _isEditMode ? "Edit Note" : "Note Details",
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textdark),
          onPressed: _isSubmitting ? null : () => context.pop(),
        ),
        actions: [
          if (_isEditMode && !_isSubmitting)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditMode = false;
                  _newImages.clear();
                  _imagesToDelete.clear();
                });
                _fetchNoteDetails();
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
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8.h),
                                PrimaryTextField(
                                  controller: _titleController,
                                  label: const Text("Title"),
                                  hintText: "Enter title",
                                  prefixIcon: Icons.title,
                                  enabled: _isEditMode && !_isSubmitting,
                                  validator: (v) =>
                                      v!.isEmpty ? 'Required' : null,
                                ),
                                SizedBox(height: 16.h),

                                // Entity selection
                                Text(
                                  "Linked to *",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                IgnorePointer(
                                  ignoring: !_isEditMode || _isSubmitting,
                                  child: Opacity(
                                    opacity: (!_isEditMode || _isSubmitting)
                                        ? 0.7
                                        : 1.0,
                                    child: _buildEntityTypeSelector(),
                                  ),
                                ),

                                SizedBox(height: 16.h),
                                PrimaryTextField(
                                  controller: _descriptionController,
                                  label: const Text("Description"),
                                  hintText: "Enter description",
                                  prefixIcon: Icons.description_outlined,
                                  enabled: _isEditMode && !_isSubmitting,
                                  minLines: 1,
                                  maxLines: 5,
                                  validator: (v) =>
                                      v!.isEmpty ? 'Required' : null,
                                ),
                                SizedBox(height: 24.h),
                                IgnorePointer(
                                  ignoring: !_isEditMode || _isSubmitting,
                                  child: Opacity(
                                    opacity: (!_isEditMode || _isSubmitting)
                                        ? 0.7
                                        : 1.0,
                                    child: _buildImageSection(),
                                  ),
                                ),
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
                  label: _isSubmitting
                      ? "Saving..."
                      : (_isEditMode ? "Save Changes" : "Edit Note"),
                  onPressed: _isSubmitting
                      ? null
                      : (_isEditMode ? _handleSubmit : _toggleEditMode),
                  leadingIcon: _isEditMode
                      ? Icons.check_rounded
                      : Icons.edit_outlined,
                  size: ButtonSize.medium,
                  isLoading: _isSubmitting,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEntityTypeSelector() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildEntityTypeChip(
                  type: EntityType.party,
                  label: 'Party',
                  icon: Icons.store_outlined,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildEntityTypeChip(
                  type: EntityType.prospect,
                  label: 'Prospect',
                  icon: Icons.person_search_outlined,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildEntityTypeChip(
                  type: EntityType.site,
                  label: 'Site',
                  icon: Icons.location_city_outlined,
                ),
              ),
            ],
          ),
          if (_hasEntitySelected) ...[
            SizedBox(height: 12.h),
            Builder(
              builder: (context) {
                final selectedColor = _getEntityColor(_selectedEntityType!);
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: selectedColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: selectedColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getEntityIcon(_selectedEntityType!),
                        color: selectedColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedEntityName!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textdark,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              _getEntityTypeName(_selectedEntityType!),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isEditMode)
                        GestureDetector(
                          onTap: _clearSelection,
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.grey.shade600,
                              size: 16.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEntityTypeChip({
    required EntityType type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedEntityType == type;
    final selectedColor = _getEntityColor(type);

    return GestureDetector(
      onTap: _isEditMode ? () => _showEntitySelector(type) : null,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 22.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    // Filter out images marked for deletion
    final visibleExistingImages = _existingImages
        .where((img) => !_imagesToDelete.contains(img.imageNumber))
        .toList();
    final totalImages = visibleExistingImages.length + _newImages.length;
    final canAddMore = totalImages < 2;
    if (visibleExistingImages.isEmpty && _newImages.isEmpty && !_isEditMode) {
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
      images: _newImages,
      networkImageUrls: visibleExistingImages.map((e) => e.imageUrl).toList(),
      maxImages: 2,
      label: 'Note Images (Optional)',
      enabled: _isEditMode,
      hintText: 'Tap to add note image ($totalImages/2)',
      onPick: () async {
        if (!_isEditMode || !canAddMore) return;
        final image = await showImagePickerSheet(context);
        if (image != null) {
          setState(() => _newImages.add(image));
        }
      },
      onRemove: (index) {
        if (!_isEditMode) return;
        setState(() => _newImages.removeAt(index));
      },
      onRemoveNetwork: (index) {
        if (!_isEditMode) return;
        final noteImage = visibleExistingImages[index];
        setState(() => _imagesToDelete.add(noteImage.imageNumber));
      },
    );
  }
}
