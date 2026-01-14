import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/widget/custom_dropdown_textfield.dart';
import 'package:sales_sphere/features/collection/models/collection.model.dart';
import 'package:sales_sphere/features/collection/vm/collection.vm.dart';
import 'package:sales_sphere/features/collection/vm/edit_collection.vm.dart';
import 'package:sales_sphere/features/collection/vm/bank_names.vm.dart';
import 'package:sales_sphere/features/parties/vm/parties.vm.dart';

class EditCollectionScreen extends ConsumerStatefulWidget {
  final String collectionId;

  const EditCollectionScreen({super.key, required this.collectionId});

  @override
  ConsumerState<EditCollectionScreen> createState() =>
      _EditCollectionScreenState();
}

class _EditCollectionScreenState extends ConsumerState<EditCollectionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _bankNameController;
  late TextEditingController _chequeNoController;
  late TextEditingController _chequeDateController;
  late TextEditingController _descriptionController;

  // State
  String? _selectedPartyId;
  PaymentMode? _selectedPaymentMode;
  ChequeStatus? _selectedChequeStatus;
  String? _selectedBank;
  bool _isEditMode = false;
  bool _isLoading = true;
  String? _errorMessage;

  final List<XFile> _selectedImages = [];
  final List<String> _existingImages = []; // URLs from API
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _dateController = TextEditingController();
    _bankNameController = TextEditingController();
    _chequeNoController = TextEditingController();
    _chequeDateController = TextEditingController();
    _descriptionController = TextEditingController();
    _fetchCollectionData();
  }

  /// Fetch collection details from API
  Future<void> _fetchCollectionData() async {
    try {
      final vm = ref.read(editCollectionViewModelProvider.notifier);
      final data = await vm.fetchCollectionDetails(widget.collectionId);
      if (mounted) {
        _prefillDataFromApi(data);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Prefill form data from API response
  void _prefillDataFromApi(CollectionDetailApiData data) {
    _amountController.text = data.amountReceived.toString();

    // Format received date
    try {
      final dateTime = DateTime.parse(data.receivedDate);
      _dateController.text = DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      _dateController.text = data.receivedDate;
    }

    _selectedPartyId = data.party.id;
    _selectedPaymentMode = PaymentMode.fromApiValue(data.paymentMethod);
    _descriptionController.text = data.description;
    _selectedBank = data.bankName;
    _bankNameController.text = data.bankName ?? '';

    _chequeNoController.text = data.chequeNumber ?? '';

    // Format cheque date
    if (data.chequeDate != null && data.chequeDate!.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(data.chequeDate!);
        _chequeDateController.text = DateFormat('dd MMM yyyy').format(dateTime);
      } catch (e) {
        _chequeDateController.text = data.chequeDate!;
      }
    }

    if (data.chequeStatus != null) {
      _selectedChequeStatus = ChequeStatus.values.firstWhere(
        (e) => e.label.toLowerCase() == data.chequeStatus!.toLowerCase(),
        orElse: () => ChequeStatus.pending,
      );
    }

    // Store existing image URLs
    _existingImages.clear();
    _existingImages.addAll(data.images);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _bankNameController.dispose();
    _chequeNoController.dispose();
    _chequeDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showImagePreview(XFile imageFile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.w),
        child: Stack(
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(File(imageFile.path)),
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
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNetworkImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.w),
        child: Stack(
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  imageUrl,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 300.w,
                      height: 300.h,
                      color: Colors.grey.shade800,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 64.sp, color: Colors.white),
                          SizedBox(height: 16.h),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white, fontSize: 14.sp),
                          ),
                        ],
                      ),
                    );
                  },
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
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 24.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 2) return;
    try {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  context.pop();
                  final XFile? img = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 70,
                  );
                  if (img != null) setState(() => _selectedImages.add(img));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  context.pop();
                  final XFile? img = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 70,
                  );
                  if (img != null) setState(() => _selectedImages.add(img));
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  /// Parse date from controller text (handles both dd/MM/yyyy and other formats)
  DateTime _parseDateFromController(String dateText) {
    try {
      // If already in ISO format, parse directly
      if (dateText.contains('-')) {
        return DateTime.parse(dateText);
      }
      // Try parsing "dd MMM yyyy" format
      final dateTime = DateFormat('dd MMM yyyy').parse(dateText);
      return dateTime;
    } catch (e) {
      return DateTime.now();
    }
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Show loading
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Updating collection...'),
              backgroundColor: AppColors.primary,
              duration: Duration(seconds: 30),
            ),
          );
        }

        final vm = ref.read(editCollectionViewModelProvider.notifier);

        // Convert dates to ISO format (yyyy-MM-dd)
        final parsedReceivedDate = _parseDateFromController(_dateController.text);
        final formattedReceivedDate = parsedReceivedDate.toIso8601String().split('T')[0];

        // Only include cheque fields if payment mode is Cheque
        String? formattedChequeDate;
        String? chequeNumber;
        String? chequeStatus;

        if (_selectedPaymentMode == PaymentMode.cheque) {
          if (_chequeDateController.text.isNotEmpty) {
            final parsedChequeDate = _parseDateFromController(_chequeDateController.text);
            formattedChequeDate = parsedChequeDate.toIso8601String().split('T')[0];
          }
          chequeNumber = _chequeNoController.text.trim().isEmpty 
              ? null 
              : _chequeNoController.text.trim();
          chequeStatus = _selectedChequeStatus?.label.toLowerCase();
        }

        await vm.updateCollection(
          collectionId: widget.collectionId,
          amountReceived: double.parse(_amountController.text.trim()),
          receivedDate: formattedReceivedDate,
          paymentMethod: _selectedPaymentMode?.apiValue ?? 'cash',
          bankName: _selectedBank,
          chequeNumber: chequeNumber,
          chequeDate: formattedChequeDate,
          chequeStatus: chequeStatus,
          description: _descriptionController.text.trim(),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Collection Updated Successfully'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(collectionViewModelProvider);
        context.pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignedPartiesAsync = ref.watch(assignedPartiesProvider);

    // Show loading state while fetching data
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show error state
    if (_errorMessage != null) {
      return Scaffold(
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
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error: $_errorMessage'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCollectionData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final bool requiresImage = [
      PaymentMode.cheque,
      PaymentMode.bankTransfer,
      PaymentMode.qrPay,
    ].contains(_selectedPaymentMode);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Collection Details",
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
                setState(() {
                  _isEditMode = false;
                  // Re-fetch data to reset form
                  _fetchCollectionData();
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
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
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
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          bottom: 24.h,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: 100.h,
                                bottom: 16.h,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Container(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Party Name - populated from API
                                      assignedPartiesAsync.when(
                                        data: (parties) {
                                          final dropdownItems = parties
                                              .map(
                                                (p) => DropdownItem(
                                                  value: p.id,
                                                  label: p.displayName,
                                                ),
                                              )
                                              .toList();

                                          return CustomDropdownTextField<String>(
                                            hintText: "Party Name",
                                            searchHint: "Search party...",
                                            value: _selectedPartyId,
                                            prefixIcon: Icons.people_outline,
                                            enabled: _isEditMode,
                                            items: dropdownItems,
                                            onChanged: (val) => setState(
                                              () => _selectedPartyId = val,
                                            ),
                                          );
                                        },
                                        loading: () => PrimaryTextField(
                                          controller: TextEditingController(text: 'Loading...'),
                                          hintText: "Party Name",
                                          prefixIcon: Icons.people_outline,
                                          enabled: false,
                                          suffixWidget: const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        ),
                                        error: (e, _) => PrimaryTextField(
                                          controller: TextEditingController(text: ''),
                                          hintText: "Party Name",
                                          prefixIcon: Icons.people_outline,
                                          enabled: false,
                                          errorText: "Failed to load parties",
                                        ),
                                      ),
                                      SizedBox(height: 16.h),
                                      PrimaryTextField(
                                        controller: _amountController,
                                        hintText: "Amount Received",
                                        prefixIcon: Icons.currency_rupee,
                                        enabled: _isEditMode,
                                        keyboardType: TextInputType.number,
                                        validator: (v) =>
                                            v!.isEmpty ? 'Required' : null,
                                      ),
                                      SizedBox(height: 16.h),
                                      CustomDatePicker(
                                        controller: _dateController,
                                        hintText: "Received Date",
                                        prefixIcon:
                                            Icons.calendar_today_outlined,
                                        enabled: _isEditMode,
                                      ),
                                      SizedBox(height: 16.h),
                                      CustomDropdownTextField<PaymentMode>(
                                        hintText: "Payment Mode",
                                        value: _selectedPaymentMode,
                                        prefixIcon: Icons.credit_card_outlined,
                                        enabled: _isEditMode,
                                        items: PaymentMode.values
                                            .map(
                                              (mode) => DropdownItem(
                                                value: mode,
                                                label: mode.label,
                                                icon: mode.icon,
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) => setState(() {
                                          _selectedPaymentMode = val;
                                          _selectedBank = null;
                                          _chequeNoController.clear();
                                          _selectedChequeStatus = null;
                                        }),
                                        validator: (v) =>
                                            v == null ? 'Required' : null,
                                      ),
                                      if (_selectedPaymentMode ==
                                              PaymentMode.cheque ||
                                          _selectedPaymentMode ==
                                              PaymentMode.bankTransfer) ...[
                                        SizedBox(height: 16.h),
                                        // Bank Selector Dropdown from API
                                        ref.watch(bankNamesViewModelProvider).when(
                                          data: (banks) => CustomDropdownTextField<String>(
                                            hintText: "Select Bank",
                                            searchHint: "Search your bank...",
                                            value: _selectedBank,
                                            prefixIcon: Icons.account_balance_outlined,
                                            enabled: _isEditMode,
                                            items: banks
                                                .map(
                                                  (bank) => DropdownItem<String>(
                                                    value: bank.name,
                                                    label: bank.name,
                                                    icon: Icons.account_balance,
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (val) => setState(
                                              () => _selectedBank = val,
                                            ),
                                            validator: (v) =>
                                                v == null ? 'Required' : null,
                                          ),
                                          loading: () => PrimaryTextField(
                                            controller: TextEditingController(text: 'Loading banks...'),
                                            hintText: "Select Bank",
                                            prefixIcon: Icons.account_balance_outlined,
                                            enabled: false,
                                            suffixWidget: const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                          error: (e, _) => PrimaryTextField(
                                            controller: TextEditingController(text: ''),
                                            hintText: "Select Bank",
                                            prefixIcon: Icons.account_balance_outlined,
                                            enabled: false,
                                            errorText: "Failed to load banks",
                                          ),
                                        ),
                                      ],
                                      if (_selectedPaymentMode ==
                                          PaymentMode.cheque) ...[
                                        SizedBox(height: 16.h),
                                        PrimaryTextField(
                                          controller: _chequeNoController,
                                          hintText: "Cheque Number",
                                          prefixIcon: Icons.numbers_outlined,
                                          enabled: _isEditMode,
                                          validator: (v) =>
                                              v!.isEmpty ? 'Required' : null,
                                        ),
                                        SizedBox(height: 16.h),
                                        CustomDatePicker(
                                          controller: _chequeDateController,
                                          hintText: "Date of Cheque",
                                          prefixIcon:
                                              Icons.calendar_today_outlined,
                                          enabled: _isEditMode,
                                        ),
                                        SizedBox(height: 16.h),
                                        CustomDropdownTextField<ChequeStatus>(
                                          hintText: "Cheque Status",
                                          value: _selectedChequeStatus,
                                          prefixIcon: Icons.assignment_outlined,
                                          enabled: _isEditMode,
                                          items: ChequeStatus.values
                                              .map(
                                                (status) => DropdownItem(
                                                  value: status,
                                                  label: status.label,
                                                  icon: status.icon,
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (val) => setState(
                                            () => _selectedChequeStatus = val,
                                          ),
                                          validator: (v) =>
                                              v == null ? 'Required' : null,
                                        ),
                                      ],
                                      SizedBox(height: 16.h),
                                      PrimaryTextField(
                                        controller: _descriptionController,
                                        hintText: "Description",
                                        prefixIcon: Icons.description_outlined,
                                        enabled: _isEditMode,
                                        maxLines: 5,
                                        minLines: 1,
                                      ),
                                      if (requiresImage ||
                                          _selectedImages.isNotEmpty) ...[
                                        SizedBox(height: 20.h),
                                        Text(
                                          "Collection Images",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade600,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        _buildImageSection(),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomButton(),
                  ],
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildBottomButton() {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
    if (isKeyboardVisible) {
      return const SizedBox.shrink();
    }
    
    return Container(
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
        label: _isEditMode ? "Save Changes" : "Edit Detail",
        onPressed: _isEditMode
            ? _handleUpdate
            : () => setState(() => _isEditMode = true),
        width: double.infinity,
        leadingIcon: _isEditMode ? Icons.check_rounded : Icons.edit_outlined,
      ),
    );
  }

  Widget _buildImageSection() {
    final totalImages = _selectedImages.length + _existingImages.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show existing images from API (URLs)
        if (_existingImages.isNotEmpty)
          ..._existingImages.asMap().entries.map((entry) {
            int index = entry.key;
            String imageUrl = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildNetworkImageThumbnail(imageUrl, index),
            );
          }),
        // Show newly selected local images
        if (_selectedImages.isNotEmpty)
          ..._selectedImages.asMap().entries.map((entry) {
            int index = entry.key;
            XFile imageFile = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildImageThumbnail(imageFile, index),
            );
          }),
        if (_isEditMode && totalImages < 2)
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
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 32.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Tap to add collection image ($totalImages/2)",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Build thumbnail for network image (from API)
  Widget _buildNetworkImageThumbnail(String imageUrl, int index) {
    return GestureDetector(
      onTap: () => _showNetworkImagePreview(imageUrl),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 160.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 160.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                );
              },
            ),
          ),
          Positioned(
            bottom: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.zoom_in, color: Colors.white, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'Preview',
                    style: TextStyle(color: Colors.white, fontSize: 10.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(XFile imageFile, int index) {
    return GestureDetector(
      onTap: () => _showImagePreview(imageFile),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              File(imageFile.path),
              width: double.infinity,
              height: 160.h,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.zoom_in, color: Colors.white, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'Preview',
                    style: TextStyle(color: Colors.white, fontSize: 10.sp),
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
                onTap: () => setState(() => _selectedImages.removeAt(index)),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 16.sp),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
