# Automatic FollowUp alarm scheduler — 2026-08-26

## Scope
This slice connects the merged Automatic FollowUp delivery foundation to Arvin's existing `android_alarm_manager_plus` stack without introducing another scheduler package or persistence source.

## What changed
- `AutomaticFollowUpService` can now expose all authoritative scheduled candidates, while `dueCandidates` remains the due-only projection used by UI/background delivery.
- `AutomaticFollowUpCandidate.deliveryIdentity` is shared by delivery and scheduling so the same schedule is not treated as two different jobs.
- `AutomaticFollowUpBackgroundRunner.decodeDeliveryState` exposes the existing delivery metadata safely to the scheduler.
- `AutomaticFollowUpAlarmPlanner` chooses the nearest not-yet-delivered schedule and clamps overdue retries to a short future delay.
- `AndroidAutomaticFollowUpScheduler` keeps one Android alarm, runs the existing background runner, then reschedules the next pending canonical FollowUp.

## Runtime dependency
This slice depends on the shared Android reboot/runtime contract from PR #187. It must not merge before that runtime change is validated and integrated on main.

## Validation
Focused planner tests cover earliest candidate ordering, delivery-state skipping, overdue retry delay, inactive task exclusion, and superseded old schedules.

## Architecture guard
- Canonical `Task.followUps` stays the source of truth.
- `arvin.followup.notificationState` remains delivery metadata only.
- No new database/repository/scheduler package.
- One AlarmManager alarm is reused for the nearest pending FollowUp.
- UI/write-path rescheduling is deliberately a later integration slice after this scheduler core and PR #187 are green.
