// lib/features/prospects/models/prospect_interest.model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'prospect_interest.model.freezed.dart';
part 'prospect_interest.model.g.dart';

// ============================================================================
// PROSPECT INTEREST MODELS
// ============================================================================

/// Prospect interest - category with selected brands
/// Used in create/update prospect requests
@freezed
abstract class ProspectInterest with _$ProspectInterest {
  const ProspectInterest._();

  const factory ProspectInterest({
    required String category,
    required List<String> brands,
    @JsonKey(name: '_id') String? id,
  }) = _ProspectInterest;

  factory ProspectInterest.fromJson(Map<String, dynamic> json) =>
      _$ProspectInterestFromJson(json);

  /// Helper to create from API category with selected brands
  factory ProspectInterest.fromCategory({
    required String category,
    required List<String> brands,
  }) {
    return ProspectInterest(category: category, brands: brands);
  }

  /// Display string for UI
  String get displayString {
    return '$category (${brands.length} brand${brands.length == 1 ? '' : 's'})';
  }
}

// ============================================================================
// PROSPECT CATEGORY MODELS (from /api/v1/prospects/categories)
// ============================================================================

/// Prospect category available from the API
@freezed
abstract class ProspectCategory with _$ProspectCategory {
  const factory ProspectCategory({
    @JsonKey(name: '_id') required String id,
    required String name,
    required List<String> brands,
    String? organizationId,
    String? createdAt,
    String? updatedAt,
    @JsonKey(name: '__v') int? v,
  }) = _ProspectCategory;

  factory ProspectCategory.fromJson(Map<String, dynamic> json) =>
      _$ProspectCategoryFromJson(json);
}

/// API Response for prospect categories endpoint
@freezed
abstract class ProspectCategoriesResponse with _$ProspectCategoriesResponse {
  const factory ProspectCategoriesResponse({
    required bool success,
    required int count,
    required List<ProspectCategory> data,
  }) = _ProspectCategoriesResponse;

  factory ProspectCategoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$ProspectCategoriesResponseFromJson(json);
}
