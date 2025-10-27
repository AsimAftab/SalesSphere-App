import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_button.dart';

/// Example usage of CustomButton component
/// This file demonstrates all button variations and configurations
class CustomButtonExamplesPage extends StatelessWidget {
  const CustomButtonExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Button Examples')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ============== PRIMARY BUTTONS ==============
            _buildSectionTitle('Primary Buttons'),
            SizedBox(height: 12.h),

            // Basic Primary Button
            PrimaryButton(
              label: 'Login',
              onPressed: () {},
            ),
            SizedBox(height: 12.h),

            // Primary Button with Loading
            PrimaryButton(
              label: 'Processing...',
              onPressed: () {},
              isLoading: true,
            ),
            SizedBox(height: 12.h),

            // Primary Button with Icon
            PrimaryButton(
              label: 'Send Message',
              leadingIcon: Icons.send,
              onPressed: () {},
            ),
            SizedBox(height: 12.h),

            // Primary Button - Small Size
            PrimaryButton(
              label: 'Small Button',
              size: ButtonSize.small,
              onPressed: () {},
            ),
            SizedBox(height: 12.h),

            // Primary Button - Large Size
            PrimaryButton(
              label: 'Large Button',
              size: ButtonSize.large,
              onPressed: () {},
            ),
            SizedBox(height: 12.h),

            // Disabled Primary Button
            PrimaryButton(
              label: 'Disabled',
              isDisabled: true,
              onPressed: () {},
            ),

            SizedBox(height: 24.h),

            // ============== SECONDARY BUTTONS ==============
            _buildSectionTitle('Secondary Buttons'),
            SizedBox(height: 12.h),

            SecondaryButton(
              label: 'Secondary Action',
              onPressed: () {},
            ),
            SizedBox(height: 12.h),

            SecondaryButton(
              label: 'Save',
              leadingIcon: Icons.save,
              onPressed: () {},
            ),

            SizedBox(height: 24.h),

            // ============== OUTLINED BUTTONS ==============
            _buildSectionTitle('Outlined Buttons'),
            SizedBox(height: 12.h),

            OutlinedCustomButton(
              label: 'Cancel',
              onPressed: () {},
            ),
            SizedBox(height: 12.h),

            OutlinedCustomButton(
              label: 'Edit Price',
              leadingIcon: Icons.edit,
              onPressed: () {},
            ),
            SizedBox(height: 12.h),

            OutlinedCustomButton(
              label: 'Download Report',
              trailingIcon: Icons.download,
              onPressed: () {},
            ),

            SizedBox(height: 24.h),

            // ============== GRADIENT BUTTONS ==============
            _buildSectionTitle('Gradient Buttons'),
            SizedBox(height: 12.h),

            GradientButton(
              label: 'Get Started',
              onPressed: () {},
            ),
            SizedBox(height: 12.h),

            GradientButton(
              label: 'Upgrade Now',
              trailingIcon: Icons.arrow_forward,
              onPressed: () {},
            ),
            SizedBox(height: 12.h),

            GradientButton(
              label: 'Loading...',
              isLoading: true,
              onPressed: () {},
            ),

            SizedBox(height: 24.h),

            // ============== TEXT BUTTONS ==============
            _buildSectionTitle('Text Buttons'),
            SizedBox(height: 12.h),

            CustomButton(
              label: 'Skip for now',
              type: ButtonType.text,
              onPressed: () {},
            ),
            SizedBox(height: 12.h),

            CustomButton(
              label: 'Learn More',
              type: ButtonType.text,
              trailingIcon: Icons.arrow_forward,
              onPressed: () {},
            ),

            SizedBox(height: 24.h),

            // ============== CUSTOM BUTTONS ==============
            _buildSectionTitle('Custom Styled Buttons'),
            SizedBox(height: 12.h),

            // Custom colors and size
            CustomButton(
              label: 'Custom Button',
              type: ButtonType.primary,
              backgroundColor: Colors.purple,
              borderRadius: 25.r,
              onPressed: () {},
            ),
            SizedBox(height: 12.h),

            // Fixed width button
            CustomButton(
              label: 'Fixed Width',
              type: ButtonType.outlined,
              width: 200.w,
              onPressed: () {},
            ),
            SizedBox(height: 12.h),

            // Button with both icons
            CustomButton(
              label: 'Share',
              type: ButtonType.primary,
              leadingIcon: Icons.share,
              trailingIcon: Icons.arrow_forward,
              onPressed: () {},
            ),

            SizedBox(height: 24.h),

            // ============== BUTTON STATES ==============
            _buildSectionTitle('Button States'),
            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Enabled',
                    size: ButtonSize.small,
                    onPressed: () {},
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PrimaryButton(
                    label: 'Disabled',
                    size: ButtonSize.small,
                    isDisabled: true,
                    onPressed: () {},
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PrimaryButton(
                    label: 'Loading',
                    size: ButtonSize.small,
                    isLoading: true,
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        fontFamily: 'Poppins',
      ),
    );
  }
}
