# Automatic FollowUp background runner — 2026-08-26

## Scope
This slice advances Issue #180 from a user-facing due list toward real background-capable delivery while reusing existing canonical data and notification dependencies.

## What changed
- Added `AutomaticFollowUpBackgroundRunner` that loads canonical Tasks through existing `TaskStore` and derives due work through the merged `AutomaticFollowUpService`.
- Added `AutomaticFollowUpNotificationService` using the already-installed `flutter_local_notifications` package and a dedicated Arvin FollowUp notification channel.
- Background delivery stores only a small notification-delivery marker in SharedPreferences so the same latest FollowUp schedule is not repeatedly announced.
- A failed platform notification is not marked delivered and is retried by a later runner invocation.
- A newer authoritative FollowUp/nextFollowUp identity can notify again.
- Stale notification markers for deleted Tasks are pruned.

## Storage boundary
`arvin.tasks` remains the only Task/FollowUp source of truth. `arvin.followup.notificationState` is delivery metadata only; it does not duplicate Task, FollowUp, Reminder or scheduling domain data.

## Validation
Focused tests cover:
- one-time delivery of a due latest FollowUp;
- retry after notification failure;
- delivery of a new latest FollowUp after an older candidate was already announced;
- exclusion of future/completed items through canonical due logic.

## Existing foundation reused
- canonical `Task.followUps` + `TaskStore`;
- merged `AutomaticFollowUpService`;
- existing `flutter_local_notifications` dependency and initialization pattern already used by `BackupNotificationService`.

## Deliberate boundary
This PR does **not** register an Android AlarmManager schedule yet. The project already uses `android_alarm_manager_plus`, but runtime manifest/reboot/exact-alarm requirements must be audited against Arvin's generated Android platform before enabling a repeating background trigger. This prevents a compile-green but runtime-broken automatic scheduler from being claimed as delivery.

## Next slice
Reuse the existing AlarmManager foundation to invoke this runner periodically/background, add runtime/platform validation, and only then consider raising Automatic FollowUp above Stage 70.

## Guardrails
- No second Task/FollowUp/Reminder model.
- No new database/repository/storage source of truth.
- No new scheduler or notification package.
- No UI rewrite.
- Exact-head CI/APK required before merge.
