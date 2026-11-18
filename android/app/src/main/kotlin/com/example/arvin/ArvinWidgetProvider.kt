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

    /**
     * Native mirror of Arvin's canonical Gregorian -> Jalali display rule.
     *
     * The widget can render while Flutter is not running, so it cannot call the
     * Dart PersianDateFormatter directly. It keeps the canonical ISO timestamp
     * unchanged in storage and derives only the user-visible Jalali/Persian text.
     */
    private fun formatTimestamp(value: String): String {
        if (value.length >= 16 &&
            value.getOrNull(4) == '-' &&
            value.getOrNull(7) == '-' &&
            value.getOrNull(10) == 'T'
        ) {
            val year = value.substring(0, 4).toIntOrNull()
            val month = value.substring(5, 7).toIntOrNull()
            val day = value.substring(8, 10).toIntOrNull()
            if (year != null && month != null && day != null) {
                val (jalaliYear, jalaliMonth, jalaliDay) = toJalali(year, month, day)
                val date =
                    "${jalaliYear.toString().padStart(4, '0')}/" +
                        "${jalaliMonth.toString().padStart(2, '0')}/" +
                        jalaliDay.toString().padStart(2, '0')
                val time = value.substring(11, 16)
                return "${toPersianDigits(date)} | ${toPersianDigits(time)}"
            }
        }
        return toPersianDigits(value)
    }

    private fun toJalali(year: Int, month: Int, day: Int): Triple<Int, Int, Int> {
        val gy = year - 1600
        val gm = month - 1
        val gd = day - 1
        val gDays = intArrayOf(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)

        var gDayNo =
            365 * gy + (gy + 3) / 4 - (gy + 99) / 100 + (gy + 399) / 400
        for (index in 0 until gm) {
            gDayNo += gDays[index]
        }
        if (gm > 1 && isGregorianLeap(year)) {
            gDayNo++
        }
        gDayNo += gd

        var jDayNo = gDayNo - 79
        val jNp = jDayNo / 12053
        jDayNo %= 12053
        var jy = 979 + 33 * jNp + 4 * (jDayNo / 1461)
        jDayNo %= 1461
        if (jDayNo >= 366) {
            jy += (jDayNo - 1) / 365
            jDayNo = (jDayNo - 1) % 365
        }
        val jm = if (jDayNo < 186) 1 + jDayNo / 31 else 7 + (jDayNo - 186) / 30
        val jd = 1 + if (jDayNo < 186) jDayNo % 31 else (jDayNo - 186) % 30
        return Triple(jy, jm, jd)
    }

    private fun isGregorianLeap(year: Int): Boolean =
        year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)

    private fun toPersianDigits(value: String): String {
        val digits = "۰۱۲۳۴۵۶۷۸۹"
        return buildString(value.length) {
            value.forEach { character ->
                if (character in '0'..'9') {
                    append(digits[character - '0'])
                } else {
                    append(character)
                }
            }
        }
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
