import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sales_sphere/core/utils/logger.dart';

/// Geocoding service combining geocoding library and Nominatim API
class GeocodingService {
  final Dio _dio;

  GeocodingService(this._dio);

  /// Search for addresses using Nominatim API
  /// Returns list of address suggestions with lat/long
  Future<List<AddressSuggestion>> searchAddress(String query) async {
    if (query.trim().isEmpty || query.trim().length < 3) return [];

    try {
      AppLogger.i('🔍 Searching for address: $query');

      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': 1,
          'limit': 5,
          'accept-language': 'en', // Force English language
        },
        options: Options(
          headers: {
            'User-Agent': 'SalesSphere/1.0',
            'Accept-Language': 'en', // Force English in header too
          },
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        final results = (response.data as List)
            .map((json) => AddressSuggestion.fromJson(json))
            .toList();

        AppLogger.i('✅ Found ${results.length} address suggestions');
        return results;
      }

      return [];
    } catch (e) {
      AppLogger.e('❌ Error searching address: $e');
      return [];
    }
  }

  /// Reverse geocode using geocoding library
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      AppLogger.i('🔄 Reverse geocoding: $latitude, $longitude');

      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          place.street,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.country,
          place.postalCode,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        AppLogger.i('✅ Reverse geocoded: $address');
        return address;
      }

      return null;
    } catch (e) {
      AppLogger.e('❌ Error reverse geocoding: $e');
      return null;
    }
  }
}

/// Address suggestion model from Nominatim
class AddressSuggestion {
  final String displayName;
  final double latitude;
  final double longitude;
  final String? city;
  final String? state;
  final String? country;
  final String? postcode;

  AddressSuggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
    this.country,
    this.postcode,
  });

  factory AddressSuggestion.fromJson(Map<String, dynamic> json) {
    return AddressSuggestion(
      displayName: json['display_name'] ?? '',
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
      city: json['address']?['city'] ??
          json['address']?['town'] ??
          json['address']?['village'],
      state: json['address']?['state'],
      country: json['address']?['country'],
      postcode: json['address']?['postcode'],
    );
  }
}
