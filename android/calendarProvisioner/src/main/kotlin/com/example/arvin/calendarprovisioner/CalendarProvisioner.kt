package com.example.arvin.calendarprovisioner

import android.accounts.Account
import android.accounts.AccountManager
import android.content.ContentResolver
import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.provider.CalendarContract

object CalendarProvisioner {
    const val ACCOUNT_NAME = "ARVIN CI Acceptance"
    const val ACCOUNT_TYPE = "com.example.arvin.calendarprovisioner.account"
    const val CALENDAR_NAME = "ARVIN CI Acceptance"
    private const val AUTHORITY = CalendarContract.AUTHORITY

    data class ProvisionedCalendar(val id: Long, val accountName: String, val accountType: String)

    fun ensureProvisioned(context: Context): ProvisionedCalendar {
        val appContext = context.applicationContext
        val account = Account(ACCOUNT_NAME, ACCOUNT_TYPE)
        val manager = AccountManager.get(appContext)
        val registered = manager.getAccountsByType(ACCOUNT_TYPE).any { it.name == ACCOUNT_NAME }
        check(registered || manager.addAccountExplicitly(account, null, null)) {
            "Unable to register the ARVIN CI acceptance account"
        }

        ContentResolver.setIsSyncable(account, AUTHORITY, 1)
        ContentResolver.setSyncAutomatically(account, AUTHORITY, true)
        val uri = syncAdapterUri(CalendarContract.Calendars.CONTENT_URI, account)
        val selection = "${CalendarContract.Calendars.ACCOUNT_NAME} = ? AND ${CalendarContract.Calendars.ACCOUNT_TYPE} = ? AND ${CalendarContract.Calendars.CALENDAR_DISPLAY_NAME} = ?"
        appContext.contentResolver.query(uri, arrayOf(CalendarContract.Calendars._ID), selection, arrayOf(ACCOUNT_NAME, ACCOUNT_TYPE, CALENDAR_NAME), null)?.use { cursor ->
            if (cursor.moveToFirst()) {
                check(cursor.count == 1) { "Duplicate ARVIN CI acceptance calendars were found" }
                return verify(appContext, cursor.getLong(cursor.getColumnIndexOrThrow(CalendarContract.Calendars._ID)))
            }
        }

        val values = ContentValues().apply {
            put(CalendarContract.Calendars.ACCOUNT_NAME, ACCOUNT_NAME)
            put(CalendarContract.Calendars.ACCOUNT_TYPE, ACCOUNT_TYPE)
            put(CalendarContract.Calendars.NAME, CALENDAR_NAME)
            put(CalendarContract.Calendars.CALENDAR_DISPLAY_NAME, CALENDAR_NAME)
            put(CalendarContract.Calendars.OWNER_ACCOUNT, ACCOUNT_NAME)
            put(CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL, CalendarContract.Calendars.CAL_ACCESS_OWNER)
            put(CalendarContract.Calendars.CALENDAR_TIME_ZONE, "UTC")
            put(CalendarContract.Calendars.VISIBLE, 1)
            put(CalendarContract.Calendars.SYNC_EVENTS, 1)
        }
        val inserted = appContext.contentResolver.insert(uri, values) ?: error("Calendar Provider refused to create the acceptance calendar")
        val id = inserted.lastPathSegment?.toLongOrNull() ?: error("Calendar Provider returned an invalid calendar id")
        return verify(appContext, id)
    }

    private fun verify(context: Context, id: Long): ProvisionedCalendar {
        val uri = syncAdapterUri(CalendarContract.Calendars.CONTENT_URI, Account(ACCOUNT_NAME, ACCOUNT_TYPE))
        val projection = arrayOf(CalendarContract.Calendars._ID, CalendarContract.Calendars.ACCOUNT_NAME, CalendarContract.Calendars.ACCOUNT_TYPE, CalendarContract.Calendars.CALENDAR_DISPLAY_NAME, CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL)
        context.contentResolver.query(uri, projection, "${CalendarContract.Calendars._ID} = ?", arrayOf(id.toString()), null)?.use { cursor ->
            check(cursor.moveToFirst()) { "Provisioned calendar is not visible in Calendar Provider" }
            check(cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.ACCOUNT_NAME)) == ACCOUNT_NAME)
            check(cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.ACCOUNT_TYPE)) == ACCOUNT_TYPE)
            check(cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.CALENDAR_DISPLAY_NAME)) == CALENDAR_NAME)
            check(cursor.getInt(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL)) >= 500) { "Provisioned calendar is not writable" }
            return ProvisionedCalendar(id, ACCOUNT_NAME, ACCOUNT_TYPE)
        }
        error("Calendar Provider query returned no cursor")
    }

    private fun syncAdapterUri(uri: Uri, account: Account): Uri =
        uri.buildUpon()
            .appendQueryParameter(CalendarContract.CALLER_IS_SYNCADAPTER, "true")
            .appendQueryParameter(CalendarContract.Calendars.ACCOUNT_NAME, account.name)
            .appendQueryParameter(CalendarContract.Calendars.ACCOUNT_TYPE, account.type)
            .build()
}
