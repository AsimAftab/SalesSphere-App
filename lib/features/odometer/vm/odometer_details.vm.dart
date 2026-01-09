import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../model/odometer.model.dart';

part 'odometer_details.vm.g.dart';

@riverpod
class OdometerDetailsViewModel extends _$OdometerDetailsViewModel {
  @override
  Future<OdometerDetails> build(String id) async {
    // Simulating API fetch for details
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data matching the design image
    return OdometerDetails(
      id: id,
      startTime: DateTime(2024, 12, 21, 8, 30),
      stopTime: DateTime(2024, 12, 21, 17, 45),
      startReading: 45320,
      stopReading: 45485,
      distanceTravelled: 165,
      startLocation: "Downtown Warehouse, 123 Main St",
      stopLocation: "Central Distribution Center, 456 Oak",
      description: "Regular daily route. No issues encountered. All deliveries completed successfully.",
    );
  }
}