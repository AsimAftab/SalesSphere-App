# Sites Feature Refactoring Summary

## Overview
Successfully refactored the Sites feature to support the new API structure with **sub-organizations** and **site interests**.

## Changes Made

### 1. **API Endpoints** (`lib/core/network_layer/api_endpoints.dart`)
Added new endpoints:
```dart
static const String siteSubOrganizations = '/api/v1/sites/sub-organizations';
static const String siteCategories = '/api/v1/sites/categories';
```

### 2. **Models** (`lib/features/sites/models/sites.model.dart`)

#### New Models Added:
- **`SiteTechnician`** - Technician details (name, phone, id)
- **`SiteInterest`** - Site interest with category, brands, and technicians
- **`SubOrganization`** - Sub-organization model (id, name)
- **`SiteCategory`** - Full category data from API (id, name, brands, technicians, timestamps)
- **`SubOrganizationsResponse`** - API response for GET /sites/sub-organizations
- **`SiteCategoriesResponse`** - API response for GET /sites/categories

#### Updated Models:
- **`CreateSiteRequest`** - Added:
  - `subOrganization` (required String)
  - `siteInterest` (List<SiteInterest>, default: [])

- **`UpdateSiteRequest`** - Added:
  - `subOrganization` (required String)
  - `siteInterest` (List<SiteInterest>, default: [])

- **`CreateSiteResponseData`** - Added:
  - `subOrganization`
  - `siteInterest`
  - `assignedUsers`, `assignedBy`, `assignedAt` (from API response)
  - Changed `images` from `List<String>` to `List<SiteImageData>`

- **`UpdateSiteResponseData`** - Added:
  - `subOrganization`
  - `siteInterest`

- **`FetchSiteData`** - Added:
  - `subOrganization`
  - `siteInterest`

- **`GetSiteData`** - Added:
  - `subOrganization`
  - `siteInterest`

### 3. **ViewModels** (`lib/features/sites/vm/site_options.vm.dart`)
Created new ViewModel file with two providers:

#### `SubOrganizationsViewModel`:
- Fetches sub-organizations from `/api/v1/sites/sub-organizations`
- Auto-loads on screen init
- Returns `List<SubOrganization>`

#### `SiteCategoriesViewModel`:
- Fetches site categories from `/api/v1/sites/categories`
- Auto-loads on screen init
- Returns `List<SiteCategory>`

### 4. **UI Layer** (`lib/features/sites/views/add_sites_screen.dart`)

#### New State Variables:
```dart
String? _selectedSubOrganization;
List<SiteInterest> _selectedSiteInterests = [];
```

#### New UI Components:
1. **Sub-Organization Dropdown** (`_buildSubOrganizationDropdown()`)
   - Required field with validation
   - Dropdown menu populated from API
   - Loading, error, and empty states handled
   - Positioned after Email field

2. **Site Interests Selector** (`_buildSiteInterestsSection()`)
   - Optional multi-select checkboxes
   - Shows category name and brands
   - Automatically includes all brands and technicians when category is selected
   - Positioned after Notes field

#### Updated Form Submission:
- Added validation for sub-organization (required)
- Passes `_selectedSubOrganization` and `_selectedSiteInterests` to `CreateSiteRequest`

### 5. **Code Generation**
All models generated successfully with:
```bash
dart run build_runner build --delete-conflicting-outputs --build-filter="lib/features/sites/**"
```

## API Request/Response Examples

### Create Site Request:
```json
{
  "siteName": "New Site",
  "ownerName": "Site Manager Name",
  "subOrganization": "North Zone Logistics",
  "dateJoined": "2024-11-05",
  "contact": {
    "phone": "9876543210",
    "email": "warehouse@example.com"
  },
  "location": {
    "address": "123 Industrial Area, City",
    "latitude": 27.7009,
    "longitude": 85.3002
  },
  "description": "Optional notes",
  "siteInterest": [
    {
      "category": "Security Systems",
      "brands": ["Hikvision", "CP Plus"],
      "technicians": [
        { "name": "Ramesh Tech", "phone": "98765123456" },
        { "name": "Suresh Fixer", "phone": "9876512347" }
      ]
    }
  ]
}
```

### Sub-Organizations Response:
```json
{
  "success": true,
  "count": 1,
  "data": [
    { "_id": "...", "name": "North Zone Logistics" }
  ]
}
```

### Site Categories Response:
```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "_id": "...",
      "name": "Security Systems",
      "brands": ["Hikvision", "CP Plus"],
      "technicians": [
        { "name": "Ramesh Tech", "phone": "98765123456", "_id": "..." }
      ],
      "organizationId": "...",
      "createdAt": "...",
      "updatedAt": "...",
      "__v": 0
    }
  ]
}
```

## Files Modified
1. `lib/core/network_layer/api_endpoints.dart` - Added 2 new endpoints
2. `lib/features/sites/models/sites.model.dart` - Updated with 6 new models + updated 8 existing models
3. `lib/features/sites/vm/site_options.vm.dart` - New file with 2 ViewModels
4. `lib/features/sites/views/add_sites_screen.dart` - Updated with new form fields and logic

## Testing Checklist
- [ ] Sub-organization dropdown loads data correctly
- [ ] Site interests section displays all categories
- [ ] Form validation works for sub-organization (required)
- [ ] Site creation API call includes new fields
- [ ] Loading states work for both dropdowns
- [ ] Error states display properly
- [ ] Selected site interests are properly sent to API

## Next Steps
To fully complete the refactoring:
1. Update **Edit Site** screen to handle sub-organization and site interests
2. Update **Site Details** screen to display the new fields
3. Update **Sites List** screen if needed to show sub-organization
4. Add unit tests for new models and ViewModels
5. Test end-to-end flow with actual backend API

## Notes
- **Both sub-organization and site interests are OPTIONAL fields**
- Site interests can be left empty - user can skip selecting any categories
- Sub-organization can be left blank - dropdown shows "(Optional)" label
- When a category is selected, ALL brands and technicians from that category are included
- The `_id` field in nested objects (technicians, interests) is marked as `includeIfNull: false` to prevent sending null IDs to API
- **Important:** All `subOrganization` fields are nullable throughout the codebase for full flexibility

## Bug Fixes
**Issue:** Sites list API failing with `type 'Null' is not a subtype of type 'String'`
- **Root Cause:** API response contained sites without `subOrganization` field
- **Fix:** Changed `subOrganization` from `required String` to `String?` in ALL models:
  - `CreateSiteRequest` - Optional for new sites
  - `UpdateSiteRequest` - Optional for updates
  - `CreateSiteResponseData` - Handles API response
  - `UpdateSiteResponseData` - Handles API response
  - `FetchSiteData` - List response
  - `GetSiteData` - Single site response
- **UI Changes:**
  - Removed required validation from sub-organization dropdown
  - Changed label from "Sub-Organization *" to "Sub-Organization (Optional)"
  - Removed manual validation check before form submission
- **Status:** ✅ Fixed - Sites work with or without sub-organization and site interests
