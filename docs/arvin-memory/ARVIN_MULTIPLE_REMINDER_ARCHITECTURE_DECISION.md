# ARVIN Multiple Reminder Architecture Decision

Date: 2026-10-13
Repository: `mobinpda-lab/Arvin-clean`
Status: OWNER DECISION APPROVED; implementation and validation are still pending.

## 1. Product decision

A Task may own multiple independent Task-level reminders. Each reminder has a stable ID, editable title, date/time, status, Task ID, createdAt, updatedAt, and explicit date-only/all-day metadata. Editing or deleting one reminder must not mutate the Task, Follow-up, or another reminder.

The canonical Task remains the single source of truth. Reminder data belongs inside the existing canonical Task JSON/persistence envelope. No parallel database, store, or scheduler may be introduced.

## 2. Follow-up and reminder are distinct

- `nextFollowUp` is the planned next action/review time.
- A Reminder is a system alert and calendar event.
- Setting or changing `nextFollowUp` never creates, overwrites, or deletes a Reminder unless the user explicitly opts into adding one.
- Keep legacy `Task.reminderDate` and per-Follow-up `FollowUp.reminderDate` semantically separate from `nextFollowUp`.
- Internal Follow-up Action calendar projections are display-only: they must not schedule notifications and must not enter outbound external Calendar sync.

## 3. Canonical reminder fields and identity

Each new TaskReminder contains:
- immutable stable `id`;
- `taskId`;
- editable `title`;
- date/time value plus explicit `isAllDay` (date-only is not inferred from midnight);
- `status`;
- `createdAt` and `updatedAt`.

Use the existing Task JSON, SQL envelope, Calendar bridge and notification engine. Persist reminder sequence/allocation state (or equivalent durable history) so deletion does not recycle or renumber identifiers. Titles are presentation, never identity.

New external Calendar identity: `task-reminder-item:<taskId>:<reminderId>`.
Legacy Task reminder identity: `task-reminder:<taskId>` during compatibility. A single logical reminder must never be emitted through both identities after migration. Follow-up internal-action IDs remain outside outbound sync.

## 4. Legacy migration and compatibility

Source legacy value: `Task.reminderDate`.
Target: one TaskReminder collection item representing that same reminder, with a deterministic stable migration identity, original schedule preserved, and a safe default title derived from the Task title. The migration must be idempotent: repeated startup, restore, or migration execution must not create another item.

Migration must not infer all-day from midnight, normalize times, overwrite an existing reminder, or treat `nextFollowUp` as a reminder. Preserve the legacy value in a backward-compatible representation until the new item is durably written and validated. Define and test the single-source/projection rule so the legacy event and migrated item cannot both create external events. Existing per-Follow-up `FollowUp.reminderDate` values remain separate and are not folded into Task-level reminders.

Old JSON and backups without a reminder collection must decode safely. New JSON/SQL/backup/restore must round-trip the collection, reminder status, all-day marker, and Calendar-link identity. Migration must be transactional or recoverable: failure must leave the old reminder usable and retryable. Rollback must not delete the old value or produce duplicate calendar events.

## 5. Calendar and notifications

- Each TaskReminder is projected independently to internal Calendar.
- When external sync is enabled, use stable identity and CREATE once, then UPDATE the same event. Do not match by title or date.
- Deleting a reminder deletes only its linked event/notification and reminder record; it must not delete the Task, Follow-up, or other reminders.
- Each reminder has an independent notification schedule and cancellation key. Prevent duplicate scheduling/delivery.
- Date-only reminders remain all-day calendar entries. Notification delivery time must follow the product's documented local-time policy; it must not mutate the event's date-only state.
- Internal Follow-up Action projections are display-only and excluded from outbound Calendar sync and reminder notification scheduling.

## 6. UI

Full Task form:
- retain the existing Follow-up-enabled control;
- remove any misleading system-generated Follow-up timestamp;
- show a Reminder list with independent add/edit/delete controls.

Quick Entry:
- provide compact Follow-up and Checklist toggles beside primary icons;
- expand the related roll box only when selected;
- do not add a large Reminder editor to Quick Entry.

## 7. Required acceptance tests

1. Create one Task with three reminders; all persist independently.
2. Edit reminder 2; reminders 1 and 3 remain byte-for-byte/logically unchanged.
3. Delete reminder 2; Task, Follow-up, reminders 1 and 3 remain.
4. Backup/restore round-trip preserves all reminder fields, status, all-day state, and Calendar links.
5. Calendar create/update/delete uses stable IDs; repeated sync does not duplicate events.
6. Legacy `Task.reminderDate` migrates to exactly one TaskReminder and repeated migration remains idempotent.
7. Old JSON and old backups decode; legacy per-Follow-up reminder values remain independent.
8. `nextFollowUp` never silently creates or replaces a reminder.
9. Same-time reminders with different IDs remain distinct.
10. Deleted sequence numbers are not reused; date-only and intentional midnight remain distinguishable.
11. Internal Follow-up Action never enters outbound Calendar sync or notification scheduling.
12. Notification rescheduling/cancellation is independent per reminder and does not duplicate alarms.

## 8. Safe integration and validation

Do not directly merge PR #2655. Reconcile onto a fresh branch from current `main`, path by path:
1. canonical Task model/JSON and idempotent legacy migration;
2. persistence/backup/restore compatibility;
3. editor and independent CRUD;
4. notification planning/delivery;
5. Calendar inbound/outbound stable identity while preserving internal-only Follow-up projection;
6. focused regression tests.

On the final exact SHA require Analyze, all test shards 0-5, Debug and Release APK, Calendar Provider Acceptance, and all six Device Smoke lanes. Then review artifacts and validate on a physical device, including real Calendar sync, backup/restore, restored Calendar-link integrity, and Persian RTL/compact-screen UI.

## 9. Rollback plan

Keep the migration idempotent and preserve the legacy reminder value until the migrated record and link are confirmed. If a validation gate fails, do not merge or release; revert the integration branch/PR rather than deleting user data. Verify backup restoration and ensure rollback cannot emit both legacy and new external events.

## 10. Current evidence status

- Product/architecture direction: approved by the owner command dated 2026-10-13.
- Existing multiple-reminder implementation: present on PR #2655, not merged.
- Safe integration: not yet performed.
- Exact-final-head CI, Calendar Provider Acceptance, physical-device validation: pending.
- Release: NO-GO until every required gate passes.
