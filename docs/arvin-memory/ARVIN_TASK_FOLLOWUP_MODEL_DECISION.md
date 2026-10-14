# ARVIN Task Follow-up Model Decision

Date: 2026-10-13
Status: Owner-approved; implementation in progress

## Product decision

Every Task can receive Follow-ups during its lifecycle. There is no user-facing or domain-decision flag named `followUpEnabled` / «کار پیگیری‌دار». A Follow-up exists only when a real FollowUp record or a compatible legacy FollowUp date exists.

## Canonical model

`Task`
- `checklist[]`: Task-owned checklist capability.
- `followUps[]`: zero or more independent FollowUp records.
- `taskReminders[]` and legacy reminder fields: independent alert scheduling, not an implicit Follow-up.

A Task may have zero Follow-ups or multiple Follow-ups. Adding or deleting a Follow-up must never create, copy, or delete the Task itself.

## Flag compatibility and migration

- `followUpEnabled` is deprecated compatibility data only; it must not control UI, list filtering, Task status, or whether Follow-up functionality is available.
- Keep reading legacy values during migration/rollback compatibility. Do not erase legacy fields in a lossy migration.
- On writes, derive the compatibility mirror from real data (`followUps.isNotEmpty || followUpDate != null`) where a legacy reader still requires it.
- A legacy `followUpEnabled=true` with no FollowUp record/date does not invent a synthetic Follow-up and does not make the Task appear in Follow-up lists.
- Preserve existing FollowUp records and their IDs. When applying editor changes, merge new records by stable ID rather than replacing concurrently updated history.

## Follow-up creation and waiting-for-response

- Quick Entry has no «پیگیری‌دار» flag; keep the optional checklist control.
- Full Task editor provides a «پیگیری‌ها» section and an «افزودن پیگیری» action.
- Waiting-for-response state remains in the latest canonical `FollowUp.result` using `waiting_for_response`; no parallel Task state/store.
- The user must be able to open a dedicated visible list from Home/More, titled «منتظر پاسخ دیگران». It includes only active, non-completed, non-archived, non-trashed Tasks whose latest Follow-up result is waiting.
- A newer non-waiting Follow-up resolves the waiting state. Older waiting history remains intact.
- `nextFollowUp` remains an action/review time and must not automatically create a Reminder. Follow-up Reminder remains optional and independent.

## Validation required

- Quick Entry exposes checklist but no follow-up flag.
- Full editor adds a real FollowUp record and persists it without overwriting prior/concurrent FollowUp history.
- Legacy flag alone does not affect list scopes or detail status.
- Waiting-for-response list is directly reachable from Home/More and filters only each Task's latest Follow-up.
- Adding/editing/deleting a Follow-up never deletes the Task; Reminder deletion does not delete the Follow-up.
- Exact-head analyzer, test shards, build, UI/navigation, persistence, backup/restore, and device validation must pass before merge/release.
