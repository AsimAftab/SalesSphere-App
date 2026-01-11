import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../model/odometer.model.dart';

part 'odometer.vm.g.dart';

/// Fetch the dynamic monthly summary stats from the API
@riverpod
Future<OdometerMonthlySummary> odometerMonthlySummary(Ref ref) async {
  // In a real app, you would watch your repository and call the summary endpoint
  // final repo = ref.watch(odometerRepositoryProvider);
  // return await repo.getMonthlySummary();

  // Mock implementation for demonstration
  await Future.delayed(const Duration(milliseconds: 800));
  return const OdometerMonthlySummary(
    totalReadings: 18,
    totalDistance: 2847.0,
    unit: 'KM',
  );
}

@riverpod
class OdometerViewModel extends _$OdometerViewModel {
  final ImagePicker _picker = ImagePicker();

  @override
  FutureOr<OdometerReading?> build() async {
    // Logic to fetch the currently active trip from the API on initialization
    // If no trip is active, return null
    return null;
  }

  /// Refreshes the active trip state
  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidateSelf();
  }

  /// Helper to pick images from the camera
  Future<XFile?> pickImage() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
  }

  /// Starts a new trip and updates the state
  Future<void> startTrip({
    required double reading,
    required String unit,
    required String imagePath,
    String? description,
  }) async {
    state = const AsyncLoading();

    // API CALL: POST /api/v1/odometer/start
    // After success, invalidate self to show the "In Progress" status
    state = AsyncData(
      OdometerReading(
        startReading: reading,
        unit: unit,
        startReadingImage: imagePath,
        description: description,
        startTime: DateTime.now(),
      ),
    );

    // Also invalidate the summary as a new reading has been added
    ref.invalidate(odometerMonthlySummaryProvider);
  }

  /// Stops an active trip and refreshes the monthly summary
  Future<void> stopTrip({
    required double reading,
    required String imagePath,
    String? description,
  }) async {
    state = const AsyncLoading();

    // API CALL: PUT /api/v1/odometer/stop/:id

    // After successful stop, we must invalidate the monthly summary provider
    // so the Odometer Screen updates its stats immediately.
    ref.invalidate(odometerMonthlySummaryProvider);

    // Reset the active trip state to null as the trip is finished
    state = const AsyncData(null);
  }
}
