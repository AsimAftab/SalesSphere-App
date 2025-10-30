import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/core/utils/field_validators.dart';
import 'package:sales_sphere/features/parties/models/edit_party_details.model.dart';
import 'package:sales_sphere/features/parties/vm/edit_party.vm.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';
import 'package:sales_sphere/widget/custom_button.dart';

class EditPartyDetailsScreen extends ConsumerStatefulWidget {
  final String partyId;

  const EditPartyDetailsScreen({
    super.key,
    required this.partyId,
  });

  @override
  ConsumerState<EditPartyDetailsScreen> createState() => _EditPartyDetailsScreenState();
}

class _EditPartyDetailsScreenState extends ConsumerState<EditPartyDetailsScreen> {
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
    if (!mounted) return;
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

      try {
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
          ref.invalidate(partyByIdProvider(widget.partyId));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update details: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
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

    if (party.latitude != null && party.longitude != null) {
      url = Uri(
        scheme: 'geo',
        path: '0,0',
        queryParameters: {'q': '${party.latitude},${party.longitude}'},
      );
    } else if (party.fullAddress.isNotEmpty) {
      url = Uri(
        scheme: 'geo',
        path: '0,0',
        queryParameters: {'q': party.fullAddress},
      );
    }

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textdark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Details',
          style: TextStyle(
            color: AppColors.textdark,
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
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/images/corner_bubble.svg',
              fit: BoxFit.cover,
              height: 160.h,
            ),
          ),
          partyAsync.when(
            data: (party) {
              if (party == null) {
                return Center(
                  child: Text(
                    'Party not found',
                    style: TextStyle(fontSize: 16.sp, color: AppColors.textdark),
                  ),
                );
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_currentParty == null || _currentParty!.id != party.id) {
                  _populateFields(party);
                }
              });

              return Column(
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
                                padding: EdgeInsets.all(20.w),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _nameController.text,
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textdark,
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
                                                _fullAddressController.text.isEmpty
                                                    ? 'No address set'
                                                    : _fullAddressController.text,
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
                                              color: AppColors.primary.withValues(alpha: 0.7),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                'Party Details',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textdark,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(14.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha:0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
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
                                    PrimaryTextField(
                                      hintText: "Email Address",
                                      controller: _emailController,
                                      prefixIcon: Icons.email_outlined,
                                      hasFocusBorder: true,
                                      enabled: _isEditMode,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) {
                                        if (value != null && value.trim().isNotEmpty) {
                                          return FieldValidators.validateEmail(value);
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16.h),
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
                                    PrimaryTextField(
                                      hintText: "Latitude",
                                      controller: _latitudeController,
                                      prefixIcon: Icons.explore_outlined,
                                      hasFocusBorder: true,
                                      enabled: _isEditMode,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      textInputAction: TextInputAction.next,
                                    ),
                                    SizedBox(height: 16.h),
                                    PrimaryTextField(
                                      hintText: "Longitude",
                                      controller: _longitudeController,
                                      prefixIcon: Icons.explore_outlined,
                                      hasFocusBorder: true,
                                      enabled: _isEditMode,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      textInputAction: TextInputAction.next,
                                    ),
                                    SizedBox(height: 16.h),
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
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, MediaQuery.of(context).padding.bottom + 16.h),
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
                ],
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
                  SizedBox(height: 16.h),
                  Text(
                    'Failed to load party details',
                    style: TextStyle(fontSize: 16.sp, color: AppColors.textdark, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      error.toString(),
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
