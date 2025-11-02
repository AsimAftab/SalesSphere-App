// lib/features/prospects/models/prospects.model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'prospects.model.freezed.dart';
part 'prospects.model.g.dart';

@freezed
abstract class Prospects with _$Prospects {
  const factory Prospects({
    required String id,
    required String name,
    required String location,
    String? ownerName,
    String? phoneNumber,
    String? email,
    String? panVatNumber,
    double? latitude,
    double? longitude,
    String? notes,
    String? dateJoined,

    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _Prospects;

  factory Prospects.fromJson(Map<String, dynamic> json) =>
      _$ProspectsFromJson(json);
}