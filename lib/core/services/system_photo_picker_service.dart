import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class SystemPhotoPickerService {
  static const MethodChannel _channel = MethodChannel(
    'com.salessphere/system_photo_picker',
  );

  static final ImagePicker _picker = ImagePicker();

  static Future<List<XFile>> pickMultipleImages({required int maxItems}) async {
    try {
      final List<dynamic>? paths = await _channel.invokeMethod<List<dynamic>>(
        'pickMultipleImages',
        <String, dynamic>{'maxItems': maxItems},
      );

      if (paths == null || paths.isEmpty) return <XFile>[];

      return paths
          .whereType<String>()
          .where((path) => path.isNotEmpty)
          .map((path) => XFile(path))
          .toList();
    } on MissingPluginException {
      // Native channel not registered yet (e.g., hot reload after Kotlin changes).
      return _picker.pickMultiImage(limit: maxItems);
    }
  }
}
