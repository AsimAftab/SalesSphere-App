
import 'dart:io';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_sphere/features/sites/models/sites.model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:sales_sphere/core/utils/logger.dart';

part 'sites_images.vm.g.dart';

// ============================================================================
// Local Storage Key
// ============================================================================
const String _siteImagesStorageKey = 'site_images_storage';

// ============================================================================
// Providers
// ============================================================================

/// Provider to get SharedPreferences instance
@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return await SharedPreferences.getInstance();
}

/// Provider to get all images for a specific site
@riverpod
Future<List<SiteImage>> siteImages(Ref ref, String siteId) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);

  // Get all stored images
  final storedData = prefs.getString(_siteImagesStorageKey);
  if (storedData == null) return [];

  final List<dynamic> jsonList = json.decode(storedData);
  final allImages = jsonList
      .map((json) => SiteImage.fromJson(json as Map<String, dynamic>))
      .toList();

  // Filter by siteId and sort by order
  final siteImages = allImages
      .where((img) => img.siteId == siteId)
      .toList()
    ..sort((a, b) => a.imageOrder.compareTo(b.imageOrder));

  return siteImages;
}

/// Provider to get image count for a site
@riverpod
Future<int> siteImageCount(Ref ref, String siteId) async {
  final images = await ref.watch(siteImagesProvider(siteId).future);
  return images.length;
}

// ============================================================================
// Site Images ViewModel - Manages all image operations
// ============================================================================

@riverpod
class SiteImagesViewModel extends _$SiteImagesViewModel {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  /// Add a new image to a site
  Future<SiteImage> addImage({
    required String siteId,
    required File imageFile,
    String? caption,
  }) async {
    try {
      AppLogger.i('📸 Adding new image for site: $siteId');

      final prefs = await ref.read(sharedPreferencesProvider.future);

      // Get existing images
      final storedData = prefs.getString(_siteImagesStorageKey);
      final List<SiteImage> allImages = storedData != null
          ? (json.decode(storedData) as List<dynamic>)
              .map((json) => SiteImage.fromJson(json as Map<String, dynamic>))
              .toList()
          : [];

      // Get existing images for this site
      final siteImages = allImages.where((img) => img.siteId == siteId).toList();

      if (siteImages.length >= 9) {
        AppLogger.w('⚠️ Maximum 9 photos limit reached for site: $siteId');
        throw Exception('Maximum 9 photos allowed per site');
      }

      // Save image to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final sitesDir = Directory('${appDir.path}/sites/$siteId/images');
      if (!await sitesDir.exists()) {
        await sitesDir.create(recursive: true);
      }

      // Generate unique filename
      final uuid = const Uuid();
      final fileName = '${uuid.v4()}.jpg';
      final newImagePath = '${sitesDir.path}/$fileName';

      // Copy file to app directory
      await imageFile.copy(newImagePath);

      // Create new SiteImage
      final newImage = SiteImage.create(
        siteId: siteId,
        imageUrl: newImagePath,
        imageOrder: siteImages.length + 1,
        caption: caption,
      );

      // Add to list
      allImages.add(newImage);

      // Save to SharedPreferences
      final jsonList = allImages.map((img) => img.toJson()).toList();
      await prefs.setString(_siteImagesStorageKey, json.encode(jsonList));

      AppLogger.i('✅ Image added successfully for site: $siteId');
      return newImage;
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error adding image: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Delete an image from a site
  Future<void> deleteImage(String imageId, String siteId) async {
    try {
      AppLogger.i('🗑️ Deleting image: $imageId from site: $siteId');

      final prefs = await ref.read(sharedPreferencesProvider.future);

      // Get all stored images
      final storedData = prefs.getString(_siteImagesStorageKey);
      if (storedData == null) return;

      final List<SiteImage> allImages = (json.decode(storedData) as List<dynamic>)
          .map((json) => SiteImage.fromJson(json as Map<String, dynamic>))
          .toList();

      // Find the image to delete
      final imageToDelete = allImages.firstWhere(
        (img) => img.id == imageId,
        orElse: () => throw Exception('Image not found'),
      );

      // Delete physical file
      final file = File(imageToDelete.imageUrl);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from list
      allImages.removeWhere((img) => img.id == imageId);

      // Reorder remaining images for this site
      final siteImages = allImages.where((img) => img.siteId == siteId).toList()
        ..sort((a, b) => a.imageOrder.compareTo(b.imageOrder));

      // Update order
      final reorderedSiteImages = <SiteImage>[];
      for (int i = 0; i < siteImages.length; i++) {
        reorderedSiteImages.add(siteImages[i].copyWith(imageOrder: i + 1));
      }

      // Replace old images with reordered ones
      allImages.removeWhere((img) => img.siteId == siteId);
      allImages.addAll(reorderedSiteImages);

      // Save to SharedPreferences
      final jsonList = allImages.map((img) => img.toJson()).toList();
      await prefs.setString(_siteImagesStorageKey, json.encode(jsonList));

      AppLogger.i('✅ Image deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error deleting image: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Reorder images for a site
  Future<void> reorderImages(String siteId, int oldIndex, int newIndex) async {
    try {
      AppLogger.i('🔄 Reordering images for site: $siteId');

      final prefs = await ref.read(sharedPreferencesProvider.future);

      // Get all stored images
      final storedData = prefs.getString(_siteImagesStorageKey);
      if (storedData == null) return;

      final List<SiteImage> allImages = (json.decode(storedData) as List<dynamic>)
          .map((json) => SiteImage.fromJson(json as Map<String, dynamic>))
          .toList();

      // Get images for this site
      final siteImages = allImages.where((img) => img.siteId == siteId).toList()
        ..sort((a, b) => a.imageOrder.compareTo(b.imageOrder));

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final item = siteImages.removeAt(oldIndex);
      siteImages.insert(newIndex, item);

      // Update order
      final reorderedSiteImages = <SiteImage>[];
      for (int i = 0; i < siteImages.length; i++) {
        reorderedSiteImages.add(siteImages[i].copyWith(imageOrder: i + 1));
      }

      // Replace old images with reordered ones
      allImages.removeWhere((img) => img.siteId == siteId);
      allImages.addAll(reorderedSiteImages);

      // Save to SharedPreferences
      final jsonList = allImages.map((img) => img.toJson()).toList();
      await prefs.setString(_siteImagesStorageKey, json.encode(jsonList));

      AppLogger.i('✅ Images reordered successfully');
    } catch (e, stackTrace) {
      AppLogger.e('❌ Error reordering images: $e', e, stackTrace);
      rethrow;
    }
  }
}
