# SalesSphere Project Documentation

Welcome to the SalesSphere project documentation! This folder contains everything you need to understand the project structure and build new features.

---

## 📚 Documentation Files

### 1. [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)
**Start here!** Comprehensive overview of the entire project.

**What's inside:**
- Technology stack (Flutter, Riverpod, GoRouter, Freezed)
- Project folder structure
- Architecture patterns
- Code generation workflow
- Key conventions
- Network layer setup
- Build commands

**When to read:** When you're new to the project or need to understand how everything fits together.

---

### 2. [REUSABLE_COMPONENTS.md](REUSABLE_COMPONENTS.md)
Complete guide to all reusable UI components and widgets.

**What's inside:**
- Custom buttons (PrimaryButton, SecondaryButton, etc.)
- Text fields (PrimaryTextField)
- Field validators
- Common layout patterns
- Success/error dialogs
- Loading states
- Spacing & sizing helpers
- Icon usage
- SVG assets

**When to read:** When building UI or looking for existing components to reuse.

---

### 3. [CREATING_NEW_PAGES.md](CREATING_NEW_PAGES.md)
Step-by-step guide for creating new screens/pages.

**What's inside:**
- Quick checklist
- Full example: Registration page (complete code)
- Pattern templates (Simple display, Form page, API page)
- Common page types (List, Detail, Settings)
- Production-ready checklist

**When to read:** When you need to create a new page or screen.

---

### 4. [THEMING_AND_STYLING.md](THEMING_AND_STYLING.md)
Complete reference for colors, typography, spacing, and styling.

**What's inside:**
- Color palette (all AppColors constants)
- Typography system
- Spacing system (8, 16, 24, 32, 40)
- Border radius standards
- Elevation & shadows
- Responsive sizing (.w, .h, .sp, .r)
- Common UI patterns (Cards, Dividers, Chips, Messages)
- Best practices

**When to read:** When styling UI elements or ensuring consistency.

---

### 5. [CODE_EXAMPLES.md](CODE_EXAMPLES.md)
Practical, copy-paste ready code examples.

**What's inside:**
- Complete screen examples
- Riverpod ViewModels
- Freezed models
- Form handling
- Navigation patterns
- API calls (GET, POST)
- State management
- Common UI patterns
- Quick snippets

**When to read:** When you need working code examples to reference or copy.

---

### 6. [code-examples/](code-examples/) 📁
**Actual working code files from the project**

