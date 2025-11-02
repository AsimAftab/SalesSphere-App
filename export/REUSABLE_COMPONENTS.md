# Reusable Components Guide

## Overview
This document covers all reusable UI components available in the SalesSphere project. These components are designed to maintain consistency across the app and speed up development.

---

## 1. Custom Buttons (`lib/widget/custom_button.dart`)

### Available Button Types
- **PrimaryButton**: Blue filled button (default CTA)
- **SecondaryButton**: Dark blue filled button
- **OutlinedCustomButton**: Border-only button
- **GradientButton**: Gradient background button
- **CustomButton**: Fully customizable base button

### Button Sizes
```dart
enum ButtonSize {
  small,   // Height: 40.h
  medium,  // Height: 50.h (default)
  large,   // Height: 60.h
}
```

### Usage Examples

#### Primary Button (Most Common)
```dart
PrimaryButton(
  label: 'Send Reset Link',
  onPressed: () {
    // Handle click
  },
  size: ButtonSize.medium,
  isLoading: false,
  isDisabled: false,
)
```

#### Button with Icon
```dart
PrimaryButton(
  label: 'Add Party',
  leadingIcon: Icons.add,
  onPressed: () => context.go('/add-party'),
)

// OR trailing icon
PrimaryButton(
  label: 'Next',
  trailingIcon: Icons.arrow_forward,
  onPressed: () {},
)
```

#### Loading State
```dart
PrimaryButton(
  label: 'Login',
  onPressed: () => _handleLogin(),
  isLoading: isLoading,  // Shows circular progress indicator
)
```

#### Disabled State
```dart
PrimaryButton(
  label: 'Submit',
  onPressed: () {},
  isDisabled: true,  // Grayed out, not clickable
)
```

#### Secondary Button
```dart
SecondaryButton(
  label: 'Cancel',
  onPressed: () => context.go('/'),
  size: ButtonSize.small,
)
```

#### Outlined Button
```dart
OutlinedCustomButton(
  label: 'Learn More',
  onPressed: () {},
)
```

#### Gradient Button
```dart
GradientButton(
  label: 'Get Started',
  onPressed: () {},
  size: ButtonSize.large,
)
```

#### Custom Width
```dart
PrimaryButton(
  label: 'Half Width',
  onPressed: () {},
  width: 150.w,  // Custom width instead of full width
)
```

### Fully Customizable Button
```dart
CustomButton(
  label: 'Custom',
  onPressed: () {},
  type: ButtonType.primary,
  size: ButtonSize.medium,
  backgroundColor: Colors.green,
  textColor: Colors.white,
  borderRadius: 20.r,
  leadingIcon: Icons.check,
)
```

### Button Parameters Reference
| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `label` | String | Button text | Required |
| `onPressed` | VoidCallback? | Click handler | null |
| `isLoading` | bool | Show loading indicator | false |
| `isDisabled` | bool | Disable button | false |
| `size` | ButtonSize | Button size | medium |
| `leadingIcon` | IconData? | Icon before text | null |
| `trailingIcon` | IconData? | Icon after text | null |
| `width` | double? | Custom width | full width |
| `height` | double? | Custom height | size-based |

---

## 2. Text Fields (`lib/widget/custom_text_field.dart`)

### Primary Text Field
Beautiful, consistent text input with built-in error handling.

### Basic Usage
```dart
final _emailController = TextEditingController();

PrimaryTextField(
  hintText: "Email Address",
  controller: _emailController,
  prefixIcon: Icons.email_outlined,
  hasFocusBorder: true,
)
```

### With Validation
```dart
PrimaryTextField(
  hintText: "Email Address",
  controller: _emailController,
  prefixIcon: Icons.email_outlined,
  validator: (value) {
    return FieldValidators.validateEmail(value);
  },
)
```

### Password Field
```dart
final _passwordController = TextEditingController();
bool _isPasswordVisible = false;

PrimaryTextField(
  hintText: "Password",
  controller: _passwordController,
  prefixIcon: Icons.lock_outline,
  obscureText: !_isPasswordVisible,
  suffixWidget: IconButton(
    icon: Icon(
      _isPasswordVisible
        ? Icons.visibility_outlined
        : Icons.visibility_off_outlined,
    ),
    onPressed: () {
      setState(() {
        _isPasswordVisible = !_isPasswordVisible;
      });
    },
  ),
)
```

