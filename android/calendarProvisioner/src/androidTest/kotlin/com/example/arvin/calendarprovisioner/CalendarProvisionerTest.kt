package com.example.arvin.calendarprovisioner

import android.accounts.AccountManager
import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.provider.CalendarContract
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.rule.GrantPermissionRule
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import android.util.Log
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class CalendarProvisionerTest {
    @get:Rule
    val permissions: GrantPermissionRule = GrantPermissionRule.grant(
        Manifest.permission.READ_CALENDAR,
        Manifest.permission.WRITE_CALENDAR,
    )

    @Test
    fun provisionsExactlyOneWritableCalendarIdempotently() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        val first = CalendarProvisioner.ensureProvisioned(context)
        val second = CalendarProvisioner.ensureProvisioned(context)
        assertEquals(first.id, second.id)
        assertEquals(CalendarProvisioner.ACCOUNT_NAME, second.accountName)
        assertEquals(CalendarProvisioner.ACCOUNT_TYPE, second.accountType)

        val projection = arrayOf(CalendarContract.Calendars._ID, CalendarContract.Calendars.ACCOUNT_NAME, CalendarContract.Calendars.ACCOUNT_TYPE, CalendarContract.Calendars.CALENDAR_DISPLAY_NAME, CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL)
        context.contentResolver.query(CalendarContract.Calendars.CONTENT_URI, projection, "${CalendarContract.Calendars._ID} = ?", arrayOf(second.id.toString()), null)?.use { cursor ->
            assertTrue("Provisioned calendar must be queryable", cursor.moveToFirst())
            assertEquals(CalendarProvisioner.ACCOUNT_NAME, cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.ACCOUNT_NAME)))
            assertEquals(CalendarProvisioner.ACCOUNT_TYPE, cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.ACCOUNT_TYPE)))
            assertEquals(CalendarProvisioner.CALENDAR_NAME, cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.CALENDAR_DISPLAY_NAME)))
            assertTrue("Calendar must be writable", cursor.getInt(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL)) >= 500)
        } ?: throw AssertionError("Calendar Provider query returned no cursor")
        emitForensicCheckpoint(context, "B-after-provisioner-assertions")
        val evidence = "CALENDAR_PROVISIONER=PASS calendarId=${second.id} account=${second.accountName} accessLevel>=500"
        println(evidence)
        android.util.Log.i("CalendarProvisionerTest", evidence)
    }
    private fun emitForensicCheckpoint(context: Context, label: String) {
        val tag = "CalendarProvisionerForensics"
        val accountName = CalendarProvisioner.ACCOUNT_NAME
        val accountType = CalendarProvisioner.ACCOUNT_TYPE
        Log.i(tag, "CHECKPOINT_BEGIN label=$label timestamp_epoch_ms=${System.currentTimeMillis()} sdk=${Build.VERSION.SDK_INT} model=${Build.MODEL} fingerprint=${Build.FINGERPRINT}")
        Log.i(tag, "COMMAND=PackageManager.getPackageInfo(${context.packageName})")
        try {
            context.packageManager.getPackageInfo(context.packageName, 0)
            Log.i(tag, "PACKAGE_STATUS package=${context.packageName} installed=true EXIT_CODE=0")
        } catch (error: PackageManager.NameNotFoundException) {
            Log.i(tag, "PACKAGE_STATUS package=${context.packageName} installed=false EXIT_CODE=1 error=${error.javaClass.simpleName}")
        } catch (error: Exception) {
            Log.i(tag, "PACKAGE_STATUS package=${context.packageName} installed=unknown EXIT_CODE=1 error=${error.javaClass.simpleName}")
        }
        Log.i(tag, "COMMAND=AccountManager.get(context).getAccountsByType(accountType)")
        try {
            val accounts = AccountManager.get(context).getAccountsByType(accountType)
            val matchingCount = accounts.count { it.name == accountName }
            Log.i(tag, "ACCOUNT_STATUS source=AccountManager.getAccountsByType account_name=${accountName} account_type=${accountType} matching_count=${matchingCount} exists=${matchingCount > 0} EXIT_CODE=0")
        } catch (error: Exception) {
            Log.i(tag, "ACCOUNT_STATUS source=AccountManager.getAccountsByType exists=unknown EXIT_CODE=1 error=${error.javaClass.simpleName}")
        }
        val projection = arrayOf(
            CalendarContract.Calendars._ID,
            CalendarContract.Calendars.ACCOUNT_NAME,
            CalendarContract.Calendars.ACCOUNT_TYPE,
            CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,
            CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL,
        )
        Log.i(tag, "COMMAND=ContentResolver.query(CalendarContract.Calendars.CONTENT_URI, projection)")
        var rowCount = 0
        var matchingCount = 0
        try {
            val cursor = context.contentResolver.query(CalendarContract.Calendars.CONTENT_URI, projection, null, null, null)
                ?: throw IllegalStateException("Calendar Provider returned a null cursor")
            cursor.use {
                while (it.moveToNext()) {
                    rowCount++
                    val id = it.getLong(it.getColumnIndexOrThrow(CalendarContract.Calendars._ID))
                    val rowAccountName = it.getString(it.getColumnIndexOrThrow(CalendarContract.Calendars.ACCOUNT_NAME)).orEmpty()
                    val rowAccountType = it.getString(it.getColumnIndexOrThrow(CalendarContract.Calendars.ACCOUNT_TYPE)).orEmpty()
                    val displayName = it.getString(it.getColumnIndexOrThrow(CalendarContract.Calendars.CALENDAR_DISPLAY_NAME)).orEmpty()
                    val accessLevel = it.getInt(it.getColumnIndexOrThrow(CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL))
                    val targetAccount = rowAccountName == accountName && rowAccountType == accountType
                    val expectedCalendar = targetAccount && displayName == CalendarProvisioner.CALENDAR_NAME && accessLevel >= 500
                    if (expectedCalendar) matchingCount++
                    Log.i(tag, "CALENDAR_ROW id=$id account_name=${if (targetAccount) rowAccountName else "<redacted>"} account_type=${if (targetAccount) rowAccountType else "<redacted>"} display_name=${if (targetAccount && displayName == CalendarProvisioner.CALENDAR_NAME) displayName else "<redacted>"} access_level=$accessLevel expected_calendar=$expectedCalendar")
                }
            }
            Log.i(tag, "CALENDAR_QUERY_STATUS EXIT_CODE=0 raw_row_count=$rowCount matching_expected_calendar_count=$matchingCount")
        } catch (error: Exception) {
            Log.i(tag, "CALENDAR_QUERY_STATUS EXIT_CODE=1 raw_row_count=unknown matching_expected_calendar_count=unknown error=${error.javaClass.simpleName}")
        }
        Log.i(tag, "CHECKPOINT_END label=$label timestamp_epoch_ms=${System.currentTimeMillis()}")
    }

}
