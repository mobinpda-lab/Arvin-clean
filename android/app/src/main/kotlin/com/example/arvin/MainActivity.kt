package com.example.arvin

import android.Manifest
import android.content.ContentUris
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
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
    private var pendingCalendarAccessPermissionResult: MethodChannel.Result? = null

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
                    val reminderId = call.argument<String>("reminderId")
                    if (!isExportableTaskReminderId(reminderId)) {
                        result.error("invalid_reminder_id", "Only Task and TaskReminder identities may be exported", null)
                        return@setMethodCallHandler
                    }
                    if (!hasCalendarWritePermission()) {
                        result.error("calendar_write_permission_denied", "Calendar write permission is required", null)
                        return@setMethodCallHandler
                    }
                    val calendarId = call.argument<String>("calendarId")?.trim()?.toLongOrNull()
                    val title = call.argument<String>("title")?.trim().orEmpty()
                    val startMillis = call.argument<Number>("startMillis")?.toLong()
                    val endMillis = call.argument<Number>("endMillis")?.toLong()
                    val allDay = call.argument<Boolean>("allDay") ?: false
                    val description = call.argument<String>("description")?.trim()
                    if (calendarId == null || title.isEmpty() || startMillis == null || endMillis == null || endMillis <= startMillis) {
                        result.error("invalid_event", "Calendar provider event payload is incomplete", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val existingEventId = findOwnedProviderEventId(calendarId, reminderId!!)
                        if (existingEventId != null) {
                            result.success(existingEventId.toString())
                        } else {
                            val uri = contentResolver.insert(
                                CalendarContract.Events.CONTENT_URI,
                                eventValues(calendarId, reminderId, title, startMillis, endMillis, allDay, description),
                            )
                            result.success(uri?.lastPathSegment)
                        }
                    } catch (error: SecurityException) {
                        result.error("calendar_write_denied", "Android Calendar Provider denied create", error.message)
                    } catch (error: RuntimeException) {
                        result.error("calendar_write_failed", "Android Calendar Provider create failed", error.message)
                    }
                }
                METHOD_UPDATE_DEVICE_CALENDAR_EVENT -> {
                    val reminderId = call.argument<String>("reminderId")
                    if (!isExportableTaskReminderId(reminderId)) {
                        result.error("invalid_reminder_id", "Only Task and TaskReminder identities may be exported", null)
                        return@setMethodCallHandler
                    }
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
                    val description = call.argument<String>("description")?.trim()
                    if (calendarId == null || eventId == null || title.isEmpty() || startMillis == null || endMillis == null || endMillis <= startMillis) {
                        result.error("invalid_event", "Calendar provider update payload is incomplete", null)
                        return@setMethodCallHandler
                    }
                    try {
                        // Selection is not permitted on an item URI by Calendar Provider.
                        // Use the collection URI and constrain both row and owner calendar.
                        val updated = contentResolver.update(
                            CalendarContract.Events.CONTENT_URI,
                            eventValues(calendarId, reminderId!!, title, startMillis, endMillis, allDay, description),
                            eventOwnershipSelection(),
                            eventOwnershipArgs(eventId, calendarId, reminderId!!),
                        )
                        result.success(updated == 1)
                    } catch (error: SecurityException) {
                        result.error("calendar_write_denied", "Android Calendar Provider denied update", error.message)
                    } catch (error: RuntimeException) {
                        result.error("calendar_write_failed", "Android Calendar Provider update failed", error.message)
                    }
                }
                METHOD_OPEN_DEVICE_CALENDAR_EVENT -> {
                    val calendarIdText = call.argument<String>("calendarId")?.trim().orEmpty()
                    val calendarId = calendarIdText.toLongOrNull()
                    val eventId = call.argument<String>("eventId")?.trim()?.toLongOrNull()
                    if (calendarId == null || eventId == null) {
                        result.error("invalid_event", "Calendar event identifiers are invalid", null)
                        return@setMethodCallHandler
                    }
                    val editIntent = Intent(Intent.ACTION_EDIT).apply {
                        data = ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, eventId)
                        putExtra(CalendarContract.Events.CALENDAR_ID, calendarId)
                    }
                    if (editIntent.resolveActivity(packageManager) == null) {
                        result.success(false)
                    } else {
                        try {
                            startActivity(editIntent)
                            result.success(true)
                        } catch (error: RuntimeException) {
                            result.error("calendar_editor_unavailable", "No calendar editor could open this event", error.message)
                        }
                    }
                }
                METHOD_VERIFY_DEVICE_CALENDAR_EVENT -> {
                    val reminderId = call.argument<String>("reminderId")
                    if (!isExportableTaskReminderId(reminderId)) {
                        result.error("invalid_reminder_id", "Only Task and TaskReminder identities may be verified", null)
                        return@setMethodCallHandler
                    }
                    if (!hasCalendarReadPermission()) {
                        result.error("calendar_read_permission_denied", "Calendar read permission is required to verify a linked event", null)
                        return@setMethodCallHandler
                    }
                    val calendarIdText = call.argument<String>("calendarId")?.trim().orEmpty()
                    val calendarId = calendarIdText.toLongOrNull()
                    val eventId = call.argument<String>("eventId")?.trim()?.toLongOrNull()
                    if (calendarId == null || eventId == null) {
                        result.error("invalid_event", "Calendar event identity is incomplete", null)
                        return@setMethodCallHandler
                    }
                    try {
                        var exists = false
                        contentResolver.query(
                            CalendarContract.Events.CONTENT_URI,
                            arrayOf(
                                CalendarContract.Events._ID,
                                CalendarContract.Events.CALENDAR_ID,
                                CalendarContract.Events.CUSTOM_APP_PACKAGE,
                                CalendarContract.Events.CUSTOM_APP_URI,
                            ),
                            eventOwnershipSelection(),
                            eventOwnershipArgs(eventId, calendarId, reminderId!!),
                            null,
                        )?.use { cursor ->
                            exists = cursor.moveToFirst() &&
                                cursor.getLong(cursor.getColumnIndexOrThrow(CalendarContract.Events._ID)) == eventId &&
                                cursor.getLong(cursor.getColumnIndexOrThrow(CalendarContract.Events.CALENDAR_ID)) == calendarId &&
                                cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Events.CUSTOM_APP_PACKAGE)) == packageName &&
                                cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Events.CUSTOM_APP_URI)) == customAppUriForReminder(reminderId!!)
                        }
                        result.success(exists)
                    } catch (error: SecurityException) {
                        result.error("calendar_read_denied", "Android Calendar Provider denied linked-event verification", error.message)
                    } catch (error: RuntimeException) {
                        result.error("calendar_query_failed", "Android Calendar Provider linked-event verification failed", error.message)
                    }
                }
                METHOD_DELETE_DEVICE_CALENDAR_EVENT -> {
                    val reminderId = call.argument<String>("reminderId")
                    if (!isExportableTaskReminderId(reminderId)) {
                        result.error("invalid_reminder_id", "Only Task and TaskReminder identities may be exported", null)
                        return@setMethodCallHandler
                    }
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
                        // Use the collection URI because Calendar Provider rejects selections
                        // attached to a row-specific Events URI.
                        val deleted = contentResolver.delete(
                            CalendarContract.Events.CONTENT_URI,
                            eventOwnershipSelection(),
                            eventOwnershipArgs(eventId, calendarId, reminderId!!),
                        )
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
                METHOD_REQUEST_CALENDAR_ACCESS_PERMISSIONS -> {
                    if (hasCalendarReadPermission() && hasCalendarWritePermission()) {
                        result.success(true)
                        return@setMethodCallHandler
                    }
                    if (pendingCalendarAccessPermissionResult != null) {
                        result.error(
                            "permission_request_in_progress",
                            "Calendar access permission request is already active",
                            null,
                        )
                        return@setMethodCallHandler
                    }
                    pendingCalendarAccessPermissionResult = result
                    val permissions = mutableListOf<String>()
                    if (!hasCalendarReadPermission()) {
                        permissions.add(Manifest.permission.READ_CALENDAR)
                    }
                    if (!hasCalendarWritePermission()) {
                        permissions.add(Manifest.permission.WRITE_CALENDAR)
                    }
                    ActivityCompat.requestPermissions(
                        this,
                        permissions.toTypedArray(),
                        CALENDAR_ACCESS_PERMISSION_REQUEST_CODE,
                    )
                }
                METHOD_ENSURE_ARVIN_LOCAL_CALENDAR -> {
                    if (!hasCalendarReadPermission() || !hasCalendarWritePermission()) {
                        result.error(
                            "calendar_access_permission_denied",
                            "Read and write calendar permissions are required to ensure Arvin's local calendar",
                            null,
                        )
                        return@setMethodCallHandler
                    }
                    try {
                        result.success(ensureArvinLocalCalendar())
                    } catch (error: SecurityException) {
                        result.error("calendar_write_denied", "Android Calendar Provider denied local Arvin calendar creation", error.message)
                    } catch (error: RuntimeException) {
                        result.error("calendar_local_creation_failed", "Unable to ensure the local Arvin calendar", error.message)
                    }
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

    private fun isExportableTaskReminderId(reminderId: String?): Boolean {
        val id = reminderId?.trim().orEmpty()
        val prefix = listOf(
            "task-due:",
            "task-reminder-item:",
            "task-reminder:",
            "task-recurrence:",
        ).firstOrNull { id.startsWith(it) } ?: return false
        return id.removePrefix(prefix).isNotBlank()
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

    /**
     * Creates or reuses only the app-owned local Arvin calendar. A matching
     * display name alone is never treated as proof of ownership.
     */
    @Synchronized
    private fun ensureArvinLocalCalendar(): Map<String, Any?> {
        val accountName = packageName
        val accountType = CalendarContract.ACCOUNT_TYPE_LOCAL
        val uri = arvinLocalCalendarSyncAdapterUri(accountName, accountType)
        val selection =
            "${CalendarContract.Calendars.ACCOUNT_NAME} = ? AND " +
                "${CalendarContract.Calendars.ACCOUNT_TYPE} = ? AND " +
                "${CalendarContract.Calendars.NAME} = ? AND " +
                "${CalendarContract.Calendars.OWNER_ACCOUNT} = ?"
        val args = arrayOf(
            accountName,
            accountType,
            ARVIN_LOCAL_CALENDAR_NAME,
            accountName,
        )
        val ids = mutableListOf<Long>()
        contentResolver.query(
            uri,
            arrayOf(CalendarContract.Calendars._ID),
            selection,
            args,
            null,
        )?.use { cursor ->
            val idIndex = cursor.getColumnIndexOrThrow(CalendarContract.Calendars._ID)
            while (cursor.moveToNext()) ids.add(cursor.getLong(idIndex))
        }

        check(ids.size <= 1) {
            "Multiple app-owned Arvin local calendars were found; refusing to create another"
        }
        val calendarId = if (ids.size == 1) {
            ids.single()
        } else {
            val values = ContentValues().apply {
                put(CalendarContract.Calendars.ACCOUNT_NAME, accountName)
                put(CalendarContract.Calendars.ACCOUNT_TYPE, accountType)
                put(CalendarContract.Calendars.NAME, ARVIN_LOCAL_CALENDAR_NAME)
                put(CalendarContract.Calendars.CALENDAR_DISPLAY_NAME, ARVIN_LOCAL_CALENDAR_DISPLAY_NAME)
                put(CalendarContract.Calendars.OWNER_ACCOUNT, accountName)
                put(CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL, CalendarContract.Calendars.CAL_ACCESS_OWNER)
                put(CalendarContract.Calendars.CALENDAR_TIME_ZONE, TimeZone.getDefault().id)
                put(CalendarContract.Calendars.VISIBLE, 1)
                put(CalendarContract.Calendars.SYNC_EVENTS, 0)
            }
            val inserted = contentResolver.insert(uri, values)
                ?: error("Calendar Provider returned no URI for the local Arvin calendar")
            inserted.lastPathSegment?.toLongOrNull()
                ?: error("Calendar Provider returned an invalid local Arvin calendar ID")
        }

        val projection = arrayOf(
            CalendarContract.Calendars._ID,
            CalendarContract.Calendars.ACCOUNT_NAME,
            CalendarContract.Calendars.ACCOUNT_TYPE,
            CalendarContract.Calendars.NAME,
            CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,
            CalendarContract.Calendars.OWNER_ACCOUNT,
            CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL,
        )
        contentResolver.query(
            uri,
            projection,
            "${CalendarContract.Calendars._ID} = ?",
            arrayOf(calendarId.toString()),
            null,
        )?.use { cursor ->
            check(cursor.moveToFirst()) { "The local Arvin calendar could not be read back" }
            check(cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.ACCOUNT_NAME)) == accountName)
            check(cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.ACCOUNT_TYPE)) == accountType)
            check(cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.NAME)) == ARVIN_LOCAL_CALENDAR_NAME)
            check(cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.OWNER_ACCOUNT)) == accountName)
            val access = cursor.getInt(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL))
            check(access >= CalendarContract.Calendars.CAL_ACCESS_OWNER) { "The local Arvin calendar is not writable" }
            return mapOf(
                "id" to cursor.getLong(cursor.getColumnIndexOrThrow(CalendarContract.Calendars._ID)).toString(),
                "displayName" to cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.CALENDAR_DISPLAY_NAME)),
                "accountName" to accountName,
                "accountType" to accountType,
                "ownerAccount" to accountName,
                "accessLevel" to access,
                "isArvinLocal" to true,
            )
        }
        error("Calendar Provider returned no cursor while verifying the local Arvin calendar")
    }

    private fun arvinLocalCalendarSyncAdapterUri(
        accountName: String,
        accountType: String,
    ): Uri = CalendarContract.Calendars.CONTENT_URI.buildUpon()
        .appendQueryParameter(CalendarContract.CALLER_IS_SYNCADAPTER, "true")
        .appendQueryParameter(CalendarContract.Calendars.ACCOUNT_NAME, accountName)
        .appendQueryParameter(CalendarContract.Calendars.ACCOUNT_TYPE, accountType)
        .build()

    private fun customAppUriForReminder(reminderId: String): String =
        Uri.Builder().scheme("arvin").authority("task").appendPath(reminderId).build().toString()

    private fun eventOwnershipSelection(): String =
        CalendarContract.Events._ID + " = ? AND " +
            CalendarContract.Events.CALENDAR_ID + " = ? AND " +
            CalendarContract.Events.CUSTOM_APP_PACKAGE + " = ? AND " +
            CalendarContract.Events.CUSTOM_APP_URI + " = ?"

    private fun eventOwnershipArgs(eventId: Long, calendarId: Long, reminderId: String): Array<String> =
        arrayOf(eventId.toString(), calendarId.toString(), packageName, customAppUriForReminder(reminderId))

    private fun findOwnedProviderEventId(calendarId: Long, reminderId: String): Long? {
        val ids = mutableListOf<Long>()
        contentResolver.query(
            CalendarContract.Events.CONTENT_URI,
            arrayOf(CalendarContract.Events._ID),
            CalendarContract.Events.CALENDAR_ID + " = ? AND " +
                CalendarContract.Events.CUSTOM_APP_PACKAGE + " = ? AND " +
                CalendarContract.Events.CUSTOM_APP_URI + " = ?",
            arrayOf(calendarId.toString(), packageName, customAppUriForReminder(reminderId)),
            null,
        )?.use { cursor ->
            val index = cursor.getColumnIndexOrThrow(CalendarContract.Events._ID)
            while (cursor.moveToNext()) ids.add(cursor.getLong(index))
        }
        check(ids.size <= 1) { "Multiple Arvin-owned events exist for one Task and calendar" }
        return ids.singleOrNull()
    }

    private fun eventValues(
        calendarId: Long,
        reminderId: String,
        title: String,
        startMillis: Long,
        endMillis: Long,
        allDay: Boolean,
        description: String?,
    ): ContentValues = ContentValues().apply {
        put(CalendarContract.Events.CALENDAR_ID, calendarId)
        put(CalendarContract.Events.CUSTOM_APP_PACKAGE, packageName)
        put(CalendarContract.Events.CUSTOM_APP_URI, customAppUriForReminder(reminderId))
        put(CalendarContract.Events.TITLE, title)
        put(CalendarContract.Events.DTSTART, startMillis)
        put(CalendarContract.Events.DTEND, endMillis)
        put(CalendarContract.Events.ALL_DAY, if (allDay) 1 else 0)
        if (!description.isNullOrBlank()) put(CalendarContract.Events.DESCRIPTION, description)
        put(CalendarContract.Events.EVENT_TIMEZONE, if (allDay) "UTC" else TimeZone.getDefault().id)
    }

    private fun readDeviceCalendars(): List<Map<String, Any?>> {
        val projection = arrayOf(
            CalendarContract.Calendars._ID,
            CalendarContract.Calendars.NAME,
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
            val nameIndex = cursor.getColumnIndexOrThrow(CalendarContract.Calendars.NAME)
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
                        "isArvinLocal" to (
                            cursor.getString(accountNameIndex) == packageName &&
                                cursor.getString(accountTypeIndex) == CalendarContract.ACCOUNT_TYPE_LOCAL &&
                                cursor.getString(nameIndex) == ARVIN_LOCAL_CALENDAR_NAME &&
                                cursor.getString(ownerAccountIndex) == packageName
                        ),
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
        if (requestCode == CALENDAR_ACCESS_PERMISSION_REQUEST_CODE) {
            val pending = pendingCalendarAccessPermissionResult
            pendingCalendarAccessPermissionResult = null
            val granted = hasCalendarReadPermission() && hasCalendarWritePermission()
            pending?.success(granted)
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
        const val METHOD_CALENDAR_READ_PERMISSION_GRANTED =
            "calendarReadPermissionGranted"
        const val METHOD_REQUEST_CALENDAR_READ_PERMISSION =
            "requestCalendarReadPermission"
        const val METHOD_CALENDAR_WRITE_PERMISSION_GRANTED =
            "calendarWritePermissionGranted"
        const val METHOD_REQUEST_CALENDAR_WRITE_PERMISSION =
            "requestCalendarWritePermission"
        const val METHOD_REQUEST_CALENDAR_ACCESS_PERMISSIONS = "requestCalendarAccessPermissions"
        const val METHOD_CREATE_DEVICE_CALENDAR_EVENT = "createDeviceCalendarEvent"
        const val METHOD_UPDATE_DEVICE_CALENDAR_EVENT = "updateDeviceCalendarEvent"
        const val METHOD_VERIFY_DEVICE_CALENDAR_EVENT = "verifyDeviceCalendarEvent"
        const val METHOD_DELETE_DEVICE_CALENDAR_EVENT = "deleteDeviceCalendarEvent"
        const val METHOD_OPEN_DEVICE_CALENDAR_EVENT = "openDeviceCalendarEvent"
        const val METHOD_ENSURE_ARVIN_LOCAL_CALENDAR = "ensureArvinLocalCalendar"
        const val ARVIN_LOCAL_CALENDAR_NAME = "com.example.arvin.local.calendar.v1"
        const val ARVIN_LOCAL_CALENDAR_DISPLAY_NAME = "Arvin"
        const val METHOD_LIST_DEVICE_CALENDARS = "listDeviceCalendars"
        const val METHOD_LIST_DEVICE_CALENDAR_EVENTS = "listDeviceCalendarEvents"
        const val CALENDAR_PERMISSION_REQUEST_CODE = 4102
        const val CALENDAR_WRITE_PERMISSION_REQUEST_CODE = 4103
        const val CALENDAR_ACCESS_PERMISSION_REQUEST_CODE = 4104
        const val MAX_EVENT_QUERY_CALENDARS = 20
        const val MAX_EVENT_QUERY_WINDOW_MILLIS = 93L * 24L * 60L * 60L * 1000L
    }
}
