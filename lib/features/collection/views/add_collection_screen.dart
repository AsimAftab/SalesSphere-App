import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/widget/custom_dropdown_textfield.dart';
import 'package:sales_sphere/features/collection/vm/add_collection.vm.dart';
import 'package:sales_sphere/features/collection/models/collection.model.dart';

class AddCollectionScreen extends ConsumerStatefulWidget {
  const AddCollectionScreen({super.key});

  @override
  ConsumerState<AddCollectionScreen> createState() =>
      _AddCollectionScreenState();
}

class _AddCollectionScreenState extends ConsumerState<AddCollectionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _bankNameController;
  late TextEditingController _chequeNoController;
  late TextEditingController _chequeDateController;
  late TextEditingController _descriptionController;

  String? _selectedPartyId = "Mock Party";
  PaymentMode? _selectedPaymentMode;
  ChequeStatus? _selectedChequeStatus;
  String? _selectedBank;

  final List<XFile> _selectedImages = [];
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
      builder: (BuildContext context) => Dialog(
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

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedPaymentMode == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Payment Mode')),
        );
        return;
      }

      final bool imageRequired = [
        PaymentMode.cheque,
        PaymentMode.bankTransfer,
        PaymentMode.qrPay,
      ].contains(_selectedPaymentMode);

      if (imageRequired && _selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please upload an image for ${_selectedPaymentMode?.label} payment',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
        return;
      }

      try {
        final vm = ref.read(addCollectionViewModelProvider.notifier);
        final data = {
          'party': _selectedPartyId,
          'amount': double.parse(_amountController.text),
          'date': _dateController.text,
          'paymentMode': _selectedPaymentMode?.label,
          if (_selectedPaymentMode == PaymentMode.cheque ||
              _selectedPaymentMode == PaymentMode.bankTransfer)
            'bankName': _selectedBank,
          if (_selectedPaymentMode == PaymentMode.cheque) ...{
            'chequeNumber': _chequeNoController.text,
            'chequeDate': _chequeDateController.text,
            'chequeStatus': _selectedChequeStatus?.label,
          },
          'description': _descriptionController.text.trim(),
        };

        await vm.submitCollection(
          data: data,
          images: _selectedImages.map((e) => e.path).toList(),
        );

        // --- CHANGE START ---
        // Crucial: Check if the widget is still in the tree before using context
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Collection Added Successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        context.pop();
        // --- CHANGE END ---
      } catch (e) {
        // Also check here for safety
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool requiresImage = [
      PaymentMode.cheque,
      PaymentMode.bankTransfer,
      PaymentMode.qrPay,
    ].contains(_selectedPaymentMode);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Add Collection",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          margin: EdgeInsets.only(top: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.r),
              topRight: Radius.circular(32.r),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 24.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Party Name (Disabled for this example)
                        CustomDropdownTextField<String>(
                          hintText: "Party Name",
                          value: _selectedPartyId,
                          prefixIcon: Icons.people_outline,
                          enabled: false,
                          items: [
                            DropdownItem(
                              value: "Mock Party",
                              label: "Mock Party",
                            ),
                          ],
                          onChanged: (_) {},
                        ),
                        SizedBox(height: 16.h),
                        PrimaryTextField(
                          controller: _amountController,
                          hintText: "Amount Received",
                          prefixIcon: Icons.currency_rupee,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        SizedBox(height: 16.h),
                        CustomDatePicker(
                          controller: _dateController,
                          hintText: "Received Date",
                          prefixIcon: Icons.calendar_today_outlined,
                        ),
                        SizedBox(height: 16.h),

                        // Payment Mode Dropdown
                        CustomDropdownTextField<PaymentMode>(
                          hintText: "Payment Mode",
                          value: _selectedPaymentMode,
                          prefixIcon: Icons.credit_card_outlined,
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
                          validator: (v) => v == null ? 'Required' : null,
                        ),

                        if (_selectedPaymentMode == PaymentMode.cheque ||
                            _selectedPaymentMode ==
                                PaymentMode.bankTransfer) ...[
                          SizedBox(height: 16.h),
                          // Updated Bank Selector Dropdown with search and icons
                          CustomDropdownTextField<String>(
                            hintText: "Select Bank",
                            searchHint: "Search your bank...",
                            // This triggers the search bar in the overlay
                            value: _selectedBank,
                            prefixIcon: Icons.account_balance_outlined,
                            items:
                                [
                                      {
                                        'name': 'HDFC Bank',
                                        'icon': Icons.account_balance,
                                      },
                                      {
                                        'name': 'ICICI Bank',
                                        'icon': Icons.account_balance,
                                      },
                                      {
                                        'name': 'SBI',
                                        'icon': Icons.account_balance,
                                      },
                                      {
                                        'name': 'Axis Bank',
                                        'icon': Icons.account_balance,
                                      },
                                      {
                                        'name': 'Kotak Bank',
                                        'icon': Icons.account_balance,
                                      },
                                      {
                                        'name': 'PNB',
                                        'icon': Icons.account_balance,
                                      },
                                      {
                                        'name': 'Canara Bank',
                                        'icon': Icons.account_balance,
                                      },
                                    ]
                                    .map(
                                      (bank) => DropdownItem<String>(
                                        value: bank['name'] as String,
                                        label: bank['name'] as String,
                                        icon:
                                            bank['icon']
                                                as IconData, // This will show the monochrome icon
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedBank = val),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        ],

                        if (_selectedPaymentMode == PaymentMode.cheque) ...[
                          SizedBox(height: 16.h),
                          PrimaryTextField(
                            controller: _chequeNoController,
                            hintText: "Cheque Number",
                            prefixIcon: Icons.numbers_outlined,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          SizedBox(height: 16.h),
                          CustomDatePicker(
                            controller: _chequeDateController,
                            hintText: "Date of Cheque",
                            prefixIcon: Icons.calendar_today_outlined,
                          ),
                          SizedBox(height: 16.h),
                          // Cheque Status Dropdown
                          CustomDropdownTextField<ChequeStatus>(
                            hintText: "Cheque Status",
                            value: _selectedChequeStatus,
                            prefixIcon: Icons.assignment_outlined,
                            items: ChequeStatus.values
                                .map(
                                  (status) => DropdownItem(
                                    value: status,
                                    label: status.label,
                                    icon: status.icon,
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedChequeStatus = val),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        ],
                        SizedBox(height: 16.h),
                        PrimaryTextField(
                          hintText: "Description",
                          controller: _descriptionController,
                          prefixIcon: Icons.description_outlined,
                          hasFocusBorder: true,
                          minLines: 1,
                          maxLines: 5,
                          textInputAction: TextInputAction.newline,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),

                        if (requiresImage) ...[
                          SizedBox(height: 20.h),
                          Text(
                            "Upload Images",
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

                        SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom > 0
                              ? 320.h
                              : 100.h,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
                  child: PrimaryButton(
                    label: "Add Collection",
                    onPressed: _handleSubmit,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        if (_selectedImages.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedImages.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) =>
                _buildImageThumbnail(_selectedImages[index], index),
          ),

        if (_selectedImages.length < 2) ...[
          if (_selectedImages.isNotEmpty) SizedBox(height: 16.h),
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
                    "Tap to add image (${_selectedImages.length}/2)",
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
