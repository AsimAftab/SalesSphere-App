import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

/// Service for saving PDFs to Downloads folder (Google Play compliant)
/// Uses MediaStore API on Android 10+ (API 29+) - no special permissions needed
/// Falls back to app-specific storage on other platforms
class DownloadsSaverService {
  static const MethodChannel _channel = MethodChannel('com.salessphere/downloads_saver');

  /// Save PDF bytes to Downloads folder
  /// Returns the file path if successful, null otherwise
  static Future<String?> saveToDownloads({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
  }) async {
    try {
      AppLogger.i('Attempting to save $fileName to Downloads...');

      if (Platform.isAndroid) {
        // Android: Try MediaStore API for direct Downloads save (Google Play compliant)
        try {
          final result = await _channel.invokeMethod('saveToDownloads', {
            'fileName': fileName,
            'bytes': bytes,
            'mimeType': mimeType,
          });

          if (result is String && result.isNotEmpty) {
            AppLogger.i('PDF saved to Downloads via MediaStore: $result');
            return result;
          }
        } on PlatformException catch (e) {
          AppLogger.w('MediaStore save failed: ${e.message}. Falling back to app storage.');
          // Fall through to app storage fallback
        }
      }

      // Fallback: Save to app-specific storage and share
      return await _saveToAppStorage(fileName, bytes);
    } catch (e) {
      AppLogger.e('Error saving to Downloads: $e');
      return null;
    }
  }

  /// Fallback: Save to app-specific storage
  static Future<String> _saveToAppStorage(String fileName, List<int> bytes) async {
    Directory? baseDir;

    if (Platform.isAndroid) {
      baseDir = await getExternalStorageDirectory();
    } else {
      baseDir = await getApplicationDocumentsDirectory();
    }

    if (baseDir != null) {
      final salesSphereDir = Directory('${baseDir.path}/SalesSphere/Invoices');
      if (!await salesSphereDir.exists()) {
        await salesSphereDir.create(recursive: true);
      }

      final file = File('${salesSphereDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      AppLogger.i('PDF saved to app storage: ${file.path}');
      return file.path;
    }

    // Final fallback to temp
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Share PDF file using system share sheet
  /// This lets users save to Downloads, Drive, cloud storage, etc.
  static Future<void> sharePdf({
    required String filePath,
    required String fileName,
  }) async {
    try {
      AppLogger.i('Sharing PDF: $fileName');
      await Share.shareXFiles(
        [XFile(filePath, name: fileName, mimeType: 'application/pdf')],
        subject: 'Invoice PDF',
        text: 'Please find the invoice attached.',
      );
      AppLogger.i('PDF shared successfully');
    } catch (e) {
      AppLogger.e('Error sharing PDF: $e');
      rethrow;
    }
  }

  /// Save PDF and then show share options
  static Future<String?> saveAndShare({
    required String fileName,
    required List<int> bytes,
  }) async {
    // First save to app storage
    final savedPath = await _saveToAppStorage(fileName, bytes);

    // Then share it
    await sharePdf(filePath: savedPath, fileName: fileName);

    return savedPath;
  }

  /// Check if storage permission is granted (for Android < 10)
  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      return status.isGranted;
    }
    return true;
  }

  /// Request storage permission (for Android < 10)
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }
}
