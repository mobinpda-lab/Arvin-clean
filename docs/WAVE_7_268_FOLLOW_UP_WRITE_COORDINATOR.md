# Wave 7.268 — Follow-up persistence and scheduler boundary

## Scope

This change is limited to Task Editor preservation of legacy Task metadata and the
FollowUp write coordinator's scheduling boundary. It does not add a second
scheduler, storage path, or user-facing legacy Next Follow-up feature.

## Task Editor preservation

The live PR-head version of `lib/task_editor_dialog.dart` edits canonical
`Task.followUps[]` entries but does not expose an editor control for the
legacy `Task.followUpDate` field. Its save path previously omitted both
`followUpDate` and `followUpEnabled`, so saving an otherwise unrelated Task
could erase those stored compatibility values.

The save path now copies both fields from the existing Task. New Tasks retain
the model defaults (`followUpEnabled == false`, `followUpDate == null`).
No legacy Next Follow-up date editor, candidate generation, ranking, or
scheduling behavior is introduced. The canonical Follow-up UI remains based on
`Task.followUps[]`.

## Coordinator boundary

`FollowUpWriteCoordinator` no longer requires
`AutomaticFollowUpSchedulerAdapter`. The legacy adapter constructor argument
is optional and deprecated for compatibility with any not-yet-migrated caller.
New consumers must omit it.

The independent `reminderReschedule` callback remains optional and is invoked
after successful canonical repository writes. Both legacy scheduling (when a
compatibility caller supplies it) and independent reminder rescheduling are
best-effort; a scheduling failure does not roll back persisted Follow-up data.
Persistence failure prevents either callback from running.

`task_detail_page.dart` and `follow_up_office_page.dart` no longer instantiate
`AndroidAutomaticFollowUpScheduler`. They retain
`AndroidFollowUpReminderScheduler().reschedule` as the independent reminder
path. `AndroidFollowUpReminderScheduler` and its alarm planner are not removed.

## Regression coverage

- Task Editor round-trip tests (`task_editor_full_entry_test.dart` and
  `task_editor_dialog_test.dart`) assert preservation of `followUpEnabled` and
  `followUpDate` when saving an existing Task.
- Coordinator tests assert reminder callback invocation after successful add
  and update, best-effort handling of reminder scheduling failure, and no
  callback after persistence failure.
- Follow-up Office integration test asserts the independent reminder callback
  is invoked after a user write.
- Calendar apply tests assert callback invocation after successful apply and
  no callback after persistence failure.

## Validation and release gate

The PR's `Arvin Build` workflow runs Flutter Analyze, six test shards, and
Debug/Release APK builds on pull-request synchronization. Results must be read
from the exact resulting commit SHA. No local Flutter/Dart execution is claimed
by this documentation.

This change does not satisfy physical-device, Calendar Provider, Backup/Restore,
or product-owner release acceptance. PR #2995 remains a Draft and unmerged;
Issue #2102 remains open. Release remains **BLOCKED — RELEASE: NO-GO**.
