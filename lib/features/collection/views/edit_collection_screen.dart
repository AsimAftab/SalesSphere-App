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
import 'package:sales_sphere/features/collection/models/collection.model.dart';
import 'package:sales_sphere/features/collection/vm/collection.vm.dart';
import 'package:sales_sphere/features/collection/vm/edit_collection.vm.dart';

class EditCollectionScreen extends ConsumerStatefulWidget {
  final String collectionId;

  const EditCollectionScreen({super.key, required this.collectionId});

  @override
  ConsumerState<EditCollectionScreen> createState() => _EditCollectionScreenState();
}

class _EditCollectionScreenState extends ConsumerState<EditCollectionScreen> {
  final _formKey = GlobalKey<FormState>();

  // LayerLinks for attached dropdown alignment
  final LayerLink _partyLink = LayerLink();
  final LayerLink _paymentLink = LayerLink();
  final LayerLink _bankLink = LayerLink();
  final LayerLink _statusLink = LayerLink();
  OverlayEntry? _overlayEntry;

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

    _paymentMode = data.paymentMode;
    _descriptionController.text = data.remarks ?? '';
    _selectedPartyId = data.partyName;

    if (data.imagePaths != null && data.imagePaths!.isNotEmpty) {
      _selectedImages.clear();
      for (var path in data.imagePaths!) {
        _selectedImages.add(XFile(path));
      }
    }
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

