package com.example.arvin

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.CalendarContract
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Native boundary for routing Android Widget task taps into Flutter. */
class MainActivity : FlutterActivity() {
    private var widgetChannel: MethodChannel? = null
    private var systemCalendarChannel: MethodChannel? = null
    private var pendingWidgetTaskId: String? = null
    private var pendingCalendarPermissionResult: MethodChannel.Result? = null

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
                METHOD_CALENDAR_READ_PERMISSION_GRANTED -> {
                    result.success(hasCalendarReadPermission())
                }
                METHOD_REQUEST_CALENDAR_READ_PERMISSION -> {
                    if (hasCalendarReadPermission()) {
                        result.success(true)
                        return@setMethodCallHandler
                    }
                    if (pendingCalendarPermissionResult != null) {
                        result.error(
                            "permission_request_in_progress",
                            "Calendar permission request is already active",
                            null,
                        )
                        return@setMethodCallHandler
                    }
                    pendingCalendarPermissionResult = result
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.READ_CALENDAR),
                        CALENDAR_PERMISSION_REQUEST_CODE,
                    )
                }
                METHOD_LIST_DEVICE_CALENDARS -> {
                    if (!hasCalendarReadPermission()) {
                        result.error(
                            "calendar_permission_denied",
                            "Calendar read permission is required",
                            null,
                        )
                        return@setMethodCallHandler
                    }
                    try {
                        result.success(readDeviceCalendars())
                    } catch (error: SecurityException) {
                        result.error(
                            "calendar_query_denied",
                            "Android Calendar Provider denied access",
                            error.message,
                        )
                    } catch (error: RuntimeException) {
                        result.error(
                            "calendar_query_failed",
                            "Android Calendar Provider query failed",
                            error.message,
                        )
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasCalendarReadPermission(): Boolean =
        ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_CALENDAR,
        ) == PackageManager.PERMISSION_GRANTED

    private fun readDeviceCalendars(): List<Map<String, Any?>> {
        val projection = arrayOf(
            CalendarContract.Calendars._ID,
            CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,
            CalendarContract.Calendars.ACCOUNT_NAME,
            CalendarContract.Calendars.ACCOUNT_TYPE,
            CalendarContract.Calendars.OWNER_ACCOUNT,
            CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL,
            CalendarContract.Calendars.VISIBLE,
            CalendarContract.Calendars.SYNC_EVENTS,
            CalendarContract.Calendars.IS_PRIMARY,
        )

        val calendars = mutableListOf<Map<String, Any?>>()
        contentResolver.query(
            CalendarContract.Calendars.CONTENT_URI,
            projection,
            null,
            null,
            "${CalendarContract.Calendars.CALENDAR_DISPLAY_NAME} COLLATE NOCASE ASC",
        )?.use { cursor ->
            val idIndex = cursor.getColumnIndexOrThrow(CalendarContract.Calendars._ID)
            val displayNameIndex = cursor.getColumnIndexOrThrow(
                CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,
            )
            val accountNameIndex = cursor.getColumnIndexOrThrow(
                CalendarContract.Calendars.ACCOUNT_NAME,
            )
            val accountTypeIndex = cursor.getColumnIndexOrThrow(
                CalendarContract.Calendars.ACCOUNT_TYPE,
            )
            val ownerAccountIndex = cursor.getColumnIndexOrThrow(
                CalendarContract.Calendars.OWNER_ACCOUNT,
            )
            val accessLevelIndex = cursor.getColumnIndexOrThrow(
                CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL,
            )
            val visibleIndex = cursor.getColumnIndexOrThrow(
                CalendarContract.Calendars.VISIBLE,
            )
            val syncEventsIndex = cursor.getColumnIndexOrThrow(
                CalendarContract.Calendars.SYNC_EVENTS,
            )
            val primaryIndex = cursor.getColumnIndexOrThrow(
                CalendarContract.Calendars.IS_PRIMARY,
            )

            while (cursor.moveToNext()) {
                calendars.add(
                    mapOf(
                        "id" to cursor.getLong(idIndex).toString(),
                        "displayName" to cursor.getString(displayNameIndex).orEmpty(),
                        "accountName" to cursor.getString(accountNameIndex),
                        "accountType" to cursor.getString(accountTypeIndex),
                        "ownerAccount" to cursor.getString(ownerAccountIndex),
                        "accessLevel" to cursor.getInt(accessLevelIndex),
                        "visible" to (cursor.getInt(visibleIndex) != 0),
                        "syncEvents" to (cursor.getInt(syncEventsIndex) != 0),
                        "isPrimary" to (cursor.getInt(primaryIndex) != 0),
                    ),
                )
            }
        }
        return calendars
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (requestCode == CALENDAR_PERMISSION_REQUEST_CODE) {
            val pending = pendingCalendarPermissionResult
            pendingCalendarPermissionResult = null
            pending?.success(
                grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED,
            )
            return
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
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
        const val METHOD_CALENDAR_READ_PERMISSION_GRANTED =
            "calendarReadPermissionGranted"
        const val METHOD_REQUEST_CALENDAR_READ_PERMISSION =
            "requestCalendarReadPermission"
        const val METHOD_LIST_DEVICE_CALENDARS = "listDeviceCalendars"
        const val CALENDAR_PERMISSION_REQUEST_CODE = 4102
    }
}
