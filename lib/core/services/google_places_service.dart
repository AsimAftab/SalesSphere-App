import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sales_sphere/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] ?? {};
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: structuredFormatting['main_text'] ?? '',
      secondaryText: structuredFormatting['secondary_text'] ?? '',
    );
  }
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final LatLng location;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.location,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] ?? {};
    final location = geometry['location'] ?? {};

    return PlaceDetails(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      location: LatLng(
        location['lat']?.toDouble() ?? 0.0,
        location['lng']?.toDouble() ?? 0.0,
      ),
    );
  }
}

class GooglePlacesService {
  final String apiKey;
  final Dio _dio;
  final Uuid _uuid = const Uuid();
  String? _sessionToken;

  GooglePlacesService({required this.apiKey})
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://maps.googleapis.com/maps/api',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  /// Get session token for billing optimization
  String _getSessionToken() {
    _sessionToken ??= _uuid.v4();
    return _sessionToken!;
  }

  /// Clear session token after place selection
  void _clearSessionToken() {
    _sessionToken = null;
  }

  /// Get autocomplete predictions
  Future<List<PlacePrediction>> getAutocompletePredictions(
    String input, {
    LatLng? location,
    int radius = 50000, // 50km radius
  }) async {
    if (input.isEmpty || input.length < 2) {
      return [];
    }

    try {
      final params = {
        'input': input,
        'key': apiKey,
        'sessiontoken': _getSessionToken(),
        'types': 'geocode|establishment', // Include both addresses and businesses
      };

      // Add location bias if provided
      if (location != null) {
        params['location'] = '${location.latitude},${location.longitude}';
        params['radius'] = radius.toString();
      }

      AppLogger.d('Fetching autocomplete predictions for: $input');

      final response = await _dio.get(
        '/place/autocomplete/json',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final status = data['status'];

        if (status == 'OK') {
          final predictions = (data['predictions'] as List)
              .map((json) => PlacePrediction.fromJson(json))
              .toList();

          AppLogger.i('Found ${predictions.length} predictions');
          return predictions;
        } else if (status == 'ZERO_RESULTS') {
          AppLogger.w('No predictions found for: $input');
          return [];
        } else {
          AppLogger.e('Places API error: $status - ${data['error_message']}');
          return [];
        }
      } else {
        AppLogger.e('HTTP error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      AppLogger.e('Error fetching predictions: $e');
      return [];
    }
  }

  /// Get place details by place ID
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      AppLogger.d('Fetching place details for: $placeId');

      final response = await _dio.get(
        '/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': apiKey,
          'sessiontoken': _getSessionToken(),
          'fields': 'place_id,name,formatted_address,geometry',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final status = data['status'];

        if (status == 'OK') {
          final result = data['result'];
          final placeDetails = PlaceDetails.fromJson(result);

          AppLogger.i('Place details fetched: ${placeDetails.name}');

          // Clear session token after successful place selection
          _clearSessionToken();

          return placeDetails;
        } else {
          AppLogger.e('Places API error: $status - ${data['error_message']}');
          _clearSessionToken();
          return null;
        }
      } else {
        AppLogger.e('HTTP error: ${response.statusCode}');
        _clearSessionToken();
        return null;
      }
    } catch (e) {
      AppLogger.e('Error fetching place details: $e');
      _clearSessionToken();
      return null;
    }
  }

  /// Get nearby places (businesses, landmarks, etc.)
  Future<List<PlaceDetails>> getNearbyPlaces(
    LatLng location, {
    int radius = 1000, // 1km radius
    String? type,
  }) async {
    try {
      AppLogger.d('Fetching nearby places at: ${location.latitude}, ${location.longitude}');

      final params = {
        'location': '${location.latitude},${location.longitude}',
        'radius': radius.toString(),
        'key': apiKey,
      };

      if (type != null) {
        params['type'] = type;
      }

      final response = await _dio.get(
        '/place/nearbysearch/json',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final status = data['status'];

        if (status == 'OK') {
          final places = (data['results'] as List)
              .map((json) => PlaceDetails.fromJson(json))
              .take(10) // Limit to 10 results
              .toList();

          AppLogger.i('Found ${places.length} nearby places');
          return places;
        } else if (status == 'ZERO_RESULTS') {
          AppLogger.w('No nearby places found');
          return [];
        } else {
          AppLogger.e('Places API error: $status - ${data['error_message']}');
          return [];
        }
      } else {
        AppLogger.e('HTTP error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      AppLogger.e('Error fetching nearby places: $e');
      return [];
    }
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}
