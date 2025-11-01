import 'package:freezed_annotation/freezed_annotation.dart';


part 'prospects.model.freezed.dart';
part 'prospects.model.g.dart';

@freezed
// UPDATED class name to plural
abstract class Prospects with _$Prospects {
  const factory Prospects({
    required String id,
    required String name,
    required String location, // e.g., "Binamod, Nepal" or "Location"

    // Add other fields you might need for a prospects details page later
    String? ownerName,
    String? phoneNumber,
    String? email,
    @Default(true) bool isActive,
    DateTime? createdAt,

  }) = _Prospects;

  factory Prospects.fromJson(Map<String, dynamic> json) =>
      _$ProspectsFromJson(json);
}