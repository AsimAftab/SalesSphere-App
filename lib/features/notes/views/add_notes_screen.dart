import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/constants/module_config.dart';
import 'package:sales_sphere/core/providers/permission_controller.dart';
import 'package:sales_sphere/core/utils/snackbar_utils.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/primary_image_picker.dart';
import 'package:sales_sphere/features/notes/vm/add_notes.vm.dart';
import 'package:sales_sphere/features/notes/vm/notes.vm.dart';
import 'package:sales_sphere/features/parties/vm/parties.vm.dart';
import 'package:sales_sphere/features/prospects/vm/prospects.vm.dart';
import 'package:sales_sphere/features/sites/vm/sites.vm.dart';

enum EntityType { party, prospect, site }

class AddNotesScreen extends ConsumerStatefulWidget {
  const AddNotesScreen({super.key});

  @override
  ConsumerState<AddNotesScreen> createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends ConsumerState<AddNotesScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  EntityType? _selectedEntityType;
  String? _selectedEntityId;
  String? _selectedEntityName;

  // Local loading state to cover note creation + image upload
  bool _isSubmitting = false;

  // Supports up to 2 images
  final List<XFile> _selectedImages = [];

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

  // --- IMAGE PICKER LOGIC ---
  Future<void> _pickImage() async {
    if (_selectedImages.length >= 2) return;

    try {
      final image = await showImagePickerSheet(context);
      if (image != null) {
        setState(() => _selectedImages.add(image));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _handleSubmit() async {
    // Check if any directory modules are enabled
    final permissionController = ref.read(permissionControllerProvider);
    final enabledDirectoryModules = ModuleConfig.getEnabledModules(
      ModuleConfig.directoryModules,
      permissionController.isModuleEnabled,
    );

    if (enabledDirectoryModules.isEmpty) {
      SnackbarUtils.showError(
        context,
        'No directory modules enabled. Contact your administrator.',
      );
      return;
    }

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
        final vm = ref.read(addNoteViewModelProvider.notifier);

        // Step 1: Create the note
        final noteId = await vm.createNote(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          partyId: _partyId,
          prospectId: _prospectId,
          siteId: _siteId,
        );

        // Step 2: Upload images if any
        if (_selectedImages.isNotEmpty) {
          await vm.uploadNoteImages(
            noteId,
            _selectedImages.map((e) => File(e.path)).toList(),
          );
        } else {
          // No images to upload, release the provider manually
          vm.release();
        }

        if (mounted) {
          SnackbarUtils.showSuccess(context, 'Note added successfully!');
          // Invalidate the list provider to refresh the notes list
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
                Expanded(
                  child: _buildEntityList(type, scrollController),
                ),
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
                    final isSelected = _selectedEntityId == party.id &&
                        _selectedEntityType == EntityType.party;
                    return _buildListTile(
                      id: party.id,
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
                    final isSelected = _selectedEntityId == prospect.id &&
                        _selectedEntityType == EntityType.prospect;
                    return _buildListTile(
                      id: prospect.id,
                      name: prospect.name,
                      subtitle: prospect.ownerName,
                      icon: Icons.person_search,
                      selectedColor: _getEntityColor(EntityType.prospect),
                      isSelected: isSelected,
                      onTap: () {
                        _selectEntity(
                            EntityType.prospect, prospect.id, prospect.name);
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
                    final isSelected = _selectedEntityId == site.id &&
                        _selectedEntityType == EntityType.site;
                    return _buildListTile(
                      id: site.id,
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
    required String id,
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
      trailing:
          isSelected ? Icon(Icons.check_circle, color: selectedColor) : null,
      onTap: onTap,
    );
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
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins')),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _isSubmitting ? null : () => context.pop()),
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
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r)),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      PrimaryTextField(
                        controller: _titleController,
                        label: const Text("Title"),
                        hintText: "Enter title",
                        prefixIcon: Icons.description_outlined,
                        hasFocusBorder: true,
                        enabled: !_isSubmitting,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),

                      // Entity selection section
                      Text(
                        "Link to (Select one) *",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textdark,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Entity type selector chips
                      IgnorePointer(
                        ignoring: _isSubmitting,
                        child: Opacity(
                          opacity: _isSubmitting ? 0.6 : 1.0,
                          child: _buildEntityTypeSelector(),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      PrimaryTextField(
                        label: const Text("Description"),
                        hintText: "Enter description",
                        controller: _descriptionController,
                        prefixIcon: Icons.description_outlined,
                        hasFocusBorder: true,
                        minLines: 1,
                        maxLines: 5,
                        enabled: !_isSubmitting,
                        textInputAction: TextInputAction.newline,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),

                      // --- DYNAMIC IMAGE SECTION ---
                      Text("Upload Images (Optional)",
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                              fontFamily: 'Poppins')),
                      SizedBox(height: 8.h),
                      IgnorePointer(
                        ignoring: _isSubmitting,
                        child: Opacity(
                          opacity: _isSubmitting ? 0.6 : 1.0,
                          child: _buildImageSection(),
                        ),
                      ),

                      SizedBox(height: 30.h),
                      PrimaryButton(
                        label: _isSubmitting ? "Saving..." : "Add Note",
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        width: double.infinity,
                        isLoading: _isSubmitting,
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

  Widget _buildEntityTypeSelector() {
    final permissionController = ref.watch(permissionControllerProvider);

    // Get enabled directory modules
    final enabledDirectoryModules = ModuleConfig.getEnabledModules(
      ModuleConfig.directoryModules,
      permissionController.isModuleEnabled,
    );

    // Map module IDs to EntityType
    final moduleToEntityType = {
      'parties': EntityType.party,
      'prospects': EntityType.prospect,
      'sites': EntityType.site,
    };

    // If all directory modules are disabled, show message
    if (enabledDirectoryModules.isEmpty) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.folder_off,
              size: 32.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 8.h),
            Text(
              'No directory modules enabled',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Entity type options - only show enabled modules
          Row(
            children: enabledDirectoryModules.map((moduleId) {
              final entityType = moduleToEntityType[moduleId];
              if (entityType == null) return const SizedBox.shrink();

              final label = moduleId == 'parties'
                  ? 'Party'
                  : moduleId == 'prospects'
                      ? 'Prospect'
                      : 'Site';
              final icon = moduleId == 'parties'
                  ? Icons.store_outlined
                  : moduleId == 'prospects'
                      ? Icons.person_search_outlined
                      : Icons.location_city_outlined;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: enabledDirectoryModules.indexOf(moduleId) <
                            enabledDirectoryModules.length - 1
                        ? 8.w
                        : 0,
                  ),
                  child: _buildEntityTypeChip(
                    type: entityType,
                    label: label,
                    icon: icon,
                  ),
                ),
              );
            }).toList(),
          ),

          // Selected entity display
          if (_hasEntitySelected) ...[
            SizedBox(height: 12.h),
            Builder(
              builder: (context) {
                final selectedColor = _getEntityColor(_selectedEntityType!);
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: selectedColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: selectedColor.withValues(alpha: 0.3)),
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
      onTap: () => _showEntitySelector(type),
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
    return PrimaryImagePicker(
      images: _selectedImages,
      maxImages: 2,
      showLabel: false,
      hintText: 'Tap to add note image (${_selectedImages.length}/2)',
      onPick: _pickImage,
      onRemove: (index) => setState(() => _selectedImages.removeAt(index)),
    );
  }
}
