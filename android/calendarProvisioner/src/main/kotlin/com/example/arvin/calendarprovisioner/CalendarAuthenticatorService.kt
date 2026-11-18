package com.example.arvin.calendarprovisioner

import android.accounts.AbstractAccountAuthenticator
import android.accounts.Account
import android.accounts.AccountAuthenticatorResponse
import android.app.Service
import android.content.Intent
import android.os.Bundle
import android.os.IBinder

class CalendarAuthenticatorService : Service() {
    private lateinit var authenticator: AbstractAccountAuthenticator

    override fun onCreate() {
        super.onCreate()
        authenticator = object : AbstractAccountAuthenticator(this) {
            override fun editProperties(response: AccountAuthenticatorResponse?, accountType: String?) =
                throw UnsupportedOperationException("Account properties are not editable")
            override fun addAccount(response: AccountAuthenticatorResponse?, accountType: String?, authTokenType: String?, requiredFeatures: Array<out String>?, options: Bundle?) = Bundle()
            override fun confirmCredentials(response: AccountAuthenticatorResponse?, account: Account?, options: Bundle?) = Bundle()
            override fun getAuthToken(response: AccountAuthenticatorResponse?, account: Account?, authTokenType: String?, options: Bundle?) = Bundle()
            override fun getAuthTokenLabel(authTokenType: String?) = ""
            override fun updateCredentials(response: AccountAuthenticatorResponse?, account: Account?, authTokenType: String?, options: Bundle?) = Bundle()
            override fun hasFeatures(response: AccountAuthenticatorResponse?, account: Account?, features: Array<out String>?) =
                Bundle().apply { putBoolean("booleanResult", false) }
        }
    }

    override fun onBind(intent: Intent?): IBinder = authenticator.iBinder
}
