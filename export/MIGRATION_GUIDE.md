# SalesSphere Migration Guide

This document provides step-by-step instructions to replicate all changes from this branch (`add-new-party`) to a fresh clone of the SalesSphere project.

## Overview

This guide covers the addition of a **Profile Feature** and various code quality improvements across the application. The profile feature allows users to view their profile information and update their profile picture.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Dependency Changes](#dependency-changes)
3. [New Files to Create](#new-files-to-create)
4. [Files to Modify](#files-to-modify)
5. [Code Generation](#code-generation)
6. [Testing the Changes](#testing-the-changes)
7. [Summary Checklist](#summary-checklist)

---

## Prerequisites

Before starting, ensure you have:
- A fresh clone of the SalesSphere repository
- Flutter SDK installed (version matching pubspec.yaml)
- All existing dependencies installed (`flutter pub get`)
- Build runner working (`dart run build_runner build --delete-conflicting-outputs`)

---

## Dependency Changes

### 1. Update `pubspec.yaml`

**File:** `pubspec.yaml`

**Change:** Add the `image_picker` dependency in the `dependencies` section.

```yaml
dependencies:
  # ... existing dependencies ...
  image_picker: ^1.2.0  # Add this line
```

**After adding:**
```bash
flutter pub get
```

---

## New Files to Create

### 1. Profile Model

**File:** `lib/features/profile/models/profile.model.dart`

**Purpose:** Defines the Profile, UpdateProfileRequest, and ProfileResponse models using Freezed.

**Steps:**
1. Create directory: `lib/features/profile/models/`
2. Create file: `profile.model.dart`
3. Copy the complete content from your current project

**Key Points:**
- Uses `@freezed` annotation
- Requires `part 'profile.model.freezed.dart';` and `part 'profile.model.g.dart';`
- Contains three models: `Profile`, `UpdateProfileRequest`, `ProfileResponse`

---

### 2. Profile ViewModel

**File:** `lib/features/profile/vm/profile.vm.dart`

**Purpose:** Manages profile state using Riverpod AsyncNotifier pattern.

**Steps:**
1. Create directory: `lib/features/profile/vm/`
2. Create file: `profile.vm.dart`
3. Copy the complete content from your current project

**Key Features:**
- Uses `@riverpod` annotation
- Requires `part 'profile.vm.g.dart';`
- Methods: `fetchProfile()`, `updateProfile()`, `refresh()`, `updateProfileImage()`
- Currently uses **mock data** (ready for API integration)
- Stores profile image path in SharedPreferences

---

### 3. Profile Screen

**File:** `lib/features/profile/view/profile_screen.dart`

**Purpose:** UI for viewing user profile (read-only display).

**Steps:**
1. Create directory: `lib/features/profile/view/`
2. Create file: `profile_screen.dart`
3. Copy the complete content from your current project

**Key Features:**
- View-only profile information display
- Profile picture upload (camera/gallery)
- Stats cards (visits, orders, attendance)
- Pull to refresh
- Responsive design using ScreenUtil
- Clean, simple UI without edit functionality

---

## Files to Modify

### 1. Storage Keys

**File:** `lib/core/constants/storage_keys.dart`

**Change:** Add profile image path storage key.

**Location:** Add in the appropriate section (around line 29-32)

```dart
// Profile
static const String profileImagePath = 'profile_image_path';
```

---

### 2. Router Configuration

**File:** `lib/core/router/route_handler.dart`

**Changes:**

1. **Add Import** (at the top with other imports):
```dart
import 'package:sales_sphere/features/profile/view/profile_screen.dart';
```

2. **Add Route** (in the routes list, around line 92):
```dart
GoRoute(
  path: '/profile',
  name: 'profile',
  builder: (context, state) => const ProfileScreen(),
),
```

---

### 3. Home Screen - Avatar Navigation

**File:** `lib/features/home/views/home_screen.dart`

**Change:** Make avatar clickable to navigate to profile screen.

**Location:** Around line 135-165 (the CircleAvatar section in AppBar)

**Add Import:**
```dart
import 'package:go_router/go_router.dart';
```

**Wrap the avatar Container with GestureDetector:**
```dart
// User Avatar - Click to view profile
GestureDetector(
  onTap: () {
    context.push('/profile');
  },
  child: Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: AppColors.textOrange,
        width: 2.5,
      ),
    ),
    child: CircleAvatar(
      radius: 26.r,
      backgroundColor: AppColors.primary,
      backgroundImage: user?.avatarUrl != null
          ? NetworkImage(user!.avatarUrl!)
          : null,
      child: user?.avatarUrl == null
          ? Text(
        _getInitials(user?.name ?? 'User'),
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textWhite,
        ),
      )
          : null,
    ),
  ),
),
```

---

### 4. Logging Interceptor - Code Quality

**File:** `lib/core/network_layer/interceptors/logging_interceptor.dart`

**Changes:** Convert `forEach` to `for-in` loops and remove null check for stackTrace.

**Location 1:** Around line 78
```dart
// OLD:
lines.forEach((line) {
  AppLogger.i('║   $line');
});

// NEW:
for (var line in lines) {
  AppLogger.i('║   $line');
}
```

**Location 2:** Around line 118-124
```dart
// OLD:
if (err.stackTrace != null) {
  AppLogger.e('║ Stack Trace:');
  final stackLines = err.stackTrace.toString().split('\n').take(5);
  stackLines.forEach((line) {
    AppLogger.e('║   $line');
  });
}

// NEW:
AppLogger.e('║ Stack Trace:');
final stackLines = err.stackTrace.toString().split('\n').take(5);
for (var line in stackLines) {
  AppLogger.e('║   $line');
}
```

---

### 5. Auth Init Provider - Remove Unused Import

**File:** `lib/core/providers/auth_init_provider.dart`

**Change:** Remove unused import.

**Remove this line:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

Keep only:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
```

---

### 6. Login ViewModel - Add Const Keywords

**File:** `lib/features/auth/vm/login.vm.dart`

**Changes:** Add `const` keyword to AsyncError constructors where applicable.

**Locations to update (around lines 115-132):**

```dart
// Line ~115:
state = const AsyncError({
  'general': 'Login failed. Please try again.',
}, StackTrace.empty);

// Line ~123:
state = const AsyncError({
  'general': 'Invalid email or password',
}, StackTrace.empty);

// Line ~130:
state = const AsyncError({
  'general': 'Network error. Please check your connection.',
}, StackTrace.empty);

// Line ~136:
state = AsyncError(const {
  'general': 'Something went wrong. Please try again.',
}, StackTrace.current);
```

---

### 7. Catalog Screens - Add Const Keywords

**File 1:** `lib/features/catalog/views/catalog_item_list_screen.dart`

**Changes:**

Around line 137:
```dart
const BorderSide(color: AppColors.primary, width: 2),
```

Around line 236:
```dart
loading: () => const Center(
  child: CircularProgressIndicator(
    color: AppColors.primary,
  ),
),
```

**File 2:** `lib/features/catalog/views/catalog_screen.dart`

**Changes:**

Around line 136:
```dart
borderSide: const BorderSide(color: AppColors.primary, width: 2),
```

Around line 228:
```dart
loading: () => const Center(
  child: CircularProgressIndicator(
    color: AppColors.primary,
  ),
),
```

---

### 8. Catalog ViewModel - Add Const Keywords

**File:** `lib/features/catalog/vm/catalog.vm.dart`

**Change:** Add `const` keyword to all `CatalogCategory` instances in `_getMockCategories()` method.

**Location:** Around lines 34-69

```dart
List<CatalogCategory> _getMockCategories() {
  return [
    const CatalogCategory(
      id: '1',
      name: 'Marble',
      imageAssetPath: 'assets/images/placeholder_marble.png',
      itemCount: 125,
    ),
    const CatalogCategory(
      id: '2',
      name: 'Paints',
      imageAssetPath: 'assets/images/placeholder_paints.png',
      itemCount: 88,
    ),
    // ... add 'const' to all remaining CatalogCategory instances
  ];
}
```

---

### 9. Parties Screen - Add Const Keyword

**File:** `lib/features/parties/views/parties_screen.dart`

**Change:**

Around line 201:
```dart
loading: () => const Center(
  child: CircularProgressIndicator(
    color: AppColors.primary,
  ),
),
```

---

### 10. Edit Party Details Screen - Code Quality

**File:** `lib/features/parties/views/edit_party_details_screen.dart`

**Changes:**

1. **Remove unused import:**
```dart
// Remove this line:
import 'package:intl/intl.dart';
```

2. **Add const keywords to multiple widgets:**

Around line 123:
```dart
const SnackBar(
  content: Row(
    children: [
```

Around line 205:
```dart
duration: const Duration(seconds: 3),
```

Around line 217:
```dart
Future.delayed(const Duration(milliseconds: 500), () {
```

Around line 283:
```dart
duration: const Duration(seconds: 4),
```

Around line 325:
```dart
const SnackBar(
  content: Text('Could not open maps. Is Google Maps installed?'),
```

Around line 335:
```dart
const SnackBar(
  content: Text('No address or coordinates to show'),
```

Around line 628:
```dart
keyboardType: const TextInputType.numberWithOptions(decimal: true),
```

Around line 689:
```dart
loading: () => const Center(
  child: CircularProgressIndicator(color: AppColors.primary),
),
```

---

### 11. Minor Widget Updates

These files have minor const keyword additions for better performance:

- `lib/widget/app_bottom_nav.dart` - Add const where applicable
- `lib/widget/custom_text_field.dart` - Add const where applicable
- `lib/widget/settings_tile.dart` - Add const where applicable

**Note:** Run Flutter analyze to identify exact locations where `const` can be added:
```bash
flutter analyze
```

---

## Code Generation

After creating/modifying all files, run code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This will generate:
- `lib/features/profile/models/profile.model.freezed.dart`
- `lib/features/profile/models/profile.model.g.dart`
- `lib/features/profile/vm/profile.vm.g.dart`

**Verify:** Check that all three files are generated successfully.

---

## Testing the Changes

### 1. Verify App Builds

```bash
flutter run
```

### 2. Test Profile Feature

1. **Navigate to Profile:**
   - Open the app
   - Tap the avatar in the top-right corner of the Home screen
   - Verify the Profile screen opens

2. **Test Profile View:**
   - Verify all profile information displays correctly (mock data)
   - Check that stats cards show (Visits, Orders, Attendance)
   - Verify all fields are displayed in read-only format

3. **Test Profile Image:**
   - Tap the camera icon on the profile avatar
   - Select "Camera" or "Gallery"
   - Choose an image
   - Verify the image updates
   - Restart the app - image should persist (stored in SharedPreferences)

4. **Test Pull to Refresh:**
   - Pull down on the profile screen
   - Verify refresh animation works

---

## Summary Checklist

Use this checklist to ensure all changes are applied:

### Dependencies
- [ ] Added `image_picker: ^1.2.0` to pubspec.yaml
- [ ] Ran `flutter pub get`

### New Files Created
- [ ] `lib/features/profile/models/profile.model.dart`
- [ ] `lib/features/profile/vm/profile.vm.dart`
- [ ] `lib/features/profile/view/profile_screen.dart`

### Modified Files
- [ ] `lib/core/constants/storage_keys.dart` - Added profileImagePath
- [ ] `lib/core/router/route_handler.dart` - Added profile route
- [ ] `lib/features/home/views/home_screen.dart` - Avatar navigation
- [ ] `lib/core/network_layer/interceptors/logging_interceptor.dart` - Code quality
- [ ] `lib/core/providers/auth_init_provider.dart` - Removed unused import
- [ ] `lib/features/auth/vm/login.vm.dart` - Added const keywords
- [ ] `lib/features/catalog/views/catalog_item_list_screen.dart` - Added const keywords
- [ ] `lib/features/catalog/views/catalog_screen.dart` - Added const keywords
- [ ] `lib/features/catalog/vm/catalog.vm.dart` - Added const keywords
- [ ] `lib/features/parties/views/parties_screen.dart` - Added const keyword
- [ ] `lib/features/parties/views/edit_party_details_screen.dart` - Code quality improvements
- [ ] Minor widget updates (app_bottom_nav, custom_text_field, settings_tile)

### Code Generation
- [ ] Ran `dart run build_runner build --delete-conflicting-outputs`
- [ ] Verified generated files exist:
  - [ ] `profile.model.freezed.dart`
  - [ ] `profile.model.g.dart`
  - [ ] `profile.vm.g.dart`

### Testing
- [ ] App builds without errors
- [ ] Profile screen accessible from home
- [ ] Profile information displays correctly
- [ ] Profile image upload works
- [ ] Profile image persists after restart
- [ ] Pull to refresh works
- [ ] All existing features still work

---

## Additional Notes

### Profile Feature Design

The profile screen is **view-only** by design. Users can:
- ✅ View their profile information
- ✅ Update their profile picture (camera/gallery)
- ❌ Edit personal information fields (by design choice)

This simplified design provides a clean viewing experience while allowing profile picture updates. If you need to add edit functionality in the future, you can implement it by:
- Adding form fields with TextEditingControllers
- Adding validation logic
- Calling the `updateProfile()` method in the ProfileViewModel

### API Integration

The profile feature currently uses **mock data**. When the backend API is ready:

1. **Update Profile ViewModel** (`lib/features/profile/vm/profile.vm.dart`):
   - Uncomment the real API calls in `fetchProfile()` (lines 62-73)
   - Uncomment the real API calls in `updateProfile()` (lines 123-139)
   - Comment out or remove the mock data sections

2. **Add API Endpoints** (if not already present in `lib/core/network_layer/api_endpoints.dart`):
   ```dart
   static String profile = '/user/profile';
   static String updateProfile = '/user/profile';
   ```

### Profile Image Storage

Currently, profile images are stored locally:
- **Local Path:** Saved in SharedPreferences (key: `profileImagePath`)
- **Display:** Loaded from local file system using `File(path)`

When integrating with backend:
- Upload image to server
- Store the returned URL in the profile
- Update `profileImageUrl` field in Profile model

### Code Quality Improvements

Many changes in this migration are code quality improvements:
- Adding `const` keywords for better performance
- Using `for-in` loops instead of `forEach`
- Removing unused imports
- Following Flutter/Dart best practices

These changes were likely suggested by:
- `flutter analyze`
- `dart fix --apply`
- IDE linting rules

---

## Troubleshooting

### Code Generation Fails

**Problem:** `build_runner` fails or generates incomplete files.

**Solution:**
1. Clean previous builds: `dart run build_runner clean`
2. Delete generated files manually
3. Run: `dart run build_runner build --delete-conflicting-outputs`

### Import Errors

**Problem:** "Target of URI doesn't exist" errors.

**Solution:**
1. Ensure all new files are created in correct directories
2. Check that file names match exactly (case-sensitive)
3. Run `flutter pub get` again

### Image Picker Not Working

**Problem:** Image picker crashes or doesn't show.

**Solution:**
1. **Android:** Ensure permissions in `AndroidManifest.xml` (should be auto-added by package)
2. **iOS:** Ensure permissions in `Info.plist` (should be auto-added by package)
3. Check `image_picker` package documentation for platform-specific setup

### Profile Image Not Persisting

**Problem:** Profile image disappears after app restart.

**Solution:**
1. Check SharedPreferences is initialized properly
2. Verify `StorageKeys.profileImagePath` constant exists
3. Check that `updateProfileImage()` is being called after image selection

---

## Questions or Issues?

If you encounter any issues during migration:
1. Check Flutter/Dart versions match the project requirements
2. Ensure all dependencies are properly installed
3. Run `flutter clean` and `flutter pub get`
4. Verify code generation completed successfully
5. Check the console for detailed error messages

---

**Migration Guide Version:** 1.0
**Date:** 2025-11-01
**Branch:** add-new-party
**Compatible with:** SalesSphere main branch (commit: ca36965)
