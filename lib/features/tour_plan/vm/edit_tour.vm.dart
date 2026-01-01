import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:sales_sphere/features/tour_plan/models/edit_tour.model.dart';

part 'edit_tour.vm.g.dart';

@riverpod
class EditTourViewModel extends _$EditTourViewModel {
  @override
  FutureOr<void> build() => null;

  // Mock fetch - replace with dio.get(ApiEndpoints.tourById(id)) later
  Future<TourDetails?> getTourById(String id) async {
    AppLogger.i('Fetching tour details for ID: $id');
    await Future.delayed(const Duration(milliseconds: 500));

    // Returning dummy data for frontend development
    return TourDetails(
      id: id,
      placeOfVisit: "Kathmandu, Nepal",
      startDate: "2024-05-20",
      endDate: "2024-05-25",
      purposeOfVisit: "Client meeting and site inspection for new project.",
      status: "Approved",
    );
  }

  Future<void> updateTour(TourDetails updatedTour) async {
    AppLogger.i('Updating tour: ${updatedTour.id}');
    // Logic for Dio put request goes here
    await Future.delayed(const Duration(seconds: 1));
  }
}

@riverpod
Future<TourDetails?> tourById(Ref ref, String tourId) async {
  final vm = ref.read(editTourViewModelProvider.notifier);
  return vm.getTourById(tourId);
}