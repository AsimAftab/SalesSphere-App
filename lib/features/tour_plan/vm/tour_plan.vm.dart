import 'package:riverpod_annotation/riverpod_annotation.dart';
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
    AppLogger.i('📝 Fetching Mock Tour Plans');
    await Future.delayed(const Duration(seconds: 1));

    // Helper to calculate duration for mocks to match business logic (Inclusive)
    int calc(String s, String e) {
      final startDate = DateTime.parse(s);
      final endDate = DateTime.parse(e);
      return endDate.difference(startDate).inDays + 1;
    }

    return [
      TourPlanListItem(
        id: '1',
        placeOfVisit: 'Singapore',
        startDate: '2024-12-15',
        endDate: '2024-12-22',
        status: 'Approved',
        durationDays: calc('2024-12-15', '2024-12-22'),
      ),
      TourPlanListItem(
        id: '2',
        placeOfVisit: 'New York, USA',
        startDate: '2024-11-18',
        endDate: '2024-11-20',
        status: 'Pending',
        durationDays: calc('2024-11-18', '2024-11-20'),
      ),
      TourPlanListItem(
        id: '3',
        placeOfVisit: 'London, UK',
        startDate: '2024-11-15',
        endDate: '2024-11-18',
        status: 'Approved',
        durationDays: calc('2024-11-15', '2024-11-18'),
      ),
      TourPlanListItem(
        id: '4',
        placeOfVisit: 'Bali, Indonesia',
        startDate: '2024-11-12',
        endDate: '2024-11-16',
        status: 'Rejected',
        durationDays: calc('2024-11-12', '2024-11-16'),
      ),
    ];
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