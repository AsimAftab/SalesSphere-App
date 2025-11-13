import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import '../models/home.models.dart';

part 'home.vm.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  Future<HomeModel> build() async {
    // Auto-fetch home data on initialization
    return _fetchHomeData();
  }

  /// Fetch home data from API
  Future<HomeModel> _fetchHomeData() async {
    try {
      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiEndpoints.home);

      if (response.statusCode == 200) {
        return HomeModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load home data');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh home data (pull-to-refresh)
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchHomeData());
  }

  /// Manual fetch
  Future<void> fetchData() async {
    state = await AsyncValue.guard(() => _fetchHomeData());
  }
}