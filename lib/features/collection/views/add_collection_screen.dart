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
import 'package:sales_sphere/features/collection/vm/add_collection.vm.dart';

class AddCollectionScreen extends ConsumerStatefulWidget {
  const AddCollectionScreen({super.key});

  @override
  ConsumerState<AddCollectionScreen> createState() => _AddCollectionScreenState();
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
  String? _paymentMode;
  String? _chequeStatus;

  // Supports up to 2 images
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
                    if (image != null) {
                      setState(() => _selectedImages.add(image));
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
                      setState(() => _selectedImages.add(image));
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
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                        color: Colors.black54, shape: BoxShape.circle),
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

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_paymentMode == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Payment Mode')));
        return;
      }
      try {
        final vm = ref.read(addCollectionViewModelProvider.notifier);
        final data = {
          'party': _selectedPartyId,
          'amount': double.parse(_amountController.text),
          'date': _dateController.text,
          'paymentMode': _paymentMode,
          if (_paymentMode == 'Cheque' || _paymentMode == 'Bank Transfer') 'bankName': _bankNameController.text,
          if (_paymentMode == 'Cheque') ...{
            'chequeNumber': _chequeNoController.text,
            'chequeDate': _chequeDateController.text,
            'chequeStatus': _chequeStatus,
          },
          'description': _descriptionController.text.trim(),
        };

        final id = await vm.submitCollection(
          data: data,
          images: _selectedImages.map((e) => e.path).toList(),
        );

        if (_selectedImages.isNotEmpty) {
          await vm.uploadCollectionImages(
            id,
            _selectedImages.map((e) => File(e.path)).toList(),
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Collection Added Successfully'), backgroundColor: Colors.green));
          context.pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
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
        title: const Text("Add Collection", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), topRight: Radius.circular(32.r)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Party Name
                      _buildDropdown("Party Name", _selectedPartyId, Icons.people_outline, () {}),
                      SizedBox(height: 16.h),
                      // 2. Amount Received
                      PrimaryTextField(
                        controller: _amountController,
                        hintText: "Amount Received",
                        prefixIcon: Icons.currency_rupee,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 16.h),
                      // 3. Received Date
                      CustomDatePicker(
                        controller: _dateController,
                        hintText: "Received Date",
                        prefixIcon: Icons.calendar_today_outlined,
                      ),
                      SizedBox(height: 16.h),
                      // 4. Payment Mode
                      _buildPaymentModeDropdown(),

                      if (_paymentMode == 'Cheque' || _paymentMode == 'Bank Transfer') ...[
                        SizedBox(height: 16.h),
                        PrimaryTextField(
                            controller: _bankNameController,
                            hintText: "Bank Name",
                            prefixIcon: Icons.account_balance_outlined
                        ),
                      ],
                      if (_paymentMode == 'Cheque') ...[
                        SizedBox(height: 16.h),
                        PrimaryTextField(
                            controller: _chequeNoController,
                            hintText: "Cheque Number",
                            prefixIcon: Icons.numbers_outlined
                        ),
                        SizedBox(height: 16.h),
                        CustomDatePicker(
                            controller: _chequeDateController,
                            hintText: "Date of Cheque",
                            prefixIcon: Icons.date_range_outlined
                        ),
                        SizedBox(height: 16.h),
                        _buildChequeStatusDropdown(),
                      ],
                      SizedBox(height: 16.h),
                      // 5. Description
                      PrimaryTextField(
                        hintText: "Description",
                        controller: _descriptionController,
                        prefixIcon: Icons.description_outlined,
                        hasFocusBorder: true,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      SizedBox(height: 20.h),
                      // 6. Upload Images
                      Text(
                        "Upload Images",
                        style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins'
                        ),
                      ),
                      SizedBox(height: 8.h),
                      _buildImageSection(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
                child: PrimaryButton(label: "Add Collection", onPressed: _handleSubmit, width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- IMAGE SECTION HELPERS ---
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

        if (_selectedImages.length < 2)
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
                  Text('Preview', style: TextStyle(color: Colors.white, fontSize: 10.sp)),
                ],
              ),
            ),
          ),
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

  // --- COLLECTION SPECIFIC DROPDOWNS ---
  Widget _buildPaymentModeDropdown() {
    return _buildDropdownField(
      label: "Payment Mode",
      value: _paymentMode,
      icon: Icons.payments_outlined,
      items: ['Cash', 'Cheque', 'Bank Transfer', 'QR Pay', 'Others'],
      onChanged: (val) => setState(() {
        _paymentMode = val;
        _bankNameController.clear();
        _chequeNoController.clear();
        _chequeStatus = null;
      }),
    );
  }

  Widget _buildChequeStatusDropdown() {
    return _buildDropdownField(
      label: "Cheque Status",
      value: _chequeStatus,
      icon: Icons.assignment_outlined,
      items: ['Pending', 'Deposited', 'Cleared', 'Bounced'],
      onChanged: (val) => setState(() => _chequeStatus = val!),
    );
  }

  Widget _buildDropdownField({required String label, String? value, required IconData icon, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(label, style: TextStyle(color: AppColors.textHint, fontSize: 14.sp, fontFamily: 'Poppins')),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontFamily: 'Poppins')))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12.r)),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20.sp),
            SizedBox(width: 12.w),
            Text(value ?? label, style: TextStyle(color: value != null ? Colors.black : AppColors.textHint, fontFamily: 'Poppins')),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}