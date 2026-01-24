package com.salessphere

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.salessphere/downloads_saver"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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
