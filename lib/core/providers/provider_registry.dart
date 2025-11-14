import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales_sphere/features/catalog/vm/catalog.vm.dart';
import 'package:sales_sphere/features/catalog/vm/catalog_item.vm.dart';
import 'package:sales_sphere/features/home/vm/home.vm.dart';
import 'package:sales_sphere/features/invoice/vm/invoice.vm.dart';
import 'package:sales_sphere/features/parties/vm/parties.vm.dart';
import 'package:sales_sphere/features/profile/vm/profile.vm.dart';
import 'package:sales_sphere/features/prospects/vm/prospects.vm.dart';
import 'package:sales_sphere/features/sites/vm/sites.vm.dart';
import 'package:sales_sphere/features/attendance/vm/attendance.vm.dart';
import 'package:sales_sphere/features/beat_plan/vm/beat_plan.vm.dart';

/// Provider Registry
/// Central registry for all data providers that need to be refreshed
/// when connectivity is restored after being offline.
///
/// **How to use:**
/// 1. Add your provider invalidation to `invalidateAll()` method below
/// 2. Call `ProviderRegistry.invalidateAll(ref)` when connectivity returns
///
/// **When to register a provider:**
/// - Providers that fetch data from API
/// - Providers that need fresh data after reconnection
/// - NOT state-only providers (search queries, selections, etc.)
///
/// **Production-ready pattern:**
/// - Single source of truth for all data providers
/// - Easy to maintain - just add one line when creating new features
/// - Type-safe - compiler catches errors if provider doesn't exist
class ProviderRegistry {
  /// Invalidate all registered data providers
  /// Call this when connectivity is restored to refresh all data
  ///
  /// **Adding new providers:**
  /// Simply add `ref.invalidate(yourNewProvider);` below
  static void invalidateAll(WidgetRef ref) {
    // Catalog
    ref.invalidate(catalogViewModelProvider);
    ref.invalidate(allCatalogItemsProvider);

    // Home
    ref.invalidate(homeViewModelProvider);

    // Parties
    ref.invalidate(partiesViewModelProvider);

    // Invoice
    ref.invalidate(invoiceHistoryProvider);

    // Prospects
    ref.invalidate(prospectViewModelProvider);

    // Sites
    ref.invalidate(siteViewModelProvider);

    // Attendance
    ref.invalidate(todayAttendanceViewModelProvider);
    ref.invalidate(monthlyAttendanceReportViewModelProvider);

    // Profile
    ref.invalidate(profileViewModelProvider);

    // Beat Plan
    ref.invalidate(beatPlanListViewModelProvider);

    // Add new feature providers here...
    // ref.invalidate(yourNewProvider);
  }
}
