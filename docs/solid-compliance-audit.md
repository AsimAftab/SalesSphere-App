# SOLID Compliance Audit & Bug Report — SalesSphere

**Date:** 2026-03-03
**Scope:** Full codebase — 21 features + core infrastructure
**Framework:** Flutter 3.9.2, Riverpod 3.0 AsyncNotifier pattern

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Scoring Methodology](#2-scoring-methodology)
3. [Per-Feature Scorecards](#3-per-feature-scorecards)
4. [SOLID Violations by Principle](#4-solid-violations-by-principle)
   - [Single Responsibility (S)](#41-single-responsibility-principle-s--11-violations)
   - [Open/Closed (O)](#42-openclosed-principle-o--6-violations)
   - [Liskov Substitution (L)](#43-liskov-substitution-principle-l--3-violations)
   - [Interface Segregation (I)](#44-interface-segregation-principle-i--4-violations)
   - [Dependency Inversion (D)](#45-dependency-inversion-principle-d--6-violations)
5. [Bug Inventory](#5-bug-inventory)
   - [Critical](#51-critical-severity-5)
   - [High](#52-high-severity-7)
   - [Medium](#53-medium-severity-10)
   - [Low](#54-low-severity-1)
6. [Cross-Cutting / Systemic Issues](#6-cross-cutting--systemic-issues)
7. [Prioritized Remediation Roadmap](#7-prioritized-remediation-roadmap)
8. [Appendix: File Index](#8-appendix-file-index)

---

## 1. Executive Summary

| Metric | Count |
|--------|-------|
| **SOLID Violations** | 30 |
| — Single Responsibility | 11 |
| — Open/Closed | 6 |
| — Liskov Substitution | 3 |
| — Interface Segregation | 4 |
| — Dependency Inversion | 6 |
| **Bugs** | 23 |
| — Critical | 5 |
| — High | 7 |
| — Medium | 10 |
| — Low | 1 |
| **Systemic Issues** | 7 |

**Overall Grade: C-**

The codebase delivers its features but has accumulated significant technical debt. The most pervasive problem is the absence of a repository/service layer — 103 direct `ref.read(dioClientProvider)` calls across 55 files make testing impossible and tightly couple every ViewModel to the HTTP implementation. Two god-class files (TrackingCoordinator at 1160 lines, InvoiceScreen at 1974 lines) account for a disproportionate share of complexity. Five critical bugs can cause runtime crashes under normal usage.

---

## 2. Scoring Methodology

### Grading Scale

| Grade | Meaning |
|-------|---------|
| **A** | No violations, no bugs. Exemplary adherence. |
| **B** | Minor violations only (1–2 low-severity). No bugs. |
| **C** | Moderate violations or 1–2 medium bugs. Functional but needs attention. |
| **D** | Multiple violations or high-severity bugs. Active risk. |
| **F** | Critical bugs or systemic violations. Immediate action required. |

### Severity Definitions

| Severity | Definition |
|----------|------------|
| **Critical** | Runtime crash, data loss, or infinite loop under normal usage. |
| **High** | Race condition, null dereference, or silent data corruption under common conditions. |
| **Medium** | Resource leak, inconsistent behavior, or error masking under edge conditions. |
| **Low** | Code quality issue, data accuracy concern, or minor inconsistency. |

### SOLID Assessment

Each principle is marked **Pass** (no violations), **Warn** (minor violations), or **Fail** (significant violations) per feature.

---

## 3. Per-Feature Scorecards

| # | Feature | S | O | L | I | D | Bugs | Grade | Priority |
|---|---------|---|---|---|---|---|------|-------|----------|
| 1 | **Auth** | Fail | Pass | Pass | Pass | Fail | 1M | D | Medium |
| 2 | **Home** | Pass | Pass | Pass | Pass | Fail | 0 | B | Low |
| 3 | **Attendance** | Warn | Pass | Pass | Pass | Fail | 3 (1H, 1H, 1M) | D | High |
| 4 | **Beat Plan** | Warn | Pass | Pass | Pass | Fail | 1C | F | Critical |
| 5 | **Catalog** | Pass | Warn | Pass | Pass | Fail | 1M | C | Low |
| 6 | **Collection** | Warn | Fail | Pass | Warn | Fail | 1H | D | Medium |
| 7 | **Expense Claim** | Pass | Fail | Pass | Warn | Fail | 1H | D | Medium |
| 8 | **Invoice** | Fail | Pass | Warn | Pass | Fail | 4 (1C, 1C, 1M, 1M) | F | Critical |
| 9 | **Leave** | Pass | Warn | Pass | Warn | Fail | 0 | C | Low |
| 10 | **Miscellaneous** | Warn | Pass | Pass | Pass | Fail | 2 (1C, 1M) | F | Critical |
| 11 | **Notes** | Pass | Pass | Pass | Warn | Fail | 0 | B | Low |
| 12 | **Odometer** | Warn | Pass | Pass | Pass | Fail | 1H | C | Medium |
| 13 | **Onboarding** | Pass | Pass | Fail | Pass | Pass | 1C | F | Critical |
| 14 | **Parties** | Fail | Pass | Warn | Warn | Fail | 1M | D | Medium |
| 15 | **Profile** | Warn | Pass | Pass | Pass | Fail | 2 (1H, 1M) | D | High |
| 16 | **Prospects** | Warn | Pass | Pass | Warn | Fail | 1H | C | Medium |
| 17 | **Settings** | Pass | Pass | Pass | Pass | Fail | 1M | C | Low |
| 18 | **Sites** | Fail | Pass | Pass | Fail | Fail | 0 | D | Medium |
| 19 | **Splash** | Pass | Pass | Fail | Pass | Pass | 1M | C | Low |
| 20 | **Tour Plan** | Pass | Fail | Pass | Pass | Fail | 2 (1M, 1L) | D | Medium |
| 21 | **Utilities** | Pass | Pass | Pass | Pass | Pass | 0 | A | None |
| — | **Core Infra** | Fail | Fail | Pass | Fail | Fail | 1M | F | Critical |

**Legend:** C = Critical, H = High, M = Medium, L = Low

**Summary:** 4 features graded F (immediate action), 6 graded D (active risk), 6 graded C (needs attention), 4 graded B (minor), 1 graded A (clean).

---

## 4. SOLID Violations by Principle

### 4.1 Single Responsibility Principle (S) — 11 Violations

---

#### V-S01: LoginViewModel — 8 Responsibilities

**File:** `lib/features/auth/vm/login.vm.dart:39-172`
**Lines:** 174 total, `login()` method is 133 lines

**Code Evidence:**
```dart
Future<void> login(String email, String password) async {
  // 1. Input validation (lines 41-51)
  // 2. API call via Dio (lines 55-60)
  // 3. Token storage (lines 67-69)
  // 4. User data persistence (lines 73-76)
  // 5. Permission caching (lines 80-95)
  // 6. Subscription extraction & save (lines 99-115)
  // 7. Session expiry management (lines 79-81)
  // 8. Global state updates — UserController + PermissionController (lines 120-130)
}
```

**Impact:** Untestable — changes to token storage, permission logic, or API contract all require modifying this single method.

**Suggested Fix:** Extract `AuthenticationService` (API + token), `SessionBootstrapService` (user/permission/subscription persistence). Keep ViewModel as a thin orchestrator.

---

#### V-S02: BeatPlanDetailViewModel — Mixed Tracking + API + UI Concerns

**File:** `lib/features/beat_plan/vm/beat_plan.vm.dart:179-411`

**Code Evidence:**
```dart
Future<bool> markVisitComplete(String beatPlanId, String directoryId, ...) async {
  // 1. API call to mark visit (line 278)
  // 2. State refresh (line 289)
  // 3. TrackingCoordinator.instance.updateVisitProgress(...) (line 312)
}
```

**Impact:** ViewModel directly calls singleton tracking service, making unit testing impossible without the real `TrackingCoordinator`.

**Suggested Fix:** Inject tracking service via provider; extract visit management to a dedicated service.

---

#### V-S03: InvoiceScreen — God Widget (1974 lines)

**File:** `lib/features/invoice/views/invoice_screen.dart` (1974 lines, 51+ controllers)

**Code Evidence:**
- `_InvoiceScreenState` with 51+ `TextEditingController`/`FocusNode` fields
- `build()` starts at line 181
- Handles: invoice form, estimate form, party search/selection, order item display, discount calculation, tax config selection, delivery date picking, and submission

**Impact:** Impossible to test individual sections, extremely difficult to maintain. A change to party selection can break tax calculation.

**Suggested Fix:** Decompose into `PartySelectionSection`, `OrderItemsSection`, `InvoiceSummarySection`, `EstimateFormSection`. Delegate logic to dedicated ViewModels.

---

#### V-S04: Standalone `updateSite()` Function with WidgetRef

**File:** `lib/features/sites/vm/edit_site_details.vm.dart:66-134`

**Code Evidence:**
```dart
Future<void> updateSite(WidgetRef ref, ...) async {
  final dio = ref.read(dioClientProvider);
  // Direct API call, then:
  ref.read(siteViewModelProvider.notifier).updateSite(siteData);
}
```

**Impact:** A loose function receiving `WidgetRef` is untestable and bypasses the ViewModel pattern used everywhere else.

**Suggested Fix:** Move into a proper `EditSiteViewModel` class extending `AsyncNotifier`.

---

#### V-S05: Image Management Logic Duplicated Across 3 Features

**Files:**
- `lib/features/parties/vm/party_image.vm.dart`
- `lib/features/prospects/vm/prospect_images.vm.dart`
- `lib/features/sites/vm/sites_images.vm.dart` (329 lines)

**Code Evidence:** Each file contains nearly identical patterns for: pick image → upload via Dio → update state → handle error → delete image → update state.

**Impact:** Bug fixes must be applied in 3 places; inconsistencies between implementations are inevitable.

**Suggested Fix:** Create a generic `ImageManagementService<T>` or base mixin `ImageUploadMixin` with shared upload/delete logic.

---

#### V-S06: Collection ViewModel — Direct Mutable State Mutation

**File:** `lib/features/collection/vm/collection.vm.dart:47-62`

**Code Evidence:**
```dart
_allCollections[index] = updatedItem;  // Direct mutation!
state = AsyncData(_allCollections);
```

**Impact:** Violates immutable state patterns. Concurrent reads during mutation can see inconsistent data.

**Suggested Fix:** Use `List.from()` or spread operator to create a new list before setting state.

---

#### V-S07: Validation Logic Duplicated in Add/Edit ViewModels

**Files:**
- `lib/features/parties/vm/add_party.vm.dart:69`
- `lib/features/parties/vm/edit_party.vm.dart:103`
- `lib/features/prospects/vm/add_prospect.vm.dart`
- `lib/features/sites/vm/add_sites.vm.dart`

**Impact:** Same validators duplicated across add and edit ViewModels. Maintenance burden and risk of inconsistent validation.

**Suggested Fix:** Use the existing `FieldValidators` from `lib/core/utils/field_validators.dart`, or create feature-specific validation mixins.

---

#### V-S08: MiscellaneousEditViewModel — Dio as Method Parameter

**File:** `lib/features/miscellaneous/vm/miscellaneous_edit.vm.dart`

**Code Evidence:**
```dart
Future<void> updateWork(Dio dio, ...) async { ... }
Future<void> uploadImage(Dio dio, ...) async { ... }
Future<void> deleteImage(Dio dio, ...) async { ... }
```

**Impact:** Violates both S and D — the ViewModel should not know about `Dio`, and passing it as a method parameter is an unusual coupling pattern not used elsewhere.

**Suggested Fix:** Read `dioClientProvider` inside the class, or better, inject a repository abstraction.

---

#### V-S09: AuthInterceptor — 4 Responsibilities

**File:** `lib/core/network_layer/interceptors/auth_interceptor.dart` (335 lines)

**Code Evidence:**
1. **Token injection** — `onRequest()` (line 31)
2. **Token extraction from responses** — `onResponse()` (line 48)
3. **Token refresh with mutex** — `_refreshTokenWithLock()` (line 108)
4. **Force logout** — `_handleAuthFailure()` (line 250)

**Impact:** Token refresh logic is complex (~140 lines) and interleaved with auth header and extraction concerns. Difficult to test refresh logic in isolation.

**Suggested Fix:** Extract `TokenRefreshService` class. AuthInterceptor delegates to it.

---

#### V-S10: ProfileViewModel — Mixed Fetch + Upload + Global State

**File:** `lib/features/profile/vm/profile.vm.dart` (169 lines)

**Code Evidence:**
```dart
// Fetch profile (line 37)
// Upload profile image (line 100)
// Update global UserController (line 135-144)
ref.read(userControllerProvider.notifier).setUser(
  currentUser.copyWith(avatar: uploadedUrl),
);
```

**Impact:** Profile fetching, image upload, and global state updates are three distinct concerns mixed in one class.

**Suggested Fix:** Extract `UploadProfileImageViewModel` or create a `ProfileService`.

---

#### V-S11: TrackingCoordinator — God Class (1160 lines)

**File:** `lib/core/services/tracking_coordinator.dart` (1160 lines)

**Code Evidence:**
- Orchestrates 5 services: `LocationTrackingService`, `TrackingSocketService`, `OfflineQueueService`, `BackgroundTrackingService`, `ConnectivityService`
- `_checkAndResumeTracking()` alone is ~338 lines (180-518) with two nearly identical code blocks for server-side and local-state recovery
- Manages: location tracking, socket communication, offline queue, background service, connectivity monitoring, SharedPreferences persistence, API calls, session recovery, notification progress

**Impact:** Any change risks breaking unrelated tracking concerns. Extremely difficult to test.

**Suggested Fix:** Decompose into `TrackingSessionManager` (session lifecycle), `TrackingStatePersistence` (SharedPreferences), `TrackingRecoveryService` (session recovery). Keep `TrackingCoordinator` as a thin facade.

---

### 4.2 Open/Closed Principle (O) — 6 Violations

---

#### V-O01: Hardcoded Payment Method Mapping

**File:** `lib/features/collection/vm/edit_collection.vm.dart:146-159`

**Code Evidence:**
```dart
String _mapPaymentMethodToLabel(String apiValue) {
  switch (apiValue) {
    case 'bank_transfer': return 'Bank Transfer';
    case 'cash': return 'Cash';
    case 'cheque': return 'Cheque';
    case 'qr': return 'QR Pay';
    default: return apiValue;
  }
}
```

**Impact:** Adding a new payment method requires modifying the switch statement.

**Suggested Fix:** Use a `Map<String, String>` constant or enum with display labels.

---

#### V-O02: Hardcoded Status Filtering with String Literals

**Files:**
- `lib/features/expense-claim/vm/expense_claims.vm.dart:193`
- `lib/features/leave/vm/leave.vm.dart`

**Code Evidence:**
```dart
// expense_claims.vm.dart
c.status.toLowerCase() == 'pending'
// leave.vm.dart
l.status.toLowerCase() == 'approved'
```

**Impact:** No single source of truth for status values. Typo in any string silently breaks filtering.

**Suggested Fix:** Create status enums:
```dart
enum ClaimStatus { pending, approved, rejected, all }
```

---

#### V-O03: Hardcoded Status Colors in Tour Plan

**File:** `lib/features/tour_plan/views/tour_plan_screen.dart:42-53`

**Code Evidence:**
```dart
Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved': return Colors.green;
    case 'pending': return Colors.orange;
    case 'rejected': return Colors.red;
    default: return Colors.grey;
  }
}
```

**Impact:** Adding new statuses requires code changes to the view.

**Suggested Fix:** Create a `StatusTheme` configuration map or extension on a status enum.

---

#### V-O04: Hardcoded Status Card Styling in Edit Tour

**File:** `lib/features/tour_plan/views/edit_tour_details_screen.dart:488-560`

**Code Evidence:** `_buildStatusCard()` uses an inline switch for status-specific colors and icons.

**Impact:** Same as V-O03 — not extensible without code changes.

**Suggested Fix:** Consolidate with V-O03 into a shared `StatusStyleConfig`.

---

#### V-O05: Hardcoded Auth Endpoints List

**File:** `lib/core/network_layer/interceptors/auth_interceptor.dart:18-23`

**Code Evidence:**
```dart
static const _authEndpoints = [
  '/auth/login',
  '/auth/refresh',
  '/auth/forgotpassword',
  '/auth/resetpassword',
];
```

**Impact:** Adding a new public endpoint requires modifying the interceptor.

**Suggested Fix:** Move to `ApiEndpoints` as a static set, or tag endpoints with metadata.

---

#### V-O06: Duplicated Error Extraction Logic

**Files:**
- `lib/features/tour_plan/vm/add_tour.vm.dart`
- `lib/features/tour_plan/vm/edit_tour.vm.dart`
- 6+ other ViewModels with similar patterns

**Code Evidence:**
```dart
String _extractMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data['message'] ?? data['error'] ?? 'Unknown error';
  }
  return data.toString();
}
```

**Impact:** Identical method copy-pasted across 8+ ViewModels. Bug fix must be applied everywhere.

**Suggested Fix:** Create `NetworkErrorExtractor` utility in `lib/core/utils/`.

---

### 4.3 Liskov Substitution Principle (L) — 3 Violations

---

#### V-L01: Inconsistent AsyncNotifier Error Handling Contract

**Files:** Multiple ViewModels across the codebase

**Code Evidence:**
```dart
// Pattern A: AsyncValue.guard() — parties.vm.dart:99
state = await AsyncValue.guard(() async { ... });

// Pattern B: Manual try-catch — add_party.vm.dart:24
try { ... } catch (e) { state = AsyncError(e, StackTrace.current); }

// Pattern C: Direct mutation — collection.vm.dart:47
_allCollections[index] = updatedItem;
state = AsyncData(_allCollections);
```

**Impact:** Substituting one ViewModel pattern for another produces different error propagation behaviors. Consumers cannot rely on a consistent contract.

**Suggested Fix:** Standardize on `AsyncValue.guard()` for all async operations.

---

#### V-L02: OnboardingVM Returns Non-AsyncValue State

**File:** `lib/features/onboarding/vm/onboarding.vm.dart`

**Code Evidence:** Provider returns `OnboardingState` directly (a plain class), not wrapped in `AsyncValue`.

**Impact:** Inconsistent with the Riverpod `AsyncNotifier` pattern used by all other features. `AsyncValue.when()` cannot be used for loading/error states.

**Suggested Fix:** Either use `AsyncNotifier<OnboardingState>` or document why this differs (synchronous-only state).

---

#### V-L03: SplashVM Returns Raw Boolean

**File:** `lib/features/splash/vm/splash.vm.dart:22`

**Code Evidence:** `build()` returns `bool` directly instead of `AsyncValue<bool>`.

**Impact:** Same as V-L02 — inconsistent state handling pattern.

**Suggested Fix:** Use `AsyncNotifier<bool>` or `Notifier<bool>` consistently.

---

### 4.4 Interface Segregation Principle (I) — 4 Violations

---

#### V-I01: Fat ViewModel Pattern Across Features

**Files:** All add/edit ViewModels (parties, prospects, collection, expense-claim, notes, leave)

**Code Evidence:** Single ViewModel classes handle:
1. API calls (create, update, delete)
2. Validation (separate validator methods)
3. Image upload/management
4. State management

Example: `add_collection.vm.dart` has both `submitCollection()` and `uploadCollectionImages()`.

**Impact:** Consumers of the ViewModel are exposed to all concerns. UI widgets that only need validation still depend on API call methods.

**Suggested Fix:** Split into focused ViewModels per concern, or extract API calls to a repository.

---

#### V-I02: SiteImagesViewModel — Overloaded (329 lines)

**File:** `lib/features/sites/vm/sites_images.vm.dart` (329 lines)

**Code Evidence:**
- `addImage()` (line 112) — upload with gap-filling logic
- `deleteImage()` (line 228) — API delete + state update
- `reorderImages()` (line 282) — SharedPreferences-based reordering
- Plus: redundant `sharedPreferencesProvider` at line 25, and multiple functional providers

**Impact:** Image upload, deletion, and reordering are independent concerns forced into one class. The reorder function uses SharedPreferences while add/delete use the API — inconsistent data sources.

**Suggested Fix:** Split into `SiteImageUploadService`, `SiteImageReorderService`.

---

#### V-I03: TokenStorageService — 16+ Public Methods

**File:** `lib/core/network_layer/token_storage_service.dart` (228 lines)

**Code Evidence:**
```dart
// Token concern
saveToken(), getToken(), deleteToken(), hasToken()
// Refresh token concern
saveRefreshToken(), getRefreshToken()
// Session concern
saveSessionExpiresAt(), getSessionExpiresAt(), isSessionExpired()
// User data concern
saveUserData(), getUserData(), clearAuthData()
// Permission concern
savePermissions(), getPermissions()
// Subscription concern
saveSubscription(), getSubscription()
```

**Impact:** The AuthInterceptor only needs token methods but is forced to depend on the full 16-method class. Same for any consumer.

**Suggested Fix:** Split into `TokenRepository`, `SessionRepository`, `UserDataRepository`, `PermissionRepository`.

---

#### V-I04: PermissionState — Mixed Data + Logic

**File:** `lib/core/providers/permission_controller.dart:9-50`

**Code Evidence:**
```dart
class PermissionState {
  // Data fields
  final Map<String, dynamic>? permissions;
  final Subscription? subscription;
  final bool mobileAppAccess;
  final bool webPortalAccess;
  final List<String> enabledModules;

  // Logic methods
  bool hasPermission(String permission) { ... }
  bool isModuleEnabled(String module) { ... }
  // Plus: getters for subscriptionTier, planName
}
```

Also: `PermissionController` duplicates `hasPermission()` and `isModuleEnabled()` as pass-through proxies (lines 106, 111).

**Impact:** Clients that only care about module access must depend on subscription data.

**Suggested Fix:** Separate into `ModuleAccessChecker`, `SubscriptionInfo` interfaces. Use Freezed for immutability.

---

### 4.5 Dependency Inversion Principle (D) — 6 Violations

---

#### V-D01: All ViewModels Coupled to `dioClientProvider` (103 occurrences / 55 files)

**Files:** Every ViewModel that makes API calls

**Code Evidence:**
```dart
// Found in every VM file:
final dio = ref.read(dioClientProvider);
final response = await dio.get('/endpoint');
```

**Impact:** Cannot inject a mock HTTP client for testing. No abstraction layer means changing from Dio to another HTTP client requires modifying 55 files.

**Suggested Fix:** Introduce a `Repository` layer:
```dart
abstract class IPartyRepository {
  Future<List<Party>> getParties({int page, int limit});
  Future<Party> createParty(CreatePartyRequest request);
}

class PartyRepository implements IPartyRepository {
  final Dio _dio;
  PartyRepository(this._dio);
  // ...
}
```

---

#### V-D02: Direct SharedPreferences in SiteImagesViewModel

**File:** `lib/features/sites/vm/sites_images.vm.dart:25, 282-327`

**Code Evidence:**
```dart
@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return await SharedPreferences.getInstance();
}
// ... later in reorderImages():
final prefs = ref.read(sharedPreferencesProvider).value;
```

**Impact:** Redundant provider (duplicates existing `sharedPrefsProvider` in core), and direct dependency on `SharedPreferences` implementation.

**Suggested Fix:** Use the existing `sharedPrefsProvider` from core, or inject a storage abstraction.

---

#### V-D03: No Error Abstraction Layer

**Files:** Multiple ViewModels

**Code Evidence:**
```dart
// Every VM catches DioException directly:
} on DioException catch (e) {
  if (e.response?.statusCode == 400) { ... }
  if (e.error is NetworkException) { ... }
}
```

**Impact:** Leaky abstraction — UI layer must understand Dio error types. Changing HTTP libraries requires updating all error handling.

**Suggested Fix:** Create `AppException` hierarchy mapped from `DioException` in the repository layer. ViewModels only catch `AppException`.

---

#### V-D04: MiscellaneousAddViewModel — Concrete Dio Dependency

**File:** `lib/features/miscellaneous/vm/miscellaneous_add.vm.dart`

**Code Evidence:** Reads `dioClientProvider` directly in methods with raw Dio calls.

**Impact:** Same as V-D01 but compounded by V-S08 (Dio as method parameter in the related edit VM).

**Suggested Fix:** Inject `IMiscWorkRepository` abstraction.

---

#### V-D05: ProfileViewModel — Direct UserController Manipulation

**File:** `lib/features/profile/vm/profile.vm.dart:135-144`

**Code Evidence:**
```dart
ref.read(userControllerProvider.notifier).setUser(
  currentUser.copyWith(avatar: uploadedUrl),
);
```

**Impact:** Hidden dependency between profile and user controller. Changes to `UserController` API break `ProfileViewModel`.

**Suggested Fix:** Use event emitter pattern or create a `UserProfileService` that encapsulates this interaction.

---

#### V-D06: AuthInterceptor — Direct TokenStorageService Coupling

**File:** `lib/core/network_layer/interceptors/auth_interceptor.dart`

**Code Evidence:**
```dart
// Lines 276, 278, 294, 296:
await tokenStorage.saveToken(token);
await tokenStorage.saveRefreshToken(refreshToken);
// Line 250:
await tokenStorage.clearAuthData();
```

Also: `_extractAndSaveTokens()` is fire-and-forget — the async `saveToken()` calls are not properly awaited in `onResponse()` (line 50-51).

**Impact:** Interceptor depends on the concrete `TokenStorageService`. Cannot be tested without real SharedPreferences.

**Suggested Fix:** Create `ITokenStorage` interface; inject into interceptor.

---

## 5. Bug Inventory

### 5.1 Critical Severity (5)

---

#### BUG-01: Force Unwrap `state.value!` Crash in Invoice Creation

**File:** `lib/features/invoice/vm/invoice.vm.dart:266`
**Also:** Line 347 (CreateEstimate)

**Code:**
```dart
// Line 262-266
if (state.hasError) {
  throw state.error!;
}
return state.value!;  // CRASH: if state is AsyncLoading, value is null
```

**Problem:** After `AsyncValue.guard()` completes, if the guard itself throws during the guard callback but before data is set, `state` can be `AsyncLoading` with `value == null`. The `state.value!` force unwrap throws `Null check operator used on a null value`.

**Fix:**
```dart
return state.maybeWhen(
  data: (response) => response,
  error: (e, st) => throw e,
  orElse: () => throw StateError('Unexpected state after guard'),
);
```

---

#### BUG-02: Blocking Busy-Wait Loop in Beat Plan

**File:** `lib/features/beat_plan/vm/beat_plan.vm.dart:42-47`
**Also:** Lines 201-204 (BeatPlanDetailViewModel)

**Code:**
```dart
if (_isFetching) {
  while (_isFetching) {
    await Future.delayed(const Duration(milliseconds: 100));
  }
  return state.hasValue ? state.requireValue : [];
}
```

**Problem:** Busy-wait loop burns CPU cycles polling every 100ms. If `_isFetching` is never reset (e.g., if the fetch throws before reaching `_isFetching = false`), this loops indefinitely, freezing the feature.

**Fix:**
```dart
Completer<List<BeatPlan>>? _fetchCompleter;

Future<List<BeatPlan>> _fetchBeatPlans() async {
  if (_fetchCompleter != null) return _fetchCompleter!.future;
  _fetchCompleter = Completer();
  try {
    final result = await _doFetch();
    _fetchCompleter!.complete(result);
    return result;
  } catch (e) {
    _fetchCompleter!.completeError(e);
    rethrow;
  } finally {
    _fetchCompleter = null;
  }
}
```

---

#### BUG-03: Memory Leak — Double PageController in OnboardingVM

**File:** `lib/features/onboarding/vm/onboarding.vm.dart:17, 32`

**Code:**
```dart
OnboardingState build() {
  final controller = PageController();        // Controller A — created here
  ref.onDispose(() {
    _autoAdvanceTimer?.cancel();
    controller.dispose();                      // Controller A — disposed here
  });
  return OnboardingState(
    currentPage: 0,
    pageController: PageController(),          // Controller B — DIFFERENT instance, NEVER disposed
    pages: const [ ... ],
  );
}
```

**Problem:** Two `PageController` instances are created. Controller A (line 17) is properly disposed. Controller B (line 32, stored in state) is the one actually used by the UI but is never disposed. This is a memory leak.

**Fix:**
```dart
OnboardingState build() {
  final controller = PageController();
  ref.onDispose(() {
    _autoAdvanceTimer?.cancel();
    controller.dispose();
  });
  return OnboardingState(
    currentPage: 0,
    pageController: controller,  // Use the SAME controller
    pages: const [ ... ],
  );
}
```

---

#### BUG-04: MiscellaneousListViewModel Throws on Duplicate Fetch

**File:** `lib/features/miscellaneous/vm/miscellaneous_list.vm.dart:37-39`

**Code:**
```dart
if (_isFetching) {
  AppLogger.w('⚠️ Already fetching misc works, skipping duplicate request');
  throw Exception('Fetch already in progress');
}
```

**Problem:** Throws an exception when a duplicate fetch is attempted. Multiple rapid tab switches or pull-to-refresh gestures will trigger this, causing the UI to show an error state. This is a hostile UX pattern — the user sees "Fetch already in progress" as an error.

**Fix:**
```dart
if (_isFetching) {
  AppLogger.w('Already fetching, returning current state');
  return state.valueOrNull ?? [];
}
```

---

#### BUG-05: Race Condition in Invoice History Optimistic Update

**File:** `lib/features/invoice/vm/invoice.vm.dart:234-255`

**Code:**
```dart
state = await AsyncValue.guard(() async {
  // ... create invoice ...
  return response;
});
// Optimistic update OUTSIDE the guard:
ref.read(invoiceHistoryProvider.notifier).addInvoiceOptimistic(historyItem);
```

**Problem:** If the guard succeeds but `addInvoiceOptimistic` throws, the invoice is created server-side but the history list doesn't reflect it. Conversely, if state transitions fail, the optimistic update is orphaned.

**Fix:** Move the optimistic update inside the guard callback, or wrap both operations in a single error boundary.

---

### 5.2 High Severity (7)

---

#### BUG-06: Null Dereference in Attendance Geofence Validation

**File:** `lib/features/attendance/vm/attendance.vm.dart:154-158`

**Code:**
```dart
throw GeofenceViolationException(
  'You are outside the attendance geofence. '
  'Please move within ${radiusFormatted} of ${orgLocation.address}. '
  '(Current distance: ${distanceFormatted} away)',
);
```

**Problem:** `orgLocation.address` can be null if the organization location has coordinates but no address string. String interpolation of `null` produces the literal string `"null"`.

**Fix:** Add null-coalescing: `${orgLocation.address ?? 'the designated location'}`.

---

#### BUG-07: State Restoration Race Condition in Attendance CheckIn

**File:** `lib/features/attendance/vm/attendance.vm.dart:217-322`

**Code:**
```dart
final previousState = state;
state = const AsyncLoading();
try {
  await refresh();  // This re-fetches and updates state
} on GeofenceViolationException {
  state = previousState;  // Restoring STALE state — refresh may have updated it
  rethrow;
}
```

**Problem:** `refresh()` updates `state` during execution. If a `GeofenceViolationException` is thrown after `refresh()` partially updates state, `previousState` is stale and restoring it reverts legitimate state changes.

**Fix:** Capture the state after refresh completes, or use `AsyncValue.guard()` which handles state transitions atomically.

---

#### BUG-08: Silent Image Upload Failure in Odometer

**File:** `lib/features/odometer/vm/odometer.vm.dart:177-206`

**Code:**
```dart
Future<void> _uploadImage({...}) async {
  try {
    // ... upload logic ...
  } catch (e) {
    AppLogger.e('Failed to upload image: $e');
    // Don't throw — allow trip to continue
  }
}
```

**Problem:** Silently swallows all upload failures including permission errors, disk space issues, and server errors. The UI has no indication that the upload failed, leading to trips without required photographic evidence.

**Fix:** Surface error to UI while allowing trip to continue:
```dart
catch (e) {
  AppLogger.e('Failed to upload image: $e');
  state = state.copyWith(imageUploadError: e.toString());
  // Don't throw — trip continues, but UI shows warning
}
```

---

#### BUG-09: Race Condition in ProfileViewModel Image Upload

**File:** `lib/features/profile/vm/profile.vm.dart:129-150`

**Code:**
```dart
if (ref.mounted) {
  try {
    final updatedProfile = await fetchProfile();  // AWAIT — widget could unmount
    ref.read(userControllerProvider.notifier).setUser(
      currentUser.copyWith(avatar: uploadedUrl),
    );
  }
}
```

**Problem:** `ref.mounted` is checked before the `await`, but the widget may unmount during the async `fetchProfile()` call. After the await, `ref.read()` on an unmounted provider throws.

**Fix:** Check `ref.mounted` after each async gap:
```dart
final updatedProfile = await fetchProfile();
if (!ref.mounted) return;
ref.read(userControllerProvider.notifier).setUser(...);
```

---

#### BUG-10: Null Dereference in Edit Collection

**File:** `lib/features/collection/vm/edit_collection.vm.dart:125-126`

**Code:**
```dart
final listItem = CollectionListItem(
  imagePaths: data.images,  // Could be null
);
```

**Problem:** `data.images` can be null when the collection has no uploaded images. Passing null to a non-nullable field crashes.

**Fix:** Use null-coalescing: `imagePaths: data.images ?? []`.

---

#### BUG-11: Missing Response Validation in Expense Claim

**File:** `lib/features/expense-claim/vm/expense_claim_add.vm.dart:68-72`

**Code:**
```dart
if (data is Map && data.containsKey('data')) {
  return data['data']['_id'] as String;  // No null check on nested access
}
throw Exception('Invalid API response format');
```

**Problem:** `data['data']` could be null, and `data['data']['_id']` could be null. The cast `as String` on null throws `TypeError`.

**Fix:**
```dart
if (data is Map && data.containsKey('data')) {
  final innerData = data['data'];
  if (innerData is Map && innerData.containsKey('_id')) {
    return innerData['_id'] as String;
  }
}
throw Exception('Invalid API response format');
```

---

#### BUG-12: Unchecked Type Cast in Prospect Images

**File:** `lib/features/prospects/vm/prospect_images.vm.dart:44-45`

**Code:**
```dart
final prospectImages = imagesData.map((json) {
  final imageJson = json as Map<String, dynamic>;  // Unchecked cast
```

**Problem:** If the API returns a non-Map element in the images array (e.g., a string URL), this cast throws `TypeError`, crashing the entire image gallery.

**Fix:**
```dart
final prospectImages = imagesData.whereType<Map<String, dynamic>>().map((imageJson) {
  // ...
```

---

### 5.3 Medium Severity (10)

---

#### BUG-13: Timer Not Cancelled in InvoiceDraftController

**File:** `lib/features/invoice/vm/invoice_draft_vm.dart:24-38`

**Code:**
```dart
@Riverpod(keepAlive: true)
class InvoiceDraftController extends _$InvoiceDraftController {
  Timer? _timer;
  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(_timeout, () {
      state = const InvoiceDraftState();
      ref.read(orderControllerProvider.notifier).clearOrder();
    });
  }
  // NO ref.onDispose() to cancel _timer
}
```

**Problem:** With `keepAlive: true`, the provider persists indefinitely. If it is ever invalidated or if the container is disposed, the running timer continues executing, potentially modifying disposed state.

**Fix:** Add `ref.onDispose(() => _timer?.cancel());` in `build()`.

---

#### BUG-14: Timer Not Cancelled in ProfileViewModel

**File:** `lib/features/profile/vm/profile.vm.dart:26-29`

**Code:**
```dart
final link = ref.keepAlive();
Timer(const Duration(seconds: 60), () {
  link.close();
});
```

**Problem:** If the provider is disposed before the 60-second timer fires, the timer callback executes on a disposed `KeepAliveLink`, which is a no-op but wastes resources. If the timer fires after provider disposal, it may cause issues depending on Riverpod version.

**Fix:**
```dart
final link = ref.keepAlive();
final timer = Timer(const Duration(seconds: 60), () => link.close());
ref.onDispose(() => timer.cancel());
```

---

#### BUG-15: Unsafe Cast Operations in Multiple Files

**Files:**
- `lib/features/attendance/views/attendance_screen.dart`
- `lib/features/catalog/vm/catalog_item.vm.dart:49`

**Code:**
```dart
final odometerMap = data['odometer'] as Map<String, dynamic>;
.map((json) => CatalogItem.fromJson(json as Map<String, dynamic>))
```

**Problem:** Unchecked `as` casts crash if the API response shape changes. These should use safe casting.

**Fix:** Use `is` checks before casting, or try-catch with meaningful error messages.

---

#### BUG-16: Session Expiry Returns False When No Expiry Set

**File:** `lib/core/network_layer/token_storage_service.dart:154-176`

**Code:**
```dart
bool isSessionExpired() {
  final expiryDateStr = getSessionExpiresAt();
  if (expiryDateStr == null) {
    return false;  // No expiry set, assume valid
  }
  // ...
}
```

**Problem:** Returns `false` (session valid) when no expiry timestamp exists. This allows sessions without proper expiry data to remain active indefinitely, bypassing session timeout.

**Fix:** Return a tri-state or treat missing expiry as expired:
```dart
if (expiryDateStr == null) {
  AppLogger.w('No session expiry set — treating as expired');
  return true;
}
```

---

#### BUG-17: Map Passed as AsyncError in ChangePasswordViewModel

**File:** `lib/features/settings/vm/change_password_vm.dart:64, 78, 85`

**Code:**
```dart
state = AsyncError({'general': message}, StackTrace.current);
```

**Problem:** `AsyncError` expects an `Object` (typically `Exception`) as its first parameter, not a `Map`. Error-handling widgets that check `error is Exception` will fail, and `.toString()` on the map produces `{general: message}` instead of a clean error message.

**Fix:**
```dart
state = AsyncError(Exception(message), StackTrace.current);
```

---

#### BUG-18: Unchecked `firstWhere` in Miscellaneous List Screen

**File:** `lib/features/miscellaneous/views/miscellaneous_list_screen.dart:35-42`

**Code:**
```dart
void _navigateToWorkDetails(String workId) {
  final worksAsync = ref.read(miscellaneousListViewModelProvider);
  worksAsync.whenData((works) {
    final work = works.firstWhere((w) => w.id == workId);  // Throws StateError!
  });
}
```

**Problem:** `firstWhere` without `orElse` throws `StateError` if no matching work is found. This can happen if the list is refreshed between tapping an item and the navigation callback executing.

**Fix:**
```dart
final work = works.firstWhereOrNull((w) => w.id == workId);
if (work == null) return;
```

---

#### BUG-19: String Thrown Directly as Error in Edit Tour

**File:** `lib/features/tour_plan/vm/edit_tour.vm.dart:102-119`

**Code:**
```dart
if (e.error is NetworkException) {
  throw (e.error as NetworkException).userFriendlyMessage;  // Throws String!
}
// ... line 117:
throw 'Failed to fetch tour details';  // Also throws String!
```

**Problem:** Dart allows throwing any object, but error handlers expect `Exception` instances. Widgets using `error.toString()` work, but `error is Exception` checks fail, causing unhandled error states.

**Fix:**
```dart
throw Exception((e.error as NetworkException).userFriendlyMessage);
```

---

#### BUG-20: Stale State After Party Creation with Image Upload

**File:** `lib/features/parties/views/add_party_screen.dart:280-291`

**Code:**
```dart
final createdParty = await vm.createParty(createRequest);
if (_selectedImage != null && mounted) {
  await imageVm.uploadImage(...);  // May fail silently
}
```

**Problem:** Two-phase operation without transaction semantics. If the image upload fails after party creation, the party exists without its image. No error notification is shown to the user about the partial failure.

**Fix:** Show a warning snackbar if image upload fails, or implement retry logic.

---

#### BUG-21: API Response Assumes Non-null `response.data`

**File:** `lib/features/invoice/vm/invoice.vm.dart:51-61`

**Code:**
```dart
final Map<String, dynamic> responseData;
if (response.data is String) {
  responseData = jsonDecode(response.data as String);
} else if (response.data is Map<String, dynamic>) {
  responseData = response.data;
} else {
  throw Exception('Unexpected response type: ${response.data.runtimeType}');
}
```

**Problem:** `response.data` can be null (e.g., on 204 No Content or network timeout). Calling `.runtimeType` on null is safe, but the null case is never handled — it falls through to the else branch and throws a confusing error message.

**Fix:** Add null check as the first condition:
```dart
if (response.data == null) {
  throw Exception('Empty API response');
}
```

---

#### BUG-22: Unsafe Type Assumption in SplashVM

**File:** `lib/features/splash/vm/splash.vm.dart:62-65`

**Code:**
```dart
final checkStatusResponse = CheckStatusResponse.fromJson(response.data);
```

**Problem:** No type check that `response.data` is `Map<String, dynamic>`. If the API returns a string or null, `fromJson` throws a `TypeError`.

**Fix:**
```dart
if (response.data is! Map<String, dynamic>) {
  throw Exception('Invalid response format');
}
final checkStatusResponse = CheckStatusResponse.fromJson(response.data);
```

---

### 5.4 Low Severity (1)

---

#### BUG-23: DateTime.now() Fallback Hides Bad Data

**File:** `lib/features/tour_plan/models/tour_plan.model.dart:54-69`

**Code:**
```dart
final start = DateTime.tryParse(apiData.startDate) ?? DateTime.now();
final end = DateTime.tryParse(apiData.endDate) ?? DateTime.now();
```

**Problem:** If the API sends an unparseable date string, the fallback to `DateTime.now()` produces incorrect duration calculations (0 days) and hides data quality issues. The user sees "today" instead of the actual planned dates.

**Fix:** Throw or return null to surface bad data:
```dart
final start = DateTime.tryParse(apiData.startDate);
if (start == null) {
  AppLogger.e('Invalid startDate: ${apiData.startDate}');
}
```

---

## 6. Cross-Cutting / Systemic Issues

---

### SYS-01: No Repository/Service Layer

**Scope:** 103 occurrences of `ref.read(dioClientProvider)` across 55 files

**Problem:** Every ViewModel directly constructs HTTP requests, parses responses, and handles errors. There is no abstraction between business logic and network communication.

**Impact:**
- Unit testing is impossible without mocking Dio itself
- Changing HTTP libraries requires touching 55 files
- No place to add caching, retry logic, or request deduplication
- Response parsing is duplicated everywhere

**Recommended Fix:** Introduce a repository layer:
```
ViewModel → Repository (abstract) → RepositoryImpl (Dio)
```

---

### SYS-02: Search Logic Duplicated Across 4+ Features

**Files:**
- `lib/features/parties/vm/parties.vm.dart`
- `lib/features/prospects/vm/prospects.vm.dart`
- `lib/features/sites/vm/sites.vm.dart`
- `lib/features/collection/vm/collection.vm.dart`

**Problem:** Each feature re-implements: search query state, filtered list computation, debounce logic, and filter-by-status with near-identical code.

**Recommended Fix:** Create a `SearchableListMixin` or generic `SearchableListViewModel<T>` base class.

---

### SYS-03: Error Message Extraction Duplicated in 8+ ViewModels

**Problem:** The pattern of extracting user-friendly error messages from `DioException.response.data` is copy-pasted across ViewModels:
```dart
String _extractMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data['message'] ?? data['error'] ?? 'Unknown error';
  }
  return data.toString();
}
```

**Recommended Fix:** Create `NetworkErrorExtractor` utility in `lib/core/utils/`.

---

### SYS-04: Inconsistent `keepAlive` Timer Pattern

**Problem:** 6+ ViewModels use `ref.keepAlive()` with `Timer` for cache invalidation, but patterns vary:
- Some cancel timers on dispose, some don't (BUG-13, BUG-14)
- Some use 30s timeout, some use 60s
- `parties.vm.dart` uses timer-based keep-alive; `collection.vm.dart` doesn't use keep-alive at all

**Recommended Fix:** Standardize with a `CachedAsyncNotifier` mixin that handles the keep-alive + timer pattern consistently.

---

### SYS-05: No Test Entry Points

**Problem:** Tight coupling to `dioClientProvider` and singleton services (`TrackingCoordinator.instance`, `TrackingSocketService.instance`) makes the codebase fundamentally untestable without extensive mocking infrastructure.

**Recommended Fix:** Implement SYS-01 (repository layer) and convert singletons to Riverpod providers for DI.

---

### SYS-06: String-Based Error Messages (No Error Codes/Types)

**Problem:** All error handling uses raw strings:
```dart
throw Exception('Failed to fetch parties');
throw 'Failed to fetch tour details';  // Not even an Exception!
```

No error codes for analytics, no structured error types for the UI to differentiate between network errors, validation errors, and server errors.

**Recommended Fix:** Create error type hierarchy:
```dart
sealed class AppError {
  final String code;
  final String userMessage;
}
class NetworkError extends AppError { ... }
class ValidationError extends AppError { ... }
class ServerError extends AppError { ... }
```

---

### SYS-07: Map Passed as AsyncError Instead of Exception

**Files:** `login.vm.dart`, `change_password_vm.dart`

**Problem:** Several ViewModels pass `Map<String, dynamic>` to `AsyncError`:
```dart
state = AsyncError({'general': message}, StackTrace.current);
```

`AsyncError.error` is typed as `Object`, so this compiles, but downstream error handlers that check `error is Exception` will fail.

**Recommended Fix:** Standardize on `Exception` or custom error types. Create a lint rule to prevent Map-as-error.

---

## 7. Prioritized Remediation Roadmap

### Phase 1 — Critical Bug Fixes (Immediate, 1-2 days)

| ID | Action | File |
|----|--------|------|
| BUG-01 | Replace `state.value!` with `state.maybeWhen()` | `invoice.vm.dart:266, 347` |
| BUG-02 | Replace busy-wait loop with `Completer` | `beat_plan.vm.dart:42-47, 201-204` |
| BUG-03 | Fix double PageController — use same instance | `onboarding.vm.dart:32` |
| BUG-04 | Return cached state instead of throwing | `miscellaneous_list.vm.dart:37-39` |
| BUG-05 | Move optimistic update inside guard | `invoice.vm.dart:234-255` |

### Phase 2 — High Priority Fixes (Short-term, 1 week)

| ID | Action | File |
|----|--------|------|
| BUG-06 | Add null-coalescing for `orgLocation.address` | `attendance.vm.dart:154` |
| BUG-07 | Use `AsyncValue.guard()` for atomic state transitions | `attendance.vm.dart:217` |
| BUG-08 | Surface image upload error to UI | `odometer.vm.dart:177` |
| BUG-09 | Add `ref.mounted` check after async gap | `profile.vm.dart:129` |
| BUG-10 | Add null-coalescing for `data.images` | `edit_collection.vm.dart:125` |
| BUG-11 | Add nested null checks for response parsing | `expense_claim_add.vm.dart:68` |
| BUG-12 | Use `whereType<Map>()` for safe casting | `prospect_images.vm.dart:44` |
| BUG-17 | Replace Map with Exception in AsyncError | `change_password_vm.dart:64,78,85` |
| BUG-19 | Wrap string errors in Exception() | `edit_tour.vm.dart:102,117` |
| SYS-07 | Standardize AsyncError to use Exception types | All affected VMs |
| SYS-03 | Create `NetworkErrorExtractor` utility | New file in `core/utils/` |

### Phase 3 — Architecture Improvements (Medium-term, 2-4 weeks)

| ID | Action | Files |
|----|--------|-------|
| V-D01, SYS-01 | Introduce repository layer — start with 3 most-used features | New `repository/` dirs |
| V-S01 | Extract `AuthenticationService` from LoginVM | `auth/` feature |
| V-S05 | Create shared `ImageManagementService` | `core/services/` |
| V-S09 | Extract `TokenRefreshService` from AuthInterceptor | `network_layer/` |
| V-I03 | Split `TokenStorageService` into focused repositories | `network_layer/` |
| V-O02, V-O03 | Create status enums and color maps | `core/constants/` |
| SYS-02 | Create `SearchableListMixin` | `core/utils/` |
| SYS-04 | Standardize keepAlive timer pattern | All list VMs |
| BUG-13, BUG-14 | Add `ref.onDispose()` timer cleanup everywhere | All VMs with timers |

### Phase 4 — Long-term Refactoring & Testing (1-3 months)

| ID | Action | Files |
|----|--------|-------|
| V-S11 | Decompose TrackingCoordinator into 4-5 classes | `core/services/` |
| V-S03 | Decompose InvoiceScreen into section widgets | `invoice/views/` |
| SYS-05 | Add unit tests using repository mocks | New `test/` files |
| SYS-06 | Implement structured error types | `core/exceptions/` |
| V-L01 | Standardize on `AsyncValue.guard()` everywhere | All VMs |
| V-I04 | Convert `PermissionState` to Freezed with focused interfaces | `core/providers/` |

---

## 8. Appendix: File Index

Every file referenced in this audit, mapped to its violation and bug IDs.

| File | Violations | Bugs |
|------|-----------|------|
| `lib/core/network_layer/interceptors/auth_interceptor.dart` | V-S09, V-O05, V-D06 | — |
| `lib/core/network_layer/dio_client.dart` | V-D01 | — |
| `lib/core/network_layer/token_storage_service.dart` | V-I03 | BUG-16 |
| `lib/core/providers/permission_controller.dart` | V-I04 | — |
| `lib/core/services/tracking_coordinator.dart` | V-S11 | — |
| `lib/core/services/tracking_socket_service.dart` | V-S11 (related) | — |
| `lib/core/services/background_tracking_service.dart` | V-S11 (related) | — |
| `lib/core/router/route_handler.dart` | — | — |
| `lib/features/auth/vm/login.vm.dart` | V-S01 | — |
| `lib/features/auth/vm/forgot_password.vm.dart` | V-S07 (related) | — |
| `lib/features/attendance/vm/attendance.vm.dart` | V-D01 | BUG-06, BUG-07 |
| `lib/features/attendance/views/attendance_screen.dart` | — | BUG-15 |
| `lib/features/beat_plan/vm/beat_plan.vm.dart` | V-S02, V-D01 | BUG-02 |
| `lib/features/catalog/vm/catalog_item.vm.dart` | V-D01 | BUG-15 |
| `lib/features/collection/vm/collection.vm.dart` | V-S06, V-D01 | — |
| `lib/features/collection/vm/add_collection.vm.dart` | V-D01 | — |
| `lib/features/collection/vm/edit_collection.vm.dart` | V-O01, V-D01 | BUG-10 |
| `lib/features/expense-claim/vm/expense_claims.vm.dart` | V-O02, V-D01 | — |
| `lib/features/expense-claim/vm/expense_claim_add.vm.dart` | V-D01 | BUG-11 |
| `lib/features/expense-claim/vm/expense_claim_edit.vm.dart` | V-O06 (related), V-D01 | — |
| `lib/features/invoice/vm/invoice.vm.dart` | V-D01 | BUG-01, BUG-05, BUG-21 |
| `lib/features/invoice/vm/invoice_draft_vm.dart` | — | BUG-13 |
| `lib/features/invoice/views/invoice_screen.dart` | V-S03 | — |
| `lib/features/leave/vm/leave.vm.dart` | V-O02, V-D01 | — |
| `lib/features/miscellaneous/vm/miscellaneous_list.vm.dart` | V-D01 | BUG-04 |
| `lib/features/miscellaneous/vm/miscellaneous_edit.vm.dart` | V-S08 | — |
| `lib/features/miscellaneous/views/miscellaneous_list_screen.dart` | — | BUG-18 |
| `lib/features/notes/vm/notes.vm.dart` | V-D01 | — |
| `lib/features/odometer/vm/odometer.vm.dart` | V-D01 | BUG-08 |
| `lib/features/onboarding/vm/onboarding.vm.dart` | V-L02 | BUG-03 |
| `lib/features/parties/vm/parties.vm.dart` | V-D01 | — |
| `lib/features/parties/vm/add_party.vm.dart` | V-S07, V-D01 | — |
| `lib/features/parties/vm/edit_party.vm.dart` | V-S07, V-D01 | — |
| `lib/features/parties/vm/party_image.vm.dart` | V-S05 | — |
| `lib/features/parties/views/add_party_screen.dart` | — | BUG-20 |
| `lib/features/profile/vm/profile.vm.dart` | V-S10, V-D05 | BUG-09, BUG-14 |
| `lib/features/prospects/vm/prospects.vm.dart` | V-D01 | — |
| `lib/features/prospects/vm/add_prospect.vm.dart` | V-S07 | — |
| `lib/features/prospects/vm/prospect_images.vm.dart` | V-S05 | BUG-12 |
| `lib/features/settings/vm/change_password_vm.dart` | — | BUG-17 |
| `lib/features/sites/vm/sites_images.vm.dart` | V-I02, V-D02 | — |
| `lib/features/sites/vm/edit_site_details.vm.dart` | V-S04, V-D01 | — |
| `lib/features/sites/vm/add_sites.vm.dart` | V-S07 | — |
| `lib/features/splash/vm/splash.vm.dart` | V-L03 | BUG-22 |
| `lib/features/tour_plan/vm/add_tour.vm.dart` | V-O06 | — |
| `lib/features/tour_plan/vm/edit_tour.vm.dart` | V-O06 | BUG-19 |
| `lib/features/tour_plan/views/tour_plan_screen.dart` | V-O03 | — |
| `lib/features/tour_plan/views/edit_tour_details_screen.dart` | V-O04 | — |
| `lib/features/tour_plan/models/tour_plan.model.dart` | — | BUG-23 |
| `lib/features/miscellaneous/vm/miscellaneous_add.vm.dart` | V-D04 | — |

---

*Generated by SOLID Compliance Audit — SalesSphere v1.0*
