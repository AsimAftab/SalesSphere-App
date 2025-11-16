import 'package:hive/hive.dart';
import 'package:sales_sphere/core/models/location_address.dart';

/// Queued Location Model
/// Stores location data in Hive when offline for later synchronization
@HiveType(typeId: 0)
class QueuedLocation extends HiveObject {
  @HiveField(0)
  final String beatPlanId;

  @HiveField(1)
  final double latitude;

  @HiveField(2)
  final double longitude;

  @HiveField(3)
  final double accuracy;

  @HiveField(4)
  final double speed;

  @HiveField(5)
  final double heading;

  @HiveField(6)
  final DateTime timestamp;

  @HiveField(7)
  final int retryCount;

  @HiveField(8)
  final bool isSynced;

  @HiveField(9)
  final Map<String, dynamic>? address; // Stored as Map for Hive compatibility

  QueuedLocation({
    required this.beatPlanId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.timestamp,
    this.retryCount = 0,
    this.isSynced = false,
    this.address,
  });

  /// Convert to JSON for API transmission
  Map<String, dynamic> toJson() {
    return {
      'beatPlanId': beatPlanId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      if (address != null) 'address': address,
    };
  }

  /// Create from LocationUpdate
  factory QueuedLocation.fromLocationUpdate({
    required String beatPlanId,
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
    required double heading,
    Map<String, dynamic>? address,
  }) {
    return QueuedLocation(
      beatPlanId: beatPlanId,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      speed: speed,
      heading: heading,
      timestamp: DateTime.now(),
      address: address,
    );
  }

  /// Create a copy with updated fields
  QueuedLocation copyWith({
    String? beatPlanId,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? speed,
    double? heading,
    DateTime? timestamp,
    int? retryCount,
    bool? isSynced,
    Map<String, dynamic>? address,
  }) {
    return QueuedLocation(
      beatPlanId: beatPlanId ?? this.beatPlanId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      isSynced: isSynced ?? this.isSynced,
      address: address ?? this.address,
    );
  }

  @override
  String toString() {
    return 'QueuedLocation('
        'beatPlan: $beatPlanId, '
        'lat: ${latitude.toStringAsFixed(6)}, '
        'lng: ${longitude.toStringAsFixed(6)}, '
        'time: $timestamp, '
        'synced: $isSynced'
        ')';
  }
}

/// Manual Hive TypeAdapter for QueuedLocation
/// Written manually to avoid dependency conflicts with hive_generator
class QueuedLocationAdapter extends TypeAdapter<QueuedLocation> {
  @override
  final int typeId = 0;

  @override
  QueuedLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Handle address field with proper type casting and backward compatibility
    Map<String, dynamic>? address;
    if (fields.containsKey(9) && fields[9] != null) {
      // Cast from _Map<dynamic, dynamic> to Map<String, dynamic>
      final rawAddress = fields[9];
      if (rawAddress is Map) {
        address = Map<String, dynamic>.from(rawAddress);
      }
    }

    return QueuedLocation(
      beatPlanId: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      accuracy: fields[3] as double,
      speed: fields[4] as double,
      heading: fields[5] as double,
      timestamp: fields[6] as DateTime,
      retryCount: fields[7] as int,
      isSynced: fields[8] as bool,
      address: address, // Now properly cast
    );
  }

  @override
  void write(BinaryWriter writer, QueuedLocation obj) {
    writer
      ..writeByte(10) // Updated field count
      ..writeByte(0)
      ..write(obj.beatPlanId)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.accuracy)
      ..writeByte(4)
      ..write(obj.speed)
      ..writeByte(5)
      ..write(obj.heading)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.retryCount)
      ..writeByte(8)
      ..write(obj.isSynced)
      ..writeByte(9)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueuedLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
