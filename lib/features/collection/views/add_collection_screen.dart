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
import 'package:sales_sphere/features/collection/vm/add_collection.vm.dart';

class AddCollectionScreen extends ConsumerStatefulWidget {
  const AddCollectionScreen({super.key});

  @override
  ConsumerState<AddCollectionScreen> createState() => _AddCollectionScreenState();
}

class _AddCollectionScreenState extends ConsumerState<AddCollectionScreen> {
  final _formKey = GlobalKey<FormState>();

  final LayerLink _paymentLink = LayerLink();
  final LayerLink _bankLink = LayerLink();
  final LayerLink _statusLink = LayerLink();

  OverlayEntry? _overlayEntry;

  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _bankNameController;
  late TextEditingController _chequeNoController;
  late TextEditingController _chequeDateController;
  late TextEditingController _descriptionController;

  String? _selectedPartyId = "Mock Party";
  String? _paymentMode;
  String? _chequeStatus;

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
    _hideDropdown();
    _amountController.dispose();
    _dateController.dispose();
    _bankNameController.dispose();
    _chequeNoController.dispose();
    _chequeDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Robust Searchable Dropdown with proper Z-index and Tap detection
  void _showSearchableDropdown({
    required LayerLink link,
    required List<String> items,
    required String? currentValue,
    required String searchHint,
    required Function(String) onSelected,
    bool isSearchable = false,
  }) {
    _hideDropdown();
    String searchQuery = "";

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // This layer allows clicking outside the dropdown to close it
          GestureDetector(
            onTap: _hideDropdown,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: MediaQuery.of(context).size.width - 48.w,
            child: CompositedTransformFollower(
              link: link,
              showWhenUnlinked: false,
              offset: Offset(0, 52.h),
              child: Material(
                elevation: 12, // High elevation ensures it floats above the white container
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.white,
                child: StatefulBuilder(
                  builder: (context, setOverlayState) {
                    final filteredItems = items
                        .where((item) => item.toLowerCase().contains(searchQuery.toLowerCase()))
                        .toList();

                    return Container(
                      constraints: BoxConstraints(maxHeight: 250.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSearchable)
                            Padding(
                              padding: EdgeInsets.all(8.w),
                              child: TextField(
                                autofocus: true,
                                style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
                                decoration: InputDecoration(
                                  hintText: searchHint,
                                  prefixIcon: Icon(Icons.search, size: 18.sp),
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                                ),
                                onChanged: (val) => setOverlayState(() => searchQuery = val),
                              ),
                            ),
                          Flexible(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final bool isSelected = currentValue == item;
                                return ListTile(
                                  dense: true,
                                  title: Text(item, style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp)),
                                  trailing: isSelected
                                      ? Icon(Icons.check, color: AppColors.primary, size: 20.sp)
                                      : null,
                                  onTap: () {
                                    onSelected(item);
                                    _hideDropdown();
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _showImagePreview(XFile imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.w),
        child: Stack(
          children: [
            InteractiveViewer(child: ClipRRect(borderRadius: BorderRadius.circular(12.r), child: Image.file(File(imageFile.path)))),
            Positioned(top: 0, right: 0, child: GestureDetector(onTap: () => context.pop(), child: Container(padding: EdgeInsets.all(8.w), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: Icon(Icons.close, color: Colors.white, size: 24.sp)))),
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
              ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () async { context.pop(); final XFile? img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70); if (img != null) setState(() => _selectedImages.add(img)); }),
              ListTile(leading: const Icon(Icons.photo_camera), title: const Text('Camera'), onTap: () async { context.pop(); final XFile? img = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70); if (img != null) setState(() => _selectedImages.add(img)); }),
            ],
          ),
        ),
      );
    } catch (e) { debugPrint("Error: $e"); }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_paymentMode == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Payment Mode')));
        return;
      }

      final bool imageRequired = ['Cheque', 'Bank Transfer', 'QR Pay'].contains(_paymentMode);
      if (imageRequired && _selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please upload an image for $_paymentMode payment'),
          backgroundColor: AppColors.primary,
        ));
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
            'chequeStatus': _chequeStatus
          },
          'description': _descriptionController.text.trim(),
        };

        await vm.submitCollection(
          data: data,
          images: _selectedImages.map((e) => e.path).toList(),
        );

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
    final bool requiresImage = ['Cheque', 'Bank Transfer', 'QR Pay'].contains(_paymentMode);

    return Scaffold(
      resizeToAvoidBottomInset: true, // Crucial for keyboard handling
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, centerTitle: true,
        title: const Text("Add Collection", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismiss keyboard on background tap
          _hideDropdown();
        },
        child: Container(
          margin: EdgeInsets.only(top: 16.h),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), topRight: Radius.circular(32.r))),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDropdown("Party Name", _selectedPartyId, Icons.people_outline, () {}, true, null),
                        SizedBox(height: 16.h),
                        PrimaryTextField(controller: _amountController, hintText: "Amount Received", prefixIcon: Icons.currency_rupee, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
                        SizedBox(height: 16.h),
                        CustomDatePicker(controller: _dateController, hintText: "Received Date", prefixIcon: Icons.calendar_today_outlined),
                        SizedBox(height: 16.h),

                        _buildDropdown("Payment Mode", _paymentMode, Icons.credit_card_outlined, () {
                          _showSearchableDropdown(
                            link: _paymentLink,
                            items: ['Cash', 'Cheque', 'Bank Transfer', 'QR Pay'],
                            currentValue: _paymentMode,
                            searchHint: "",
                            isSearchable: false,
                            onSelected: (val) => setState(() {
                              _paymentMode = val;
                              _bankNameController.clear();
                              _chequeNoController.clear();
                              _chequeStatus = null;
                            }),
                          );
                        }, true, _paymentLink),

                        if (_paymentMode == 'Cheque' || _paymentMode == 'Bank Transfer') ...[
                          SizedBox(height: 16.h),
                          _buildDropdown("Select Bank", _bankNameController.text.isEmpty ? null : _bankNameController.text, Icons.account_balance_outlined, () {
                            _showSearchableDropdown(
                              link: _bankLink,
                              items: ["HDFC Bank", "ICICI Bank", "SBI", "Axis Bank", "Kotak", "PNB", "Canara Bank"],
                              currentValue: _bankNameController.text,
                              searchHint: "Search bank...",
                              isSearchable: true,
                              onSelected: (val) => setState(() => _bankNameController.text = val),
                            );
                          }, true, _bankLink),
                        ],
                        if (_paymentMode == 'Cheque') ...[
                          SizedBox(height: 16.h),
                          PrimaryTextField(controller: _chequeNoController, hintText: "Cheque Number", prefixIcon: Icons.numbers_outlined, validator: (v) => v!.isEmpty ? 'Required' : null),
                          SizedBox(height: 16.h),
                          CustomDatePicker(controller: _chequeDateController, hintText: "Date of Cheque", prefixIcon: Icons.calendar_today_outlined),
                          SizedBox(height: 16.h),
                          _buildDropdown("Cheque Status", _chequeStatus, Icons.assignment_outlined, () {
                            _showSearchableDropdown(
                              link: _statusLink,
                              items: ['Pending', 'Deposited', 'Cleared', 'Bounced'],
                              currentValue: _chequeStatus,
                              searchHint: "",
                              isSearchable: false,
                              onSelected: (val) => setState(() => _chequeStatus = val),
                            );
                          }, true, _statusLink),
                        ],
                        SizedBox(height: 16.h),
                        PrimaryTextField(hintText: "Description", controller: _descriptionController, prefixIcon: Icons.description_outlined, hasFocusBorder: true, minLines: 1, maxLines: 5, textInputAction: TextInputAction.newline, validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null),

                        if (requiresImage) ...[
                          SizedBox(height: 20.h),
                          Text("Upload Images", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600, fontFamily: 'Poppins')),
                          SizedBox(height: 8.h),
                          _buildImageSection(),
                        ],

                        // KEYBOARD BUFFER FIX: Pushes content up to allow scrolling when keyboard is open
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 320.h : 100.h),
                      ],
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h), child: PrimaryButton(label: "Add Collection", onPressed: _handleSubmit, width: double.infinity)),
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
            separatorBuilder: (context, index) => SizedBox(height: 12.h), // Clean gaps between previews
            itemBuilder: (context, index) => _buildImageThumbnail(_selectedImages[index], index),
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
                  Icon(Icons.add_photo_alternate_outlined, size: 32.sp, color: Colors.grey.shade400),
                  SizedBox(height: 8.h),
                  Text(
                      "Tap to add image (${_selectedImages.length}/2)",
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, fontFamily: 'Poppins')
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
          ClipRRect(borderRadius: BorderRadius.circular(12.r), child: Image.file(File(imageFile.path), width: double.infinity, height: 160.h, fit: BoxFit.cover)),
          Positioned(bottom: 8.h, right: 8.w, child: Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20.r)), child: Row(children: [Icon(Icons.zoom_in, color: Colors.white, size: 14.sp), SizedBox(width: 4.w), Text('Preview', style: TextStyle(color: Colors.white, fontSize: 10.sp))]))),
          Positioned(top: 8.h, right: 8.w, child: GestureDetector(onTap: () => setState(() => _selectedImages.removeAt(index)), child: Container(padding: EdgeInsets.all(4.w), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: Icon(Icons.close, color: Colors.white, size: 16.sp)))),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, IconData icon, VoidCallback onTap, bool isRequired, LayerLink? link) {
    Widget dropdown = FormField<String>(
      validator: (v) => isRequired && (value == null || value.isEmpty) ? '$label is required' : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: state.hasError ? Colors.red : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.r)
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.grey.shade600, size: 20.sp),
                    SizedBox(width: 12.w),
                    Text(value ?? label, style: TextStyle(color: value != null ? Colors.black : Colors.grey.shade500, fontFamily: 'Poppins', fontSize: 14.sp)),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            if (state.hasError) Padding(padding: EdgeInsets.only(top: 5.h, left: 12.w), child: Text(state.errorText!, style: TextStyle(color: Colors.red, fontSize: 12.sp))),
          ],
        );
      },
    );

    return link != null ? CompositedTransformTarget(link: link, child: dropdown) : dropdown;
  }
}