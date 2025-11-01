# Code Documentation Guide - SalesSphere

**Purpose:** Learn how to document code effectively for understanding and explanation
**Created:** 2025-11-01
**Target Audience:** Developers who need to explain their code

---

## Table of Contents
1. [Why Documentation Matters](#why-documentation-matters)
2. [Documentation Standards](#documentation-standards)
3. [How to Document Different Components](#how-to-document-different-components)
4. [Code Commenting Best Practices](#code-commenting-best-practices)
5. [Explaining Your Code (Interview/Presentation)](#explaining-your-code)
6. [Common Patterns in This Codebase](#common-patterns-in-this-codebase)

---

## Why Documentation Matters

### For You
- **Remember your decisions:** Why did you choose this approach?
- **Debug faster:** Understanding flow helps find bugs
- **Refactor confidently:** Know what can/can't be changed

### For Others
- **Onboarding:** New developers understand faster
- **Collaboration:** Team knows how to use your code
- **Maintenance:** Future changes don't break things

### For Interviews/Presentations
- **Demonstrate understanding:** Show you know WHY, not just WHAT
- **Professional credibility:** Well-documented code shows expertise
- **Answer questions confidently:** Documentation helps remember details

---

## Documentation Standards

### 1. **File-Level Documentation**

Put this at the **TOP** of every file:

```dart
/// Profile Screen - User profile management
///
/// Features:
/// - View user profile information
/// - Edit profile fields with validation
/// - Upload/change profile picture
/// - Pull-to-refresh functionality
///
/// Architecture:
/// - ConsumerStatefulWidget for state management
/// - Riverpod 3.0 for global state
/// - Freezed models for type safety
///
/// Related files:
/// - models/profile.model.dart - Data structures
/// - vm/profile.vm.dart - Business logic
///
/// Created: 2025-11-01
/// Last Modified: 2025-11-01
library;

import 'package:flutter/material.dart';
// ... rest of imports
```

**What to include:**
- Brief description (one line)
- Key features (bullet points)
- Architecture decisions
- Related files
- Dates (created/modified)

### 2. **Class-Level Documentation**

```dart
/// User profile screen with view/edit mode toggle
///
/// This screen allows users to view and edit their profile information.
/// It uses a StatefulWidget to manage edit mode and form state locally,
/// while using Riverpod for global profile data.
///
/// State management:
/// - Local: Edit mode toggle, text controllers, validation errors
/// - Global: Profile data from backend via ProfileViewModel
///
/// Example usage:
/// ```dart
/// context.push('/profile');
/// ```
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}
```

**What to include:**
- Purpose of the class
- How it manages state
- Example usage
- Any important patterns

### 3. **Method-Level Documentation**

```dart
/// Saves updated profile data to backend
///
/// Validates all fields before submission. If validation fails,
/// shows error messages inline and prevents submission.
///
/// Flow:
/// 1. Clear previous validation errors
/// 2. Validate all fields
/// 3. If valid, show loading and submit
/// 4. Handle success/error response
/// 5. Reset loading state
///
/// Parameters:
/// - [context]: BuildContext for showing SnackBars
/// - [currentProfile]: Current profile data for comparison
///
/// Returns:
/// - Future<void>: Completes when save operation finishes
///
/// Throws:
/// - No exceptions thrown directly, all errors caught internally
///
/// Example:
/// ```dart
/// await _saveProfile(context, profile);
/// ```
Future<void> _saveProfile(BuildContext context, Profile currentProfile) async {
  // Implementation...
}
```

**What to include:**
- What the method does (one line)
- Detailed flow/algorithm
- Parameters explanation
- Return value
- Exceptions (if any)
- Example usage

### 4. **Complex Logic Documentation**

```dart
// IMPORTANT: This logic handles both local files and network URLs
// because profile images can be:
// 1. Picked from device (local file path)
// 2. Loaded from backend (network URL)
//
// We check the URL format to determine which Image widget to use:
// - File(path) for local files
// - NetworkImage(url) for remote images
//
// The existsSync() check prevents crashes when:
// - File path is invalid
// - File was deleted after being picked
// - Path doesn't exist on this device
Widget _buildProfileImage(String imageUrl, String fallbackName) {
  final isLocalFile = !imageUrl.startsWith('http://') &&
                      !imageUrl.startsWith('https://') &&
                      File(imageUrl).existsSync();

  if (isLocalFile) {
    return Image.file(File(imageUrl), fit: BoxFit.cover);
  } else {
    return Image.network(imageUrl, fit: BoxFit.cover);
  }
}
```

**When to add complex logic comments:**
- Non-obvious algorithms
- Workarounds for bugs
- Business rule implementations
- Edge case handling

---

## How to Document Different Components

### Widgets

```dart
/// Editable field widget with icon, label, and TextField
///
/// This is a reusable component for creating consistent input fields
/// across the profile edit mode. It includes:
/// - Icon with themed background
/// - Label text above input
/// - TextField with validation error display
/// - Input restrictions via formatters
///
/// Why this exists:
/// - Consistency: All editable fields look the same
/// - Reusability: Used for name, phone, address, etc.
/// - Maintainability: Change one place, update all fields
///
/// Parameters:
/// - [icon]: Icon to display (e.g., Icons.person_outline)
/// - [label]: Field label (e.g., "Full Name")
/// - [controller]: TextEditingController for the field
/// - [keyboardType]: Optional keyboard type (e.g., TextInputType.phone)
/// - [maxLines]: Number of lines (default: 1)
/// - [inputFormatters]: Optional input restrictions
/// - [errorText]: Optional error message to display
Widget _buildEditableField({
  required IconData icon,
  required String label,
  required TextEditingController controller,
  TextInputType? keyboardType,
  int maxLines = 1,
  List<TextInputFormatter>? inputFormatters,
  String? errorText,
}) {
  // Implementation...
}
```

### Models (Freezed)

```dart
/// User profile data model
///
/// This model represents a user's profile information in the system.
/// It uses Freezed for immutability and JSON serialization.
///
/// Why Freezed:
/// - Immutability: Prevents accidental mutations
/// - copyWith: Easy partial updates
/// - Equality: Value comparison (a == b works correctly)
/// - JSON: Auto-generated toJson/fromJson
///
/// Field explanations:
/// - id: Unique identifier from MongoDB (_id field)
/// - fullName: User's complete name (required)
/// - email: Email address (required, used for login)
/// - phoneNumber: Contact number (required, format: 10 digits)
/// - gender: User's gender (optional, cannot be edited)
/// - citizenship: 14-digit citizenship number (optional, editable)
/// - panNumber: 9-digit PAN number (optional, editable)
/// - dateOfBirth: Birth date (optional, editable)
/// - dateJoined: Account creation date (optional, read-only)
/// - profileImageUrl: Path to profile image (can be local or network)
///
/// Usage:
/// ```dart
/// final profile = Profile(
///   id: '123',
///   fullName: 'John Doe',
///   email: 'john@example.com',
///   phoneNumber: '9841234567',
///   address: 'Kathmandu',
/// );
///
/// // Update profile
/// final updated = profile.copyWith(fullName: 'Jane Doe');
/// ```
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    @JsonKey(name: '_id') required String id,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String address,
    String? gender,
    String? citizenship,
    String? panNumber,
    DateTime? dateOfBirth,
    DateTime? dateJoined,
    String? profileImageUrl,
    String? role,
    @Default(0) int totalVisits,
    @Default(0) int totalOrders,
    @Default(0.0) double attendancePercentage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
```

### ViewModels (Riverpod)

```dart
/// Profile ViewModel - Manages profile data and operations
///
/// This ViewModel handles all profile-related business logic including:
/// - Fetching profile data from backend/storage
/// - Updating profile information
/// - Managing profile image uploads
/// - Persisting data to SharedPreferences
///
/// Architecture:
/// - Extends Riverpod's AsyncNotifier
/// - Auto-generated provider: profileViewModelProvider
/// - State type: AsyncValue<Profile?>
///
/// State flow:
/// ```
/// Initial: AsyncLoading()
///     ↓
/// Success: AsyncData(Profile)
///     ↓
/// Update: AsyncLoading() → AsyncData(UpdatedProfile)
///     ↓
/// Error: AsyncError(exception, stackTrace)
/// ```
///
/// Usage in UI:
/// ```dart
/// // Watch state
/// final profileState = ref.watch(profileViewModelProvider);
///
/// // Call methods
/// await ref.read(profileViewModelProvider.notifier).updateProfile(...);
/// ```
///
/// TODO: Replace mock data with real API calls
@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  Future<Profile?> build() async {
    return await fetchProfile();
  }

  /// Fetches user profile from backend
  ///
  /// Currently returns mock data. Will be replaced with API call.
  ///
  /// Also loads saved profile image path from SharedPreferences
  /// to persist user-uploaded images across app restarts.
  ///
  /// Returns:
  /// - Profile object if successful
  /// - null if error occurs
  Future<Profile?> fetchProfile() async {
    // Implementation...
  }
}
```

### Validators

```dart
/// Validates phone number format and length
///
/// This validator ensures phone numbers meet the following criteria:
/// - Not empty/null
/// - Contains only digits (0-9)
/// - Minimum length requirement met
///
/// Used in:
/// - Profile page (Phone Number field)
/// - Add New Party screen (Phone field)
/// - Any other phone input fields
///
/// Parameters:
/// - [value]: Phone number string to validate
/// - [minLength]: Minimum required digits (default: 10)
///
/// Returns:
/// - null if valid
/// - Error message string if invalid
///
/// Examples:
/// ```dart
/// validatePhone('9841234567') // null (valid)
/// validatePhone('12345') // 'Phone number must be at least 10 digits'
/// validatePhone('abc123') // 'Please enter only numbers'
/// validatePhone(null) // 'Phone number is required'
/// ```
static String? validatePhone(String? value, {int minLength = 10}) {
  if (value == null || value.isEmpty) {
    return 'Phone number is required';
  }

  final phoneRegex = RegExp(r'^[0-9]+$');

  if (!phoneRegex.hasMatch(value)) {
    return 'Please enter only numbers';
  }

  if (value.length < minLength) {
    return 'Phone number must be at least $minLength digits';
  }

  return null;
}
```

---

## Code Commenting Best Practices

### ✅ Good Comments

#### 1. **Explain WHY, not WHAT**

```dart
// ❌ BAD: Describing what code does (obvious)
// Get the user's name from the controller
final name = _nameController.text;

// ✅ GOOD: Explaining why we do something
// Trim whitespace to prevent accidental spaces in database
final name = _nameController.text.trim();
```

#### 2. **Document Business Rules**

```dart
// ✅ GOOD: Explaining business requirements
// Gender cannot be edited due to legal/compliance requirements.
// Users must contact support to update this field.
_buildInfoRow(
  label: 'Gender',
  value: profile.gender ?? 'N/A',
),
```

#### 3. **Explain Complex Logic**

```dart
// ✅ GOOD: Breaking down algorithm
// Calculate age from date of birth:
// 1. Get current date
// 2. Calculate year difference
// 3. Adjust if birthday hasn't occurred this year
final now = DateTime.now();
final age = now.year - dateOfBirth.year;
final adjustedAge = now.month < dateOfBirth.month ||
                    (now.month == dateOfBirth.month && now.day < dateOfBirth.day)
    ? age - 1
    : age;
```

#### 4. **Warn About Critical Code**

```dart
// ⚠️ CRITICAL: Do not remove this mounted check!
// Without it, setState() on disposed widget causes crash when:
// - User navigates away during async operation
// - Network is slow and response comes after navigation
if (!mounted) return;

setState(() {
  _isLoading = false;
});
```

#### 5. **Document Temporary Solutions**

```dart
// TODO: Replace with real API call when backend is ready
// Current implementation uses mock data for development/testing
await Future.delayed(const Duration(seconds: 2));
final mockProfile = Profile(...);
```

### ❌ Bad Comments

#### 1. **Obvious Statements**

```dart
// ❌ BAD: Comment adds no value
// Increment counter
counter++;

// ✅ BETTER: No comment needed, code is self-explanatory
counter++;
```

#### 2. **Outdated Comments**

```dart
// ❌ BAD: Comment doesn't match code
// This method validates email addresses
Future<void> validatePhone(String phone) { ... }

// ✅ BETTER: Update comment or remove it
// This method validates phone numbers
Future<void> validatePhone(String phone) { ... }
```

#### 3. **Commented-Out Code**

```dart
// ❌ BAD: Leaving dead code
// setState(() {
//   _oldValidationMethod();
// });

// ✅ BETTER: Remove it (it's in git history if needed)
setState(() {
  _newValidationMethod();
});
```

---

## Explaining Your Code (Interview/Presentation)

### How to Present Features

#### 1. **Start with the Problem**

"The Profile page solves the problem of users needing to update their personal information. Without this feature, users couldn't change their phone number or upload a profile picture."

#### 2. **Explain Your Solution**

"I implemented a view/edit mode toggle pattern. In view mode, users see their profile information as read-only text. When they click edit, fields become editable TextFields with validation."

#### 3. **Highlight Technical Decisions**

"I chose ConsumerStatefulWidget because I needed both:
- Local state for edit mode and form controllers
- Global state for profile data from the backend

This hybrid approach keeps the code clean while maintaining good performance."

#### 4. **Discuss Trade-offs**

"I considered using a separate edit screen, but chose inline editing because:
✅ Better UX - no extra navigation
✅ Faster for users - immediate feedback
✅ Less code - reuse same UI components
❌ Slightly more complex state management
❌ More code in one file

The UX benefits outweighed the complexity cost."

#### 5. **Explain Validation Strategy**

"For the Profile page, I used manual validation with setState because:
- Only 5-6 editable fields
- Need fine-grained control over each field
- Display errors inline as user types

For Add New Party, I used Flutter's Form widget because:
- 9+ fields would be tedious to validate manually
- One-time submission (not editing)
- Form.validate() provides clean API"

### Code Walkthrough Structure

When presenting code, use this structure:

```
1. Overview (1 minute)
   - What the feature does
   - Why it exists

2. Architecture (2 minutes)
   - Widget type and state management
   - Data flow
   - Key patterns used

3. Key Components (3 minutes)
   - Critical methods
   - Important logic
   - Edge cases handled

4. Demonstration (2 minutes)
   - Show working feature
   - Point out validation, errors, success states

5. Q&A (2 minutes)
   - Answer questions confidently
   - Refer to documentation when needed
```

### Example Explanation: _buildProfileImage

**Problem:**
"The profile image can come from two sources: local device (after user picks image) or backend server (after syncing). I needed to handle both."

**Solution:**
```dart
Widget _buildProfileImage(String imageUrl, String fallbackName) {
  // Check if it's a local file or network URL
  final isLocalFile = !imageUrl.startsWith('http://') &&
                      !imageUrl.startsWith('https://') &&
                      File(imageUrl).existsSync();

  if (isLocalFile) {
    return Image.file(File(imageUrl), fit: BoxFit.cover);
  } else {
    return Image.network(imageUrl, fit: BoxFit.cover);
  }
}
```

**Explanation:**
"I check the URL format to determine the source:
1. If it doesn't start with http/https, it's likely a local file
2. I verify the file exists to prevent crashes
3. Then use Image.file() for local or Image.network() for remote

This prevents crashes when:
- File was deleted after picking
- Network URL is invalid
- Device changes (different file paths)

The fallback shows user initials if image fails to load."

---

## Common Patterns in This Codebase

### Pattern 1: Riverpod AsyncNotifier

**When to use:**
- Fetching data from backend
- Handling async operations
- Managing loading/error states

**Example:**
```dart
@riverpod
class MyViewModel extends _$MyViewModel {
  @override
  Future<Data?> build() async {
    return await fetchData();
  }

  Future<Data?> fetchData() async {
    state = const AsyncLoading();
    try {
      // API call
      state = AsyncData(data);
      return data;
    } catch (e) {
      state = AsyncError(e, stackTrace);
      return null;
    }
  }
}
```

**How to explain:**
"Riverpod's AsyncNotifier handles async operations cleanly. The state property automatically manages loading/data/error states, which the UI can react to using the .when() method."

### Pattern 2: Freezed Models

**When to use:**
- Data classes
- API request/response models
- Immutable state

**Example:**
```dart
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    String? email,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

**How to explain:**
"Freezed generates immutable data classes with useful features like copyWith, equality, and JSON serialization. This prevents accidental mutations and provides type-safe updates."

### Pattern 3: Form Validation

**Pattern A: GlobalKey (Add New Party)**
```dart
final _formKey = GlobalKey<FormState>();

// In submit handler
if (!_formKey.currentState!.validate()) {
  return; // Don't submit if invalid
}
```

**How to explain:**
"GlobalKey<FormState> provides a reference to the Form widget, allowing us to call validate() on all fields at once. This is efficient for forms with many fields."

**Pattern B: Manual Validation (Profile Page)**
```dart
String? _nameError;

// In save method
if (_nameController.text.isEmpty) {
  setState(() {
    _nameError = 'Name is required';
  });
  hasError = true;
}
```

**How to explain:**
"Manual validation with setState gives fine-grained control over when errors appear. I use this when I need to show/hide errors dynamically as user types."

### Pattern 4: Image Handling

```dart
Widget _buildProfileImage(String imageUrl, String fallbackName) {
  final isLocalFile = !imageUrl.startsWith('http://') &&
                      !imageUrl.startsWith('https://') &&
                      File(imageUrl).existsSync();

  if (isLocalFile) {
    return Image.file(File(imageUrl), fit: BoxFit.cover);
  } else {
    return Image.network(imageUrl, fit: BoxFit.cover);
  }
}
```

**How to explain:**
"This pattern handles images from multiple sources (local device or network server) with proper error handling to prevent crashes."

### Pattern 5: Safe Navigation After Async

```dart
Future<void> submit() async {
  // ... async operation

  if (!mounted) return; // ← Critical check

  ScaffoldMessenger.of(context).showSnackBar(...);
  context.pop();
}
```

**How to explain:**
"The mounted check prevents calling setState or using context after the widget is disposed. This happens when users navigate away before async operations complete."

---

## Documentation Checklist

Before saying "I'm done", ensure:

### For Each File
- [ ] File-level comment at top
- [ ] Imports organized and necessary
- [ ] No commented-out code
- [ ] TODO comments for incomplete features

### For Each Class
- [ ] Class documentation explaining purpose
- [ ] State management approach documented
- [ ] Example usage provided

### For Each Method
- [ ] Doc comment explaining what it does
- [ ] Complex logic has inline comments
- [ ] Edge cases documented
- [ ] Parameters explained

### For Each Model
- [ ] Field explanations
- [ ] Required vs optional noted
- [ ] Usage examples

### For Critical Code
- [ ] WHY comments (not just WHAT)
- [ ] Warnings for code that shouldn't be removed
- [ ] Links to related files/methods

---

## Summary: The Golden Rule

> **Write documentation as if you're explaining to yourself 6 months from now**

You won't remember:
- Why you chose this approach
- What alternatives you considered
- Why certain code can't be changed
- The business rules behind decisions

Good documentation helps:
- Future you debug faster
- Teammates understand your code
- Interviewers see your thought process
- Managers appreciate your professionalism

---

**Remember:**
- Code tells you HOW
- Comments tell you WHY
- Documentation tells you EVERYTHING

**Happy Documenting! 📝**
