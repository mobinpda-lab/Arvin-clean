# ARVIN FOLLOW-UP & WAITING RESPONSE PERSON MODEL DECISION

- **Decision date:** 2026-10-13
- **Status:** ACCEPTED — owner-specified product/architecture decision; implementation pending.
- **Repository/branch:** `mobinpda-lab/Arvin-clean` / `integration/task-multiple-reminders-safe-20261013`
- **Scope:** Task follow-ups, reminders, waiting-for-response, Person management, reports, legacy migration.

## Product decision

1. Every Task is inherently eligible for follow-up. `followUpEnabled` must not control product behavior and is compatibility-only until safe removal is proven.
2. A Task may have zero, one, or many Follow-up records over its lifecycle. Follow-ups are created when needed; they are not enabled by a Task-level checkbox.
3. Quick Entry removes the `پیگیری‌دار` option. The checklist option remains.
4. The full Task form removes `کار پیگیری‌دار` and the automatically populated follow-up time. It exposes a `پیگیری‌ها` section with `+ افزودن پیگیری`.
5. Follow-up fields: optional title/note, result, `nextFollowUp`, optional Reminder association, waiting-response status, and one or more associated Persons.
6. `nextFollowUp` is the next action/review time. It must not create a Reminder, notification, or external Calendar event by itself.
7. Reminder is a distinct entity/capability. A Task may have zero, one, or multiple Reminders. Reminders may generate notifications and Calendar synchronization only when configured.
8. `reminderDate` remains semantically distinct from `nextFollowUp`; never substitute or migrate one into the other.
9. `waitingForResponse` is invalid as a standalone Boolean without at least one Person. The UI must require one or more Persons when enabled.
10. Person is a lightweight reusable directory for Task/Follow-up associations and reports, not a CRM. Settings must provide add, edit, delete, and search.
11. Reports must filter by Person and show Task, Follow-up, response-waiting status, and next action time.
12. Removing a Person association must not delete the Task or Follow-up. Deleting a Reminder must not delete the Follow-up.

## Current implementation findings

- The current Task model already has a `FollowUp` record type and a `Task.followUps` collection, plus legacy `followUpEnabled` and `followUpDate` fields.
- `TaskStore.addFollowUp` currently sets `task.followUpEnabled = true`; `enableFollowUp` and other paths still rely on the legacy flag.
- The current `FollowUp` JSON has id/dateTime/note/result/reminderDate/nextFollowUp/completed, but no waiting-response state or Person IDs.
- `PersonReference` currently exists as a lightweight embedded reference; this is not yet proof of a reusable canonical Person directory in Settings.
- The full Task editor still contains the `کار پیگیری‌دار` toggle and automatic follow-up date/time state.
- Multiple Task Reminders are being developed on this branch. Preserve that implementation and its stable identity/migration rules; do not introduce a competing reminder store.

## Migration plan — do not destroy legacy data

1. Inventory all reads/writes of `followUpEnabled`, `followUpDate`, `followUps`, `reminderDate`, and `nextFollowUp` across model, UI, SQL/Drift schema, TaskStore, JSON, backup/restore, Calendar, reports, and tests.
2. Define canonical Person identity and lifecycle before adding schema. Reuse existing PersonReference only as a reference/association where appropriate; do not treat embedded snapshots as a reusable directory without evidence.
3. Add waiting-response status and stable Person associations to Follow-up, preserving old JSON defaults and unknown/legacy fields.
4. Build the reusable Person directory and referential behavior. Removing a Person association must not cascade-delete Task or Follow-up.
5. Remove flag-driven UI and behavior. Keep `followUpEnabled` only as a deprecated compatibility field until all old data is migrated and every consumer is removed.
6. Migrate legacy `followUpEnabled`/`followUpDate` without dropping dates or confusing next-action time with notification time. Existing `followUps` remain canonical; do not manufacture duplicate Follow-up rows for already represented history.
7. Preserve independent Reminder records and Calendar external IDs; do not create Reminder records from `nextFollowUp`.
8. Add report filtering by Person and cover backup/restore, migration idempotency, deletion semantics, and all seven owner-specified acceptance cases.

## Acceptance tests

- Task can be created without Follow-up.
- Follow-up can be added later without replacing or recreating the Task.
- Reminder can be added independently.
- Enabling waiting-for-response requires one or more Persons.
- Person-filtered reports show every Task/Follow-up waiting on that Person and its next action time.
- Deleting a Reminder leaves Follow-up intact.
- Removing a Person association leaves Task and Follow-up intact.

## Validation status

- **Decision recorded:** yes.
- **Implementation complete:** no.
- **Migration tested:** no.
- **Automated test evidence for this decision:** pending.
- **Physical-device evidence:** pending.
- **Release status:** NO-GO until exact-head tests/build/migration/backup-restore/Calendar gates pass.

---

## Implementation checkpoint — 2026-10-13

The accepted decision above remains authoritative. Source implementation has begun on [PR #2681](https://github.com/mobinpda-lab/Arvin-clean/pull/2681), stacked on [PR #2666](https://github.com/mobinpda-lab/Arvin-clean/pull/2666). The model, SQL fields, Person directory UI and waiting-entry validation are present on that branch; cleanup also removed several legacy flag writes and fixed Calendar inbound field preservation.

**Not complete:** standalone Person directory records are not included in the existing portable backup/restore contract; Person-specific reporting is incomplete; exact-head tests/build/migration/Calendar/device validation has not been confirmed. These are tracked in `ARVIN_REPOSITORY_CLEANUP_AUDIT_2026-10-13.md`. Release remains NO-GO.

---

## Latest validation and branch-safety checkpoint — 2026-10-13

- Parent PR #2666 remains open. Latest observed head `d70827e1db927dcac2afc7367ca0d2e759359d8e` has Build/Device Smoke queued and Calendar Provider Acceptance in progress.
- Child PR #2681 remains Draft and GitHub reports it not mergeable against its integration base. Do not merge or force-update refs; synchronize changes safely first.
- Related PR #2679's Build failed one waiting-list test (232 passed, 1 failed) at its own merge head. Its latest-only/result-text assumptions conflict with structured per-Follow-up waiting semantics; reconcile before merging.
- Open blockers are tracked as [#2682](https://github.com/mobinpda-lab/Arvin-clean/issues/2682) (Person directory backup/restore) and [#2683](https://github.com/mobinpda-lab/Arvin-clean/issues/2683) (Person-specific reports).
- No exact-head validation is established for PR #2681. Release remains NO-GO.
