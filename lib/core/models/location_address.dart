/// Location Address Model
/// Represents reverse geocoded address information
class LocationAddress {
  final String? formattedAddress;
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? locality;

  LocationAddress({
    this.formattedAddress,
    this.street,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.locality,
  });

  /// Create from geocoding Placemark
  factory LocationAddress.fromPlacemark(dynamic placemark) {
    return LocationAddress(
      formattedAddress: _buildFormattedAddress(placemark),
      street: placemark.street,
      city: placemark.locality, // City/town
      state: placemark.administrativeArea, // State/province
      country: placemark.country,
      postalCode: placemark.postalCode,
      locality: placemark.subLocality, // Neighborhood/area
    );
  }

  /// Build formatted address string
  static String _buildFormattedAddress(dynamic placemark) {
    final parts = <String>[];

    if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    }
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      parts.add(placemark.subLocality!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
      parts.add(placemark.postalCode!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      parts.add(placemark.country!);
    }

    return parts.join(', ');
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      if (formattedAddress != null) 'formattedAddress': formattedAddress,
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (postalCode != null) 'postalCode': postalCode,
      if (locality != null) 'locality': locality,
    };
  }

  /// Create from JSON
  factory LocationAddress.fromJson(Map<String, dynamic> json) {
    return LocationAddress(
      formattedAddress: json['formattedAddress'] as String?,
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      locality: json['locality'] as String?,
    );
  }

  /// Check if address is empty
  bool get isEmpty =>
      formattedAddress == null &&
      street == null &&
      city == null &&
      state == null &&
      country == null &&
      postalCode == null &&
      locality == null;

  @override
  String toString() {
    return formattedAddress ?? 'Unknown Location';
  }

  /// Create empty address
  factory LocationAddress.empty() {
    return LocationAddress();
  }
}
