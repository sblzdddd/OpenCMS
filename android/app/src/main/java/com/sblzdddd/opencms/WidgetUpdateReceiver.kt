package com.sblzdddd.opencms

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Custom broadcast receiver to trigger widget updates from ADB
 * Usage: adb shell am broadcast -a com.sblzdddd.opencms.UPDATE_WIDGET
 */
class WidgetUpdateReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("WidgetUpdateReceiver", "Received broadcast: ${intent.action}")
        
        if (intent.action == "com.sblzdddd.opencms.UPDATE_WIDGET") {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, NextClassWidget::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            
            if (appWidgetIds.isNotEmpty()) {
                Log.d("WidgetUpdateReceiver", "Updating ${appWidgetIds.size} widget(s)")
                val updateIntent = Intent(context, NextClassWidget::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
                }
                context.sendBroadcast(updateIntent)
            } else {
                Log.d("WidgetUpdateReceiver", "No widgets found to update")
            }
        }
    }
}
