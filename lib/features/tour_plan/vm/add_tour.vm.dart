import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import '../models/add_tour.models.dart';

part 'add_tour.vm.g.dart';

@riverpod
class AddTourViewModel extends _$AddTourViewModel {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<bool> saveTourPlanLocally(CreateTourRequest request) async {
    state = const AsyncLoading();

    try {
      AppLogger.i('Frontend: Saving tour plan for ${request.placeOfVisit}');

      await Future.delayed(const Duration(milliseconds: 500));

      state = const AsyncData(null);
      return true;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return false;
    }
  }

  // Validation helpers matching your Party VM logic
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}