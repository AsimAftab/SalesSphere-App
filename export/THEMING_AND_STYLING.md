# Theming and Styling Guide

Complete reference for colors, typography, spacing, and styling patterns in SalesSphere.

---

## Color Palette

### Primary Colors
Located in `lib/core/constants/app_colors.dart`

```dart
AppColors.primary        // #163355 - Dark Blue (Nav, Headers)
AppColors.primaryDark    // #163355 - Same as primary
AppColors.primaryLight   // #BB86FC - Light Purple

AppColors.secondary      // #197ADC - Bright Blue (Buttons, CTA)
AppColors.secondaryDark  // #018786 - Teal
AppColors.secondaryLight // #66FFF9 - Cyan
```

### Background Colors
```dart
AppColors.background     // #F1F4FC - Light Blue-Gray (Main background)
AppColors.backgroundDark // #121212 - Dark mode background
AppColors.surface        // #FFFFFF - White (Cards, surfaces)
AppColors.surfaceDark    // #1E1E1E - Dark mode surfaces
```

### Text Colors
```dart
AppColors.textPrimary    // #212121 - Almost Black (Main text)
AppColors.textSecondary  // #757575 - Gray (Secondary text)
AppColors.textHint       // #9E9E9E - Light Gray (Placeholders)
AppColors.textDisabled   // #BDBDBD - Very Light Gray (Disabled)
AppColors.textWhite      // #FFFFFF - White text
AppColors.textOrange     // #FF7029 - Orange text
AppColors.textdark       // #DD000000 - Dark text
```

### Status Colors
```dart
AppColors.success        // #4CAF50 - Green (Success states)
AppColors.error          // #B00020 - Red (Errors)
AppColors.warning        // #FFA726 - Orange (Warnings)
AppColors.info           // #2196F3 - Blue (Info messages)
```

### Border & Divider Colors
```dart
AppColors.border         // #E0E0E0 - Light Gray
AppColors.borderDark     // #424242 - Dark borders
AppColors.divider        // #BDBDBD - Divider lines
```

### Semantic Colors
```dart
AppColors.positive       // #4CAF50 - Green (Positive actions)
AppColors.negative       // #F44336 - Red (Negative actions)
AppColors.neutral        // #9E9E9E - Gray (Neutral)
```

### Utility Colors
```dart
AppColors.transparent    // Transparent
AppColors.shadow         // Black with 10% opacity
AppColors.shadowDark     // Black with 30% opacity
AppColors.overlay        // Black with 50% opacity
AppColors.overlayLight   // Black with 30% opacity
```

### Gradients
```dart
AppColors.primaryGradient    // Primary to PrimaryLight
AppColors.secondaryGradient  // Secondary to SecondaryLight
```

### Chart Colors
```dart
AppColors.chartColors  // List of 6 colors for charts/graphs
```

---

## Typography

### Font Family
- **Primary Font**: Poppins (defined in `pubspec.yaml`)
- **Fallback**: System default

### Font Weights
```dart
FontWeight.w400  // Regular (body text)
FontWeight.w500  // Medium (emphasis)
FontWeight.w600  // Semi-bold (buttons, subtitles)
FontWeight.w700  // Bold (headings)
```

### Common Text Styles

#### Headings
```dart
// Large Heading (Page Titles)
TextStyle(
  fontFamily: 'Poppins',
  fontSize: 24.sp,
  fontWeight: FontWeight.w700,
  color: AppColors.primary,
)

// Medium Heading (Section Titles)
TextStyle(
  fontFamily: 'Poppins',
  fontSize: 20.sp,
  fontWeight: FontWeight.w600,
  color: AppColors.textPrimary,
)

// Small Heading (Card Titles)
TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16.sp,
  fontWeight: FontWeight.w600,
  color: AppColors.textPrimary,
)
```

