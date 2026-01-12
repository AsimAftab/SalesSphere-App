import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:sales_sphere/features/expense-claim/vm/expense_categories.vm.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EditExpenseClaimScreen extends ConsumerStatefulWidget {
  final String claimId;

  const EditExpenseClaimScreen({
    super.key,
    required this.claimId,
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
  String? _selectedCategoryId;
  String? _selectedPartyId;
  bool _isAddingNewCategory = false;
  late TextEditingController _newCategoryController;

  // Date
  DateTime _selectedDate = DateTime.now();

  // Image Picking
  final ImagePicker _picker = ImagePicker();
  XFile? _newImage;
  bool _hasExistingImage = false;

  // Track if data has been loaded
  bool _isDataLoaded = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    _dateController = TextEditingController();
    _newCategoryController = TextEditingController();
  }

  void _loadExistingData(ExpenseClaimDetailApiData claimData) {
    _titleController.text = claimData.title;
    _amountController.text = claimData.amount.toString();

    _selectedCategoryId = claimData.category?.id;

    if (claimData.party != null && claimData.party is Map) {
      _selectedPartyId = (claimData.party as Map)['_id'] as String?;
    }

    _descriptionController.text = claimData.description ?? '';

    try {
      _selectedDate = DateTime.parse(claimData.date);
      _dateController.text = _formatDateForDisplay(_selectedDate);
    } catch (e) {
      _selectedDate = DateTime.now();
      _dateController.text = _formatDateForDisplay(_selectedDate);
    }

    if (claimData.receiptUrl != null && claimData.receiptUrl!.isNotEmpty) {
      _hasExistingImage = true;
    }
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
    _newCategoryController.dispose();
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
                    context.pop();
                    final XFile? image = await _picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 70);
                    if (image != null) {
                      setState(() {
                        _newImage = image;
                        _hasExistingImage = false;
                      });
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
                      setState(() {
                        _newImage = image;
                        _hasExistingImage = false;
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

  // ---------------------------------------------------------------------------
  // SUBMIT LOGIC
  // ---------------------------------------------------------------------------
  Future<void> _handleSubmit() async {
    final claimAsync = ref.read(expenseClaimByIdProvider(widget.claimId));
    final claim = claimAsync.value;

    if (claim != null && claim.status != 'pending') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot edit ${claim.status} expense claims'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategoryId == null &&
          (!_isAddingNewCategory || _newCategoryController.text.trim().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select or add a category')),
        );
        return;
      }

      try {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Updating expense claim...'),
              backgroundColor: AppColors.primary,
              duration: Duration(seconds: 30),
            ),
          );
        }

        final formattedDate = _selectedDate.toIso8601String().split('T')[0];

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

        final vm = ref.read(expenseClaimEditViewModelProvider.notifier);
        await vm.updateExpenseClaim(
          claimId: widget.claimId,
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
          category: categoryToSend,
          incurredDate: formattedDate,
          party: _selectedPartyId,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );

        if (_newImage != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Uploading receipt...'),
                backgroundColor: AppColors.primary,
                duration: Duration(seconds: 30),
              ),
            );
          }

          await vm.uploadReceipt(
            claimId: widget.claimId,
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
          ref.invalidate(expenseClaimsViewModelProvider);
          context.pop();
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
                    ListTile(
                      leading: const Icon(Icons.clear, color: AppColors.textSecondary),
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
                        context.pop();
                      },
                    ),
                    const Divider(height: 1),
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
                              context.pop();
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
                  onPressed: () => context.pop(),
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
    final categoriesAsync = ref.watch(expenseCategoriesViewModelProvider);
    final claimAsync = ref.watch(expenseClaimByIdProvider(widget.claimId));

    return claimAsync.when(
      data: (claimData) {
        return _buildScreen(context, claimData, partiesAsync, categoriesAsync);
      },
      loading: () => Scaffold(
        backgroundColor: Colors.grey.shade50,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Details",
            style: TextStyle(
              color: AppColors.textdark,
              fontSize: 18.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textdark),
            onPressed: () => context.pop(),
          ),
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                      child: Skeletonizer(
                        enabled: true,
                        child: Column(
                          children: [
                            Container(
                              height: 56.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              height: 56.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              height: 56.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Container(
                              height: 120.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Error'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textdark),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
              SizedBox(height: 16.h),
              Text(
                'Error loading claim',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textdark,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '$error',
                style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => ref.invalidate(expenseClaimByIdProvider(widget.claimId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreen(
      BuildContext context,
      ExpenseClaimDetailApiData claimData,
      AsyncValue partiesAsync,
      AsyncValue categoriesAsync,
      ) {
    // Always load data when screen is built to prevent empty fields
    if (!_isDataLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingData(claimData);
        setState(() {
          _isDataLoaded = true;
        });
      });
    }
    
    final bool isPending = claimData.status == 'pending';
    final bool isEditable = isPending && _isEditMode;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Details",
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 18.sp,
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
                  _newImage = null;
                  _isAddingNewCategory = false;
                  _hasExistingImage = false; // Will be set true in _loadExistingData if url exists
                  _loadExistingData(claimData); // Reset data
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
              // White Card Container
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Padding(
                    padding: EdgeInsets.only(top: 100.h, bottom: 16.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- NEW STATUS CARD ---
                          _buildStatusCard(claimData.status),
                          SizedBox(height: 24.h),

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(14.w),
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
                              children: [
                                // Title
                                PrimaryTextField(
                                  hintText: "Title",
                                  controller: _titleController,
                                  prefixIcon: Icons.title_outlined,
                                  hasFocusBorder: true,
                                  enabled: isEditable,
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
                                  enabled: isEditable,
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
                                categoriesAsync.when(
                                  data: (categories) => GestureDetector(
                                    onTap: isEditable ? () => _showCategoryDialog(categories) : null,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 14.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isEditable ? Colors.white : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: isEditable
                                              ? AppColors.border
                                              : AppColors.border.withValues(alpha: 0.2),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.category_outlined,
                                            color: Colors.grey.shade600,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Text(
                                              _isAddingNewCategory
                                                  ? 'Add New Category'
                                                  : (_selectedCategoryId == null
                                                  ? 'Category'
                                                  : categories
                                                  .firstWhere((c) => c.id == _selectedCategoryId,
                                                  orElse: () => const ExpenseCategory(id: '', name: 'Category'))
                                                  .name),
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                color: _isAddingNewCategory
                                                    ? AppColors.primary
                                                    : (_selectedCategoryId == null
                                                    ? AppColors.textHint
                                                    : (isEditable
                                                        ? AppColors.textPrimary
                                                        : AppColors.textSecondary.withValues(alpha: 0.6))),
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400,
                                              ),
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
                                  loading: () => const SizedBox.shrink(),
                                  error: (error, stack) => const SizedBox.shrink(),
                                ),
                                SizedBox(height: 16.h),

                                if (_isAddingNewCategory) ...[
                                  PrimaryTextField(
                                    controller: _newCategoryController,
                                    hintText: 'Enter new category name',
                                    prefixIcon: Icons.label_outline,
                                    enabled: isEditable,
                                    suffixWidget: IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.grey.shade600,
                                        size: 20.sp,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isAddingNewCategory = false;
                                          _newCategoryController.clear();
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (_isAddingNewCategory && (value == null || value.trim().isEmpty)) {
                                        return 'Please enter category name';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 16.h),
                                ],

                                // Party Dropdown
                                partiesAsync.when(
                                  data: (parties) => GestureDetector(
                                    onTap: isEditable ? () => _showPartySearchDialog(parties) : null,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 14.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isEditable ? Colors.white : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: isEditable
                                              ? AppColors.border
                                              : AppColors.border.withValues(alpha: 0.2),
                                          width: 1.5,
                                        ),
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
                                                  .firstWhere((p) => p.id == _selectedPartyId)
                                                  .name,
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                color: _selectedPartyId == null
                                                    ? AppColors.textHint
                                                    : (isEditable
                                                        ? AppColors.textPrimary
                                                        : AppColors.textSecondary.withValues(alpha: 0.6)),
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.search, color: Colors.grey.shade600, size: 20.sp),
                                        ],
                                      ),
                                    ),
                                  ),
                                  loading: () => const SizedBox.shrink(),
                                  error: (error, stack) => const SizedBox.shrink(),
                                ),
                                SizedBox(height: 16.h),

                                // Date Picker
                                CustomDatePicker(
                                  hintText: "Date",
                                  controller: _dateController,
                                  prefixIcon: Icons.calendar_today_outlined,
                                  enabled: isEditable,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                ),
                                SizedBox(height: 16.h),

                                // Description
                                PrimaryTextField(
                                  hintText: "Description (Optional)",
                                  controller: _descriptionController,
                                  prefixIcon: Icons.description_outlined,
                                  hasFocusBorder: true,
                                  enabled: isEditable,
                                  minLines: 1,
                                  maxLines: 5,
                                  textInputAction: TextInputAction.newline,
                                ),
                                SizedBox(height: 24.h),

                                // Image Picker Section - only show label if there's an image or in edit mode
                                if (_hasExistingImage || _newImage != null || isEditable) ...[
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
                                  _buildImageSection(claimData),
                                ],
                              ],
                            ),
                          ),

                          SizedBox(height: 80.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Button
          if (isPending)
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
              child: _isEditMode
                  ? PrimaryButton(
                      label: 'Save Changes',
                      onPressed: _handleSubmit,
                      leadingIcon: Icons.check_rounded,
                      size: ButtonSize.medium,
                    )
                  : PrimaryButton(
                      label: 'Edit Detail',
                      onPressed: _toggleEditMode,
                      leadingIcon: Icons.edit_outlined,
                                            size: ButtonSize.medium,
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
  // ---------------------------------------------------------------------------
  // STATUS CARD WIDGET
  // ---------------------------------------------------------------------------
  Widget _buildStatusCard(String status) {
    // Define styles based on status
    Color bgColor;
    Color borderColor;
    Color textColor;
    String displayStatus;

    switch (status.toLowerCase()) {
      case 'approved':
        bgColor = const Color(0xFFE8F5E9); // Light Green
        borderColor = const Color(0xFFC8E6C9);
        textColor = const Color(0xFF2E7D32); // Dark Green
        displayStatus = 'Approved';
        break;
      case 'rejected':
        bgColor = const Color(0xFFFFEBEE); // Light Red
        borderColor = const Color(0xFFFFCDD2);
        textColor = const Color(0xFFC62828); // Dark Red
        displayStatus = 'Rejected';
        break;
      case 'pending':
      default:
        bgColor = const Color(0xFFFFF9E6); // Light Yellow (Cream)
        borderColor = const Color(0xFFFFECB3);
        textColor = const Color(0xFFB78628); // Gold/Brown
        displayStatus = 'Pending';
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r), // Highly rounded
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // The Dot
          Container(
            height: 10.w,
            width: 10.w,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 16.w),

          // The Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Expense Status",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  displayStatus,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: textColor,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Read Only / Web Only Tag
          if (status.toLowerCase() != 'pending')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                "Read Only",
                style: TextStyle(
                  fontSize: 10.sp,
                  color: textColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCategoryDialog(List<ExpenseCategory> categories) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Select Category',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...categories.map((category) {
                return ListTile(
                  leading: Icon(
                    _getCategoryIcon(category.name),
                    color: AppColors.primary,
                  ),
                  title: Text(
                    category.name,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  selected: _selectedCategoryId == category.id,
                  selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = category.id;
                      _isAddingNewCategory = false;
                    });
                    context.pop();
                  },
                );
              }),
              Divider(height: 1.h, color: Colors.grey.shade300),
              ListTile(
                leading: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Add New Category',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _isAddingNewCategory = true;
                    _selectedCategoryId = null;
                  });
                  context.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'travel': return Icons.directions_car;
      case 'food': return Icons.restaurant;
      case 'accommodation': return Icons.hotel;
      case 'fuel': return Icons.local_gas_station;
      case 'miscellaneous': return Icons.more_horiz;
      default: return Icons.category;
    }
  }

  Widget _buildImageSection(ExpenseClaimDetailApiData claimData) {
    final bool isEditable = claimData.status == 'pending' && _isEditMode;

    if (_newImage != null) {
      return _buildNewImagePreview(isEditable);
    }

    if (_hasExistingImage && claimData.receiptUrl != null) {
      return _buildExistingImagePreview(claimData.receiptUrl!, isEditable);
    }

    if (isEditable) {
      return _buildImageUploadArea();
    }

    return const SizedBox.shrink();
  }

  Widget _buildNewImagePreview(bool isEditable) {
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
            if (isEditable)
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
                    child: Icon(Icons.close, color: Colors.white, size: 20.sp),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingImagePreview(String imageUrl, bool isEditable) {
    return GestureDetector(
      onTap: () => _showNetworkImagePreview(imageUrl),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              imageUrl,
              height: 200.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200.h,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
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
          if (isEditable)
            Positioned(
              top: 8.h,
              right: 8.w,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _hasExistingImage = false;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete, color: Colors.white, size: 20.sp),
                ),
              ),
            ),
        ],
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(File(_newImage!.path)),
          ),
        ),
      ),
    );
  }

  void _showNetworkImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}