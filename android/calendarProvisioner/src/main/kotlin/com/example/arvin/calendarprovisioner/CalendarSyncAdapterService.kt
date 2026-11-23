package com.example.arvin.calendarprovisioner

import android.accounts.Account
import android.app.Service
import android.content.AbstractThreadedSyncAdapter
import android.content.ContentProviderClient
import android.content.Context
import android.content.Intent
import android.content.SyncResult
import android.os.Bundle
import android.os.IBinder

class CalendarSyncAdapterService : Service() {
    private lateinit var syncAdapter: AbstractThreadedSyncAdapter

    override fun onCreate() {
        super.onCreate()
        syncAdapter = object : AbstractThreadedSyncAdapter(this, true) {
            override fun onPerformSync(account: Account, extras: Bundle, authority: String, provider: ContentProviderClient, syncResult: SyncResult) {
                // CI-only local calendar: no remote data source is configured.
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder = syncAdapter.syncAdapterBinder
}
