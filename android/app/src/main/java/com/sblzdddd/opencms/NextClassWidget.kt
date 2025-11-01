package com.sblzdddd.opencms

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.view.View

// New import.
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Implementation of App Widget functionality.
 * App Widget Configuration implemented in [NextClassWidgetConfigureActivity]
 */
class NextClassWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.next_class_widget)
            
            // Get data from shared preferences
            val subjectName = widgetData.getString("subject_name", "Next Class") ?: "Next Class"
            val subjectCode = widgetData.getString("subject_code", "") ?: ""
            val room = widgetData.getString("room", "") ?: ""
            val time = widgetData.getString("time", "") ?: ""
            val isCurrentClass = widgetData.getBoolean("is_current_class", false)
            
            // Handle class_progress - Flutter saves as double (0.0-1.0), which might be stored as Long or Float
            val classProgress = try {
                // Try to get as Float first
                widgetData.getFloat("class_progress", 0.0f)
            } catch (e: ClassCastException) {
                // If that fails, try to get as Long and convert (SharedPreferences may store 0.0 as 0L)
                try {
                    val longValue = widgetData.getLong("class_progress", 0L)
                    longValue.toFloat()
                } catch (e2: Exception) {
                    0.0f
                }
            } catch (e: Exception) {
                0.0f
            }
            
            val timeUntil = widgetData.getString("time_until", "") ?: ""
            
            // Update text views
            views.setTextViewText(R.id.SubjectName, subjectName)
            views.setTextViewText(R.id.SubjectCode, subjectCode)
            views.setTextViewText(R.id.RoomText, room)
            
            // Update time text with "time until" if not current class
            val timeText = if (!isCurrentClass && timeUntil.isNotEmpty()) {
                "$timeUntil • $time"
            } else {
                time
            }
            views.setTextViewText(R.id.TimeText, timeText)
            
            // Update progress bar
            if (isCurrentClass && classProgress > 0) {
                // Show progress bar for current class
                views.setViewVisibility(R.id.progressBar3, View.VISIBLE)
                views.setProgressBar(R.id.progressBar3, 100, (classProgress * 100).toInt(), false)
            } else {
                // Hide progress bar when not in class
                views.setViewVisibility(R.id.progressBar3, View.GONE)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}