**What's inside:**
- **widgets/**: `custom_button.dart`, `custom_text_field.dart`
- **screens/**: `login_screen.dart`, `forgot_password_screen.dart`
- **models/**: `login.models.dart`, `forgot_password.models.dart`
- **viewmodels/**: `login.vm.dart`, `forgot_password.vm.dart`
- **constants/**: `app_colors.dart`, `api_endpoints.dart`, `field_validators.dart`
- **router/**: `route_handler.dart`
- **INDEX.md**: Complete guide to all code files

**When to use:** When you want to see the actual implementation files, not just snippets. Perfect for:
- Copying complete files as templates
- Understanding full file structure
- Seeing imports and dependencies
- Learning annotation patterns
- Reference while building

---

## 🚀 Quick Start Guide

### For New Developers

1. **Read [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)** to understand the project structure
2. **Scan [REUSABLE_COMPONENTS.md](REUSABLE_COMPONENTS.md)** to see what components are available
3. **Browse [code-examples/](code-examples/)** to see real working code
4. **Follow [CREATING_NEW_PAGES.md](CREATING_NEW_PAGES.md)** to build your first page
5. **Reference [THEMING_AND_STYLING.md](THEMING_AND_STYLING.md)** for styling guidelines
6. **Use [CODE_EXAMPLES.md](CODE_EXAMPLES.md)** for code snippets

### For Experienced Developers

- **Building UI?** → [REUSABLE_COMPONENTS.md](REUSABLE_COMPONENTS.md) + [code-examples/widgets/](code-examples/widgets/)
- **Creating a page?** → [CREATING_NEW_PAGES.md](CREATING_NEW_PAGES.md) + [code-examples/screens/](code-examples/screens/)
- **Need code examples?** → [code-examples/](code-examples/) + [CODE_EXAMPLES.md](CODE_EXAMPLES.md)
- **Styling questions?** → [THEMING_AND_STYLING.md](THEMING_AND_STYLING.md) + [code-examples/constants/](code-examples/constants/)
- **Understanding routing?** → [code-examples/router/](code-examples/router/)

---

## 📖 Common Tasks

### Task: Create a New Auth Page

1. Read the Registration example in [CREATING_NEW_PAGES.md](CREATING_NEW_PAGES.md)
2. **Copy actual files** from [code-examples/screens/](code-examples/screens/) as starting point
3. Check [code-examples/models/](code-examples/models/) for model structure
4. Reference [code-examples/viewmodels/](code-examples/viewmodels/) for ViewModel patterns
5. Use [REUSABLE_COMPONENTS.md](REUSABLE_COMPONENTS.md) for form components
6. Check [THEMING_AND_STYLING.md](THEMING_AND_STYLING.md) for colors and spacing

### Task: Add a New Button Style

1. Check [REUSABLE_COMPONENTS.md](REUSABLE_COMPONENTS.md) for existing button types
2. If creating custom, reference [THEMING_AND_STYLING.md](THEMING_AND_STYLING.md) for colors
3. See [CODE_EXAMPLES.md](CODE_EXAMPLES.md) for implementation examples

### Task: Integrate an API Endpoint

1. Add endpoint to `lib/core/constants/api_endpoints.dart` (see [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md))
2. Create Freezed models (see [CODE_EXAMPLES.md](CODE_EXAMPLES.md))
3. Create ViewModel with API call (see [CODE_EXAMPLES.md](CODE_EXAMPLES.md))
4. Build UI using [CREATING_NEW_PAGES.md](CREATING_NEW_PAGES.md) template
5. Run code generation

### Task: Style a Component

1. Check [THEMING_AND_STYLING.md](THEMING_AND_STYLING.md) for color palette
2. Use standard spacing values (8.h, 16.h, 24.h, etc.)
3. Apply responsive sizing (.w, .h, .sp, .r)
4. Reference [CODE_EXAMPLES.md](CODE_EXAMPLES.md) for complete examples

---

## 🎯 Key Principles

### 1. **Consistency**
- Use `AppColors` for all colors
- Use standard spacing (8, 16, 24, 32, 40)
- Use Poppins font family
- Use `.w`, `.h`, `.sp`, `.r` for all sizing

### 2. **Reusability**
- Always check [REUSABLE_COMPONENTS.md](REUSABLE_COMPONENTS.md) before creating new components
- Use `PrimaryButton`, `PrimaryTextField`, etc.
- Follow established patterns

### 3. **Architecture**
- Feature-first folder structure
- Riverpod for state management
- Freezed for models
- GoRouter for navigation

### 4. **Code Quality**
- Run code generation after changes
- Validate forms properly
- Handle loading/error states
- Use AppLogger for logging (never `print()`)

---

## 📝 Code Generation

Remember to run code generation after creating/modifying:
- Riverpod providers (`@riverpod`)
- Freezed models (`@freezed`)
- JSON serializable classes

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 🛠️ Development Workflow

1. **Plan**: Understand requirements
2. **Design**: Reference [THEMING_AND_STYLING.md](THEMING_AND_STYLING.md)
3. **Model**: Create Freezed models (see [CODE_EXAMPLES.md](CODE_EXAMPLES.md))
4. **ViewModel**: Create Riverpod ViewModel (see [CODE_EXAMPLES.md](CODE_EXAMPLES.md))
5. **View**: Build UI using [CREATING_NEW_PAGES.md](CREATING_NEW_PAGES.md)
6. **Route**: Add to `route_handler.dart`
7. **Generate**: Run code generation
8. **Test**: Test on device

---

## 📞 Support

If you have questions:
1. Search these documentation files
2. Check [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) for general questions
3. Check [CODE_EXAMPLES.md](CODE_EXAMPLES.md) for implementation help
4. Review existing code in the project

---

## 📂 File Reference

```
export/
├── README.md                      (This file - Navigation guide)
├── PROJECT_OVERVIEW.md            (Architecture & structure)
├── REUSABLE_COMPONENTS.md         (UI components & widgets)
├── CREATING_NEW_PAGES.md          (Step-by-step page creation)
├── THEMING_AND_STYLING.md         (Colors, fonts, spacing)
├── CODE_EXAMPLES.md               (Copy-paste code snippets)
└── code-examples/                 (Actual working code files)
    ├── INDEX.md                   (Guide to all code files)
    ├── widgets/                   (Button, TextField components)
    ├── screens/                   (Login, Forgot Password screens)
    ├── models/                    (Freezed data models)
    ├── viewmodels/                (Riverpod ViewModels)
    ├── constants/                 (Colors, endpoints, validators)
    └── router/                    (GoRouter configuration)
```

---

## 🎓 Learning Path

**Beginner:**
1. PROJECT_OVERVIEW.md (understand basics)
2. CODE_EXAMPLES.md (see working code)
3. CREATING_NEW_PAGES.md (follow step-by-step)

**Intermediate:**
1. REUSABLE_COMPONENTS.md (master components)
2. THEMING_AND_STYLING.md (consistent styling)
3. CODE_EXAMPLES.md (advanced patterns)

**Advanced:**
- All files as quick reference
- Focus on architecture patterns
- Contribute new components

---

**Happy Coding! 🚀**
