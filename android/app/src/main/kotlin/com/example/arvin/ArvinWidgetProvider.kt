package com.example.arvin

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject

/**
 * Read-only Android Widget over Arvin's canonical SharedPreferences task JSON.
 *
 * The provider owns no storage. It reads the same `arvin.tasks` payload written
 * by Flutter shared_preferences and projects the latest FollowUp for active
 * Tasks into at most three rows.
 */
class ArvinWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { widgetId ->
            appWidgetManager.updateAppWidget(widgetId, buildViews(context, widgetId))
        }
    }

    private fun buildViews(context: Context, widgetId: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.arvin_widget)
        val rows = loadRows(context)

        views.setViewVisibility(
            R.id.widget_empty,
            if (rows.isEmpty()) View.VISIBLE else View.GONE,
        )

        ROWS.forEachIndexed { index, ids ->
            val row = rows.getOrNull(index)
            if (row == null) {
                views.setViewVisibility(ids.container, View.GONE)
                return@forEachIndexed
            }

            views.setViewVisibility(ids.container, View.VISIBLE)
            views.setTextViewText(ids.title, row.title)
            views.setTextViewText(
                ids.followUp,
                buildString {
                    append(row.note.ifBlank { "پیگیری ثبت‌شده" })
                    if (!row.result.isNullOrBlank()) append(" • ${row.result}")
                    append("\n${formatTimestamp(row.dateTime)}")
                },
            )

            val launchIntent = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
                ?: Intent(context, MainActivity::class.java)
            launchIntent
                .putExtra(EXTRA_TASK_ID, row.taskId)
                .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)

            val pendingIntent = PendingIntent.getActivity(
                context,
                widgetId * 10 + index,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(ids.container, pendingIntent)
        }

        return views
    }

    private fun loadRows(context: Context): List<WidgetRow> {
        val preferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val raw = preferences.getString(TASKS_KEY, null) ?: return emptyList()
        val tasks = runCatching { JSONArray(raw) }.getOrNull() ?: return emptyList()
        val rows = mutableListOf<WidgetRow>()

        for (index in 0 until tasks.length()) {
            val task = tasks.optJSONObject(index) ?: continue
            if (task.optBoolean("trashed") ||
                task.optBoolean("archived") ||
                task.optBoolean("completed")
            ) {
                continue
            }

            val followUps = task.optJSONArray("followUps") ?: continue
            val latest = latestFollowUp(followUps) ?: continue
            val taskId = task.optString("id")
            if (taskId.isBlank()) continue

            rows += WidgetRow(
                taskId = taskId,
                title = task.optString("title").ifBlank { "بدون عنوان" },
                note = latest.optString("note"),
                result = latest.optString("result").takeIf { it.isNotBlank() && it != "null" },
                dateTime = latest.optString("dateTime"),
            )
        }

        return rows
            .sortedByDescending { it.dateTime }
            .take(MAX_ROWS)
    }

    private fun latestFollowUp(followUps: JSONArray): JSONObject? {
        var latest: JSONObject? = null
        var latestDate = ""
        for (index in 0 until followUps.length()) {
            val candidate = followUps.optJSONObject(index) ?: continue
            val candidateDate = candidate.optString("dateTime")
            if (candidateDate > latestDate) {
                latestDate = candidateDate
                latest = candidate
            }
        }
        return latest
    }

    private fun formatTimestamp(value: String): String {
        if (value.length >= 16 && value[10] == 'T') {
            return "${value.substring(0, 10)} | ${value.substring(11, 16)}"
        }
        return value
    }

    private data class WidgetRow(
        val taskId: String,
        val title: String,
        val note: String,
        val result: String?,
        val dateTime: String,
    )

    private data class RowIds(val container: Int, val title: Int, val followUp: Int)

    companion object {
        const val EXTRA_TASK_ID = "arvin_task_id"
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val TASKS_KEY = "flutter.arvin.tasks"
        private const val MAX_ROWS = 3

        private val ROWS = listOf(
            RowIds(R.id.widget_row_1, R.id.widget_title_1, R.id.widget_followup_1),
            RowIds(R.id.widget_row_2, R.id.widget_title_2, R.id.widget_followup_2),
            RowIds(R.id.widget_row_3, R.id.widget_title_3, R.id.widget_followup_3),
        )
    }
}
