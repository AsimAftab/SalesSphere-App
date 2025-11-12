import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_sphere/features/settings/vm/change_password_vm.dart';
import 'package:sales_sphere/widget/custom_button.dart';
import 'package:sales_sphere/widget/custom_text_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmNewPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _toggleCurrentPasswordVisibility() {
    setState(() {
      _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
    });
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _isNewPasswordVisible = !_isNewPasswordVisible;
    });
  }

  void _toggleConfirmNewPasswordVisibility() {
    setState(() {
      _isConfirmNewPasswordVisible = !_isConfirmNewPasswordVisible;
    });
  }

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(changePasswordViewModelProvider.notifier).changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        final error = ref.read(changePasswordViewModelProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final changePasswordState = ref.watch(changePasswordViewModelProvider);
    final isLoading = changePasswordState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryTextField(
                controller: _currentPasswordController,
                hintText: 'Current Password',
                obscureText: !_isCurrentPasswordVisible,
                suffixWidget: IconButton(
                  onPressed: _toggleCurrentPasswordVisibility,
                  icon: Icon(
                    _isCurrentPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              PrimaryTextField(
                controller: _newPasswordController,
                hintText: 'New Password',
                obscureText: !_isNewPasswordVisible,
                suffixWidget: IconButton(
                  onPressed: _toggleNewPasswordVisibility,
                  icon: Icon(
                    _isNewPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                validator: ref.read(changePasswordViewModelProvider.notifier).validatePassword,
              ),
              const SizedBox(height: 16.0),
              PrimaryTextField(
                controller: _confirmNewPasswordController,
                hintText: 'Retype New Password',
                obscureText: !_isConfirmNewPasswordVisible,
                suffixWidget: IconButton(
                  onPressed: _toggleConfirmNewPasswordVisibility,
                  icon: Icon(
                    _isConfirmNewPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              CustomButton(
                label: 'Change Password',
                onPressed: isLoading ? null : _handleChangePassword,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
