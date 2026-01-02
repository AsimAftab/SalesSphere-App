import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import '../models/add_tour.models.dart';
import 'tour_plan.vm.dart';

part 'add_tour.vm.g.dart';

@riverpod
class AddTourViewModel extends _$AddTourViewModel {
  @override
  FutureOr<void> build() {
    ref.keepAlive(); // Keeps provider alive during async gaps
    return null;
  }

  Future<bool> saveTourPlanLocally(CreateTourRequest request) async {
    state = const AsyncLoading();

    try {
      AppLogger.i('Frontend: Saving tour plan for ${request.placeOfVisit}');

      await Future.delayed(const Duration(milliseconds: 500));

      if (!ref.mounted) return false;

      // REFRESH the main list provider
      ref.invalidate(tourPlanViewModelProvider);

      state = const AsyncData(null);
      return true;
    } catch (e, stack) {
      if (ref.mounted) state = AsyncError(e, stack);
      return false;
    }
  }

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}