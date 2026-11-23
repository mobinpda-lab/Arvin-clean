# Android alarm reboot runtime — 2026-08-26

## Verified gap
Arvin already calls Android AlarmManager with `rescheduleOnReboot: true` in `AndroidBackupScheduler`, but the checked-in Android manifest had the AlarmManager reboot receiver disabled and did not request `RECEIVE_BOOT_COMPLETED`.

That mismatch could make a compile-green alarm fail to restore after device reboot. It also blocks safe reuse of the same AlarmManager foundation for Automatic FollowUp.

## Change
- Keep the existing `SCHEDULE_EXACT_ALARM` permission.
- Add `android.permission.RECEIVE_BOOT_COMPLETED`.
- Enable the existing `dev.fluttercommunity.plus.androidalarmmanager.RebootBroadcastReceiver`.
- Keep the existing AlarmService/BroadcastReceiver entries and packages unchanged.

## Validation
`test/android_alarm_manifest_contract_test.dart` locks the runtime manifest contract so future generated-platform or dependency changes do not silently disable reboot rescheduling.

## Architecture guard
- No new scheduler package.
- No second alarm foundation.
- No Task/FollowUp/Backup storage change.
- This is shared Android runtime infrastructure already required by existing backup scheduling and the next Automatic FollowUp trigger slice.

## Next product slice
After exact-head CI/APK and merge, wire the merged Automatic FollowUp background runner to the existing AlarmManager foundation and validate scheduling/cancellation behavior without creating another scheduler source of truth.
