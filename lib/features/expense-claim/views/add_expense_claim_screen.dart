import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/snackbar_utils.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/widget/primary_image_picker.dart';
import 'package:sales_sphere/features/parties/vm/parties.vm.dart';
import 'package:sales_sphere/features/expense-claim/vm/expense_claim_add.vm.dart';
import 'package:sales_sphere/features/expense-claim/vm/expense_categories.vm.dart';
import 'package:sales_sphere/features/expense-claim/vm/expense_claims.vm.dart';
import 'package:sales_sphere/features/expense-claim/models/expense_claim.model.dart';

class AddExpenseClaimScreen extends ConsumerStatefulWidget {
  const AddExpenseClaimScreen({super.key});

  @override
  ConsumerState<AddExpenseClaimScreen> createState() =>
      _AddExpenseClaimScreenState();
}

class _AddExpenseClaimScreenState extends ConsumerState<AddExpenseClaimScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController; // Added Title Controller
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;

  // Dropdowns
  String? _selectedCategoryId;
  String? _selectedPartyId;

  // New Category
  bool _isAddingNewCategory = false;
  late TextEditingController _newCategoryController;

  // Date
  DateTime _selectedDate = DateTime.now();

  // Image Picking
  XFile? _selectedImage;

  // Category options (now loaded from API)

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(); // Initialize Title
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    _dateController = TextEditingController();
    _newCategoryController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose(); // Dispose Title
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // IMAGE PICKER LOGIC
  // ---------------------------------------------------------------------------
  Future<void> _pickImage() async {
    try {
      final image = await showImagePickerSheet(context);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  // ---------------------------------------------------------------------------
  // SUBMIT LOGIC
  // ---------------------------------------------------------------------------
  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate Category
      if (!_isAddingNewCategory && _selectedCategoryId == null) {
        SnackbarUtils.showWarning(context, 'Please select a category');
        return;
      }

      if (_isAddingNewCategory && _newCategoryController.text.trim().isEmpty) {
        SnackbarUtils.showWarning(context, 'Please enter new category name');
        return;
      }

      try {
        // Show Loading
        if (mounted) {
          SnackbarUtils.showInfo(
            context,
            'Submitting expense claim...',
            duration: const Duration(seconds: 30),
          );
        }

        // Get ViewModel
        final viewModel = ref.read(expenseClaimAddViewModelProvider.notifier);

        // Format date to ISO 8601 (yyyy-MM-dd)
        final formattedDate = _selectedDate.toIso8601String().split('T')[0];

        // Determine category to send
        String categoryToSend;
        if (_isAddingNewCategory && _newCategoryController.text.trim().isNotEmpty) {
          categoryToSend = _newCategoryController.text.trim();
        } else if (_selectedCategoryId != null) {
          final categoriesAsync = ref.read(expenseCategoriesViewModelProvider);
          final categories = categoriesAsync.value ?? [];
          final selectedCategory = categories.firstWhere(
                (c) => c.id == _selectedCategoryId,
            orElse: () => categories.first,
          );
          categoryToSend = selectedCategory.name;
        } else {
          throw Exception('Please select or add a category');
        }

        // Step 1: Create expense claim
        final claimId = await viewModel.createExpenseClaim(
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
          category: categoryToSend,
          incurredDate: formattedDate,
          partyId: _selectedPartyId,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );

        // Step 2: Upload receipt image if selected
        if (_selectedImage != null) {
          if (mounted) {
            SnackbarUtils.showInfo(
              context,
              'Uploading receipt...',
              duration: const Duration(seconds: 30),
            );
          }

          await viewModel.uploadReceipt(
            claimId: claimId,
            imageFile: File(_selectedImage!.path),
          );
        }

        if (mounted) {
          SnackbarUtils.showSuccess(context, 'Expense claim submitted successfully!');
          // Invalidate the list provider to refresh the expense claims list
          ref.invalidate(expenseClaimsViewModelProvider);
          context.pop(); // Go back
        }
      } catch (e) {
        if (mounted) {
          SnackbarUtils.showError(
            context,
            e.toString().replaceAll('Exception: ', ''),
          );
        }
      }
    }
  }

  void _showPartySearchDialog(List parties) {
    final searchController = TextEditingController();
    List _withSelectedFirst(List source) {
      final selectedId = _selectedPartyId;
      final sorted = List.of(source);
      if (selectedId == null) return sorted;
      sorted.sort((a, b) {
        if (a.id == selectedId && b.id != selectedId) return -1;
        if (a.id != selectedId && b.id == selectedId) return 1;
        return 0;
      });
      return sorted;
    }

    List filteredParties = _withSelectedFirst(parties);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              padding: EdgeInsets.only(
                top: 20.h,
                left: 20.w,
                right: 20.w,
                bottom: 20.h,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Icon(
                        Icons.store_outlined,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Select Party',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Choose an existing party',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search party...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        if (value.isEmpty) {
                          filteredParties = _withSelectedFirst(parties);
                        } else {
                          final searched = parties
                              .where((party) => party.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                          filteredParties = _withSelectedFirst(searched);
                        }
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  if (_selectedPartyId != null)
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      leading: Icon(
                        Icons.clear,
                        color: Colors.red.shade400,
                        size: 20.sp,
                      ),
                      title: Text(
                        'Clear selection',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Poppins',
                          color: Colors.red.shade400,
                        ),
                      ),
                      onTap: () {
                        this.setState(() {
                          _selectedPartyId = null;
                        });
                        context.pop();
                      },
                    ),
                  Divider(height: 16.h),
                  Text(
                    'Existing Parties',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: filteredParties.isEmpty
                        ? Center(
                            child: Text(
                              'No parties found',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14.sp,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredParties.length,
                            itemBuilder: (context, index) {
                              final party = filteredParties[index];
                              final isSelected = _selectedPartyId == party.id;
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                tileColor: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : null,
                                leading: Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.store_outlined,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade600,
                                  size: 20.sp,
                                ),
                                title: Text(
                                  party.name,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: 'Poppins',
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey.shade800,
                                  ),
                                ),
                                subtitle: Text(
                                  party.fullAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade500,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                onTap: () {
                                  this.setState(() {
                                    _selectedPartyId = party.id;
                                  });
                                  context.pop();
                                },
                              );
                            },
                          ),
                  ),
                ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partiesViewModelProvider);
    final categoriesAsync = ref.watch(expenseCategoriesViewModelProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Add Expense",
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
                      SizedBox(height: 8.h),
                      // 1. Title
                      PrimaryTextField(
                        label: const Text("Title"),
                        hintText: "Enter title",
                        controller: _titleController,
                        prefixIcon: Icons.title_outlined,
                        hasFocusBorder: true,
                        validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      SizedBox(height: 16.h),

                      // 2. Amount
                      PrimaryTextField(
                        label: const Text("Amount"),
                        hintText: "Enter amount",
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

                      // 3. Date Picker
                      CustomDatePicker(
                        hintText: "dd-mm-yyyy",
                        controller: _dateController,
                        prefixIcon: Icons.calendar_today_outlined,
                        enabled: true,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      ),
                      SizedBox(height: 16.h),

                      // 4. Category Dropdown
                      categoriesAsync.when(
                        data: (categories) => Column(
                          children: [
                            InkWell(
                              onTap: () => _showCategoryDialog(categories),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 14.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: AppColors.border, width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isAddingNewCategory
                                          ? Icons.add_circle_outline
                                          : Icons.category_outlined,
                                      color: AppColors.textSecondary,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        _isAddingNewCategory
                                            ? 'Add New...'
                                            : (_selectedCategoryId == null
                                                ? 'Select Category'
                                                : categories
                                                    .firstWhere(
                                                      (c) => c.id == _selectedCategoryId,
                                                      orElse: () => const ExpenseCategory(id: '', name: 'Category'),
                                                    )
                                                    .name),
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          color: (_isAddingNewCategory || _selectedCategoryId != null)
                                              ? AppColors.textPrimary
                                              : AppColors.textHint,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.textSecondary,
                                      size: 20.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_isAddingNewCategory) ...[
                              SizedBox(height: 12.h),
                              PrimaryTextField(
                                controller: _newCategoryController,
                                hintText: 'Enter new category name',
                                prefixIcon: Icons.label_outline,
                                validator: (value) {
                                  if (_isAddingNewCategory && (value == null || value.trim().isEmpty)) {
                                    return 'Please enter category name';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ],
                        ),
                        loading: () => Container(
                          height: 48.h,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        error: (error, stack) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.error, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'Failed to load categories',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.error,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // 5. Party Dropdown (Optional)
                      partiesAsync.when(
                        data: (parties) => InkWell(
                          onTap: () => _showPartySearchDialog(parties),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: AppColors.border, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.store_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    _selectedPartyId == null
                                        ? 'Select Party (Optional)'
                                        : parties
                                        .firstWhere(
                                            (p) => p.id == _selectedPartyId)
                                        .name,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: _selectedPartyId == null
                                          ? AppColors.textHint
                                          : AppColors.textPrimary,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSecondary,
                                  size: 20.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                        loading: () => Container(
                          height: 48.h,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        error: (error, stack) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.error, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'Failed to load parties',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.error,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // 6. Description
                      PrimaryTextField(
                        label: const Text("Description"),
                        hintText: "Enter description (optional)",
                        controller: _descriptionController,
                        prefixIcon: Icons.description_outlined,
                        hasFocusBorder: true,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                      ),
                      SizedBox(height: 24.h),

                      // Image Picker Section
                      PrimaryImagePicker(
                        images: _selectedImage != null ? [_selectedImage!] : [],
                        maxImages: 1,
                        label: 'Image (Optional)',
                        hintText: 'Tap to add receipt image',
                        onPick: _pickImage,
                        onRemove: (index) => _removeImage(),
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

  void _showCategoryDialog(List<ExpenseCategory> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        padding: EdgeInsets.only(
          top: 20.h,
          left: 20.w,
          right: 20.w,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Select Category',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Choose an existing category or create a new one',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 20.h),
            if (_selectedCategoryId != null)
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                leading: Icon(
                  Icons.clear,
                  color: Colors.red.shade400,
                  size: 20.sp,
                ),
                title: Text(
                  'Clear selection',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Poppins',
                    color: Colors.red.shade400,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedCategoryId = null;
                    _isAddingNewCategory = false;
                  });
                  context.pop();
                },
              ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              tileColor: _isAddingNewCategory
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : null,
              leading: Icon(
                _isAddingNewCategory
                    ? Icons.check_circle
                    : Icons.add_circle_outline,
                color: _isAddingNewCategory
                    ? AppColors.primary
                    : AppColors.success,
                size: 20.sp,
              ),
              title: Text(
                'Add New...',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Poppins',
                  fontWeight:
                      _isAddingNewCategory ? FontWeight.w600 : FontWeight.w400,
                  color: _isAddingNewCategory
                      ? AppColors.primary
                      : AppColors.success,
                ),
              ),
              onTap: () {
                context.pop();
                setState(() {
                  _isAddingNewCategory = true;
                  _selectedCategoryId = null;
                });
              },
            ),
            Divider(height: 16.h),
            Text(
              'Existing Categories',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 8.h),
            ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategoryId == category.id;
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  tileColor:
                      isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
                  leading: Icon(
                    isSelected ? Icons.check_circle : _getCategoryIcon(category.name),
                    color: isSelected ? AppColors.primary : Colors.grey.shade600,
                    size: 20.sp,
                  ),
                  title: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.primary : Colors.grey.shade800,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = category.id;
                      _isAddingNewCategory = false;
                      _newCategoryController.clear();
                    });
                    context.pop();
                  },
                );
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
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

}
