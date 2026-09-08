package com.example.arvin

import android.Manifest
import android.content.ContentUris
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.CalendarContract
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

/** Native boundary for routing Android Widget task taps into Flutter. */
class MainActivity : FlutterActivity() {
    private var widgetChannel: MethodChannel? = null
    private var systemCalendarChannel: MethodChannel? = null
    private var pendingWidgetTaskId: String? = null
    private var pendingCalendarPermissionResult: MethodChannel.Result? = null
    private var pendingCalendarWritePermissionResult: MethodChannel.Result? = null

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
                METHOD_CALENDAR_WRITE_PERMISSION_GRANTED -> {
                    result.success(hasCalendarWritePermission())
                }
                METHOD_REQUEST_CALENDAR_WRITE_PERMISSION -> {
                    if (hasCalendarWritePermission()) {
                        result.success(true)
                        return@setMethodCallHandler
                    }
                    if (pendingCalendarWritePermissionResult != null) {
                        result.error("permission_request_in_progress", "Calendar write permission request is already active", null)
                        return@setMethodCallHandler
                    }
                    pendingCalendarWritePermissionResult = result
                    ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.WRITE_CALENDAR), CALENDAR_WRITE_PERMISSION_REQUEST_CODE)
                }
                METHOD_CREATE_DEVICE_CALENDAR_EVENT -> {
                    if (!hasCalendarWritePermission()) {
                        result.error("calendar_write_permission_denied", "Calendar write permission is required", null)
                        return@setMethodCallHandler
                    }
                    val calendarId = call.argument<String>("calendarId")?.trim()?.toLongOrNull()
                    val title = call.argument<String>("title")?.trim().orEmpty()
                    val startMillis = call.argument<Number>("startMillis")?.toLong()
                    val endMillis = call.argument<Number>("endMillis")?.toLong()
                    val allDay = call.argument<Boolean>("allDay") ?: false
                    if (calendarId == null || title.isEmpty() || startMillis == null || endMillis == null || endMillis <= startMillis) {
                        result.error("invalid_event", "Calendar provider event payload is incomplete", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val uri = contentResolver.insert(CalendarContract.Events.CONTENT_URI, eventValues(calendarId, title, startMillis, endMillis, allDay))
                        result.success(uri?.lastPathSegment)
                    } catch (error: SecurityException) {
                        result.error("calendar_write_denied", "Android Calendar Provider denied create", error.message)
                    } catch (error: RuntimeException) {
                        result.error("calendar_write_failed", "Android Calendar Provider create failed", error.message)
                    }
                }
                METHOD_UPDATE_DEVICE_CALENDAR_EVENT -> {
                    if (!hasCalendarWritePermission()) {
                        result.error("calendar_write_permission_denied", "Calendar write permission is required", null)
                        return@setMethodCallHandler
                    }
                    val calendarIdText = call.argument<String>("calendarId")?.trim().orEmpty()
                    val calendarId = calendarIdText.toLongOrNull()
                    val eventId = call.argument<String>("eventId")?.trim()?.toLongOrNull()
                    val title = call.argument<String>("title")?.trim().orEmpty()
                    val startMillis = call.argument<Number>("startMillis")?.toLong()
                    val endMillis = call.argument<Number>("endMillis")?.toLong()
                    val allDay = call.argument<Boolean>("allDay") ?: false
                    if (calendarId == null || eventId == null || title.isEmpty() || startMillis == null || endMillis == null || endMillis <= startMillis) {
                        result.error("invalid_event", "Calendar provider update payload is incomplete", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val uri = ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, eventId)
                        val updated = contentResolver.update(uri, eventValues(calendarId, title, startMillis, endMillis, allDay), CalendarContract.Events.CALENDAR_ID + " = ?", arrayOf(calendarIdText))
                        result.success(updated == 1)
                    } catch (error: SecurityException) {
                        result.error("calendar_write_denied", "Android Calendar Provider denied update", error.message)
                    } catch (error: RuntimeException) {
                        result.error("calendar_write_failed", "Android Calendar Provider update failed", error.message)
                    }
                }
                METHOD_DELETE_DEVICE_CALENDAR_EVENT -> {
                    if (!hasCalendarWritePermission()) {
                        result.error("calendar_write_permission_denied", "Calendar write permission is required", null)
                        return@setMethodCallHandler
                    }
                    val calendarIdText = call.argument<String>("calendarId")?.trim().orEmpty()
                    val calendarId = calendarIdText.toLongOrNull()
                    val eventId = call.argument<String>("eventId")?.trim()?.toLongOrNull()
                    if (calendarId == null || eventId == null) {
                        result.error("invalid_event", "Calendar provider delete payload is incomplete", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val uri = ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, eventId)
                        val deleted = contentResolver.delete(uri, CalendarContract.Events.CALENDAR_ID + " = ?", arrayOf(calendarIdText))
                        result.success(deleted == 1)
                    } catch (error: SecurityException) {
                        result.error("calendar_write_denied", "Android Calendar Provider denied delete", error.message)
                    } catch (error: RuntimeException) {
                        result.error("calendar_write_failed", "Android Calendar Provider delete failed", error.message)
                    }
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
                METHOD_LIST_DEVICE_CALENDAR_EVENTS -> {
                    if (!hasCalendarReadPermission()) {
                        result.error(
                            "calendar_permission_denied",
                            "Calendar read permission is required",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    val calendarIds = call.argument<List<String>>("calendarIds")
                        ?.map { it.trim() }
                        ?.filter { it.isNotEmpty() }
                        ?.distinct()
                        .orEmpty()
                    val startMillis = call.argument<Number>("startMillis")?.toLong()
                    val endMillis = call.argument<Number>("endMillis")?.toLong()

                    if (
                        calendarIds.isEmpty() ||
                        calendarIds.size > MAX_EVENT_QUERY_CALENDARS ||
                        startMillis == null ||
                        endMillis == null ||
                        endMillis <= startMillis ||
                        endMillis - startMillis > MAX_EVENT_QUERY_WINDOW_MILLIS
                    ) {
                        result.error(
                            "invalid_event_query",
                            "Calendar event query must use 1-$MAX_EVENT_QUERY_CALENDARS calendars and a bounded positive time window",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        result.success(
                            readDeviceCalendarEvents(
                                calendarIds = calendarIds,
                                startMillis = startMillis,
                                endMillis = endMillis,
                            ),
                        )
                    } catch (error: SecurityException) {
                        result.error(
                            "calendar_query_denied",
                            "Android Calendar Provider denied event access",
                            error.message,
                        )
                    } catch (error: RuntimeException) {
                        result.error(
                            "calendar_query_failed",
                            "Android Calendar Provider event query failed",
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

    private fun hasCalendarWritePermission(): Boolean =
        ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.WRITE_CALENDAR,
        ) == PackageManager.PERMISSION_GRANTED

    private fun eventValues(
        calendarId: Long,
        title: String,
        startMillis: Long,
        endMillis: Long,
        allDay: Boolean,
    ): ContentValues = ContentValues().apply {
        put(CalendarContract.Events.CALENDAR_ID, calendarId)
        put(CalendarContract.Events.TITLE, title)
        put(CalendarContract.Events.DTSTART, startMillis)
        put(CalendarContract.Events.DTEND, endMillis)
        put(CalendarContract.Events.ALL_DAY, if (allDay) 1 else 0)
        put(CalendarContract.Events.EVENT_TIMEZONE, if (allDay) "UTC" else TimeZone.getDefault().id)
    }

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

    private fun readDeviceCalendarEvents(
        calendarIds: List<String>,
        startMillis: Long,
        endMillis: Long,
    ): List<Map<String, Any?>> {
        val instancesUri = CalendarContract.Instances.CONTENT_URI.buildUpon().also { builder ->
            ContentUris.appendId(builder, startMillis)
            ContentUris.appendId(builder, endMillis)
        }.build()
        val projection = arrayOf(
            CalendarContract.Instances._ID,
            CalendarContract.Instances.EVENT_ID,
            CalendarContract.Instances.CALENDAR_ID,
            CalendarContract.Instances.CALENDAR_DISPLAY_NAME,
            CalendarContract.Instances.TITLE,
            CalendarContract.Instances.DESCRIPTION,
            CalendarContract.Instances.BEGIN,
            CalendarContract.Instances.END,
            CalendarContract.Instances.ALL_DAY,
            CalendarContract.Instances.EVENT_TIMEZONE,
            CalendarContract.Instances.RRULE,
            CalendarContract.Instances.STATUS,
        )
        val placeholders = calendarIds.joinToString(",") { "?" }
        val selection =
            "${CalendarContract.Instances.CALENDAR_ID} IN ($placeholders) AND " +
                "(${CalendarContract.Instances.STATUS} IS NULL OR ${CalendarContract.Instances.STATUS} != ?)"
        val selectionArgs = (calendarIds + CalendarContract.Events.STATUS_CANCELED.toString())
            .toTypedArray()

        val events = mutableListOf<Map<String, Any?>>()
        contentResolver.query(
            instancesUri,
            projection,
            selection,
            selectionArgs,
            "${CalendarContract.Instances.BEGIN} ASC, ${CalendarContract.Instances.END} ASC",
        )?.use { cursor ->
            val instanceIdIndex = cursor.getColumnIndexOrThrow(CalendarContract.Instances._ID)
            val eventIdIndex = cursor.getColumnIndexOrThrow(CalendarContract.Instances.EVENT_ID)
            val calendarIdIndex = cursor.getColumnIndexOrThrow(CalendarContract.Instances.CALENDAR_ID)
            val calendarNameIndex = cursor.getColumnIndexOrThrow(
                CalendarContract.Instances.CALENDAR_DISPLAY_NAME,
            )
            val titleIndex = cursor.getColumnIndexOrThrow(CalendarContract.Instances.TITLE)
            val descriptionIndex = cursor.getColumnIndexOrThrow(
                CalendarContract.Instances.DESCRIPTION,
            )
            val beginIndex = cursor.getColumnIndexOrThrow(CalendarContract.Instances.BEGIN)
            val endIndex = cursor.getColumnIndexOrThrow(CalendarContract.Instances.END)
            val allDayIndex = cursor.getColumnIndexOrThrow(CalendarContract.Instances.ALL_DAY)
            val timezoneIndex = cursor.getColumnIndexOrThrow(
                CalendarContract.Instances.EVENT_TIMEZONE,
            )
            val recurrenceIndex = cursor.getColumnIndexOrThrow(CalendarContract.Instances.RRULE)

            while (cursor.moveToNext()) {
                events.add(
                    mapOf(
                        "instanceId" to cursor.getLong(instanceIdIndex).toString(),
                        "eventId" to cursor.getLong(eventIdIndex).toString(),
                        "calendarId" to cursor.getLong(calendarIdIndex).toString(),
                        "calendarName" to cursor.getString(calendarNameIndex),
                        "title" to cursor.getString(titleIndex).orEmpty(),
                        "description" to cursor.getString(descriptionIndex),
                        "startMillis" to cursor.getLong(beginIndex),
                        "endMillis" to cursor.getLong(endIndex),
                        "allDay" to (cursor.getInt(allDayIndex) != 0),
                        "eventTimezone" to cursor.getString(timezoneIndex),
                        "recurrenceRule" to cursor.getString(recurrenceIndex),
                    ),
                )
            }
        }
        return events
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
        if (requestCode == CALENDAR_WRITE_PERMISSION_REQUEST_CODE) {
            val pending = pendingCalendarWritePermissionResult
            pendingCalendarWritePermissionResult = null
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
        const val METHOD_CALENDAR_WRITE_PERMISSION_GRANTED =
            "calendarWritePermissionGranted"
        const val METHOD_REQUEST_CALENDAR_WRITE_PERMISSION =
            "requestCalendarWritePermission"
        const val METHOD_CREATE_DEVICE_CALENDAR_EVENT = "createDeviceCalendarEvent"
        const val METHOD_UPDATE_DEVICE_CALENDAR_EVENT = "updateDeviceCalendarEvent"
        const val METHOD_DELETE_DEVICE_CALENDAR_EVENT = "deleteDeviceCalendarEvent"
        const val METHOD_LIST_DEVICE_CALENDARS = "listDeviceCalendars"
        const val METHOD_LIST_DEVICE_CALENDAR_EVENTS = "listDeviceCalendarEvents"
        const val CALENDAR_PERMISSION_REQUEST_CODE = 4102
        const val CALENDAR_WRITE_PERMISSION_REQUEST_CODE = 4103
        const val MAX_EVENT_QUERY_CALENDARS = 20
        const val MAX_EVENT_QUERY_WINDOW_MILLIS = 93L * 24L * 60L * 60L * 1000L
    }
}
