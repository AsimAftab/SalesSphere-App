package com.salessphere

import android.app.Activity
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.webkit.MimeTypeMap
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.util.UUID

class MainActivity : FlutterActivity() {
    private val DOWNLOADS_CHANNEL = "com.salessphere/downloads_saver"
    private val PHOTO_PICKER_CHANNEL = "com.salessphere/system_photo_picker"
    private val PICK_IMAGES_REQUEST_CODE = 7001

    private var pendingPhotoPickerResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DOWNLOADS_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveToDownloads") {
                val fileName = call.argument<String>("fileName")
                val bytes = call.argument<ByteArray>("bytes")
                val mimeType = call.argument<String>("mimeType") ?: "application/pdf"

                if (fileName != null && bytes != null) {
                    val path = saveToDownloads(fileName, bytes, mimeType)
                    if (path != null) {
                        result.success(path)
                    } else {
                        result.error("SAVE_FAILED", "Failed to save file", null)
                    }
                } else {
                    result.error("INVALID_ARGS", "Missing fileName or bytes", null)
                }
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PHOTO_PICKER_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "pickMultipleImages") {
                val maxItems = (call.argument<Int>("maxItems") ?: 1).coerceAtLeast(1)

                if (pendingPhotoPickerResult != null) {
                    result.error("PICKER_IN_PROGRESS", "Photo picker is already open", null)
                    return@setMethodCallHandler
                }

                pendingPhotoPickerResult = result
                launchSystemPhotoPicker(maxItems)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun launchSystemPhotoPicker(maxItems: Int) {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Intent(MediaStore.ACTION_PICK_IMAGES).apply {
                type = "image/*"
                putExtra(MediaStore.EXTRA_PICK_IMAGES_MAX, maxItems)
            }
        } else {
            Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "image/*"
                putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
            }
        }

        startActivityForResult(intent, PICK_IMAGES_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != PICK_IMAGES_REQUEST_CODE) return

        val result = pendingPhotoPickerResult ?: return
        pendingPhotoPickerResult = null

        if (resultCode != Activity.RESULT_OK) {
            result.success(emptyList<String>())
            return
        }

        val selectedPaths = mutableListOf<String>()

        val clipData = data?.clipData
        if (clipData != null) {
            for (index in 0 until clipData.itemCount) {
                val uri = clipData.getItemAt(index).uri
                copyImageToCache(uri)?.let { selectedPaths.add(it) }
            }
        } else {
            val uri = data?.data
            if (uri != null) {
                copyImageToCache(uri)?.let { selectedPaths.add(it) }
            }
        }

        result.success(selectedPaths)
    }

    private fun copyImageToCache(uri: Uri): String? {
        return try {
            val mimeType = contentResolver.getType(uri) ?: return null
            if (!mimeType.startsWith("image/")) return null
            val extension = MimeTypeMap.getSingleton().getExtensionFromMimeType(mimeType) ?: "jpg"
            val file = File(cacheDir, "photo_picker_${UUID.randomUUID()}.$extension")

            contentResolver.openInputStream(uri)?.use { input ->
                FileOutputStream(file).use { output ->
                    input.copyTo(output)
                }
            } ?: return null

            file.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun saveToDownloads(fileName: String, bytes: ByteArray, mimeType: String): String? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Android 10+ (API 29+): Save to app's external files directory
                // This works without any permissions and returns a real file path
                val appSpecificDir = File(
                    getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS),
                    "SalesSphere/Invoices"
                )

                if (!appSpecificDir.exists()) {
                    appSpecificDir.mkdirs()
                }

                val file = File(appSpecificDir, fileName)
                FileOutputStream(file).use { output ->
                    output.write(bytes)
                    output.flush()
                }

                // Also try to save to actual Downloads folder via MediaStore for user convenience
                try {
                    val resolver = contentResolver
                    val contentValues = ContentValues().apply {
                        put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                        put(MediaStore.Downloads.MIME_TYPE, mimeType)
                        put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS + "/SalesSphere/Invoices")
                    }

                    val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)

                    if (uri != null) {
                        resolver.openOutputStream(uri)?.use { output ->
                            output.write(bytes)
                            output.flush()
                        }
                        // Query the actual file path from MediaStore
                        val projection = arrayOf(MediaStore.Downloads.DATA)
                        resolver.query(uri, projection, null, null, null)?.use { cursor ->
                            if (cursor.moveToFirst()) {
                                val dataIndex = cursor.getColumnIndexOrThrow(MediaStore.Downloads.DATA)
                                val filePath = cursor.getString(dataIndex)
                                if (filePath != null && File(filePath).exists()) {
                                    return filePath
                                }
                            }
                        }
                    }
                } catch (e: Exception) {
                    // MediaStore save failed, but app-specific save succeeded
                    e.printStackTrace()
                }

                // Return app-specific file path (always works with open_file)
                file.absolutePath
            } else {
                // Android < 10: Use traditional file approach
                val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                val salesSphereDir = File(downloadsDir, "SalesSphere/Invoices")

                if (!salesSphereDir.exists()) {
                    salesSphereDir.mkdirs()
                }

                val file = File(salesSphereDir, fileName)
                FileOutputStream(file).use { output ->
                    output.write(bytes)
                    output.flush()
                }
                file.absolutePath
            }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}