  // FIXED DROPDOWN OVERLAY LOGIC
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
          GestureDetector(
            onTap: _hideDropdown,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: MediaQuery.of(context).size.width - 64.w,
            child: CompositedTransformFollower(
              link: link,
              showWhenUnlinked: false,
              offset: Offset(0, 52.h),
              child: Material(
                elevation: 12,
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
      builder: (context) => Dialog(
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

  Future<void> _handleUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      final bool imageRequired = ['Cheque', 'Bank Transfer', 'QR Pay'].contains(_paymentMode);
      if (imageRequired && _selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please upload an image for $_paymentMode payment'),
          backgroundColor: AppColors.primary,
        ));
        return;
      }

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

        await vm.updateCollection(
          collectionId: widget.collectionId,
          data: updateData,
          imagePaths: _selectedImages.map((e) => e.path).toList(),
        );

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
    final bool requiresImage = ['Cheque', 'Bank Transfer', 'QR Pay'].contains(_paymentMode);

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
            title: Text("Collection Details", style: TextStyle(color: AppColors.textdark, fontSize: 18.sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textdark), onPressed: () => context.pop()),
            actions: [
              if (_isEditMode)
                TextButton(
                  onPressed: () {
                    setState(() { _isEditMode = false; _prefillData(item); });
                  },
                  child: Text('Cancel', style: TextStyle(color: AppColors.error, fontSize: 14.sp, fontWeight: FontWeight.w500)),
                ),
            ],
          ),
          body: GestureDetector(
            onTap: () { FocusScope.of(context).unfocus(); _hideDropdown(); },
            child: Stack(
              children: [
                Positioned(top: 0, left: 0, right: 0, child: SvgPicture.asset('assets/images/corner_bubble.svg', fit: BoxFit.cover, height: 180.h)),
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 100.h, bottom: 16.h),
                              child: Form(
                                key: _formKey,
                                child: Container(
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
                                      _buildDropdown("Party Name", _selectedPartyId, Icons.people_outline, () {
                                        _showSearchableDropdown(
                                          link: _partyLink, items: ["Party A", "Party B", "Mock Party"], currentValue: _selectedPartyId,
                                          searchHint: "Search party...", isSearchable: true, onSelected: (val) => setState(() => _selectedPartyId = val),
                                        );
                                      }, _isEditMode, _partyLink),
                                      SizedBox(height: 16.h),
                                      PrimaryTextField(controller: _amountController, hintText: "Amount Received", prefixIcon: Icons.currency_rupee, enabled: _isEditMode, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
                                      SizedBox(height: 16.h),
                                      CustomDatePicker(controller: _dateController, hintText: "Received Date", prefixIcon: Icons.calendar_today_outlined, enabled: _isEditMode),
                                      SizedBox(height: 16.h),
                                      _buildDropdown("Payment Mode", _paymentMode, Icons.credit_card_outlined, () {
                                        _showSearchableDropdown(
                                          link: _paymentLink, items: ['Cash', 'Cheque', 'Bank Transfer', 'QR Pay'], currentValue: _paymentMode,
                                          searchHint: "", onSelected: (val) => setState(() { _paymentMode = val; _bankNameController.clear(); _chequeNoController.clear(); }),
                                        );
                                      }, _isEditMode, _paymentLink),

                                      if (_paymentMode == 'Cheque' || _paymentMode == 'Bank Transfer') ...[
                                        SizedBox(height: 16.h),
                                        _buildDropdown("Select Bank", _bankNameController.text.isEmpty ? null : _bankNameController.text, Icons.account_balance_outlined, () {
                                          _showSearchableDropdown(
                                            link: _bankLink, items: ["HDFC Bank", "ICICI Bank", "SBI", "Axis Bank"], currentValue: _bankNameController.text,
                                            searchHint: "Search bank...", isSearchable: true, onSelected: (val) => setState(() => _bankNameController.text = val),
                                          );
                                        }, _isEditMode, _bankLink),
                                      ],

                                      if (_paymentMode == 'Cheque') ...[
                                        SizedBox(height: 16.h),
                                        PrimaryTextField(controller: _chequeNoController, hintText: "Cheque Number", prefixIcon: Icons.numbers_outlined, enabled: _isEditMode, validator: (v) => v!.isEmpty ? 'Required' : null),
                                        SizedBox(height: 16.h),
                                        CustomDatePicker(controller: _chequeDateController, hintText: "Date of Cheque", prefixIcon: Icons.calendar_today_outlined, enabled: _isEditMode),
                                        SizedBox(height: 16.h),
                                        _buildDropdown("Cheque Status", _chequeStatus, Icons.assignment_outlined, () {
                                          _showSearchableDropdown(
                                            link: _statusLink, items: ['Pending', 'Deposited', 'Cleared', 'Bounced'], currentValue: _chequeStatus,
                                            searchHint: "", onSelected: (val) => setState(() => _chequeStatus = val),
                                          );
                                        }, _isEditMode, _statusLink),
                                      ],

                                      SizedBox(height: 16.h),
                                      PrimaryTextField(controller: _descriptionController, hintText: "Description", prefixIcon: Icons.description_outlined, enabled: _isEditMode, maxLines: 5, minLines: 1),

                                      if (requiresImage || _selectedImages.isNotEmpty) ...[
                                        SizedBox(height: 20.h),
                                        Text("Collection Images", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600, fontFamily: 'Poppins')),
                                        SizedBox(height: 8.h),
                                        _buildImageSection(),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // KEYBOARD BUFFER FIX
                            SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 320.h : 100.h),
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
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedImages.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedImages.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) => _buildImageThumbnail(_selectedImages[index], index),
          ),

        if (_isEditMode && _selectedImages.length < 2) ...[
          if (_selectedImages.isNotEmpty) SizedBox(height: 16.h),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 100.h, width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: const Color(0xFFE0E0E0))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 32.sp, color: Colors.grey.shade400),
                  SizedBox(height: 8.h),
                  Text("Tap to add collection image (${_selectedImages.length}/2)", style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, fontFamily: 'Poppins')),
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
          Positioned(
            bottom: 8.h, right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20.r)),
              child: Row(
                children: [
                  Icon(Icons.zoom_in, color: Colors.white, size: 14.sp),
                  SizedBox(width: 4.w),
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
                child: Container(padding: EdgeInsets.all(4.w), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: Icon(Icons.close, color: Colors.white, size: 16.sp)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, IconData icon, VoidCallback onTap, bool enabled, LayerLink? link) {
    Widget dropdown = FormField<String>(
      validator: (v) => (value == null || value.isEmpty) ? '$label is required' : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: enabled ? onTap : null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                    color: enabled ? Colors.white : Colors.grey.shade100,
                    border: Border.all(
                        color: state.hasError
                            ? Colors.red
                            : (enabled ? Colors.grey.shade300 : Colors.grey.shade200)
                    ),
                    borderRadius: BorderRadius.circular(12.r)
                ),
                child: Row(
                  children: [
                    Icon(icon, color: enabled ? Colors.grey.shade600 : Colors.grey.shade400, size: 20.sp),
                    SizedBox(width: 12.w),
                    Text(
                        value ?? label,
                        style: TextStyle(
                            color: enabled
                                ? (value != null ? Colors.black : Colors.grey.shade500)
                                : Colors.grey.shade600,
                            fontFamily: 'Poppins',
                            fontSize: 14.sp
                        )
                    ),
                    const Spacer(),
                    if (enabled) const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
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