#### Body Text
```dart
// Primary Body Text
TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14.sp,
  fontWeight: FontWeight.w400,
  color: AppColors.textPrimary,
)

// Secondary Body Text
TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14.sp,
  fontWeight: FontWeight.w400,
  color: AppColors.textSecondary,
)

// Small Text (Captions)
TextStyle(
  fontFamily: 'Poppins',
  fontSize: 12.sp,
  fontWeight: FontWeight.w400,
  color: AppColors.textSecondary,
)
```

#### Button Text
```dart
TextStyle(
  fontFamily: 'Poppins',
  fontSize: 15.sp,  // Medium button
  fontWeight: FontWeight.w600,
  color: Colors.white,
)
```

#### AppBar Title
```dart
TextStyle(
  fontFamily: 'Poppins',
  fontSize: 18.sp,
  fontWeight: FontWeight.w600,
  color: AppColors.textPrimary,
)
```

---

## Spacing System

### Standard Spacing Values
Use these consistent spacing values throughout the app:

```dart
// Micro spacing
4.h / 4.w    // Tiny gaps
8.h / 8.w    // Small gaps between related items

// Standard spacing
12.h / 12.w  // Moderate spacing
16.h / 16.w  // Default spacing (most common)
20.h / 20.w  // Medium-large spacing
24.h / 24.w  // Large spacing

// Section spacing
32.h / 32.w  // Between major sections
40.h / 40.w  // Extra large spacing
48.h / 48.w  // Maximum spacing
```

### Common Padding Patterns
```dart
// Screen padding
EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h)

// Card padding
EdgeInsets.all(16.w)

// List item padding
EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h)

// Button padding
EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h)

// Minimal padding
EdgeInsets.all(8.w)
```

---

## Border Radius System

### Standard Radius Values
```dart
8.r   // Small radius (chips, badges)
12.r  // Medium radius (text fields, buttons) - DEFAULT
16.r  // Large radius (cards, dialogs)
20.r  // Extra large radius
24.r  // Maximum radius
32.r  // Extreme radius (bottom sheets)
```

### Common Border Radius Patterns
```dart
// Default (buttons, text fields)
BorderRadius.circular(12.r)

// Cards
BorderRadius.circular(16.r)

// Bottom sheet / Modal
BorderRadius.only(
  topLeft: Radius.circular(32.r),
  topRight: Radius.circular(32.r),
)

// Rounded corners (specific sides)
BorderRadius.only(
  topLeft: Radius.circular(12.r),
  bottomRight: Radius.circular(12.r),
)
```

---

## Elevation & Shadows

### Standard Elevations
```dart
// Low elevation (subtle lift)
BoxShadow(
  color: AppColors.shadow,  // 10% opacity
  blurRadius: 4,
  offset: const Offset(0, 2),
)

// Medium elevation (cards)
BoxShadow(
  color: AppColors.shadow,
  blurRadius: 8,
  offset: const Offset(0, 4),
)

// High elevation (modals, dialogs)
BoxShadow(
  color: AppColors.shadowDark,  // 30% opacity
  blurRadius: 20,
  offset: const Offset(0, 8),
)
```

### Button Elevation
```dart
// Primary buttons
elevation: 2

// Disabled buttons
elevation: 0

// Gradient buttons
BoxShadow(
  color: AppColors.secondary.withValues(alpha: 0.3),
  blurRadius: 8,
  offset: const Offset(0, 4),
)
```

---

## Responsive Sizing

### ScreenUtil Extensions
Always use these for responsive sizing:

```dart
.w   // Width scaling
.h   // Height scaling
.sp  // Font size scaling
.r   // Radius scaling
```

### Examples
```dart
// Container sizing
Container(
  width: 200.w,   // Responsive width
  height: 100.h,  // Responsive height
  padding: EdgeInsets.all(16.w),
)

// Text sizing
Text(
  'Hello',
  style: TextStyle(fontSize: 14.sp),  // Responsive font
)

// Border radius
BorderRadius.circular(12.r)  // Responsive radius
```

