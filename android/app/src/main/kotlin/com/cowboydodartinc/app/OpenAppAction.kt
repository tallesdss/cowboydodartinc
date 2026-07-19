package com.cowboydodartinc.app

import android.content.Context
import android.content.Intent
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback

// Custom ActionCallback used by MyWidgetWidget instead of actionStartActivity.
// actionStartActivity wraps the launch in an internal "glance-action://CALLBACK"
// intent that ends up reaching MainActivity (because launchMode=singleTop) as
// the new intent — Flutter sees that URI as a deep link and go_router blows up
// with "no routes for location: glance-action:/CALLBACK". Running the launch
// ourselves through onAction bypasses that wrapping entirely.
class OpenAppAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters,
    ) {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
    }
}
