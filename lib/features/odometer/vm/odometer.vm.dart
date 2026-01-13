import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sales_sphere/core/network_layer/api_endpoints.dart';
import 'package:sales_sphere/core/network_layer/dio_client.dart';
import 'package:sales_sphere/core/services/geocoding_service.dart';
import 'package:sales_sphere/core/services/location_service.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import '../model/odometer.model.dart';

part 'odometer.vm.g.dart';

/// Provider for GeocodingService
@riverpod
GeocodingService geocodingService(Ref ref) {
  return GeocodingService(ref.watch(dioClientProvider));
}

/// Provider for LocationService
@riverpod
LocationService locationService(Ref ref) {
  return LocationService();
}

/// Fetch the dynamic monthly summary stats from the API
@riverpod
Future<OdometerMonthlySummary> odometerMonthlySummary(Ref ref) async {
  try {
    AppLogger.i('📊 Fetching odometer monthly summary...');

    final dio = ref.read(dioClientProvider);
    final response = await dio.get(
      '/api/v1/odometer/my-monthly-report',
      queryParameters: {
        'month': DateTime.now().month,
        'year': DateTime.now().year,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final summaryData = response.data['data']['summary'];
      AppLogger.d('📊 Summary data: $summaryData');
      return OdometerMonthlySummary(
        daysRecorded: summaryData['daysRecorded'] ?? 0,
        daysCompleted: summaryData['totalTrips'] ?? 0,
        daysInProgress: summaryData['daysInProgress'] ?? 0,
        totalDistance: (summaryData['totalDistance'] ?? 0).toDouble(),
        avgDailyDistance: (summaryData['avgDailyDistance'] ?? 0).toDouble(),
        unit: 'KM',
      );
    }

    // Fallback to empty summary if API fails
    return const OdometerMonthlySummary(
      daysRecorded: 0,
      daysCompleted: 0,
      daysInProgress: 0,
      totalDistance: 0.0,
      avgDailyDistance: 0.0,
      unit: 'KM',
    );
  } catch (e) {
    AppLogger.w('⚠️ Failed to fetch monthly summary: $e');
    // Return empty summary on error
    return const OdometerMonthlySummary(
      daysRecorded: 0,
      daysCompleted: 0,
      daysInProgress: 0,
      totalDistance: 0.0,
      avgDailyDistance: 0.0,
      unit: 'KM',
    );
  }
}

@riverpod
class OdometerViewModel extends _$OdometerViewModel {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<OdometerTodayStatusResponse?> build() async {
    return _fetchTodayStatus();
  }

  /// Fetch today's odometer status from API
  /// Returns OdometerTodayStatusResponse with trips array (supports multiple trips)
  Future<OdometerTodayStatusResponse?> _fetchTodayStatus() async {
    try {
      AppLogger.i('📋 Fetching today\'s odometer status...');

      final dio = ref.read(dioClientProvider);
      final response = await dio.get(ApiEndpoints.odometerTodayStatus);

      AppLogger.d('📥 Status response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        try {
          final statusResponse = OdometerTodayStatusResponse.fromJson(response.data);
          AppLogger.i('✅ Today\'s status loaded: ${statusResponse.trips.length} trips');
          AppLogger.d('📊 hasActiveTrip: ${statusResponse.hasActiveTrip}, totalTrips: ${statusResponse.totalTrips}');
          for (var trip in statusResponse.trips) {
            AppLogger.d('🚗 Trip #${trip.tripNumber}: ${trip.startReading} ${trip.unit} - ${trip.tripStatus}');
            AppLogger.d('📸 Trip #${trip.tripNumber} startImage: ${trip.startReadingImage}, description: ${trip.description}');
          }
          return statusResponse;
        } catch (parseError) {
          AppLogger.e('❌ Failed to parse status response: $parseError');
          AppLogger.e('📄 Response data: ${response.data}');
          rethrow;
        }
      }

      return null;
    } on DioException catch (e) {
      AppLogger.e('❌ Failed to fetch today\'s status: $e');
      return null;
    } catch (e) {
      AppLogger.e('❌ Unexpected error: $e');
      return null;
    }
  }

  /// Get the currently active trip from trips array
  OdometerReading? get activeTrip {
    final trips = state.value?.trips ?? [];
    if (trips.isEmpty) return null;
    try {
      return trips.firstWhere((t) => t.isInProgress);
    } catch (_) {
      // No in-progress trip, return null
      return null;
    }
  }

  /// Get completed trips count
  int get completedTripsCount {
    return state.value?.trips.where((t) => t.isCompleted).length ?? 0;
  }

  /// Get total trips count
  int get totalTripsCount {
    return state.value?.totalTrips ?? 0;
  }

  /// Check if there's an active trip
  bool get hasActiveTrip {
    return state.value?.hasActiveTrip ?? false;
  }

  /// Refreshes the active trip state
  Future<void> refresh() async {
    state = const AsyncLoading();
    // Fetch fresh data from API
    final freshData = await _fetchTodayStatus();
    state = AsyncData(freshData);
  }

  /// Helper to pick images from the camera
  Future<XFile?> pickImage() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
  }

  /// Upload image to odometer endpoint
  Future<void> _uploadImage({
    required String odometerId,
    required String imagePath,
    required bool isStart,
  }) async {
    try {
      AppLogger.i('📷 Uploading ${isStart ? "start" : "stop"} image...');

      final dio = ref.read(dioClientProvider);
      final file = await MultipartFile.fromFile(imagePath);

      final endpoint = isStart
          ? ApiEndpoints.odometerStartImage(odometerId)
          : ApiEndpoints.odometerStopImage(odometerId);

      final response = await dio.post(
        endpoint,
        data: FormData.fromMap({'image': file}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        AppLogger.i('✅ Image uploaded successfully');
      } else {
        AppLogger.w('⚠️ Image upload response: ${response.data}');
      }
    } catch (e) {
      AppLogger.e('❌ Failed to upload image: $e');
      // Don't throw - allow trip to continue even if image upload fails
    }
  }

  /// Starts a new trip and updates the state
  Future<void> startTrip({
    required double reading,
    required String unit,
    required String imagePath,
    String? description,
  }) async {
    state = const AsyncLoading();

    try {
      // Get current location
      AppLogger.i('📍 Getting current location...');
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation();

      if (location == null) {
        throw Exception('Unable to get current location. Please enable location services.');
      }

      // Get address from coordinates
      String address = 'Unknown location';
      try {
        final geocodingService = ref.read(geocodingServiceProvider);
        final fetchedAddress = await geocodingService.getAddressFromCoordinates(
          location.latitude,
          location.longitude,
        );
        if (fetchedAddress != null) {
          address = fetchedAddress;
        }
      } catch (e) {
        AppLogger.w('⚠️ Failed to get address: $e');
        address = '${location.latitude}, ${location.longitude}';
      }

      AppLogger.i('📍 Location: $address');

      // API CALL: POST /api/v1/odometer/start
      final dio = ref.read(dioClientProvider);
      final response = await dio.post(
        ApiEndpoints.odometerStart,
        data: {
          'startReading': reading,
          'startUnit': unit.toLowerCase(), // API expects "km" or "miles"
          'startDescription': description,
          'latitude': location.latitude,
          'longitude': location.longitude,
          'address': address,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true) {
          final odometerId = response.data['data']['_id'];
          final tripNumber = response.data['data']['tripNumber'] ?? 1;
          AppLogger.i('✅ Trip #$tripNumber started with ID: $odometerId');

          // Upload start image
          await _uploadImage(
            odometerId: odometerId,
            imagePath: imagePath,
            isStart: true,
          );

          // Refresh to get updated state
          await refresh();
        } else {
          throw Exception(response.data['message'] ?? 'Failed to start odometer reading');
        }
      } else {
        throw Exception('Failed to start odometer reading');
      }
    } catch (e) {
      AppLogger.e('❌ Start trip failed: $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Stops an active trip and refreshes the state
  Future<void> stopTrip({
    required double reading,
    required String imagePath,
    String? description,
  }) async {
    state = const AsyncLoading();

    try {
      // Get current location
      AppLogger.i('📍 Getting current location...');
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation();

      if (location == null) {
        throw Exception('Unable to get current location. Please enable location services.');
      }

      // Get address from coordinates
      String address = 'Unknown location';
      try {
        final geocodingService = ref.read(geocodingServiceProvider);
        final fetchedAddress = await geocodingService.getAddressFromCoordinates(
          location.latitude,
          location.longitude,
        );
        if (fetchedAddress != null) {
          address = fetchedAddress;
        }
      } catch (e) {
        AppLogger.w('⚠️ Failed to get address: $e');
        address = '${location.latitude}, ${location.longitude}';
      }

      AppLogger.i('📍 Location: $address');

      // Get current trip data to determine unit
      final currentTrip = activeTrip;
      if (currentTrip == null) {
        throw Exception('No active trip found');
      }

      // API CALL: PUT /api/v1/odometer/stop
      final dio = ref.read(dioClientProvider);

      final requestData = {
        'stopReading': reading,
        'stopUnit': currentTrip.unit.toLowerCase(),
        'stopDescription': description,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'address': address,
      };
      AppLogger.d('📤 Stop odometer request: $requestData');

      final response = await dio.put(
        ApiEndpoints.odometerStop,
        data: requestData,
      );

      AppLogger.d('📥 Stop odometer response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true) {
          final odometerId = response.data['data']['_id'];
          final tripNumber = response.data['data']['tripNumber'] ?? 1;
          AppLogger.i('✅ Trip #$tripNumber stopped with ID: $odometerId');

          // Upload stop image
          await _uploadImage(
            odometerId: odometerId,
            imagePath: imagePath,
            isStart: false,
          );

          // Invalidate the monthly summary as a new reading has been completed
          ref.invalidate(odometerMonthlySummaryProvider);

          // Refresh state from API to get the completed trip data
          // The API will return the trip with status: "completed"
          await refresh();
        } else {
          final errorMessage = response.data['message'] ?? 'Failed to stop odometer reading';
          AppLogger.e('❌ API error: $errorMessage');
          throw Exception(errorMessage);
        }
      } else {
        final errorMessage = response.data['message'] ??
            'Failed to stop odometer reading (Status: ${response.statusCode})';
        AppLogger.e('❌ HTTP error ${response.statusCode}: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.e('❌ Stop trip failed: $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
}
