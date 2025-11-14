import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import '../models/home.models.dart';

part 'home.vm.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  bool _isFetching = false;

  @override
  Future<HomeModel> build() async {
    // Keep alive for 60 seconds (prevents disposal on tab switch)
    final link = ref.keepAlive();
    Timer(const Duration(seconds: 60), () {
      link.close();
    });

    // Auto-fetch home data - Global wrapper handles connectivity
    return _fetchHomeData();
  }

  /// Fetch home data from API
  Future<HomeModel> _fetchHomeData() async {
    // Guard: prevent concurrent fetches
    if (_isFetching) {
      AppLogger.w('⚠️ Already fetching home data, skipping duplicate request');
      throw Exception('Fetch already in progress');
    }

    _isFetching = true;
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
    } finally {
      _isFetching = false;
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