### Icon Sizing
```dart
// Small icons
Icons.icon_name, size: 16.sp

// Standard icons
Icons.icon_name, size: 20.sp

// Large icons
Icons.icon_name, size: 24.sp

// Extra large icons (decorative)
Icons.icon_name, size: 48.sp
```

---

## Common UI Patterns

### Card Style
```dart
Container(
  padding: EdgeInsets.all(16.w),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16.r),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ...,
)
```

### Divider
```dart
Divider(
  color: AppColors.divider,
  thickness: 1,
  height: 32.h,
)

// OR

Container(
  height: 1,
  color: AppColors.divider,
)
```

### Chip/Badge
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
  decoration: BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(8.r),
  ),
  child: Text(
    'Badge',
    style: TextStyle(
      color: AppColors.textWhite,
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
    ),
  ),
)
```

### Error Message Container
```dart
Container(
  padding: EdgeInsets.all(12.w),
  decoration: BoxDecoration(
    color: AppColors.error.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(12.r),
    border: Border.all(
      color: AppColors.error.withValues(alpha: 0.3),
    ),
  ),
  child: Row(
    children: [
      Icon(
        Icons.error_outline,
        color: AppColors.error,
        size: 20.sp,
      ),
      SizedBox(width: 12.w),
      Expanded(
        child: Text(
          'Error message',
          style: TextStyle(
            color: AppColors.error,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  ),
)
```

### Success Message Container
```dart
Container(
  padding: EdgeInsets.all(12.w),
  decoration: BoxDecoration(
    color: AppColors.success.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(12.r),
    border: Border.all(
      color: AppColors.success.withValues(alpha: 0.3),
    ),
  ),
  child: Row(
    children: [
      Icon(
        Icons.check_circle,
        color: AppColors.success,
        size: 20.sp,
      ),
      SizedBox(width: 12.w),
      Text(
        'Success message',
        style: TextStyle(
          color: AppColors.success,
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),
)
```

---

## Theme Configuration

The app uses FlexColorScheme for advanced Material 3 theming. Configuration is in `lib/core/theme/theme.dart`.

### Text Scaling
Text scaling is clamped between 0.8x and 1.3x for consistency:

```dart
MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaler: TextScaler.linear(
      MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
    ),
  ),
  child: ...,
)
```

---

## Best Practices

### ✅ DO:
- Use `AppColors` constants for all colors
- Use `.w`, `.h`, `.sp`, `.r` for all sizing
- Use consistent spacing values (8, 12, 16, 24, 32, 40)
- Use Poppins font family
- Use standard border radius (12.r for most elements)
- Use semantic color names (success, error, warning)

### ❌ DON'T:
- Hardcode color values (`Color(0xFF...)` directly)
- Use fixed pixel values (use ScreenUtil instead)
- Mix different spacing systems
- Use random spacing values
- Override font family without good reason
- Use extreme border radius unless design requires it

---

## Quick Reference

### Most Common Values
```dart
// Padding
EdgeInsets.all(16.w)
EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h)

// Spacing
SizedBox(height: 16.h)
SizedBox(width: 12.w)

// Border Radius
BorderRadius.circular(12.r)

// Font Sizes
fontSize: 12.sp  // Small
fontSize: 14.sp  // Body
fontSize: 16.sp  // Subtitle
fontSize: 18.sp  // Title
fontSize: 24.sp  // Heading

// Colors
AppColors.primary
AppColors.secondary
AppColors.textPrimary
AppColors.textSecondary
AppColors.error
AppColors.success
```

---

## Next Steps

- **Code Examples**: See `CODE_EXAMPLES.md` for complete implementations
- **Components**: See `REUSABLE_COMPONENTS.md` for pre-styled widgets
- **Creating Pages**: See `CREATING_NEW_PAGES.md` for page templates
