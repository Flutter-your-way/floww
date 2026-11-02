package com.example.floww

import android.app.Activity
import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File

class InstagramStoriesFileProvider : FileProvider()

class InstagramStoriesChannel(private val activity: Activity) {
    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method != SHARE_METHOD) {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val image = call.argument<ByteArray>("image")
            if (image == null) {
                result.success(false)
                return@setMethodCallHandler
            }
            try {
                result.success(shareToStory(image, call.argument<String>("appId").orEmpty()))
            } catch (e: Exception) {
                result.error("share_failed", e.message, null)
            }
        }
    }

    private fun shareToStory(image: ByteArray, appId: String): Boolean {
        val directory = File(activity.cacheDir, CACHE_FOLDER).apply { mkdirs() }
        val file = File(directory, FILE_NAME).apply { writeBytes(image) }
        val uri = FileProvider.getUriForFile(activity, "${activity.packageName}$AUTHORITY_SUFFIX", file)

        val intent = Intent(ADD_TO_STORY_ACTION).apply {
            type = MIME_TYPE
            putExtra("interactive_asset_uri", uri)
            if (appId.isNotEmpty()) putExtra("source_application", appId)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        if (activity.packageManager.resolveActivity(intent, 0) == null) return false

        activity.grantUriPermission(INSTAGRAM_PACKAGE, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
        activity.startActivityForResult(intent, 0)
        return true
    }

    companion object {
        private const val CHANNEL = "floww/instagram_stories"
        private const val SHARE_METHOD = "shareToStory"
        private const val ADD_TO_STORY_ACTION = "com.instagram.share.ADD_TO_STORY"
        private const val INSTAGRAM_PACKAGE = "com.instagram.android"
        private const val AUTHORITY_SUFFIX = ".instagram_stories"
        private const val CACHE_FOLDER = "instagram_stories"
        private const val FILE_NAME = "floww_story.png"
        private const val MIME_TYPE = "image/png"
    }
}
