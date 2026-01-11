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
  bool _isDataLoaded = false;

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

  void _prefillData(CollectionListItem data) {
    _amountController.text = data.amount.toString();

    try {
      final dateTime = DateTime.parse(data.date);
      _dateController.text = DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      _dateController.text = data.date;
    }

    _selectedPaymentMode = PaymentMode.fromLabel(data.paymentMode);
    _descriptionController.text = data.remarks ?? '';
    _selectedPartyId = data.partyName;

    _selectedBank = data.bankName;
    _bankNameController.text = data.bankName ?? '';

    _chequeNoController.text = data.chequeNumber ?? '';

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
            (e) => e.label == data.chequeStatus,
        orElse: () => ChequeStatus.pending,
      );
    }

    if (data.imagePaths != null && data.imagePaths!.isNotEmpty) {
      _selectedImages.clear();
      for (var path in data.imagePaths!) {
        _selectedImages.add(XFile(path));
      }
    }
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

  Future<void> _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
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
        final vm = ref.read(editCollectionViewModelProvider.notifier);
        final updateData = {
          'party': _selectedPartyId,
          'amount': double.parse(_amountController.text),
          'date': _dateController.text,
          'paymentMode': _selectedPaymentMode?.label,
          'description': _descriptionController.text.trim(),
          // ENSURE THESE KEYS MATCH YOUR VIEWMODEL EXPECTATIONS
          'bankName': _selectedBank,
          'chequeNumber': _chequeNoController.text,
          'chequeDate': _chequeDateController.text,
          'chequeStatus': _selectedChequeStatus?.label,
        };

        await vm.updateCollection(
          collectionId: widget.collectionId,
          data: updateData,
          imagePaths: _selectedImages.map((e) => e.path).toList(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Collection Updated Successfully'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(collectionViewModelProvider);
          context.pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(collectionViewModelProvider);
    final bool requiresImage = [
      PaymentMode.cheque,
      PaymentMode.bankTransfer,
      PaymentMode.qrPay,
    ].contains(_selectedPaymentMode);

    return collectionsAsync.when(
      data: (list) {
        final item = list.firstWhere((e) => e.id == widget.collectionId);
        if (!_isDataLoaded) {
          _prefillData(item);
          _isDataLoaded = true;
        }

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
                      _prefillData(item);
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
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
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
                                      CustomDropdownTextField<String>(
                                        hintText: "Party Name",
                                        searchHint: "Search party...",
                                        value: _selectedPartyId,
                                        prefixIcon: Icons.people_outline,
                                        enabled: _isEditMode,
                                        items:
                                            ["Party A", "Party B", "Mock Party"]
                                                .map(
                                                  (e) => DropdownItem(
                                                    value: e,
                                                    label: e,
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (val) => setState(
                                          () => _selectedPartyId = val,
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
                                        CustomDropdownTextField<String>(
                                          hintText: "Select Bank",
                                          searchHint: "Search your bank...",
                                          value: _selectedBank,
                                          prefixIcon:
                                              Icons.account_balance_outlined,
                                          enabled: _isEditMode,
                                          items:
                                              [
                                                    {
                                                      'name': 'HDFC Bank',
                                                      'icon':
                                                          Icons.account_balance,
                                                    },
                                                    {
                                                      'name': 'ICICI Bank',
                                                      'icon':
                                                          Icons.account_balance,
                                                    },
                                                    {
                                                      'name': 'SBI',
                                                      'icon':
                                                          Icons.account_balance,
                                                    },
                                                    {
                                                      'name': 'Axis Bank',
                                                      'icon':
                                                          Icons.account_balance,
                                                    },
                                                  ]
                                                  .map(
                                                    (bank) =>
                                                        DropdownItem<String>(
                                                          value:
                                                              bank['name']
                                                                  as String,
                                                          label:
                                                              bank['name']
                                                                  as String,
                                                          icon:
                                                              bank['icon']
                                                                  as IconData,
                                                        ),
                                                  )
                                                  .toList(),
                                          onChanged: (val) => setState(
                                            () => _selectedBank = val,
                                          ),
                                          validator: (v) =>
                                              v == null ? 'Required' : null,
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
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildBottomButton() {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedImages.isNotEmpty)
          ..._selectedImages.asMap().entries.map((entry) {
            int index = entry.key;
            XFile imageFile = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildImageThumbnail(imageFile, index),
            );
          }),
        if (_isEditMode && _selectedImages.length < 2)
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
                    "Tap to add collection image (${_selectedImages.length}/2)",
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