### Multi-line Text Field
```dart
PrimaryTextField(
  hintText: "Enter description",
  controller: _descriptionController,
  minLines: 3,
  maxLines: 5,
  textInputAction: TextInputAction.newline,
)
```

### Disabled Field
```dart
PrimaryTextField(
  hintText: "Email",
  controller: _emailController,
  enabled: false,  // Grayed out, read-only
)
```

### Number Input
```dart
PrimaryTextField(
  hintText: "Phone Number",
  controller: _phoneController,
  prefixIcon: Icons.phone,
  keyboardType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
  ],
  maxLength: 10,
)
```

### With Keyboard Action
```dart
PrimaryTextField(
  hintText: "Email",
  controller: _emailController,
  textInputAction: TextInputAction.done,
  onFieldSubmitted: (_) => _handleSubmit(),
)
```

### Form Integration
```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      PrimaryTextField(
        hintText: "Email",
        controller: _emailController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email is required';
          }
          return null;
        },
      ),
      SizedBox(height: 16.h),
      PrimaryButton(
        label: 'Submit',
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            // Form is valid
          }
        },
      ),
    ],
  ),
)
```

### Parameters Reference
| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `hintText` | String | Placeholder text | Required |
| `controller` | TextEditingController | Text controller | Required |
| `prefixIcon` | IconData? | Leading icon | null |
| `suffixWidget` | Widget? | Trailing widget | null |
| `validator` | String? Function(String?)? | Validation function | null |
| `obscureText` | bool? | Hide text (password) | false |
| `keyboardType` | TextInputType? | Keyboard type | text |
| `enabled` | bool? | Enable/disable field | true |
| `textInputAction` | TextInputAction? | Keyboard action button | null |
| `onFieldSubmitted` | void Function(String)? | Submit handler | null |
| `onChanged` | void Function(String)? | Change handler | null |
| `minLines` | int? | Minimum lines | 1 |
| `maxLines` | int? | Maximum lines | 1 |
| `inputFormatters` | List<TextInputFormatter>? | Input restrictions | null |
| `maxLength` | int? | Maximum character length | null |
| `autofillHints` | List<String>? | Autofill hints | null |
| `hasFocusBorder` | bool | Show focus border | false |
| `errorText` | String? | External error message | null |

---

## 3. Field Validators (`lib/core/utils/field_validators.dart`)

### Available Validators

#### Email Validation
```dart
PrimaryTextField(
  hintText: "Email",
  controller: _emailController,
  validator: (value) => FieldValidators.validateEmail(value),
)
```

#### Phone Validation
```dart
PrimaryTextField(
  hintText: "Phone",
  controller: _phoneController,
  validator: (value) => FieldValidators.validatePhone(value),
)
```

#### Password Validation
```dart
PrimaryTextField(
  hintText: "Password",
  controller: _passwordController,
  validator: (value) => FieldValidators.validatePassword(value),
)
```

#### Required Field
```dart
PrimaryTextField(
  hintText: "Name",
  controller: _nameController,
  validator: (value) => FieldValidators.validateRequired(value, 'Name'),
)
```

---

## 4. Date Picker (`lib/widget/custom_date_picker.dart`)

### Usage
```dart
final selectedDate = ref.watch(selectedDateProvider);

CustomDatePicker(
  onDateSelected: (date) {
    ref.read(selectedDateProvider.notifier).state = date;
  },
  initialDate: selectedDate,
)
```

---

## 5. Settings Tile (`lib/widget/settings_tile.dart`)

### Usage
```dart
SettingsTile(
  icon: Icons.person,
  title: 'Profile',
  subtitle: 'Edit your profile information',
  onTap: () => context.go('/profile'),
  showTrailingIcon: true,
)
```

---

## 6. Common Layout Patterns

### AppBar with Back Button
```dart
Scaffold(
  appBar: AppBar(
    title: Text(
      'Page Title',
      style: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 18.sp,
      ),
    ),
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => context.go('/'),
    ),
  ),
  body: ...
)
```

### Handling Hardware Back Button
```dart
// Prevents app from closing, navigates to specific route
return PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) {
    if (!didPop) {
      context.go('/');
    }
  },
  child: Scaffold(...),
)
```

### Keyboard-Aware Screen
```dart
Scaffold(
  resizeToAvoidBottomInset: true,  // Adjusts for keyboard
  body: SafeArea(
    child: SingleChildScrollView(  // Allows scrolling when keyboard shows
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Form(...),
    ),
  ),
)
```

