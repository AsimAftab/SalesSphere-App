# Offline-First Architecture — SalesSphere Mobile App

> **Version:** 1.0
> **Date:** March 2026
> **Scope:** Comprehensive analysis and migration plan for offline-first capabilities in the SalesSphere Flutter application.

---

## Table of Contents

1. [Current State Audit](#1-current-state-audit)
2. [Database Comparison & Recommendation](#2-database-comparison--recommendation)
3. [Feature-by-Feature Offline Tier Classification](#3-feature-by-feature-offline-tier-classification)
4. [Architecture Design](#4-architecture-design)
5. [Backend API Requirements](#5-backend-api-requirements)
6. [Sync Strategy](#6-sync-strategy)
7. [Phased Implementation Roadmap](#7-phased-implementation-roadmap)
8. [New File Structure](#8-new-file-structure)

---

## 1. Current State Audit

### What Works Offline Today

| Component | Offline Capability | Implementation |
|---|---|---|
| Beat plan location tracking | Full offline queue + sync | Hive box `queued_locations`, `OfflineQueueService`, batch sync (10 locations), 3 retries |
| Background tracking service | Runs in separate isolate | `flutter_background_service` foreground service, notification ID 888 |
| Reverse geocoding in background | 5-second non-blocking timeout | Falls back gracefully if geocoding fails |
| Auth session persistence | Token + user data cached | `TokenStorageService` via SharedPreferences |
| Permission/subscription cache | Loaded from storage on startup | `PermissionController` reads from `TokenStorageService` on build |
| Theme/settings preferences | Fully local | SharedPreferences via `StorageKeys` constants |

### What Blocks When Offline

| Component | Blocking Behavior | Code Location |
|---|---|---|
| **ConnectivityInterceptor** | Rejects ALL Dio requests with `OfflineException` when `ConnectivityResult.none` is detected. First interceptor in chain — no request ever reaches the server. | `lib/core/network_layer/interceptors/connectivity_interceptor.dart` |
| **GlobalConnectivityWrapper** | Wraps entire app; replaces all screens with full-screen `NoInternetScreen` when offline. Auto-invalidates all providers when connectivity returns. | `lib/core/utils/connectivity_utils.dart` |
| **NoInternetScreen** | Modal overlay with "Ooops!" message, retry button that invalidates `appStartupProvider`. User cannot interact with any feature. | `lib/widget/no_internet_screen.dart` |
| **ErrorHandlerWidget** | Detects `OfflineException` (direct or wrapped in `DioException`) and renders `NoInternetScreen` inline. | `lib/widget/error_handler_widget.dart` |

### Key Insight

The app has a **binary online/offline model**: everything works or nothing works. The only exception is beat plan tracking, which has its own dedicated Hive-based offline queue that bypasses the Dio interceptor chain entirely (locations are sent via WebSocket, not REST). Every other feature — including viewing previously loaded data — is blocked by `GlobalConnectivityWrapper`.

### Current Data Flow (Online-Only)

```
User Action → ViewModel (AsyncNotifier) → Dio Client → ConnectivityInterceptor → AuthInterceptor → API Server
                                                ↓ (if offline)
                                         OfflineException → ErrorHandlerWidget → NoInternetScreen
```

### Target Data Flow (Offline-First)

```
User Action → ViewModel → Repository → CacheInterceptor (check local DB)
                                              ↓ (cache hit)                    ↓ (cache miss / stale)
                                        Return cached data              Dio Client → API Server
                                                                              ↓ (response)
                                                                     Update local DB + return data
                                                                              ↓ (if offline)
                                                                     Queue write in SyncQueue
```

---

## 2. Database Comparison & Recommendation

### Candidates Evaluated

| Criteria | Drift (SQLite) | Isar | ObjectBox | Hive |
|---|---|---|---|---|
| **Data model** | Relational (SQL tables, joins, foreign keys) | NoSQL (collections, links) | NoSQL (entities, relations via IDs) | Key-value (boxes, no relations) |
| **Query capability** | Full SQL — JOINs, aggregates, subqueries, window functions | Custom query API, composite indexes, full-text search | Custom query API, property queries | Basic key/value lookup, no queries |
| **Code generation** | `build_runner` (same as Freezed/Riverpod) | `build_runner` | `build_runner` | `build_runner` (optional) |
| **Background isolate** | Native isolate support via `NativeDatabase` | Isolate support | Thread-safe | Requires path passing to isolate (already done for tracking) |
| **Schema migration** | Built-in versioned migrations with `MigrationStrategy` | Auto-migration | Auto-migration | No schema concept |
| **Bundle size impact** | ~1.5 MB (SQLite is already in Flutter engine on iOS/Android) | ~2.5 MB native library | ~3 MB native library | ~200 KB (pure Dart) |
| **Maturity** | SQLite: decades; Drift: actively maintained, v2.x stable | Maintainer stepped back in 2024, uncertain future | Commercial (ObjectBox GmbH), stable | Stable but limited feature set |
| **Encryption** | Via `sqlcipher_flutter_libs` | Built-in | Not built-in | Via `hive_flutter` AES |
| **Reactive streams** | `watch()` on queries → streams | `watchLazy()` / `watchObject()` | Data observers | `watch()` on boxes |
| **Complex queries** | Excellent — date ranges, pagination, multi-field search, aggregates | Good — composite indexes | Good — property-based | Poor — manual filtering |
| **Pub.dev score** | 160 likes, actively maintained | 130 likes, maintenance uncertain | 90 likes, commercial | 150 likes, stable |

### Recommendation: **Drift (SQLite)**

**Rationale:**

1. **Relational data fits naturally.** SalesSphere has clear relational structures:
   - Invoices → InvoiceItems → Products
   - Collections → Parties
   - Expense Claims → Categories
   - Beat Plans → Directories → Visits

   SQL JOINs and foreign keys model these relationships correctly. NoSQL alternatives would require denormalization or manual relationship management.

2. **Complex query requirements.** The app needs:
   - Multi-field search (parties by name, phone, GST, PAN)
   - Date range filtering (attendance monthly reports, invoice history)
   - Pagination with sorting (all list screens)
   - Aggregates (dashboard counts, collection totals)

   Drift provides full SQL for these. Hive would require loading entire datasets into memory and filtering in Dart.

3. **Existing build_runner pipeline.** The project already uses `build_runner` for Freezed models, Riverpod generators, and JSON serialization. Drift integrates into the same pipeline with zero tooling overhead.

4. **Background isolate support.** Beat plan tracking runs in a background isolate via `flutter_background_service`. Drift's `NativeDatabase` works natively across isolates. The current Hive approach requires manually passing the Hive path through SharedPreferences — Drift eliminates this workaround.

5. **Long-term viability.** SQLite is the most battle-tested embedded database (30+ years). Drift is actively maintained by Simon Binder. Isar's maintainer reducing involvement in 2024 makes it risky for a production app. ObjectBox is commercial with potential licensing constraints.

6. **Migration support.** Drift provides `MigrationStrategy` with `onCreate`, `onUpgrade`, and versioned schema changes. Critical for a production app that will evolve over time.

### What to Keep

- **Keep Hive** for the beat plan location queue (`queued_locations` box). It's proven, works in background isolates, and the `QueuedLocation` model + `OfflineQueueService` are battle-tested. Migrating this to Drift adds risk with no benefit.
- **Keep SharedPreferences** for simple key-value settings (theme, language, onboarding flags, auth tokens). No reason to move these to a database.

### Dependency Addition

```yaml
# pubspec.yaml
dependencies:
  drift: ^2.22.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.5  # already present
  path: ^1.9.0

dev_dependencies:
  drift_dev: ^2.22.0
  build_runner: ^2.4.0   # already present
```

---

## 3. Feature-by-Feature Offline Tier Classification

### Tier Definitions

| Tier | Reads | Writes | Sync Behavior | User Experience |
|---|---|---|---|---|
| **Tier 1: Cache-only** | Served from local DB (stale-while-revalidate) | Require network — show "offline" toast if attempted | Background refresh when online | Can browse cached data offline; cannot create/edit |
| **Tier 2: Full offline** | Served from local DB | Queued locally with optimistic UI, synced when online | Write queue with conflict resolution | Full CRUD offline; pending items shown with sync indicator |
| **Tier 3: Online-only** | Always from server | Always from server | No local persistence | Blocked when offline (with clear messaging, not full-screen block) |

### Classification Table

| # | Feature | Module ID | Tier | Reads Offline | Writes Offline | Rationale |
|---|---|---|---|---|---|---|
| 1 | **Dashboard/Home** | `dashboard` | Tier 1 | Cached summary metrics | N/A (read-only) | Dashboard data is aggregated server-side; cache last-known state |
| 2 | **Catalog (Products)** | `products` | Tier 1 | Full product list + categories cached | No (admin manages products) | Products rarely change; field reps only browse catalog |
| 3 | **Invoices** | `invoices` | Tier 1 | Invoice list + details cached | No — server-generated sequential numbers | Invoice numbers must be sequential and server-assigned to prevent conflicts across multiple reps |
| 4 | **Estimates** | `estimates` | Tier 1 | Estimate list + details cached | No — same sequential numbering constraint | Same server-side numbering as invoices |
| 5 | **Parties** | `parties` | Tier 1 | Full party list + details cached | No — shared resource across reps | Parties are assigned by admin; concurrent edits by multiple users would cause conflicts |
| 6 | **Prospects** | `prospects` | Tier 2 | Full prospect list + details cached | Create + edit queued offline | Prospects are typically owned by a single rep; low conflict risk; field reps need to add prospects during site visits |
| 7 | **Sites** | `sites` | Tier 2 | Full site list + details cached | Create + edit queued offline | Sites are typically created by a single rep during field work; same rationale as prospects |
| 8 | **Collections** | `collections` | Tier 2 | Collection list + details cached | Create + edit queued offline | Payment collection happens in the field; reps need to record immediately; `my-collections` scope means single-user writes |
| 9 | **Expense Claims** | `expenses` | Tier 2 | Expense list + categories cached | Create + edit queued offline | Expenses are personal to each rep; no multi-user conflict; categories are reference data |
| 10 | **Notes** | `notes` | Tier 2 | Notes list cached | Create + edit queued offline | Notes are personal (`my-notes`); simplest offline candidate — text-only, single-user |
| 11 | **Miscellaneous Work** | `miscellaneousWork` | Tier 2 | Work list cached | Create + edit queued offline | Personal work items (`my-work`); same pattern as notes with image support |
| 12 | **Leave Requests** | `leaves` | Tier 2 | Leave list cached | Create queued offline (edit limited) | Leave requests are personal; approval happens server-side; creating offline is safe |
| 13 | **Tour Plans** | `tourPlan` | Tier 1 | Tour plan list cached | No — requires admin approval workflow | Tour plans involve date coordination; caching reads is sufficient |
| 14 | **Attendance** | `attendance` | Tier 3 | Today's status cached briefly | Check-in/out: **online-only** | Server-side geofence validation for check-in/out is security-critical; cannot be faked client-side |
| 15 | **Attendance History** | `attendance` | Tier 1 | Monthly reports + search results cached | N/A (read-only) | Historical data doesn't change; safe to cache |
| 16 | **Beat Plan** | `beatPlan` | Tier 1 + existing | Beat plan list + details cached | Visit marking: **online-only** (geofence); Location tracking: already offline via Hive | Visit marking requires server-side geofence validation; location tracking already works offline |
| 17 | **Odometer** | `odometer` | Tier 3 | Today's status cached briefly | Start/stop: **online-only** | Odometer readings are time-sensitive with image uploads; server validates sequencing |
| 18 | **Profile** | — | Tier 1 | Profile data cached | Profile image upload: online-only | Profile is loaded from `TokenStorageService` cache already |
| 19 | **Settings** | — | Tier 1 | Fully local (SharedPreferences) | Fully local | Already works offline |
| 20 | **Auth** | — | Tier 3 | N/A | Login/logout: online-only | Authentication requires server validation |
| 21 | **Onboarding/Splash** | — | Already offline | Fully local | Fully local | No API calls |

### Endpoint-to-Tier Mapping

#### Tier 1 Endpoints (Cache Reads)

| Feature | Endpoint | Method | Cache Strategy |
|---|---|---|---|
| Dashboard | `/api/v1/home` | GET | Cache 5 min, stale-while-revalidate |
| Catalog | `/api/v1/categories` | GET | Cache 1 hour, refresh on pull-to-refresh |
| Catalog | `/api/v1/products` | GET | Cache 1 hour, incremental sync |
| Catalog | `/api/v1/categories/{id}` | GET | Cache 1 hour |
| Invoices | `/api/v1/invoices` | GET | Cache 15 min, paginated |
| Invoices | `/api/v1/invoices/{id}` | GET | Cache 15 min |
| Estimates | `/api/v1/invoices/estimates` | GET | Cache 15 min |
| Estimates | `/api/v1/invoices/estimates/{id}` | GET | Cache 15 min |
| Tax Config | `/api/v1/tax-configs` | GET | Cache 24 hours (rarely changes) |
| Parties | `/api/v1/parties/my-assigned` | GET | Cache 30 min, incremental sync |
| Parties | `/api/v1/parties/{id}` | GET | Cache 30 min |
| Parties | `/api/v1/parties/types` | GET | Cache 24 hours (reference data) |
| Tour Plans | `/api/v1/tour-plans/my-tour-plans` | GET | Cache 30 min |
| Tour Plans | `/api/v1/tour-plans/{id}` | GET | Cache 30 min |
| Beat Plans | `/api/v1/beat-plans/my-beatplans` | GET | Cache 30 min |
| Beat Plans | `/api/v1/beat-plans/{id}/details` | GET | Cache 30 min |
| Attendance | `/api/v1/attendance/my-monthly-report` | GET | Cache 1 hour |
| Attendance | `/api/v1/attendance/search` | GET | Cache 15 min |
| Profile | `/api/v1/users/me` | GET | Cache indefinitely (refresh on explicit action) |
| Notifications | `/api/v1/notifications` | GET | Cache 5 min |

#### Tier 2 Endpoints (Cache Reads + Queue Writes)

| Feature | Endpoint | Method | Offline Behavior |
|---|---|---|---|
| Prospects | `/api/v1/prospects` | GET | Cache 30 min, incremental sync |
| Prospects | `/api/v1/prospects/{id}` | GET | Cache 30 min |
| Prospects | `/api/v1/prospects` | POST | Queue locally, sync when online |
| Prospects | `/api/v1/prospects/{id}` | PUT | Queue locally, sync when online |
| Prospects | `/api/v1/prospects/categories` | GET | Cache 24 hours (reference data) |
| Sites | `/api/v1/sites` | GET | Cache 30 min, incremental sync |
| Sites | `/api/v1/sites/{id}` | GET | Cache 30 min |
| Sites | `/api/v1/sites` | POST | Queue locally, sync when online |
| Sites | `/api/v1/sites/{id}` | PUT | Queue locally, sync when online |
| Sites | `/api/v1/sites/sub-organizations` | GET | Cache 24 hours (reference data) |
| Sites | `/api/v1/sites/categories` | GET | Cache 24 hours (reference data) |
| Collections | `/api/v1/collections/my-collections` | GET | Cache 15 min |
| Collections | `/api/v1/collections/{id}` | GET | Cache 15 min |
| Collections | `/api/v1/collections` | POST | Queue locally, sync when online |
| Collections | `/api/v1/collections/{id}` | PUT | Queue locally, sync when online |
| Collections | `/api/v1/collections/utils/bank-names` | GET | Cache 24 hours (reference data) |
| Expenses | `/api/v1/expense-claims` | GET | Cache 15 min |
| Expenses | `/api/v1/expense-claims/{id}` | GET | Cache 15 min |
| Expenses | `/api/v1/expense-claims` | POST | Queue locally, sync when online |
| Expenses | `/api/v1/expense-claims/{id}` | PUT | Queue locally, sync when online |
| Expenses | `/api/v1/expense-claims/categories` | GET | Cache 24 hours (reference data) |
| Notes | `/api/v1/notes/my-notes` | GET | Cache 15 min |
| Notes | `/api/v1/notes/{id}` | GET | Cache 15 min |
| Notes | `/api/v1/notes` | POST | Queue locally, sync when online |
| Notes | `/api/v1/notes/{id}` | PUT | Queue locally, sync when online |
| Misc Work | `/api/v1/miscellaneous-work/my-work` | GET | Cache 15 min |
| Misc Work | `/api/v1/miscellaneous-work/{id}` | GET | Cache 15 min |
| Misc Work | `/api/v1/miscellaneous-work` | POST | Queue locally, sync when online |
| Misc Work | `/api/v1/miscellaneous-work/{id}` | PUT | Queue locally, sync when online |
| Leaves | `/api/v1/leave-requests/my-requests` | GET | Cache 15 min |
| Leaves | `/api/v1/leave-requests` | POST | Queue locally, sync when online |

#### Tier 3 Endpoints (Online-Only)

| Feature | Endpoint | Method | Reason |
|---|---|---|---|
| Auth | `/api/v1/auth/login` | POST | Server auth required |
| Auth | `/api/v1/auth/logout` | POST | Server session cleanup |
| Auth | `/api/v1/auth/refresh` | POST | Token validation |
| Auth | `/api/v1/auth/forgotpassword` | POST | Email delivery |
| Attendance | `/api/v1/attendance/check-in` | POST | Geofence validation |
| Attendance | `/api/v1/attendance/check-out` | POST | Geofence validation |
| Beat Plan | `/api/v1/beat-plans/{id}/start` | POST | Server session start |
| Beat Plan | `/api/v1/beat-plans/{id}/stop` | POST | Server session close |
| Beat Plan | `/api/v1/beat-plans/{beatPlanId}/visit` | POST | Geofence validation |
| Odometer | `/api/v1/odometer/start` | POST | Time-stamped with image |
| Odometer | `/api/v1/odometer/stop` | POST | Time-stamped with image |
| Invoice | `/api/v1/invoices` | POST | Sequential number generation |
| Invoice | `/api/v1/invoices/{id}` | PUT | Financial record integrity |
| Estimate | `/api/v1/invoices/estimates` | POST | Sequential number generation |
| Estimate | `/api/v1/invoices/estimates/{id}/convert` | POST | Creates invoice (sequential) |
| Profile | `/api/v1/users/me/profile-image` | POST | Image upload |
| Profile | `/api/v1/users/me/password` | PUT | Security-critical |
| Upload | `/api/v1/upload/image` | POST | File transfer |
| Upload | `/api/v1/upload/file` | POST | File transfer |
| Notifications | `/api/v1/notifications/read` | PUT | Real-time state |

#### Image Upload Endpoints (Queue Separately)

| Feature | Endpoint | Offline Behavior |
|---|---|---|
| Prospects | `/api/v1/prospects/{id}/images` | Queue image file + metadata; upload after text sync completes |
| Sites | `/api/v1/sites/{siteId}/images` | Queue image file + metadata; upload after text sync completes |
| Collections | `/api/v1/collections/{collectionId}/images` | Queue image file + metadata |
| Expenses | `/api/v1/expense-claims/{id}/receipt` | Queue receipt image |
| Notes | `/api/v1/notes/{noteId}/images` | Queue image file + metadata |
| Misc Work | `/api/v1/miscellaneous-work/{workId}/images` | Queue image file + metadata |
| Parties | `/api/v1/parties/{partyId}/image` | Online-only (Tier 1 feature) |

---

## 4. Architecture Design

### 4.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        UI Layer (Views)                         │
│              (No changes to existing screens)                   │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                    ViewModel Layer                               │
│         (AsyncNotifiers — minimal changes)                       │
│    Change: Read from Repository instead of Dio directly          │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                    Repository Layer (NEW)                        │
│    ┌──────────────┐  ┌───────────────┐  ┌────────────────────┐  │
│    │ CacheStrategy│  │ SyncQueueSvc  │  │ ConflictResolver   │  │
│    │ (per entity) │  │ (write queue) │  │ (server-wins/merge)│  │
│    └──────┬───────┘  └───────┬───────┘  └────────┬───────────┘  │
│           │                  │                    │              │
│    ┌──────▼──────────────────▼────────────────────▼───────────┐  │
│    │              Drift Database (SQLite)                     │  │
│    │  ┌─────────┐ ┌──────────┐ ┌───────────┐ ┌────────────┐ │  │
│    │  │ Tables  │ │ SyncQueue│ │ CacheMeta │ │ ImageQueue │ │  │
│    │  └─────────┘ └──────────┘ └───────────┘ └────────────┘ │  │
│    └─────────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                    Network Layer (existing)                      │
│    Dio Client → [CacheInterceptor (NEW)] → ConnectivityInt.     │
│              → AuthInterceptor → ErrorInterceptor               │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 CacheInterceptor

A new Dio interceptor inserted **before** `ConnectivityInterceptor` in the chain. It intercepts GET requests for cacheable endpoints, serves from local DB when offline, and updates the cache when online responses arrive.

```dart
// lib/core/offline/cache_interceptor.dart

class CacheInterceptor extends Interceptor {
  final AppDatabase db;
  final CacheConfigRegistry registry;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method != 'GET') {
      handler.next(options);
      return;
    }

    final config = registry.getConfig(options.path);
    if (config == null) {
      handler.next(options);
      return;
    }

    // Check if cache is fresh
    final cached = db.getCachedResponse(options.uri.toString());
    if (cached != null && !cached.isStale(config.maxAge)) {
      // Return cached data immediately
      handler.resolve(Response(
        requestOptions: options,
        data: cached.data,
        statusCode: 200,
        headers: Headers.fromMap({'x-cache': ['HIT']}),
      ));

      // Optionally trigger background revalidation (stale-while-revalidate)
      if (cached.isStale(config.softMaxAge)) {
        _revalidateInBackground(options);
      }
      return;
    }

    handler.next(options); // No cache or stale → proceed to network
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method == 'GET') {
      final config = registry.getConfig(response.requestOptions.path);
      if (config != null) {
        // Store response in cache with ETag/Last-Modified if present
        db.upsertCachedResponse(
          url: response.requestOptions.uri.toString(),
          data: response.data,
          etag: response.headers.value('etag'),
          lastModified: response.headers.value('last-modified'),
        );
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is OfflineException) {
      // Try to serve stale cache when offline
      final cached = db.getCachedResponse(err.requestOptions.uri.toString());
      if (cached != null) {
        handler.resolve(Response(
          requestOptions: err.requestOptions,
          data: cached.data,
          statusCode: 200,
          headers: Headers.fromMap({'x-cache': ['STALE']}),
        ));
        return;
      }
    }
    handler.next(err);
  }
}
```

**Updated interceptor order:**

1. **CacheInterceptor** (NEW) — serves cached GET responses, bypasses network when cache is fresh
2. **ConnectivityInterceptor** — blocks non-cached requests when offline
3. **AuthInterceptor** — adds JWT, handles 401 refresh
4. **PrettyDioLogger** — debug logging
5. **LoggingInterceptor** — custom logging
6. **ErrorInterceptor** — error transformation

### 4.3 Repository Layer

Each feature gets a repository that mediates between the ViewModel and both the local database and remote API.

```dart
// lib/core/offline/base_repository.dart

abstract class BaseRepository<T> {
  final AppDatabase db;
  final Dio dio;
  final SyncQueueService syncQueue;

  /// Read with cache-first strategy
  Future<List<T>> getAll({bool forceRefresh = false});

  /// Read single item
  Future<T?> getById(String id);

  /// Create with offline queue
  Future<T> create(Map<String, dynamic> data) {
    if (await _isOnline()) {
      final response = await dio.post(endpoint, data: data);
      final item = fromJson(response.data);
      await db.upsert(tableName, item);
      return item;
    } else {
      final tempId = Uuid().v4();
      final item = fromJson({...data, '_id': tempId, '_pendingSync': true});
      await db.upsert(tableName, item);
      await syncQueue.enqueue(SyncOperation(
        id: tempId,
        type: SyncType.create,
        endpoint: endpoint,
        data: data,
        tableName: tableName,
        createdAt: DateTime.now(),
      ));
      return item;
    }
  }

  /// Update with offline queue
  Future<T> update(String id, Map<String, dynamic> data);
}
```

**Example: NotesRepository**

```dart
// lib/features/notes/repository/notes_repository.dart

class NotesRepository extends BaseRepository<Note> {
  @override
  String get endpoint => '/api/v1/notes';

  @override
  String get tableName => 'notes';

  @override
  String get listEndpoint => '/api/v1/notes/my-notes';

  @override
  Future<List<Note>> getAll({bool forceRefresh = false}) async {
    // 1. Return cached notes immediately
    final cached = await db.getAllNotes();
    if (cached.isNotEmpty && !forceRefresh) {
      _refreshInBackground(); // Stale-while-revalidate
      return cached;
    }

    // 2. Fetch from network
    try {
      final response = await dio.get(listEndpoint);
      final notes = (response.data['data'] as List)
          .map((j) => Note.fromJson(j))
          .toList();
      await db.replaceAllNotes(notes);
      return notes;
    } on DioException catch (e) {
      if (e.error is OfflineException && cached.isNotEmpty) {
        return cached; // Serve stale cache when offline
      }
      rethrow;
    }
  }
}
```

### 4.4 SyncQueueService

Manages a queue of pending write operations (creates, updates, deletes) that need to sync to the server.

```dart
// lib/core/offline/sync_queue_service.dart

/// Drift table for sync operations
class SyncQueue extends Table {
  TextColumn get id => text()();           // UUID
  TextColumn get type => text()();         // create | update | delete
  TextColumn get endpoint => text()();     // API path
  TextColumn get method => text()();       // POST | PUT | DELETE
  TextColumn get data => text()();         // JSON payload
  TextColumn get tableName => text()();    // local table to update after sync
  TextColumn get entityId => text()();     // ID of entity (temp for create, real for update)
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get maxRetries => integer().withDefault(const Constant(5))();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get idempotencyKey => text()();  // For server-side dedup

  @override
  Set<Column> get primaryKey => {id};
}
```

**Sync execution flow:**

```dart
class SyncQueueService {
  static const int _batchSize = 10;
  static const int _maxRetries = 5;

  /// Process all pending operations in priority order
  Future<SyncResult> processQueue() async {
    final pending = await db.getPendingSyncOps(limit: _batchSize);

    int synced = 0, failed = 0, skipped = 0;

    for (final op in pending) {
      if (op.retryCount >= _maxRetries) {
        await db.updateSyncStatus(op.id, 'failed');
        failed++;
        continue;
      }

      try {
        final response = await _executeOp(op);

        if (op.type == 'create') {
          // Replace temp ID with server-assigned ID in local DB
          final serverId = response.data['data']['_id'];
          await db.replaceTempId(op.tableName, op.entityId, serverId);
          // Update any queued operations that reference this temp ID
          await db.updateQueuedReferences(op.entityId, serverId);
        }

        await db.updateSyncStatus(op.id, 'synced');
        synced++;
      } on DioException catch (e) {
        if (e.response?.statusCode == 409) {
          // Conflict — server has newer version
          await _handleConflict(op, e.response!);
        } else {
          await db.incrementRetry(op.id, e.message);
          failed++;
        }
      }
    }

    return SyncResult(synced: synced, failed: failed, remaining: await db.pendingCount());
  }

  Future<Response> _executeOp(SyncOperation op) {
    return dio.request(
      op.endpoint,
      data: jsonDecode(op.data),
      options: Options(
        method: op.method,
        headers: {'Idempotency-Key': op.idempotencyKey},
      ),
    );
  }
}
```

### 4.5 Conflict Resolution

```dart
// lib/core/offline/conflict_resolver.dart

enum ConflictStrategy {
  serverWins,     // Default — discard local changes, accept server version
  clientWins,     // Overwrite server with local (dangerous, rarely used)
  merge,          // Field-level merge (for compatible changes)
  askUser,        // Show conflict UI and let user decide
}

class ConflictResolver {
  /// Default strategy per entity type
  static const Map<String, ConflictStrategy> _strategies = {
    'notes': ConflictStrategy.serverWins,       // Simple, low-risk
    'collections': ConflictStrategy.serverWins,  // Financial data — server is authority
    'expense_claims': ConflictStrategy.serverWins,
    'prospects': ConflictStrategy.merge,         // Allow field-level merge
    'sites': ConflictStrategy.merge,
    'leaves': ConflictStrategy.serverWins,
    'misc_work': ConflictStrategy.serverWins,
  };

  Future<void> resolve(SyncOperation op, Response serverResponse) async {
    final strategy = _strategies[op.tableName] ?? ConflictStrategy.serverWins;

    switch (strategy) {
      case ConflictStrategy.serverWins:
        // Replace local with server version
        final serverData = serverResponse.data['data'];
        await db.upsert(op.tableName, serverData);
        await db.updateSyncStatus(op.id, 'conflict_resolved');
        break;

      case ConflictStrategy.merge:
        // Compare field-by-field, keep non-conflicting local changes
        final serverData = serverResponse.data['data'];
        final localData = jsonDecode(op.data);
        final merged = _fieldLevelMerge(localData, serverData);
        await db.upsert(op.tableName, merged);
        // Re-queue as update with merged data
        await syncQueue.enqueue(SyncOperation(
          type: SyncType.update,
          endpoint: '${op.endpoint}/${serverData['_id']}',
          data: merged,
        ));
        break;

      case ConflictStrategy.askUser:
        // Store conflict for user review
        await db.insertConflict(op, serverResponse.data);
        break;
    }
  }
}
```

### 4.6 Image Queue

Images are large and must be handled separately from text data sync.

```dart
// lib/core/offline/image_queue_service.dart

/// Drift table for pending image uploads
class ImageQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();      // 'note', 'prospect', 'site', etc.
  TextColumn get entityId => text()();        // Could be temp ID
  TextColumn get localPath => text()();       // Path in app's documents directory
  TextColumn get uploadEndpoint => text()();  // API endpoint
  IntColumn get imageNumber => integer().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class ImageQueueService {
  /// Queue an image for upload after entity sync
  Future<void> queueImage({
    required String entityType,
    required String entityId,
    required File imageFile,
    required String uploadEndpoint,
    int? imageNumber,
  }) async {
    // Copy image to app's persistent directory (survives cache clears)
    final appDir = await getApplicationDocumentsDirectory();
    final queueDir = Directory('${appDir.path}/image_queue');
    await queueDir.create(recursive: true);
    final savedFile = await imageFile.copy('${queueDir.path}/${Uuid().v4()}.jpg');

    await db.insertImageQueueEntry(ImageQueueEntry(
      id: Uuid().v4(),
      entityType: entityType,
      entityId: entityId,
      localPath: savedFile.path,
      uploadEndpoint: uploadEndpoint,
      imageNumber: imageNumber,
      createdAt: DateTime.now(),
    ));
  }

  /// Process pending image uploads
  /// MUST run after SyncQueueService (entity IDs must be resolved)
  Future<void> processQueue() async {
    final pending = await db.getPendingImages();

    for (final entry in pending) {
      // Check if entity has been synced (temp ID replaced with server ID)
      final resolvedId = await db.getResolvedEntityId(entry.entityType, entry.entityId);
      if (resolvedId == null) continue; // Entity not synced yet, skip

      final endpoint = entry.uploadEndpoint.replaceAll(entry.entityId, resolvedId);

      try {
        final formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(entry.localPath),
        });
        await dio.post(endpoint, data: formData);
        await db.updateImageStatus(entry.id, 'synced');
        // Delete local copy after successful upload
        await File(entry.localPath).delete();
      } catch (e) {
        await db.incrementImageRetry(entry.id);
      }
    }
  }
}
```

### 4.7 GlobalConnectivityWrapper Changes

The most impactful UX change: replace the full-screen block with a non-intrusive banner.

**Current behavior:** `GlobalConnectivityWrapper` shows `NoInternetScreen` (full overlay) → user is completely blocked.

**New behavior:**
- Remove `GlobalConnectivityWrapper` full-screen overlay
- Show `ConnectivityBanner` (already exists in `lib/widget/connectivity_banner.dart`) at the top of the screen
- Allow navigation and interaction with cached data
- Show inline "offline" indicators on write-capable forms
- Only show `NoInternetScreen` for Tier 3 features when offline

```dart
// Changes to lib/core/utils/connectivity_utils.dart

class GlobalConnectivityWrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(hasConnectivityProvider);

    return Column(
      children: [
        // Non-intrusive banner instead of full-screen overlay
        if (!connectivity) const ConnectivityBanner(),
        Expanded(child: child),
      ],
    );
  }
}
```

### 4.8 Drift Database Schema

```dart
// lib/core/offline/database/app_database.dart

@DriftDatabase(tables: [
  // Cache metadata
  CacheEntries,

  // Sync infrastructure
  SyncQueue,
  ImageQueue,

  // Tier 1 cached data (read-only)
  CachedProducts,
  CachedCategories,
  CachedParties,
  CachedPartyTypes,
  CachedInvoices,
  CachedEstimates,
  CachedTaxConfigs,
  CachedTourPlans,
  CachedBeatPlans,
  CachedAttendanceRecords,

  // Tier 2 data (read + write)
  CachedProspects,
  CachedProspectCategories,
  CachedSites,
  CachedSiteCategories,
  CachedSubOrganizations,
  CachedCollections,
  CachedBankNames,
  CachedExpenseClaims,
  CachedExpenseCategories,
  CachedNotes,
  CachedMiscWork,
  CachedLeaveRequests,

  // Dashboard
  CachedDashboard,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    onUpgrade: (m, from, to) async {
      // Versioned migrations for future schema changes
    },
  );
}
```

**Example table definition:**

```dart
// lib/core/offline/database/tables/cached_notes.dart

class CachedNotes extends Table {
  TextColumn get id => text()();                    // Server _id or temp UUID
  TextColumn get title => text()();
  TextColumn get content => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get images => text().nullable()();     // JSON array of image URLs
  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  // synced | pending_create | pending_update | pending_delete | conflict
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get serverVersion => text().nullable()(); // ETag or version number

  @override
  Set<Column> get primaryKey => {id};
}
```

### 4.9 Pending Sync UI Indicators

Items created or modified offline should be visually distinct:

```dart
// lib/widget/sync_status_indicator.dart

class SyncStatusIndicator extends StatelessWidget {
  final String syncStatus; // 'synced' | 'pending_create' | 'pending_update' | 'conflict'

  @override
  Widget build(BuildContext context) {
    switch (syncStatus) {
      case 'pending_create':
      case 'pending_update':
        return Icon(Icons.cloud_upload_outlined, size: 16, color: Colors.orange);
      case 'conflict':
        return Icon(Icons.warning_amber, size: 16, color: Colors.red);
      case 'synced':
      default:
        return SizedBox.shrink(); // No indicator for synced items
    }
  }
}
```

---

## 5. Backend API Requirements

### 5.1 ETag / Last-Modified Headers

**Required on all GET endpoints for Tier 1 and Tier 2 resources.**

The server must return cache validation headers so the client can make conditional requests and avoid re-downloading unchanged data.

```
# Response headers to add:
ETag: "abc123hash"
Last-Modified: Wed, 03 Mar 2026 10:15:00 GMT

# Client sends conditional request:
If-None-Match: "abc123hash"
If-Modified-Since: Wed, 03 Mar 2026 10:15:00 GMT

# Server responds:
304 Not Modified (no body) — if data unchanged
200 OK (full body) — if data changed, with new ETag/Last-Modified
```

**Implementation priority (by endpoint):**

| Priority | Endpoints | Reason |
|---|---|---|
| High | `/api/v1/products`, `/api/v1/categories`, `/api/v1/parties/my-assigned` | Large datasets, frequently accessed, rarely change |
| High | `/api/v1/notes/my-notes`, `/api/v1/collections/my-collections` | Tier 2 sync targets |
| Medium | `/api/v1/invoices`, `/api/v1/invoices/estimates` | Paginated, moderate change frequency |
| Low | `/api/v1/home`, `/api/v1/attendance/*` | Short cache TTL anyway |

### 5.2 Idempotency Keys

**Required on all POST/PUT endpoints for Tier 2 resources.**

Prevents duplicate creates when the client retries a failed sync operation (e.g., network dropped after server processed but before client received response).

```
# Client sends:
POST /api/v1/notes
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
Content-Type: application/json

{"title": "Meeting notes", "content": "..."}

# Server behavior:
1. Check if Idempotency-Key exists in idempotency store
2. If exists → return stored response (200 OK, same body)
3. If not → process request, store response keyed by Idempotency-Key, return response
4. Idempotency keys expire after 24 hours
```

**Server implementation requirements:**
- Store `{idempotency_key, response_status, response_body, created_at}` in Redis or database
- TTL: 24 hours (covers worst-case offline duration for field reps)
- Scope: Per-user (same key from different users = different operations)
- Return `409 Conflict` if same key is reused with different request body

**Affected endpoints:**

| Method | Endpoint | Notes |
|---|---|---|
| POST | `/api/v1/prospects` | Create prospect |
| PUT | `/api/v1/prospects/{id}` | Update prospect |
| POST | `/api/v1/sites` | Create site |
| PUT | `/api/v1/sites/{id}` | Update site |
| POST | `/api/v1/collections` | Create collection |
| PUT | `/api/v1/collections/{id}` | Update collection |
| POST | `/api/v1/expense-claims` | Create expense |
| PUT | `/api/v1/expense-claims/{id}` | Update expense |
| POST | `/api/v1/notes` | Create note |
| PUT | `/api/v1/notes/{id}` | Update note |
| POST | `/api/v1/miscellaneous-work` | Create misc work |
| PUT | `/api/v1/miscellaneous-work/{id}` | Update misc work |
| POST | `/api/v1/leave-requests` | Create leave |

### 5.3 Conflict Detection

**Required on all PUT endpoints for Tier 2 resources.**

Server must detect when a client tries to update a resource that has been modified since the client last read it.

```
# Client sends:
PUT /api/v1/notes/abc123
If-Match: "version-etag-from-last-read"
Content-Type: application/json

{"title": "Updated title"}

# Server behavior:
1. Compare If-Match value with current resource ETag/version
2. If match → process update, return 200 with new ETag
3. If mismatch → return 409 Conflict with current server version in body

# 409 Response format:
{
  "success": false,
  "error": "conflict",
  "message": "Resource was modified by another user",
  "serverVersion": { ...current server data... },
  "serverETag": "new-etag-value"
}
```

### 5.4 Bulk Sync Endpoint (Optional, Phase 4)

A single endpoint to sync multiple pending operations in one request, reducing round-trips for field reps returning from long offline periods.

```
POST /api/v1/sync/bulk
Content-Type: application/json

{
  "operations": [
    {
      "idempotencyKey": "uuid-1",
      "method": "POST",
      "endpoint": "/api/v1/notes",
      "data": {"title": "Note 1", "content": "..."}
    },
    {
      "idempotencyKey": "uuid-2",
      "method": "POST",
      "endpoint": "/api/v1/collections",
      "data": {"amountReceived": 5000, "partyId": "..."}
    },
    {
      "idempotencyKey": "uuid-3",
      "method": "PUT",
      "endpoint": "/api/v1/prospects/abc123",
      "data": {"name": "Updated Prospect"}
    }
  ]
}

# Response:
{
  "success": true,
  "results": [
    {"idempotencyKey": "uuid-1", "status": 201, "data": {...}},
    {"idempotencyKey": "uuid-2", "status": 201, "data": {...}},
    {"idempotencyKey": "uuid-3", "status": 409, "conflict": {...}}
  ]
}
```

### 5.5 Incremental Sync Support

**Required for large collection endpoints (products, parties, prospects, sites).**

Allow clients to fetch only records changed since their last sync, instead of re-downloading the entire dataset.

```
# Client sends:
GET /api/v1/products?updatedSince=2026-03-01T00:00:00Z

# Server returns:
- All records where updatedAt > updatedSince
- Includes soft-deleted records with `isDeleted: true` so client can remove them locally

# Response format:
{
  "success": true,
  "count": 5,
  "data": [...],
  "deletedIds": ["id1", "id2"],  // Records deleted since the timestamp
  "syncTimestamp": "2026-03-03T12:00:00Z"  // Client stores this for next sync
}
```

**Affected endpoints:**

| Endpoint | Expected Volume | Sync Frequency |
|---|---|---|
| `/api/v1/products` | 100–10,000 products | Every hour |
| `/api/v1/categories` | 10–100 categories | Every 24 hours |
| `/api/v1/parties/my-assigned` | 50–500 parties | Every 30 min |
| `/api/v1/prospects` | 50–500 prospects | Every 30 min |
| `/api/v1/sites` | 50–500 sites | Every 30 min |

### 5.6 Response Format Changes Summary

| Change | Current | Required | Affected Endpoints |
|---|---|---|---|
| ETag header | Not present | Required on all GET responses | All Tier 1 & 2 GET endpoints |
| Last-Modified header | Not present | Required on all GET responses | All Tier 1 & 2 GET endpoints |
| Idempotency-Key support | Not supported | Required on all POST/PUT | All Tier 2 write endpoints |
| `updatedSince` query param | Not supported | Required for incremental sync | Products, categories, parties, prospects, sites |
| `deletedIds` in response | Not present | Required for incremental sync | Same as above |
| `syncTimestamp` in response | Not present | Required for incremental sync | Same as above |
| 409 Conflict response | Not standardized | Standardized format with `serverVersion` | All Tier 2 PUT endpoints |
| 304 Not Modified | Not used | Required for conditional GET | All GET endpoints with ETag support |

---

## 6. Sync Strategy

### 6.1 Initial Sync (First Launch / Login)

When a user logs in for the first time (or clears app data), a full sync must populate the local database:

```
Login Success
    │
    ├─ 1. Save auth token + user data (existing flow)
    │
    ├─ 2. Sync reference data (parallel):
    │     ├─ GET /api/v1/categories → CachedCategories
    │     ├─ GET /api/v1/parties/types → CachedPartyTypes
    │     ├─ GET /api/v1/tax-configs → CachedTaxConfigs
    │     ├─ GET /api/v1/expense-claims/categories → CachedExpenseCategories
    │     ├─ GET /api/v1/prospects/categories → CachedProspectCategories
    │     ├─ GET /api/v1/sites/categories → CachedSiteCategories
    │     ├─ GET /api/v1/sites/sub-organizations → CachedSubOrganizations
    │     └─ GET /api/v1/collections/utils/bank-names → CachedBankNames
    │
    ├─ 3. Sync primary data (parallel):
    │     ├─ GET /api/v1/products → CachedProducts
    │     ├─ GET /api/v1/parties/my-assigned → CachedParties
    │     ├─ GET /api/v1/prospects → CachedProspects
    │     ├─ GET /api/v1/sites → CachedSites
    │     └─ GET /api/v1/home → CachedDashboard
    │
    ├─ 4. Sync user data (parallel):
    │     ├─ GET /api/v1/notes/my-notes → CachedNotes
    │     ├─ GET /api/v1/collections/my-collections → CachedCollections
    │     ├─ GET /api/v1/expense-claims → CachedExpenseClaims
    │     ├─ GET /api/v1/miscellaneous-work/my-work → CachedMiscWork
    │     ├─ GET /api/v1/leave-requests/my-requests → CachedLeaveRequests
    │     ├─ GET /api/v1/tour-plans/my-tour-plans → CachedTourPlans
    │     └─ GET /api/v1/beat-plans/my-beatplans → CachedBeatPlans
    │
    └─ 5. Store syncTimestamp per table
```

**UX during initial sync:**
- Show progress indicator on home screen (not blocking)
- User can navigate immediately using whatever data has loaded
- Background sync continues for remaining tables

### 6.2 Incremental Sync (Ongoing)

After initial sync, the app performs incremental syncs at regular intervals and on specific triggers.

**Automatic triggers:**
| Trigger | Action |
|---|---|
| App brought to foreground | Sync tables older than their `softMaxAge` |
| Connectivity restored (offline → online) | Process sync queue, then refresh stale tables |
| Pull-to-refresh on any list screen | Force refresh that specific table |
| Timer (every 15 minutes while active) | Sync high-priority tables |

**Sync priority order (when multiple tables need syncing):**

| Priority | Tables | Reason |
|---|---|---|
| 1 (Highest) | SyncQueue (pending writes) | User's work must not be lost |
| 2 | ImageQueue (pending uploads) | Images tied to synced writes |
| 3 | Collections, Expense Claims | Financial data — freshness matters |
| 4 | Notes, Misc Work, Leave Requests | User's personal data |
| 5 | Prospects, Sites | Shared directory data |
| 6 | Parties, Products, Categories | Reference data, lower change frequency |
| 7 | Dashboard, Tour Plans, Beat Plans | Summaries, refreshed on view |
| 8 (Lowest) | Tax configs, party types, expense categories | Reference data, rarely changes |

### 6.3 Background Sync Service

```dart
// Sync intervals by table type
const syncIntervals = {
  'reference_data': Duration(hours: 24),     // Categories, types, bank names
  'directory_data': Duration(minutes: 30),   // Parties, prospects, sites
  'user_data': Duration(minutes: 15),        // Notes, collections, expenses
  'dashboard': Duration(minutes: 5),         // Dashboard summary
};
```

### 6.4 Stale Data Handling

| Staleness Level | Criteria | UI Treatment |
|---|---|---|
| **Fresh** | Within `softMaxAge` | Normal display, no indicator |
| **Stale** | Past `softMaxAge`, within `maxAge` | Show data + subtle "last updated X min ago" |
| **Expired** | Past `maxAge` | Show data + "Outdated" badge, trigger immediate refresh |
| **Unknown** | No cached data, no connection | Show empty state with "Connect to load data" message |

```dart
class CacheConfig {
  final Duration softMaxAge;  // Start background refresh after this
  final Duration maxAge;      // Show "outdated" badge after this
  final Duration hardMaxAge;  // Delete from cache after this (disk cleanup)

  // Examples:
  static final dashboard = CacheConfig(
    softMaxAge: Duration(minutes: 5),
    maxAge: Duration(minutes: 30),
    hardMaxAge: Duration(days: 7),
  );

  static final products = CacheConfig(
    softMaxAge: Duration(hours: 1),
    maxAge: Duration(hours: 6),
    hardMaxAge: Duration(days: 30),
  );

  static final notes = CacheConfig(
    softMaxAge: Duration(minutes: 15),
    maxAge: Duration(hours: 2),
    hardMaxAge: Duration(days: 30),
  );

  static final referenceData = CacheConfig(
    softMaxAge: Duration(hours: 24),
    maxAge: Duration(days: 7),
    hardMaxAge: Duration(days: 90),
  );
}
```

### 6.5 Sync Status Provider

A global provider that tracks sync state for the entire app:

```dart
@Riverpod(keepAlive: true)
class SyncController extends _$SyncController {
  SyncState build() => SyncState.idle;

  // Exposes:
  // - bool isSyncing
  // - int pendingOperations (writes waiting)
  // - int pendingImages (images waiting)
  // - DateTime? lastSyncTime
  // - Map<String, DateTime> lastSyncPerTable
  // - Stream<SyncProgress> syncProgress
}
```

This provider can be watched by a global sync indicator widget (e.g., a small cloud icon in the app bar that shows sync status).

---

## 7. Phased Implementation Roadmap

### Phase 1: Foundation (Weeks 1–3)

**Goal:** Set up Drift database, cache interceptor, and connectivity UX changes. No feature-level offline writes yet.

#### Tasks

| # | Task | Files Affected |
|---|---|---|
| 1.1 | Add Drift dependencies to `pubspec.yaml` | `pubspec.yaml` |
| 1.2 | Create `AppDatabase` with cache tables (`CacheEntries`, `SyncQueue`, `ImageQueue`) | `lib/core/offline/database/app_database.dart` (new) |
| 1.3 | Create table definitions for all Tier 1 entities | `lib/core/offline/database/tables/` (new directory) |
| 1.4 | Initialize database in `main.dart` (after Hive init, before `runApp`) | `lib/main.dart` |
| 1.5 | Create `appDatabaseProvider` (keepAlive) | `lib/core/offline/providers/database_provider.dart` (new) |
| 1.6 | Build `CacheInterceptor` | `lib/core/offline/cache_interceptor.dart` (new) |
| 1.7 | Build `CacheConfigRegistry` (per-endpoint TTL config) | `lib/core/offline/cache_config.dart` (new) |
| 1.8 | Insert `CacheInterceptor` into Dio client interceptor chain (position 1) | `lib/core/network_layer/dio_client.dart` |
| 1.9 | Replace `GlobalConnectivityWrapper` full-screen overlay with `ConnectivityBanner` | `lib/core/utils/connectivity_utils.dart` |
| 1.10 | Update `ErrorHandlerWidget` to show inline offline message instead of `NoInternetScreen` for Tier 1/2 screens | `lib/widget/error_handler_widget.dart` |
| 1.11 | Run `dart run build_runner build --delete-conflicting-outputs` for Drift generation | — |

#### ViewModels Affected

None in Phase 1 — the cache interceptor works transparently at the Dio level. Existing ViewModels that call `dio.get()` will automatically receive cached responses when offline.

#### Backend Requirements for Phase 1

- Add `ETag` and `Last-Modified` headers to all GET endpoints (can be rolled out gradually)

#### Verification

- App displays cached data when network is toggled off (airplane mode)
- `ConnectivityBanner` shows instead of `NoInternetScreen`
- Cached data shows "last updated" timestamp
- App bar shows sync indicator
- No regressions in online behavior

---

### Phase 2: Offline Reads for All Tier 1 Features (Weeks 4–6)

**Goal:** All Tier 1 features serve cached data offline. Implement repository layer for these features.

#### Tasks

| # | Task | Files Affected |
|---|---|---|
| 2.1 | Create `BaseRepository` abstract class | `lib/core/offline/base_repository.dart` (new) |
| 2.2 | Create `CatalogRepository` (products + categories cache) | `lib/features/catalog/repository/catalog_repository.dart` (new) |
| 2.3 | Create `PartiesRepository` (party list + details + types cache) | `lib/features/parties/repository/parties_repository.dart` (new) |
| 2.4 | Create `InvoiceRepository` (invoice + estimate list/details cache) | `lib/features/invoice/repository/invoice_repository.dart` (new) |
| 2.5 | Create `TourPlanRepository` (tour plan list cache) | `lib/features/tour_plan/repository/tour_plan_repository.dart` (new) |
| 2.6 | Create `BeatPlanRepository` (beat plan list + details cache) | `lib/features/beat_plan/repository/beat_plan_repository.dart` (new) |
| 2.7 | Create `AttendanceRepository` (history + monthly report cache) | `lib/features/attendance/repository/attendance_repository.dart` (new) |
| 2.8 | Create `HomeRepository` (dashboard cache) | `lib/features/home/repository/home_repository.dart` (new) |
| 2.9 | Implement initial sync flow on login | `lib/core/offline/sync_manager.dart` (new) |
| 2.10 | Add incremental sync with `updatedSince` support | Repositories above |
| 2.11 | Add `SyncStatusIndicator` widget | `lib/widget/sync_status_indicator.dart` (new) |
| 2.12 | Add "last updated" label to list screens | Feature view files |

#### ViewModels Affected

| ViewModel | File | Change |
|---|---|---|
| `CatalogViewModel` | `lib/features/catalog/vm/catalog.vm.dart` | Read from `CatalogRepository` instead of `dio.get()` directly |
| `CategoryItemListViewModel` | `lib/features/catalog/vm/catalog_item.vm.dart` | Read from repository |
| `PartiesViewModel` | `lib/features/parties/vm/parties.vm.dart` | Read from repository |
| `PartyTypesViewModel` | `lib/features/parties/vm/party_types.vm.dart` | Read from repository |
| `InvoiceViewModel` | `lib/features/invoice/vm/invoice.vm.dart` | Read from repository |
| `TaxConfigViewModel` | `lib/features/invoice/vm/tax_config.vm.dart` | Read from repository |
| `TourPlanViewModel` | `lib/features/tour_plan/vm/tour_plan.vm.dart` | Read from repository |
| `BeatPlanListViewModel` | `lib/features/beat_plan/vm/beat_plan.vm.dart` | Read from repository |
| `BeatPlanDetailViewModel` | `lib/features/beat_plan/vm/beat_plan.vm.dart` | Read from repository |
| `AttendanceHistoryViewModel` | `lib/features/attendance/vm/attendance.vm.dart` | Read from repository |
| `AttendanceSummaryViewModel` | `lib/features/attendance/vm/attendance.vm.dart` | Read from repository |
| `HomeViewModel` | `lib/features/home/vm/home.vm.dart` | Read from repository |

#### Backend Requirements for Phase 2

- `updatedSince` query parameter on: `/api/v1/products`, `/api/v1/categories`, `/api/v1/parties/my-assigned`
- `deletedIds` array in response for incremental sync endpoints
- `syncTimestamp` field in response

#### Verification

- All Tier 1 feature list screens work offline with cached data
- Pull-to-refresh triggers fresh API call
- "Last updated" shows correct time
- Initial sync completes on fresh login
- Incremental sync only downloads changed records

---

### Phase 3: Offline Writes for Tier 2 Features (Weeks 7–10)

**Goal:** Tier 2 features support full offline CRUD with sync queue.

#### Tasks

| # | Task | Files Affected |
|---|---|---|
| 3.1 | Build `SyncQueueService` with operation queue, retry logic, priority ordering | `lib/core/offline/sync_queue_service.dart` (new) |
| 3.2 | Build `ImageQueueService` for offline image uploads | `lib/core/offline/image_queue_service.dart` (new) |
| 3.3 | Build `ConflictResolver` with per-entity strategies | `lib/core/offline/conflict_resolver.dart` (new) |
| 3.4 | Create table definitions for Tier 2 entities | `lib/core/offline/database/tables/` |
| 3.5 | Create `NotesRepository` (simplest Tier 2 — start here) | `lib/features/notes/repository/notes_repository.dart` (new) |
| 3.6 | Create `CollectionRepository` | `lib/features/collection/repository/collection_repository.dart` (new) |
| 3.7 | Create `ExpenseClaimRepository` | `lib/features/expense-claim/repository/expense_claim_repository.dart` (new) |
| 3.8 | Create `MiscWorkRepository` | `lib/features/miscellaneous/repository/misc_work_repository.dart` (new) |
| 3.9 | Create `LeaveRepository` | `lib/features/leave/repository/leave_repository.dart` (new) |
| 3.10 | Create `ProspectRepository` | `lib/features/prospects/repository/prospect_repository.dart` (new) |
| 3.11 | Create `SiteRepository` | `lib/features/sites/repository/site_repository.dart` (new) |
| 3.12 | Add connectivity-triggered sync (process queue on online transition) | `lib/core/offline/sync_manager.dart` |
| 3.13 | Add periodic background sync (15-minute timer) | `lib/core/offline/sync_manager.dart` |
| 3.14 | Add `SyncStatusIndicator` to list item cards for pending items | Feature view files |
| 3.15 | Add `SyncController` provider | `lib/core/offline/providers/sync_provider.dart` (new) |
| 3.16 | Add global sync indicator in app bar | `lib/widget/main_shell.dart` |

#### ViewModels Affected

| ViewModel | File | Change |
|---|---|---|
| `NotesViewModel` | `lib/features/notes/vm/notes.vm.dart` | Read/write via `NotesRepository` |
| `AddNoteViewModel` | `lib/features/notes/vm/add_notes.vm.dart` | Create via repository (offline queue) |
| `EditNoteViewModel` | `lib/features/notes/vm/edit_notes.vm.dart` | Update via repository (offline queue) |
| `CollectionViewModel` | `lib/features/collection/vm/collection.vm.dart` | Read via repository |
| `AddCollectionViewModel` | `lib/features/collection/vm/add_collection.vm.dart` | Create via repository (offline queue) |
| `EditCollectionViewModel` | `lib/features/collection/vm/edit_collection.vm.dart` | Update via repository (offline queue) |
| `BankNamesViewModel` | `lib/features/collection/vm/bank_names.vm.dart` | Read from cached reference data |
| `ExpenseClaimsViewModel` | `lib/features/expense-claim/vm/expense_claims.vm.dart` | Read via repository |
| `ExpenseClaimAddViewModel` | `lib/features/expense-claim/vm/expense_claim_add.vm.dart` | Create via repository |
| `ExpenseClaimEditViewModel` | `lib/features/expense-claim/vm/expense_claim_edit.vm.dart` | Update via repository |
| `ExpenseCategoriesViewModel` | `lib/features/expense-claim/vm/expense_categories.vm.dart` | Read from cached reference data |
| `MiscellaneousListViewModel` | `lib/features/miscellaneous/vm/miscellaneous_list.vm.dart` | Read via repository |
| `MiscellaneousAddViewModel` | `lib/features/miscellaneous/vm/miscellaneous_add.vm.dart` | Create via repository |
| `MiscellaneousEditViewModel` | `lib/features/miscellaneous/vm/miscellaneous_edit.vm.dart` | Update via repository |
| `LeaveViewModel` | `lib/features/leave/vm/leave.vm.dart` | Read via repository |
| `ApplyLeaveViewModel` | `lib/features/leave/vm/apply_leave.vm.dart` | Create via repository |
| `ProspectViewModel` | `lib/features/prospects/vm/prospects.vm.dart` | Read via repository |
| `AddProspectViewModel` | `lib/features/prospects/vm/add_prospect.vm.dart` | Create via repository |
| `EditProspectViewModel` | `lib/features/prospects/vm/edit_prospect_details.vm.dart` | Update via repository |
| `SiteViewModel` | `lib/features/sites/vm/sites.vm.dart` | Read via repository |
| `AddSiteViewModel` | `lib/features/sites/vm/add_sites.vm.dart` | Create via repository |
| `EditSiteViewModel` | `lib/features/sites/vm/edit_site_details.vm.dart` | Update via repository |

#### Backend Requirements for Phase 3

- `Idempotency-Key` header support on all Tier 2 write endpoints
- `409 Conflict` response format with `serverVersion` body
- `If-Match` header support for optimistic concurrency on PUT endpoints
- `updatedSince` query parameter on prospects, sites, collections, expenses, notes, misc work, leaves

#### Verification

- Create a note offline → appears in list with sync indicator → syncs when online → indicator disappears
- Create a collection offline → same flow
- Edit a prospect offline → queued → synced
- Image attached to offline-created note → image queued → entity synced first → image uploaded after
- Conflict scenario: edit same note on web + offline → server-wins resolution on sync
- 50+ queued operations sync in priority order without errors
- Retry logic works (simulate 3 failures then success)

---

### Phase 4: Polish & Optimization (Weeks 11–13)

**Goal:** Performance optimization, edge cases, bulk sync, disk management.

#### Tasks

| # | Task | Files Affected |
|---|---|---|
| 4.1 | Implement bulk sync endpoint integration (optional, if backend provides) | `lib/core/offline/sync_queue_service.dart` |
| 4.2 | Add disk usage monitoring and cache eviction (hardMaxAge cleanup) | `lib/core/offline/cache_manager.dart` (new) |
| 4.3 | Add settings screen: manual sync button, cache size display, clear cache option | `lib/features/settings/views/` |
| 4.4 | Optimize Drift queries with indexes and `watch()` streams | Database table definitions |
| 4.5 | Add Drift background isolate for heavy operations | `lib/core/offline/database/app_database.dart` |
| 4.6 | Add sync analytics (track sync success/failure rates) | `lib/core/offline/sync_analytics.dart` (new) |
| 4.7 | Handle edge case: user logs out with pending sync operations | `lib/core/offline/sync_manager.dart` |
| 4.8 | Handle edge case: server returns 410 Gone for deleted resource | `lib/core/offline/conflict_resolver.dart` |
| 4.9 | Add Sentry breadcrumbs for sync operations | `lib/core/offline/sync_queue_service.dart` |
| 4.10 | Database migration strategy for future schema changes | `lib/core/offline/database/migrations/` (new) |
| 4.11 | Add offline search (SQLite FTS for products, parties, prospects) | Database table definitions |
| 4.12 | Integration testing for full offline → online → sync cycle | `test/offline/` (new) |

#### Verification

- App size increase < 5 MB from SQLite
- Cache eviction runs weekly, keeps disk usage under 100 MB
- Full offline cycle test: airplane mode → create 10 items → go online → all sync within 60 seconds
- Logout with pending operations warns user and offers to sync first
- Search works offline for products, parties, prospects

---

## 8. New File Structure

```
lib/core/offline/
├── cache_interceptor.dart          # Dio interceptor for cache-first reads
├── cache_config.dart               # Per-endpoint TTL configuration registry
├── base_repository.dart            # Abstract repository with offline support
├── sync_queue_service.dart         # Write operation queue + processing
├── image_queue_service.dart        # Image upload queue
├── conflict_resolver.dart          # Per-entity conflict resolution strategies
├── sync_manager.dart               # Orchestrates sync triggers + scheduling
├── cache_manager.dart              # Disk usage monitoring + eviction
├── sync_analytics.dart             # Sync success/failure tracking
│
├── database/
│   ├── app_database.dart           # Main Drift database class
│   ├── app_database.g.dart         # Generated
│   ├── connection/
│   │   ├── native.dart             # NativeDatabase for mobile
│   │   └── web.dart                # Web database (if needed)
│   ├── tables/
│   │   ├── cache_entries.dart      # Generic response cache table
│   │   ├── sync_queue.dart         # Pending write operations table
│   │   ├── image_queue.dart        # Pending image uploads table
│   │   ├── cached_products.dart    # Products table
│   │   ├── cached_categories.dart  # Categories table
│   │   ├── cached_parties.dart     # Parties table
│   │   ├── cached_invoices.dart    # Invoices table
│   │   ├── cached_estimates.dart   # Estimates table
│   │   ├── cached_prospects.dart   # Prospects table (Tier 2)
│   │   ├── cached_sites.dart       # Sites table (Tier 2)
│   │   ├── cached_collections.dart # Collections table (Tier 2)
│   │   ├── cached_expenses.dart    # Expense claims table (Tier 2)
│   │   ├── cached_notes.dart       # Notes table (Tier 2)
│   │   ├── cached_misc_work.dart   # Misc work table (Tier 2)
│   │   ├── cached_leaves.dart      # Leave requests table (Tier 2)
│   │   ├── cached_tour_plans.dart  # Tour plans table
│   │   ├── cached_beat_plans.dart  # Beat plans table
│   │   ├── cached_attendance.dart  # Attendance records table
│   │   ├── cached_dashboard.dart   # Dashboard summary table
│   │   └── reference_tables.dart   # Party types, expense categories, bank names, etc.
│   ├── daos/
│   │   ├── cache_dao.dart          # Generic cache CRUD operations
│   │   ├── sync_dao.dart           # Sync queue CRUD operations
│   │   └── image_dao.dart          # Image queue CRUD operations
│   └── migrations/
│       └── migration_v1_to_v2.dart # Future schema migrations
│
└── providers/
    ├── database_provider.dart      # appDatabaseProvider (keepAlive)
    ├── sync_provider.dart          # SyncController, sync status streams
    └── cache_provider.dart         # Cache stats, disk usage

lib/widget/
├── sync_status_indicator.dart      # Pending sync badge for list items (new)
├── connectivity_banner.dart        # Offline banner (existing, already built)
└── last_updated_label.dart         # "Last updated X min ago" label (new)

# Feature-level repositories (new directories):
lib/features/catalog/repository/catalog_repository.dart
lib/features/parties/repository/parties_repository.dart
lib/features/invoice/repository/invoice_repository.dart
lib/features/home/repository/home_repository.dart
lib/features/attendance/repository/attendance_repository.dart
lib/features/beat_plan/repository/beat_plan_repository.dart
lib/features/tour_plan/repository/tour_plan_repository.dart
lib/features/notes/repository/notes_repository.dart
lib/features/collection/repository/collection_repository.dart
lib/features/expense-claim/repository/expense_claim_repository.dart
lib/features/miscellaneous/repository/misc_work_repository.dart
lib/features/leave/repository/leave_repository.dart
lib/features/prospects/repository/prospect_repository.dart
lib/features/sites/repository/site_repository.dart

# Existing (unchanged):
lib/core/services/offline_queue_service.dart    # Keep for beat plan location queue (Hive)
lib/core/models/queued_location.dart            # Keep for beat plan location queue (Hive)
```

---

## Appendix A: Unchanged Systems

The following components require **no changes** during the offline-first migration:

| Component | Reason |
|---|---|
| Hive location queue (`OfflineQueueService`) | Already works; proven in production; different data flow (WebSocket, not REST) |
| `BackgroundTrackingService` | Independent isolate-based service; not affected by Drift addition |
| `TrackingCoordinator` | Orchestrates tracking; no interaction with REST cache layer |
| `TrackingSocketService` | WebSocket-based; separate from Dio pipeline |
| `TokenStorageService` | SharedPreferences-based auth storage; simple key-value, no need for SQL |
| `ModuleConfig` | Access control logic; no data persistence |
| `GoRouter` configuration | Routing layer; no data concerns |
| Theme / ScreenUtil / FlexColorScheme | UI framework; no data concerns |

## Appendix B: Risk Assessment

| Risk | Impact | Mitigation |
|---|---|---|
| Drift adds to app bundle size | Low (~1.5 MB; SQLite is already bundled by Flutter on mobile) | Monitor APK size before/after |
| Schema migrations break on update | Medium | Drift's `MigrationStrategy` with versioned `onUpgrade`; test migrations extensively |
| Sync queue grows too large offline | Low | Max 500 pending operations; warn user at 100; force sync prompt at 500 |
| Image queue fills device storage | Medium | Max 50 queued images; compress to 80% JPEG quality; warn at 200 MB |
| Conflict resolution loses data | High | Default `serverWins` is safest; log all conflicts to Sentry; never silently discard |
| Background sync drains battery | Medium | Respect battery level (pause sync below 15%); use `battery_plus` (already a dependency) |
| build_runner conflicts with existing generators | Low | Drift uses same `build_runner`; no conflicts with Freezed/Riverpod generators |

## Appendix C: Dependency Impact

```yaml
# New dependencies
drift: ^2.22.0                    # ~500 KB compiled
sqlite3_flutter_libs: ^0.5.0      # ~1.5 MB (SQLite native binary; already bundled on iOS)
path: ^1.9.0                      # ~10 KB (likely already transitive dependency)

# New dev dependencies
drift_dev: ^2.22.0                # Build-time only, no runtime impact

# Unchanged
hive: ^2.2.3                      # Keep for location queue
hive_flutter: ^1.1.0              # Keep for location queue
shared_preferences: ^2.5.3        # Keep for settings/auth
build_runner: ^2.4.0              # Already present
```

**Total runtime size impact: ~2 MB** (mostly SQLite native library, which is already present on iOS and partial on Android).
