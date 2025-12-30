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
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/features/parties/vm/parties.vm.dart';
import 'package:sales_sphere/features/expense-claim/models/expense_claim.model.dart';
import 'package:sales_sphere/features/expense-claim/vm/expense_claim_edit.vm.dart';
import 'package:sales_sphere/features/expense-claim/vm/expense_claims.vm.dart';

class EditExpenseClaimScreen extends ConsumerStatefulWidget {
  final ExpenseClaimDetailApiData claimData;

  const EditExpenseClaimScreen({
    super.key,
    required this.claimData,
  });

  @override
  ConsumerState<EditExpenseClaimScreen> createState() =>
      _EditExpenseClaimScreenState();
}

class _EditExpenseClaimScreenState
    extends ConsumerState<EditExpenseClaimScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;

  // Dropdowns
  String? _selectedCategory;
  String? _selectedPartyId;

  // Date
  late DateTime _selectedDate;

  // Image Picking
  final ImagePicker _picker = ImagePicker();
  XFile? _newImage; // New image picked by user
  bool _hasExistingImage = false; // Track if claim has existing image
  bool _deleteExistingImage = false; // Track if user wants to delete existing image

  // Category options
  final List<String> _categories = [
    'Travel',
    'Food',
    'Accommodation',
    'Fuel',
    'Miscellaneous',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadExistingData();
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    _dateController = TextEditingController();
  }

  void _loadExistingData() {
    // Note: Model doesn't have title field, we'll use claimType for now
    _titleController.text = widget.claimData.claimType;
    _amountController.text = widget.claimData.amount.toString();
    _selectedCategory = widget.claimData.claimType;
    _selectedPartyId = null; // Model doesn't have partyId field
    _descriptionController.text = widget.claimData.description ?? '';
    
    // Parse date
    try {
      _selectedDate = DateTime.parse(widget.claimData.date);
      _dateController.text = _formatDateForDisplay(_selectedDate);
    } catch (e) {
      _selectedDate = DateTime.now();
    }

    // Check if has existing image
    _hasExistingImage = widget.claimData.receiptUrl != null && 
                        widget.claimData.receiptUrl!.isNotEmpty;
  }

  String _formatDateForDisplay(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // IMAGE PICKER LOGIC
  // ---------------------------------------------------------------------------
  Future<void> _pickImage() async {
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
                    if (image != null) {
                      setState(() {
                        _newImage = image;
                        _deleteExistingImage = false;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await _picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);
                    if (image != null) {
                      setState(() {
                        _newImage = image;
                        _deleteExistingImage = false;
                      });
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

  void _removeNewImage() {
    setState(() {
      _newImage = null;
    });
  }

  void _deleteExistingImageAction() {
    setState(() {
      _deleteExistingImage = true;
      _hasExistingImage = false;
    });
  }

  // ---------------------------------------------------------------------------
  // SUBMIT LOGIC
  // ---------------------------------------------------------------------------
  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      try {
        // Show Loading
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Updating expense claim...'),
              backgroundColor: AppColors.primary,
              duration: Duration(seconds: 30),
            ),
          );
        }

        // Format date as YYYY-MM-DD
        final formattedDate =
            '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

        // Update expense claim
        final vm = ref.read(expenseClaimEditViewModelProvider.notifier);
        await vm.updateExpenseClaim(
          claimId: widget.claimData.id,
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
          category: _selectedCategory!,
          date: formattedDate,
          partyId: _selectedPartyId,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );

        // Handle image operations
        if (_deleteExistingImage && widget.claimData.receiptUrl != null) {
          // Delete existing image
          await vm.deleteImage(claimId: widget.claimData.id);
        }

        if (_newImage != null) {
          // Upload new image
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Uploading receipt image...'),
                backgroundColor: AppColors.primary,
                duration: Duration(seconds: 30),
              ),
            );
          }
          await vm.uploadImage(
            claimId: widget.claimData.id,
            imageFile: File(_newImage!.path),
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense claim updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          // Refresh the list
          ref.invalidate(expenseClaimsViewModelProvider);
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

  void _showPartySearchDialog(List parties) {
    final searchController = TextEditingController();
    List filteredParties = parties;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Select Party',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search Field
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search party...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            filteredParties = parties;
                          } else {
                            filteredParties = parties
                                .where((party) => party.name
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          }
                        });
                      },
                    ),
                    SizedBox(height: 16.h),
                    // None Option
                    ListTile(
                      leading: const Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                      ),
                      title: Text(
                        'None',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                      onTap: () {
                        this.setState(() {
                          _selectedPartyId = null;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(height: 1),
                    // Party List
                    Expanded(
                      child: filteredParties.isEmpty
                          ? Center(
                              child: Text(
                                'No parties found',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14.sp,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredParties.length,
                              itemBuilder: (context, index) {
                                final party = filteredParties[index];
                                return ListTile(
                                  leading: const Icon(
                                    Icons.person_outline,
                                    color: AppColors.primary,
                                  ),
                                  title: Text(
                                    party.name,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  subtitle: Text(
                                    party.fullAddress,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  selected: _selectedPartyId == party.id,
                                  selectedTileColor:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  onTap: () {
                                    this.setState(() {
                                      _selectedPartyId = party.id;
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partiesViewModelProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Edit Expense Claim",
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
                      // Title
                      PrimaryTextField(
                        hintText: "Title",
                        controller: _titleController,
                        prefixIcon: Icons.title_outlined,
                        hasFocusBorder: true,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Required'
                                : null,
                      ),
                      SizedBox(height: 16.h),

                      // Amount
                      PrimaryTextField(
                        hintText: "Amount (INR)",
                        controller: _amountController,
                        prefixIcon: Icons.currency_rupee,
                        hasFocusBorder: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Invalid amount';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Category Dropdown
                      GestureDetector(
                        onTap: () => _showCategoryDialog(),
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
                                Icons.category_outlined,
                                color: Colors.grey.shade600,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                _selectedCategory ?? 'Category',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: _selectedCategory == null
                                      ? Colors.grey.shade600
                                      : AppColors.textdark,
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
                      SizedBox(height: 16.h),

                      // Party Dropdown (Optional)
                      partiesAsync.when(
                        data: (parties) => GestureDetector(
                          onTap: () => _showPartySearchDialog(parties),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6FA),
                              borderRadius: BorderRadius.circular(12.r),
                              border:
                                  Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  color: Colors.grey.shade600,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    _selectedPartyId == null
                                        ? 'Party (Optional)'
                                        : parties
                                            .firstWhere(
                                                (p) => p.id == _selectedPartyId)
                                            .name,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: _selectedPartyId == null
                                          ? Colors.grey.shade600
                                          : AppColors.textdark,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.search,
                                  color: Colors.grey.shade600,
                                  size: 20.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                        loading: () => Container(
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
                                Icons.people_outline,
                                color: Colors.grey.shade600,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              const Expanded(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        error: (error, stack) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.error),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Failed to load parties',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.error,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Date Picker
                      CustomDatePicker(
                        hintText: "Date",
                        controller: _dateController,
                        prefixIcon: Icons.calendar_today_outlined,
                        enabled: true,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      ),
                      SizedBox(height: 16.h),

                      // Description
                      PrimaryTextField(
                        hintText: "Description (Optional)",
                        controller: _descriptionController,
                        prefixIcon: Icons.description_outlined,
                        hasFocusBorder: true,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                      ),
                      SizedBox(height: 24.h),

                      // Image Picker Section
                      Text(
                        "Receipt Image (Optional)",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _buildImageSection(),

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
              label: 'Update',
              onPressed: _handleSubmit,
              size: ButtonSize.medium,
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Category',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _categories.map((category) {
              return ListTile(
                leading: Icon(
                  _getCategoryIcon(category),
                  color: AppColors.primary,
                ),
                title: Text(
                  category,
                  style: TextStyle(fontSize: 14.sp),
                ),
                selected: _selectedCategory == category,
                selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'travel':
        return Icons.directions_car;
      case 'food':
        return Icons.restaurant;
      case 'accommodation':
        return Icons.hotel;
      case 'fuel':
        return Icons.local_gas_station;
      case 'miscellaneous':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  Widget _buildImageSection() {
    // Show new image if picked
    if (_newImage != null) {
      return _buildNewImagePreview();
    }
    
    // Show existing image if available and not deleted
    if (_hasExistingImage && !_deleteExistingImage) {
      return _buildExistingImagePreview();
    }
    
    // Show upload area
    return _buildImageUploadArea();
  }

  Widget _buildNewImagePreview() {
    return GestureDetector(
      onTap: () => _showNewImagePreview(),
      child: Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            style: BorderStyle.solid,
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(
                File(_newImage!.path),
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
              ),
            ),
            // Preview overlay
            Positioned(
              bottom: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: 16.sp,
                    ),
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
            // Close button
            Positioned(
              top: 8.h,
              right: 8.w,
              child: GestureDetector(
                onTap: _removeNewImage,
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
  }

  Widget _buildExistingImagePreview() {
    return GestureDetector(
      onTap: () {
        // TODO: Show existing image preview from URL
      },
      child: Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            style: BorderStyle.solid,
          ),
        ),
        child: Stack(
          children: [
            // TODO: Load image from URL using Image.network or CachedNetworkImage
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image,
                    size: 40.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Existing Receipt Image",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textdark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            // Delete button
            Positioned(
              top: 8.h,
              right: 8.w,
              child: GestureDetector(
                onTap: _deleteExistingImageAction,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete,
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
  }

  Widget _buildImageUploadArea() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 40.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 8.h),
            Text(
              "Tap to add receipt image",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewImagePreview() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title at top
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Receipt Image Preview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Image container
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.file(
                      File(_newImage!.path),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Info text at bottom
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Pinch to zoom • Drag to pan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