### Full Page Form
```dart
Scaffold(
  appBar: AppBar(...),
  body: SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            SvgPicture.asset(
              'assets/images/logo.svg',
              height: 100.h,
              width: 100.w,
            ),

            SizedBox(height: 24.h),

            // Title
            Text(
              'Page Title',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),

            SizedBox(height: 40.h),

            // Form Fields
            PrimaryTextField(...),
            SizedBox(height: 16.h),
            PrimaryTextField(...),

            SizedBox(height: 32.h),

            // Submit Button
            PrimaryButton(...),
          ],
        ),
      ),
    ),
  ),
)
```

---

## 7. Success/Error Dialogs

### Success Dialog
```dart
void _showSuccessDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 28.sp,
          ),
          SizedBox(width: 12.w),
          const Text('Success'),
        ],
      ),
      content: Text(
        'Operation completed successfully.',
        style: TextStyle(fontSize: 14.sp),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.go('/home');
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
```

### Error Dialog
```dart
void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 28.sp,
          ),
          SizedBox(width: 12.w),
          const Text('Error'),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(fontSize: 14.sp),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
```

---

## 8. Loading States

### Full Screen Loading
```dart
if (isLoading)
  const Center(
    child: CircularProgressIndicator(),
  )
else
  // Your content
```

### Inline Loading (with Button)
```dart
PrimaryButton(
  label: 'Submit',
  onPressed: () => _handleSubmit(),
  isLoading: isLoading,  // Automatically shows loading indicator
)
```

---

## 9. Spacing & Sizing Helpers

### Common Spacing
```dart
SizedBox(height: 8.h)   // Small spacing
SizedBox(height: 16.h)  // Medium spacing
SizedBox(height: 24.h)  // Large spacing
SizedBox(height: 32.h)  // Extra large spacing
SizedBox(height: 40.h)  // Section spacing

SizedBox(width: 8.w)    // Small horizontal spacing
SizedBox(width: 16.w)   // Medium horizontal spacing
```

### Common Padding
```dart
EdgeInsets.all(16.w)                              // Uniform padding
EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h)  // H/V padding
EdgeInsets.only(top: 20.h, left: 16.w)           // Specific sides
```

### Common Border Radius
```dart
BorderRadius.circular(8.r)   // Small radius
BorderRadius.circular(12.r)  // Medium radius (default)
BorderRadius.circular(16.r)  // Large radius
BorderRadius.circular(24.r)  // Extra large radius
```

---

## 10. Icon Usage

### Common Icons
```dart
Icons.email_outlined
Icons.lock_outline
Icons.visibility_outlined
Icons.visibility_off_outlined
Icons.phone
Icons.person
Icons.arrow_back
Icons.arrow_forward
Icons.check_circle
Icons.error_outline
Icons.add
Icons.edit
Icons.delete
```

### Icon with Color
```dart
Icon(
  Icons.email_outlined,
  color: AppColors.primary,
  size: 20.sp,
)
```

---

## 11. SVG Assets

### Logo Usage
```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'assets/images/logo.svg',
  height: 100.h,
  width: 100.w,
)
```

### Colored SVG
```dart
SvgPicture.asset(
  'assets/images/icon.svg',
  height: 24.h,
  width: 24.w,
  colorFilter: ColorFilter.mode(
    AppColors.primary,
    BlendMode.srcIn,
  ),
)
```

---

## Best Practices

1. **Always use ScreenUtil**: Use `.w`, `.h`, `.sp`, `.r` for responsive sizing
2. **Prefer reusable components**: Use `PrimaryButton` instead of custom `ElevatedButton`
3. **Consistent spacing**: Use standard spacing values (8.h, 16.h, 24.h, 32.h)
4. **Form validation**: Always validate user input with `validator`
5. **Loading states**: Show loading indicators during async operations
6. **Error handling**: Display user-friendly error messages
7. **Accessibility**: Use semantic widgets and proper contrast
8. **Keyboard handling**: Use `resizeToAvoidBottomInset: true` and `SingleChildScrollView`

---

## Next Steps

- **Creating New Pages**: See `CREATING_NEW_PAGES.md`
- **Code Examples**: See `CODE_EXAMPLES.md`
- **Theming**: See `THEMING_AND_STYLING.md`
