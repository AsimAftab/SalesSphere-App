import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/field_validators.dart';
import 'package:sales_sphere/features/parties/models/party_details.model.dart';
import 'package:sales_sphere/features/parties/vm/party.vm.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';

class PartyDetailsScreen extends ConsumerStatefulWidget {
  final String partyId;

  const PartyDetailsScreen({
    super.key,
    required this.partyId,
  });

  @override
  ConsumerState<PartyDetailsScreen> createState() => _PartyDetailsScreenState();
}

class _PartyDetailsScreenState extends ConsumerState<PartyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditMode = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _ownerNameController;
  late TextEditingController _panVatNumberController;
  late TextEditingController _fullAddressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _notesController;

  PartyDetails? _currentParty;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _ownerNameController = TextEditingController();
    _panVatNumberController = TextEditingController();
    _fullAddressController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _notesController = TextEditingController();
  }

  void _populateFields(PartyDetails party) {
    _currentParty = party;
    _nameController.text = party.name;
    _phoneController.text = party.phoneNumber;
    _emailController.text = party.email ?? '';
    _ownerNameController.text = party.ownerName;
    _panVatNumberController.text = party.panVatNumber;
    _fullAddressController.text = party.fullAddress;
    _latitudeController.text = party.latitude?.toString() ?? '';
    _longitudeController.text = party.longitude?.toString() ?? '';
    _notesController.text = party.notes ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ownerNameController.dispose();
    _panVatNumberController.dispose();
    _fullAddressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_currentParty == null) return;

      final vm = ref.read(partyViewModelProvider.notifier);

      final updatedParty = _currentParty!.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        panVatNumber: _panVatNumberController.text.trim(),
        fullAddress: _fullAddressController.text.trim(),
        latitude: double.tryParse(_latitudeController.text.trim()),
        longitude: double.tryParse(_longitudeController.text.trim()),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await vm.updateParty(updatedParty);

      if (mounted) {
        setState(() {
          _isEditMode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Party details updated successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _openGoogleMaps(PartyDetails party) async {
    Uri? url;

    // Option 1: Use Latitude/Longitude
    // This creates a "geo:19.076,72.8777" link
    if (party.latitude != null && party.longitude != null) {
      url = Uri(
        scheme: 'geo',
        path: '${party.latitude},${party.longitude}',
      );
    }
    // Option 2: Fallback to Full Address (Less accurate)
    // This creates a "geo:0,0?q=123 MG Road..." link
    else if (party.fullAddress.isNotEmpty) {
      url = Uri(
        scheme: 'geo',
        path: '0,0',
        queryParameters: {'q': party.fullAddress},
      );
    }

    // Launch the URL if we have one
    if (url != null) {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not open maps. Is Google Maps installed?'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No address or coordinates to show'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final partyAsync = ref.watch(partyByIdProvider(widget.partyId));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Details',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          if (_isEditMode)
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditMode = false;
                  if (_currentParty != null) {
                    _populateFields(_currentParty!);
                  }
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
      body: partyAsync.when(
        data: (party) {
          if (party == null) {
            return Center(
              child: Text(
                'Party not found',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black87,
                ),
              ),
            );
          }

          if (_currentParty == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _populateFields(party);
            });
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Party Header Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                party.name,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 8.h),

                              InkWell(
                                onTap: () => _openGoogleMaps(party),
                                borderRadius: BorderRadius.circular(8.r),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 14.sp,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 6.w),
                                      Expanded(
                                        child: Text(
                                          party.fullAddress.isEmpty
                                              ? 'No address set'
                                              : party.fullAddress,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Icon(
                                        Icons.open_in_new,
                                        size: 13.sp,
                                        color: AppColors.primary
                                            .withOpacity(0.7),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // Section Header
                        Text(
                          'Party Details',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontFamily: 'Poppins',
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Details Form Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Owner Name
                              PrimaryTextField(
                                hintText: "Owner Name",
                                controller: _ownerNameController,
                                prefixIcon: Icons.person_outline,
                                hasFocusBorder: true,
                                enabled: _isEditMode,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Owner name is required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16.h),
                              // PAN/VAT Number
                              PrimaryTextField(
                                hintText: "PAN/VAT Number",
                                controller: _panVatNumberController,
                                prefixIcon: Icons.receipt_long_outlined,
                                hasFocusBorder: true,
                                enabled: _isEditMode,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'PAN/VAT number is required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16.h),

                              // Phone/Mobile Number
                              PrimaryTextField(
                                hintText: "Phone/Mobile Number",
                                controller: _phoneController,
                                prefixIcon: Icons.phone_outlined,
                                hasFocusBorder: true,
                                enabled: _isEditMode,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Phone number is required';
                                  }
                                  return FieldValidators.validatePhone(value);
                                },
                              ),

                              SizedBox(height: 16.h),

                              // Email
                              PrimaryTextField(
                                hintText: "Email Address",
                                controller: _emailController,
                                prefixIcon: Icons.email_outlined,
                                hasFocusBorder: true,
                                enabled: _isEditMode,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value != null &&
                                      value.trim().isNotEmpty) {
                                    return FieldValidators.validateEmail(
                                        value);
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 16.h),

                              // Full Address
                              PrimaryTextField(
                                hintText: "Full Address",
                                controller: _fullAddressController,
                                prefixIcon: Icons.location_on_outlined,
                                hasFocusBorder: true,
                                enabled: _isEditMode,
                                keyboardType: TextInputType.multiline,
                                minLines: 1,
                                maxLines: 5,
                                textInputAction: TextInputAction.newline,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Full address is required';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 16.h),

                              // Latitude
                              PrimaryTextField(
                                hintText: "Latitude",
                                controller: _latitudeController,
                                prefixIcon: Icons.explore_outlined,
                                hasFocusBorder: true,
                                enabled: _isEditMode,
                                keyboardType:
                                TextInputType.numberWithOptions(
                                    decimal: true),
                                textInputAction: TextInputAction.next,
                              ),

                              SizedBox(height: 16.h),

                              // Longitude
                              PrimaryTextField(
                                hintText: "Longitude",
                                controller: _longitudeController,
                                prefixIcon: Icons.explore_outlined,
                                hasFocusBorder: true,
                                enabled: _isEditMode,
                                keyboardType:
                                TextInputType.numberWithOptions(
                                    decimal: true),
                                textInputAction: TextInputAction.next,
                              ),

                              SizedBox(height: 16.h),

                              // Notes
                              PrimaryTextField(
                                hintText: "Notes",
                                controller: _notesController,
                                prefixIcon: Icons.note_outlined,
                                hasFocusBorder: true,
                                enabled: _isEditMode,
                                keyboardType: TextInputType.multiline,
                                minLines: 1,
                                maxLines: 5,
                                textInputAction: TextInputAction.newline,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Action Button
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: _isEditMode
                      ? PrimaryButton(
                    label: 'Save Changes',
                    onPressed: _handleSave,
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
              ),
            ],
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: AppColors.error,
              ),
              SizedBox(height: 16.h),
              Text(
                'Failed to load party details',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  error.toString(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

