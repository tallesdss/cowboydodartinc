package com.cowboydodartinc.app

import android.appwidget.AppWidgetManager
import android.content.Context
import androidx.glance.appwidget.GlanceAppWidgetManager
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver
import kotlinx.coroutines.runBlocking

class MyWidgetReceiver : HomeWidgetGlanceWidgetReceiver<MyWidgetWidget>() {
    override val glanceAppWidget = MyWidgetWidget()

    // Override the parent's onUpdate because its updateAppWidgetState
    // transformation returns the SAME state instance back. Glance compares
    // references, treats the state as unchanged, and skips the recomposition.
    // The symptom on the Flutter side: first language switch does not update,
    // user has to tap twice. We force a fresh recompose by calling update()
    // directly on each widget id — the composable then reads the latest
    // SharedPreferences values that Dart already committed synchronously.
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        runBlocking {
            val manager = GlanceAppWidgetManager(context)
            appWidgetIds.forEach { widgetId ->
                val glanceId = manager.getGlanceIdBy(widgetId)
                glanceAppWidget.update(context, glanceId)
            }
            // Defensive 2nd update: Glance occasionally coalesces or skips the
            // first invalidation when the user triggers two updates in quick
            // succession (e.g. tapping the language tile and immediately
            // returning to the home screen). A short gap + second update
            // guarantees the freshly committed SharedPreferences values
            // actually reach the composition. The symptom without this:
            // first language tap appears to do nothing, second tap "fixes" it.
            kotlinx.coroutines.delay(200)
            appWidgetIds.forEach { widgetId ->
                val glanceId = manager.getGlanceIdBy(widgetId)
                glanceAppWidget.update(context, glanceId)
            }
        }
    }
}
