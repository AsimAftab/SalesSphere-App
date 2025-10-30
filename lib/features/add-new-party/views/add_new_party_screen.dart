import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/field_validators.dart';
import 'package:sales_sphere/features/add-new-party/models/add_new_party.model.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/features/add-new-party/vm/add_new_party.vm.dart';
import 'package:go_router/go_router.dart';

class AddNewPartyScreen extends ConsumerStatefulWidget {
  const AddNewPartyScreen({super.key});

  @override
  ConsumerState<AddNewPartyScreen> createState() => _AddNewPartyScreenState();
}

class _AddNewPartyScreenState extends ConsumerState<AddNewPartyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _panVatController = TextEditingController();
  final _googleMapLinkController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  @override
  void dispose() {
    _companyNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _panVatController.dispose();
    _googleMapLinkController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _handleAddParty(AddPartyViewModel vm) async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final request = AddPartyRequest(
        companyName: _companyNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        email: _emailController.text.trim(),
        panVatNumber: _panVatController.text.trim(),
        googleMapLink: _googleMapLinkController.text.trim().isEmpty
            ? null
            : _googleMapLinkController.text.trim(),
        latitude: _latitudeController.text.trim().isEmpty
            ? null
            : double.tryParse(_latitudeController.text.trim()),
        longitude: _longitudeController.text.trim().isEmpty
            ? null
            : double.tryParse(_longitudeController.text.trim()),
      );

      await vm.addParty(request);

      // Re-validate form to show server errors
      _formKey.currentState?.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final vm = ref.read(addPartyViewModelProvider.notifier);
    final addPartyState = ref.watch(addPartyViewModelProvider);

    final isLoading = addPartyState is AsyncLoading;

    // Listen for successful party creation
    ref.listen(addPartyViewModelProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        // Party added successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.value!.message),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to success screen
        context.go('/detail-added');
      }
    });

    // Extract field errors and general error
    Map<String, String>? fieldErrors;
    String? generalError;

    if (addPartyState is AsyncError) {
      if (addPartyState.error is Map<String, String>) {
        fieldErrors = addPartyState.error as Map<String, String>;
        generalError = fieldErrors['general'];
      } else {
        generalError = addPartyState.error.toString();
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.primary, // The dark blue from the image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // --- Custom Header ---
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24.w, 0.h, 24.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "New member in the Family",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  "Add New Party",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // --- Bottom White Card with Form ---
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- General Error Message ---
                      if (generalError != null) ...[
                        ErrorDisplayWidget(generalError: generalError), // Reusable widget
                        SizedBox(height: 20.h),
                      ],

                      // --- Company Name Field ---
                      PrimaryTextField(
                        hintText: "Company Name",
                        controller: _companyNameController,
                        prefixIcon: Icons.business_outlined, // Icon from image
                        hasFocusBorder: true,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (fieldErrors?.containsKey('companyName') ?? false) {
                            return fieldErrors!['companyName'];
                          }
                          return vm.validateCompanyName(value);
                        },
                      ),
                      SizedBox(height: 16.h),

                      // --- Owner Name Field ---
                      PrimaryTextField(
                        hintText: "Owner Name",
                        controller: _ownerNameController,
                        prefixIcon: Icons.person_outline,
                        hasFocusBorder: true,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (fieldErrors?.containsKey('ownerName') ?? false) {
                            return fieldErrors!['ownerName'];
                          }
                          return vm.validateOwnerName(value);
                        },
                      ),
                      SizedBox(height: 16.h),

                      // --- Pan/Vat Number Field ---
                      PrimaryTextField(
                        hintText: "PAN/VAT Number",
                        controller: _panVatController,
                        prefixIcon: Icons.receipt_long_outlined,
                        hasFocusBorder: true,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                          LengthLimitingTextInputFormatter(14),
                        ],
                        validator: (value) {
                          if (fieldErrors?.containsKey('panVatNumber') ?? false) {
                            return fieldErrors!['panVatNumber'];
                          }
                          return vm.validatePanVat(value);
                        },
                      ),
                      SizedBox(height: 16.h),

                      // --- Phone Number Field ---
                      PrimaryTextField(
                        hintText: "Phone Number",
                        controller: _phoneController,
                        prefixIcon: Icons.phone_outlined,
                        hasFocusBorder: true,
                        enabled: !isLoading,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (fieldErrors?.containsKey('phone') ?? false) {
                            return fieldErrors!['phone'];
                          }
                          return vm.validatePhone(value);
                        },
                      ),
                      SizedBox(height: 16.h),

                      // --- Email Address Field ---
                      PrimaryTextField(
                        hintText: "Email Address",
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        hasFocusBorder: true,
                        enabled: !isLoading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (fieldErrors?.containsKey('email') ?? false) {
                            return fieldErrors!['email'];
                          }
                          return FieldValidators.validateEmail(value);
                        },
                      ),
                      SizedBox(height: 16.h),

                      // --- Address Field ---
                      PrimaryTextField(
                        hintText: "Address",
                        controller: _addressController,
                        prefixIcon: Icons.location_on_outlined,
                        hasFocusBorder: true,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (fieldErrors?.containsKey('address') ?? false) {
                            return fieldErrors!['address'];
                          }
                          return vm.validateAddress(value);
                        },
                      ),
                      SizedBox(height: 16.h),

                      // --- Auto-generated Fields Section ---
                      Text(
                        "Location Details (Auto-generated from address)",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // --- Latitude Field ---
                      PrimaryTextField(
                        hintText: "Latitude (Auto-generated)",
                        controller: _latitudeController,
                        prefixIcon: Icons.explore_outlined,
                        hasFocusBorder: true,
                        enabled: false,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),

                      // --- Longitude Field ---
                      PrimaryTextField(
                        hintText: "Longitude (Auto-generated)",
                        controller: _longitudeController,
                        prefixIcon: Icons.explore_outlined,
                        hasFocusBorder: true,
                        enabled: false,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),

                      // --- Google Map Link Field ---
                      PrimaryTextField(
                        hintText: "Google Map Link (Auto-generated)",
                        controller: _googleMapLinkController,
                        prefixIcon: Icons.map_outlined,
                        hasFocusBorder: true,
                        enabled: false,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (fieldErrors?.containsKey('googleMapLink') ?? false) {
                            return fieldErrors!['googleMapLink'];
                          }
                          return vm.validateGoogleMapLink(value);
                        },
                      ),
                      SizedBox(height: 32.h),

                      // --- Add Party Button ---
                      PrimaryButton(
                        label: 'Add Party',
                        onPressed: () => _handleAddParty(vm),
                        isLoading: isLoading,
                        size: ButtonSize.medium,
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// You can create this reusable widget or just paste the
// Container logic from LoginScreen directly.
class ErrorDisplayWidget extends StatelessWidget {
  const ErrorDisplayWidget({
    super.key,
    required this.generalError,
  });

  final String? generalError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.error,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              generalError!,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}