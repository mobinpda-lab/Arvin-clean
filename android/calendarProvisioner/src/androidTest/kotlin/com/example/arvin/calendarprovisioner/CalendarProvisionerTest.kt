package com.example.arvin.calendarprovisioner

import android.Manifest
import android.content.Context
import android.provider.CalendarContract
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.rule.GrantPermissionRule
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
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
        context.contentResolver.query(
            CalendarContract.Calendars.CONTENT_URI,
            projection,
            "${CalendarContract.Calendars._ID} = ?",
            arrayOf(second.id.toString()),
            null,
        )?.use { cursor ->
            assertTrue("Provisioned calendar must be queryable", cursor.moveToFirst())
            assertEquals("Exactly one row must match the provisioned calendar id", 1, cursor.count)
            val accountName = cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.ACCOUNT_NAME))
            val accountType = cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.ACCOUNT_TYPE))
            val displayName = cursor.getString(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.CALENDAR_DISPLAY_NAME))
            val accessLevel = cursor.getInt(cursor.getColumnIndexOrThrow(CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL))
            assertEquals(CalendarProvisioner.ACCOUNT_NAME, accountName)
            assertEquals(CalendarProvisioner.ACCOUNT_TYPE, accountType)
            assertEquals(CalendarProvisioner.CALENDAR_NAME, displayName)
            assertTrue("Calendar must be writable", accessLevel >= 500)

            val providerEvidence = "CALENDAR_PROVIDER_ROW=PASS id=${second.id} account=ARVIN_CI_ACCEPTANCE accountType=${CalendarProvisioner.ACCOUNT_TYPE} displayName=ARVIN_CI_ACCEPTANCE accessLevel=$accessLevel rowCount=${cursor.count}"
            println(providerEvidence)
            android.util.Log.i("CalendarProvisionerTest", providerEvidence)
        } ?: throw AssertionError("Calendar Provider query returned no cursor")
        val evidence = "CALENDAR_PROVISIONER=PASS calendarId=${second.id} account=${second.accountName} accessLevel>=500"
        println(evidence)
        android.util.Log.i("CalendarProvisionerTest", evidence)
    }
}
