import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/sites/models/sites.model.dart';

part 'sites.vm.g.dart';

/// Main Sites ViewModel - Manages all sites
@riverpod
class SiteViewModel extends _$SiteViewModel {
  bool _isFetching = false;

  @override
  FutureOr<List<Sites>> build() async {
    // Keep alive for 60 seconds (prevents disposal on tab switch)
    final link = ref.keepAlive();
    Timer(const Duration(seconds: 60), () {
      link.close();
    });

    // Fetch sites - Global wrapper handles connectivity
    return _fetchSites();
  }

  Future<List<Sites>> _fetchSites() async {
    // Guard: prevent concurrent fetches
    if (_isFetching) {
      AppLogger.w('⚠️ Already fetching sites, skipping duplicate request');
      throw Exception('Fetch already in progress');
    }

    _isFetching = true;
    try {
      AppLogger.i('Fetching all sites from API...');

      // Get Dio instance
      final dio = ref.read(dioClientProvider);

      // Make API call
      final response = await dio.get(ApiEndpoints.sites);

      AppLogger.d('API Response: ${response.data}');

      // Parse response
      final fetchSitesResponse = FetchSitesResponse.fromJson(response.data);

      if (!fetchSitesResponse.success) {
        throw Exception('Failed to fetch sites');
      }

      // Convert to Sites list
      final sites = fetchSitesResponse.toSitesList();

      AppLogger.i('✅ Successfully fetched ${sites.length} sites');

      return sites;
    } on DioException catch (e) {
      AppLogger.e('❌ DioException fetching sites: ${e.message}');
      AppLogger.e('Response data: ${e.response?.data}');

      // Extract error message from response if available
      String errorMessage = 'Failed to fetch sites';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] ?? errorMessage;
        }
      }

      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error fetching sites: $e');
      AppLogger.e('Stack trace: $stackTrace');
      throw Exception('Failed to fetch sites: $e');
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchSites);
  }

  // Add a site to the list
  void addSite(Sites newSite) {
    state.whenData((currentSites) {
      // Add the new site to the beginning of the list
      final updatedList = [newSite, ...currentSites];
      state = AsyncValue.data(updatedList);
    });
  }

  // Update an existing site in the list
  void updateSite(Sites updatedSite) {
    state.whenData((currentSites) {
      final updatedList = currentSites.map((site) {
        if (site.id == updatedSite.id) {
          return updatedSite;
        }
        return site;
      }).toList();
      state = AsyncValue.data(updatedList);
    });
  }
}

/// Search Query Provider
@riverpod
class SiteSearchQuery extends _$SiteSearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

/// Provider for Searched/Filtered Sites
@riverpod
class SearchedSites extends _$SearchedSites {
  @override
  FutureOr<List<Sites>> build() async {
    final searchQuery = ref.watch(siteSearchQueryProvider);
    final allSites = await ref.watch(siteViewModelProvider.future);

    if (searchQuery.isEmpty) return allSites;

    final lowerQuery = searchQuery.toLowerCase();
    return allSites.where((site) {
      return site.name.toLowerCase().contains(lowerQuery) ||
          site.location.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

/// Site Count Provider
@riverpod
int siteCount(Ref ref) {
  final sitesAsync = ref.watch(siteViewModelProvider);

  return sitesAsync.when(
    data: (sites) => sites.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}
