package com.example.arvin

import android.content.Intent
import android.provider.CalendarContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Native boundary for routing Android Widget task taps into Flutter. */
class MainActivity : FlutterActivity() {
    private var widgetChannel: MethodChannel? = null
    private var systemCalendarChannel: MethodChannel? = null
    private var pendingWidgetTaskId: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pendingWidgetTaskId = intent?.getStringExtra(EXTRA_TASK_ID)
        widgetChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        )
        widgetChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_CONSUME_TASK_ID -> {
                    val taskId = pendingWidgetTaskId
                        ?: intent?.getStringExtra(EXTRA_TASK_ID)
                    pendingWidgetTaskId = null
                    intent?.removeExtra(EXTRA_TASK_ID)
                    result.success(taskId)
                }
                else -> result.notImplemented()
            }
        }

        systemCalendarChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SYSTEM_CALENDAR_CHANNEL,
        )
        systemCalendarChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_INSERT_SYSTEM_CALENDAR_EVENT -> {
                    val title = call.argument<String>("title")?.trim().orEmpty()
                    val startMillis = call.argument<Number>("startMillis")?.toLong()
                    val endMillis = call.argument<Number>("endMillis")?.toLong()
                    val allDay = call.argument<Boolean>("allDay") ?: false

                    if (title.isEmpty() || startMillis == null || endMillis == null) {
                        result.error("invalid_event", "Calendar event payload is incomplete", null)
                        return@setMethodCallHandler
                    }

                    val calendarIntent = Intent(Intent.ACTION_INSERT).apply {
                        data = CalendarContract.Events.CONTENT_URI
                        putExtra(CalendarContract.Events.TITLE, title)
                        putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, startMillis)
                        putExtra(CalendarContract.EXTRA_EVENT_END_TIME, endMillis)
                        putExtra(CalendarContract.Events.ALL_DAY, allDay)
                    }

                    if (calendarIntent.resolveActivity(packageManager) == null) {
                        result.success(false)
                    } else {
                        startActivity(calendarIntent)
                        result.success(true)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val taskId = intent.getStringExtra(EXTRA_TASK_ID) ?: return
        pendingWidgetTaskId = taskId
        widgetChannel?.invokeMethod(METHOD_TASK_SELECTED, taskId)
    }

    companion object {
        const val CHANNEL_NAME = "arvin/widget_task"
        const val EXTRA_TASK_ID = "arvin_task_id"
        const val METHOD_CONSUME_TASK_ID = "consumeWidgetTaskId"
        const val METHOD_TASK_SELECTED = "widgetTaskSelected"

        const val SYSTEM_CALENDAR_CHANNEL = "arvin/system_calendar"
        const val METHOD_INSERT_SYSTEM_CALENDAR_EVENT = "insertSystemCalendarEvent"
    }
}
