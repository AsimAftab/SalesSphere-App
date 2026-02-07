// lib/features/prospects/models/prospect_images.model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'prospect_images.model.freezed.dart';
part 'prospect_images.model.g.dart';

// ============================================================================
// PROSPECT IMAGE MODEL
// ============================================================================

@freezed
abstract class ProspectImage with _$ProspectImage {
  const ProspectImage._();

  const factory ProspectImage({
    required String id,
    required String prospectId,
    required String imageUrl,
    required int imageOrder,
    required DateTime uploadedAt,
    String? caption,
    @Default(false) bool isUploaded,
  }) = _ProspectImage;

  factory ProspectImage.fromJson(Map<String, dynamic> json) =>
      _$ProspectImageFromJson(json);
}

// ============================================================================
// API RESPONSE MODELS
// ============================================================================

/// Upload image response data
@freezed
abstract class ProspectImageData with _$ProspectImageData {
  const factory ProspectImageData({
    required int imageNumber,
    required String imageUrl,
    String? id,
  }) = _ProspectImageData;

  factory ProspectImageData.fromJson(Map<String, dynamic> json) =>
      _$ProspectImageDataFromJson(json);
}

/// Upload image API response
@freezed
abstract class UploadProspectImageResponse with _$UploadProspectImageResponse {
  const factory UploadProspectImageResponse({
    required bool success,
    required String message,
    required ProspectImageData data,
  }) = _UploadProspectImageResponse;

  factory UploadProspectImageResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadProspectImageResponseFromJson(json);
}
