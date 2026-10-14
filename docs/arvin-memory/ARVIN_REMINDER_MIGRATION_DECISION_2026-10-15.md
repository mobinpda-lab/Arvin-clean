# ARVIN — Authoritative Reminder Migration Decision
Date: 2026-10-15
Status: OWNER DECISION RECORDED; implementation and validation remain open.
Repository: mobinpda-lab/Arvin-clean
Canonical issue: https://github.com/mobinpda-lab/Arvin-clean/issues/2654#issuecomment-6178475884

## Decision
The owner selected Option B: migrate legacy Task.reminderDate into the canonical collection of independent TaskReminder records with a deterministic, one-time, idempotent migration.

## Current database context
The owner reports that Arvin has not yet been populated with user data and that the current app database is empty. This is not evidence that every backup, fixture, test database, or other installation is empty. Preserve compatibility for those sources.

## Required invariants
- One canonical TaskReminder representation; no parallel store or scheduler.
- Stable deterministic reminder ID and explicit migration marker/version; reruns must not duplicate reminders.
- Preserve legacy reminder date/time and meaning.
- Preserve or safely map Calendar identity task-reminder:<taskId>; repeated sync updates the same event and never duplicates it.
- Keep FollowUp.reminderDate, Follow-up history and nextFollowUp independent. nextFollowUp does not implicitly create reminders.
- Test legacy/new JSON, SQL save/reload, backup/restore, retry/idempotence, failure/rollback and Calendar no-duplicate behavior.
- Do not remove legacy compatibility or overwrite old values before safety is proven.

## Execution status
PR #2655 must be reconciled because its current description says it preserves the legacy reminder without automatic migration. Inspect current code and tests before modifying it. Implement on a dedicated branch and validate the final exact SHA with Analyze, all test shards, Debug/Release APK, all six Device Smoke lanes, Calendar provider acceptance, and physical-device acceptance as required.
No application code or data migration was performed by this decision record. No test/build/device pass is claimed. Release remains NO-GO.
