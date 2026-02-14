import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/snackbar_utils.dart';
import 'package:sales_sphere/features/collection/models/collection.model.dart';
import 'package:sales_sphere/features/collection/vm/add_collection.vm.dart';
import 'package:sales_sphere/features/collection/vm/bank_names.vm.dart';
import 'package:sales_sphere/features/parties/vm/parties.vm.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_date_picker.dart';
import 'package:sales_sphere/widget/custom_dropdown_textfield.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/primary_image_picker.dart';

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

  String? _selectedPartyId;
  PaymentMode? _selectedPaymentMode;
  ChequeStatus? _selectedChequeStatus;
  String? _selectedBank;

  final List<XFile> _selectedImages = [];

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

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 2) return;
    try {
      final image = await showImagePickerSheet(context);
      if (image != null) {
        setState(() => _selectedImages.add(image));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedPaymentMode == null) {
        SnackbarUtils.showError(context, 'Please select Payment Mode');
        return;
      }

      final bool imageRequired = [
        PaymentMode.cheque,
        PaymentMode.bankTransfer,
        PaymentMode.qrPay,
      ].contains(_selectedPaymentMode);

      if (imageRequired && _selectedImages.isEmpty) {
        SnackbarUtils.showWarning(
          context,
          'Please upload an image for ${_selectedPaymentMode?.label} payment',
        );
        return;
      }

      try {
        // Show loading
        if (mounted) {
          SnackbarUtils.showInfo(
            context,
            'Creating collection...',
            duration: const Duration(seconds: 30),
          );
        }

        final vm = ref.read(addCollectionViewModelProvider.notifier);

        // Convert date to ISO format (yyyy-MM-dd)
        final parsedDate = _parseDateFromController(_dateController.text);
        final formattedDate = parsedDate.toIso8601String().split('T')[0];

        final data = {
          'party': _selectedPartyId,
          'amount': double.parse(_amountController.text.trim()),
          'date': formattedDate,
          'paymentMode': _selectedPaymentMode?.apiValue,
          // Use apiValue (e.g., 'bank_transfer', 'cash')
          if (_selectedPaymentMode == PaymentMode.cheque ||
              _selectedPaymentMode == PaymentMode.bankTransfer)
            'bankName': _selectedBank,
          if (_selectedPaymentMode == PaymentMode.cheque) ...{
            'chequeNumber': _chequeNoController.text.trim(),
            'chequeDate': _parseDateFromController(
              _chequeDateController.text,
            ).toIso8601String().split('T')[0],
            'chequeStatus': _selectedChequeStatus?.label.toLowerCase(),
          },
          'description': _descriptionController.text.trim(),
        };

        await vm.submitCollection(
          data: data,
          images: _selectedImages.map((e) => e.path).toList(),
        );

        if (!mounted) return;

        SnackbarUtils.showSuccess(context, 'Collection Added Successfully');

        context.pop(true);
      } catch (e) {
        if (!mounted) return;
        SnackbarUtils.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  /// Parse date from controller text (handles both dd/MM/yyyy and other formats)
  DateTime _parseDateFromController(String dateText) {
    try {
      // If already in ISO format, parse directly
      if (dateText.contains('-')) {
        return DateTime.parse(dateText);
      }
      // If in dd/MM/yyyy format from date picker
      final parts = dateText.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
      // Fallback
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignedPartiesAsync = ref.watch(assignedPartiesProvider);

    final bool requiresImage = [
      PaymentMode.cheque,
      PaymentMode.bankTransfer,
      PaymentMode.qrPay,
    ].contains(_selectedPaymentMode);

    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

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
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.only(
                      left: 24.w,
                      right: 24.w,
                      top: 24.h,
                      bottom: 24.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              items: dropdownItems,
                              onChanged: (val) => setState(() {
                                _selectedPartyId = val;
                              }),
                              validator: (v) => v == null ? 'Required' : null,
                            );
                          },
                          loading: () => Column(
                            children: [
                              PrimaryTextField(
                                controller: TextEditingController(
                                  text: 'Loading...',
                                ),
                                hintText: "Party Name",
                                prefixIcon: Icons.people_outline,
                                enabled: false,
                                suffixWidget: const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),
                            ],
                          ),
                          error: (e, _) => Column(
                            children: [
                              PrimaryTextField(
                                controller: TextEditingController(text: ''),
                                hintText: "Party Name",
                                prefixIcon: Icons.people_outline,
                                enabled: false,
                                errorText: "Failed to load parties",
                              ),
                              SizedBox(height: 16.h),
                            ],
                          ),
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
                          // Bank Selector Dropdown from API
                          ref
                              .watch(bankNamesViewModelProvider)
                              .when(
                                data: (banks) =>
                                    CustomDropdownTextField<String>(
                                      hintText: "Select Bank",
                                      searchHint: "Search your bank...",
                                      value: _selectedBank,
                                      prefixIcon:
                                          Icons.account_balance_outlined,
                                      items: banks
                                          .map(
                                            (bank) => DropdownItem<String>(
                                              value: bank.name,
                                              label: bank.name,
                                              icon: Icons.account_balance,
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) =>
                                          setState(() => _selectedBank = val),
                                      validator: (v) =>
                                          v == null ? 'Required' : null,
                                    ),
                                loading: () => PrimaryTextField(
                                  controller: TextEditingController(
                                    text: 'Loading banks...',
                                  ),
                                  hintText: "Select Bank",
                                  prefixIcon: Icons.account_balance_outlined,
                                  enabled: false,
                                  suffixWidget: const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
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
                          PrimaryImagePicker(
                            images: _selectedImages,
                            maxImages: 2,
                            label: 'Upload Images',
                            hintText:
                                'Tap to add image (${_selectedImages.length}/2)',
                            onPick: _pickImage,
                            onRemove: (index) => setState(
                              () => _selectedImages.removeAt(index),
                            ),
                          ),
                        ],

                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ),
                if (!isKeyboardOpen)
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

}
