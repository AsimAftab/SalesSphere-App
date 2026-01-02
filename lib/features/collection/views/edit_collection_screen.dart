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
import 'package:sales_sphere/features/collection/models/collection.model.dart';
import 'package:sales_sphere/features/collection/vm/collection.vm.dart';
import 'package:sales_sphere/features/collection/vm/edit_collection.vm.dart';
import 'package:sales_sphere/core/utils/logger.dart';

class EditCollectionScreen extends ConsumerStatefulWidget {
  final String collectionId;

  const EditCollectionScreen({super.key, required this.collectionId});

  @override
  ConsumerState<EditCollectionScreen> createState() => _EditCollectionScreenState();
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
  String? _paymentMode;
  String? _chequeStatus;
  bool _isEditMode = false;
  bool _isDataLoaded = false;

  // Image Handling
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

  /// FIXED: Prefill images from local paths to solve "image not coming" issue
  void _prefillData(CollectionListItem data) {
    _amountController.text = data.amount.toString();
    _dateController.text = data.date;
    _paymentMode = data.paymentMode;
    _descriptionController.text = data.remarks ?? '';
    _selectedPartyId = data.partyName;

    // Check if the item has stored image paths and convert them to XFiles for the UI
    if (data.imagePaths != null && data.imagePaths!.isNotEmpty) {
      _selectedImages.clear();
      for (var path in data.imagePaths!) {
        _selectedImages.add(XFile(path));
      }
      AppLogger.i('📸 Prefilled ${_selectedImages.length} images from local paths');
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
                    if (image != null) setState(() => _selectedImages.add(image));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () async {
                    context.pop();
                    final XFile? image = await _picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);
                    if (image != null) setState(() => _selectedImages.add(image));
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
                top: 0, right: 0,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
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

  Future<void> _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final vm = ref.read(editCollectionViewModelProvider.notifier);
        final updateData = {
          'party': _selectedPartyId,
          'amount': double.parse(_amountController.text),
          'date': _dateController.text,
          'paymentMode': _paymentMode,
          'description': _descriptionController.text.trim(),
          if (_paymentMode == 'Cheque' || _paymentMode == 'Bank Transfer') 'bankName': _bankNameController.text,
          if (_paymentMode == 'Cheque') ...{
            'chequeNumber': _chequeNoController.text,
            'chequeStatus': _chequeStatus,
          },
        };

        await vm.updateCollection(collectionId: widget.collectionId, data: updateData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Collection Updated Successfully'), backgroundColor: Colors.green));
          ref.invalidate(collectionViewModelProvider);
          context.pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(collectionViewModelProvider);

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
            centerTitle: false, // Left Aligned Heading
            title: Text("Details", style: TextStyle(color: AppColors.textdark, fontSize: 18.sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textdark), onPressed: () => context.pop()),
            actions: [
              if (_isEditMode)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditMode = false;
                      _prefillData(item); // Reset images and fields
                    });
                  },
                  child: Text('Cancel', style: TextStyle(color: AppColors.error, fontSize: 14.sp, fontWeight: FontWeight.w500)),
                ),
            ],
          ),
          body: Stack(
            children: [
              Positioned(top: 0, left: 0, right: 0, child: SvgPicture.asset('assets/images/corner_bubble.svg', fit: BoxFit.cover, height: 180.h)),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(14.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1. Party Name
                                    _buildSelectionDropdown(label: "Party Name", value: _selectedPartyId, icon: Icons.people_outline, enabled: false),
                                    SizedBox(height: 16.h),

                                    // 2. Amount
                                    PrimaryTextField(controller: _amountController, hintText: "Amount Received", prefixIcon: Icons.currency_rupee, enabled: _isEditMode, keyboardType: TextInputType.number),
                                    SizedBox(height: 16.h),

                                    // 3. Date
                                    CustomDatePicker(controller: _dateController, hintText: "Received Date", prefixIcon: Icons.calendar_today_outlined, enabled: _isEditMode),
                                    SizedBox(height: 16.h),

                                    // 4. Payment Mode
                                    _buildPaymentModeDropdown(),

                                    if (_paymentMode == 'Cheque' || _paymentMode == 'Bank Transfer') ...[
                                      SizedBox(height: 16.h),
                                      PrimaryTextField(controller: _bankNameController, hintText: "Bank Name", prefixIcon: Icons.account_balance_outlined, enabled: _isEditMode),
                                    ],
                                    if (_paymentMode == 'Cheque') ...[
                                      SizedBox(height: 16.h),
                                      PrimaryTextField(controller: _chequeNoController, hintText: "Cheque Number", prefixIcon: Icons.numbers_outlined, enabled: _isEditMode),
                                      SizedBox(height: 16.h),
                                      _buildChequeStatusDropdown(),
                                    ],

                                    SizedBox(height: 16.h),

                                    // 5. Description
                                    PrimaryTextField(
                                      controller: _descriptionController,
                                      hintText: "Description",
                                      prefixIcon: Icons.description_outlined,
                                      enabled: _isEditMode,
                                      maxLines: 5,
                                      minLines: 1,
                                      textInputAction: TextInputAction.newline,
                                    ),
                                    SizedBox(height: 20.h),

                                    // 6. Image Section
                                    Text("Collection Images", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600, fontFamily: 'Poppins')),
                                    SizedBox(height: 8.h),
                                    _buildImageSection(),
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
                  _buildBottomButton(),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  // --- Helper Widgets ---

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, MediaQuery.of(context).padding.bottom + 16.h),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -2))]),
      child: PrimaryButton(
        label: _isEditMode ? "Save Changes" : "Edit Detail",
        onPressed: _isEditMode ? _handleUpdate : () => setState(() => _isEditMode = true),
        width: double.infinity,
        leadingIcon: _isEditMode ? Icons.check_rounded : Icons.edit_outlined,
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
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

        if (_selectedImages.length < 2 && _isEditMode)
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
                  Text("Tap to add collection image (${_selectedImages.length}/2)",
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
          Positioned(
            bottom: 8.h, right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20.r)),
              child: Row(
                children: [
                  Icon(Icons.zoom_in, color: Colors.white, size: 14.sp),
                  SizedBox(width: 4.w),
                  // FIXED: Removed const to solve build error
                  Text('Preview', style: TextStyle(color: Colors.white, fontSize: 10.sp))
                ],
              ),
            ),
          ),
          if (_isEditMode)
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

  Widget _buildPaymentModeDropdown() {
    return _buildDropdownField(
      label: "Payment Mode",
      value: _paymentMode,
      enabled: _isEditMode,
      icon: Icons.payments_outlined,
      items: ['Cash', 'Cheque', 'Bank Transfer', 'QR Pay', 'Others'],
      onChanged: (val) => setState(() => _paymentMode = val),
    );
  }

  Widget _buildChequeStatusDropdown() {
    return _buildDropdownField(
      label: "Cheque Status",
      value: _chequeStatus,
      enabled: _isEditMode,
      icon: Icons.assignment_outlined,
      items: ['Pending', 'Deposited', 'Cleared', 'Bounced'],
      onChanged: (val) => setState(() => _chequeStatus = val),
    );
  }

  Widget _buildDropdownField({required String label, String? value, required bool enabled, required IconData icon, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: enabled ? AppColors.border : AppColors.border.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                disabledHint: Text(value ?? label, style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontFamily: 'Poppins')),
                items: enabled ? items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontFamily: 'Poppins')))).toList() : null,
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionDropdown({required String label, String? value, required IconData icon, required bool enabled}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(color: Colors.grey.shade100, border: Border.all(color: AppColors.border.withValues(alpha: 0.2), width: 1.5), borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 20.sp),
          SizedBox(width: 12.w),
          Text(value ?? label, style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 14.sp, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}