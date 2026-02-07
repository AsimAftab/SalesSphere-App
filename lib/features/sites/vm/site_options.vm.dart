import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/sites/models/sites.model.dart';

part 'site_options.vm.g.dart';

// ============================================================================
// SITE OPTIONS STATE
// ============================================================================

class SiteOptionsState {
  final List<SubOrganization> subOrganizations;
  final List<SiteCategory> categories;
  final bool isLoading;
  final String? errorMessage;

  const SiteOptionsState({
    this.subOrganizations = const [],
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SiteOptionsState copyWith({
    List<SubOrganization>? subOrganizations,
    List<SiteCategory>? categories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SiteOptionsState(
      subOrganizations: subOrganizations ?? this.subOrganizations,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ============================================================================
// SUB-ORGANIZATIONS PROVIDER
// ============================================================================

@riverpod
class SubOrganizationsViewModel extends _$SubOrganizationsViewModel {
  @override
  FutureOr<List<SubOrganization>> build() async {
    return fetchSubOrganizations();
  }

  Future<List<SubOrganization>> fetchSubOrganizations() async {
    try {
      AppLogger.i('Fetching sub-organizations...');

      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiEndpoints.siteSubOrganizations);

      AppLogger.d('Sub-organizations response: ${response.data}');

      final subOrgsResponse = SubOrganizationsResponse.fromJson(response.data);

      if (!subOrgsResponse.success) {
        throw Exception('Failed to fetch sub-organizations');
      }

      AppLogger.i('✅ Fetched ${subOrgsResponse.count} sub-organizations');
      return subOrgsResponse.data;
    } on DioException catch (e) {
      AppLogger.e('❌ DioException fetching sub-organizations: ${e.message}');
      AppLogger.e('Response data: ${e.response?.data}');

      String errorMessage = 'Failed to fetch sub-organizations';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] ?? errorMessage;
        }
      }

      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error fetching sub-organizations: $e');
      AppLogger.e('Stack trace: $stackTrace');
      throw Exception('Failed to fetch sub-organizations: $e');
    }
  }
}

// ============================================================================
// SITE CATEGORIES PROVIDER
// ============================================================================

@riverpod
class SiteCategoriesViewModel extends _$SiteCategoriesViewModel {
  @override
  FutureOr<List<SiteCategory>> build() async {
    return fetchCategories();
  }

  Future<List<SiteCategory>> fetchCategories() async {
    try {
      AppLogger.i('Fetching site categories...');

      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiEndpoints.siteCategories);

      AppLogger.d('Site categories response: ${response.data}');

      final categoriesResponse = SiteCategoriesResponse.fromJson(response.data);

      if (!categoriesResponse.success) {
        throw Exception('Failed to fetch site categories');
      }

      AppLogger.i('✅ Fetched ${categoriesResponse.count} site categories');
      return categoriesResponse.data;
    } on DioException catch (e) {
      AppLogger.e('❌ DioException fetching site categories: ${e.message}');
      AppLogger.e('Response data: ${e.response?.data}');

      String errorMessage = 'Failed to fetch site categories';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] ?? errorMessage;
        }
      }

      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error fetching site categories: $e');
      AppLogger.e('Stack trace: $stackTrace');
      throw Exception('Failed to fetch site categories: $e');
    }
  }
}
