import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import '../models/tour_plan.model.dart';

part 'tour_plan.vm.g.dart';

@riverpod
class TourPlanViewModel extends _$TourPlanViewModel {
  @override
  FutureOr<List<TourPlanListItem>> build() async {
    return _fetchTourPlans();
  }

  Future<List<TourPlanListItem>> _fetchTourPlans() async {
    try {
      AppLogger.i('📝 Fetching Tour Plans from API');
      final dio = ref.read(dioClientProvider);
      
      final response = await dio.get(ApiEndpoints.myTourPlans);
      
      // Parse response
      final apiResponse = TourPlanApiResponse.fromJson(response.data);
      
      if (!apiResponse.success) {
         throw Exception('Failed to fetch tour plans: Success flag is false');
      }

      // Map to list items
      return apiResponse.data.map((e) => TourPlanListItem.fromApiData(e)).toList();

    } catch (e, st) {
      AppLogger.e('Error fetching tour plans', e, st);
      rethrow; 
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTourPlans());
  }
}

@riverpod
class TourSearchQuery extends _$TourSearchQuery {
  @override
  String build() => '';
  void update(String query) => state = query;
}

@riverpod
Future<List<TourPlanListItem>> filteredTourPlans(Ref ref) async {
  final query = ref.watch(tourSearchQueryProvider).toLowerCase();
  final tourPlans = await ref.watch(tourPlanViewModelProvider.future);

  if (query.isEmpty) return tourPlans;

  return tourPlans.where((plan) {
    return plan.placeOfVisit.toLowerCase().contains(query) ||
        plan.status.toLowerCase().contains(query);
  }).toList();
}
