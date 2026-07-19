package com.cowboydodartinc.app

import android.content.Context
import android.os.Bundle
import androidx.appcompat.app.AppCompatDelegate
import com.google.android.gms.ads.identifier.AdvertisingIdClient
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterActivity() {
  private val CHANNEL = "kasy_kit/advertising_id"

  override fun onCreate(savedInstanceState: Bundle?) {
    applySavedThemeMode()
    super.onCreate(savedInstanceState)
  }

  // Forces the night mode to match the user's saved theme preference (read
  // from `shared_preferences`) so the native splash drawable selection
  // (drawable-night vs drawable) follows the in-app choice, not just the OS.
  private fun applySavedThemeMode() {
    val prefs = applicationContext.getSharedPreferences(
      "FlutterSharedPreferences",
      Context.MODE_PRIVATE,
    )
    val mode = when (prefs.getString("flutter.themeMode", null)) {
      "dark" -> AppCompatDelegate.MODE_NIGHT_YES
      "light" -> AppCompatDelegate.MODE_NIGHT_NO
      else -> AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM
    }
    AppCompatDelegate.setDefaultNightMode(mode)
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call,
            result ->
      if (call.method == "getAdvertisingId") {
        CoroutineScope(Dispatchers.IO).launch {
          try {
            val adInfo = AdvertisingIdClient.getAdvertisingIdInfo(applicationContext)
            val advertisingId = adInfo?.id
            withContext(Dispatchers.Main) { result.success(advertisingId ?: "") }
          } catch (e: Exception) {
            withContext(Dispatchers.Main) { result.success("") }
          }
        }
      } else {
        result.notImplemented()
      }
    }
  }
}