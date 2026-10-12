# ARVIN FOLLOW-UP CONCEPT DECISION

- **Date:** 2026-10-12
- **Status:** ACCEPTED — owner/product decision
- **Scope:** Task follow-up, reminders, Calendar projection, reporting and filtering

## Decision
`nextFollowUp` and `reminderDate` are independent concepts and must remain distinct.

- `nextFollowUp`: when the user should next act on or review the topic.
- `reminderDate`: when the system should notify the user.

Example: `nextFollowUp = 25 مهر` means revisit the purchase on 25 Mehr. `reminderDate = 25 مهر، ساعت 09:00` means notify the user at 9 AM on 25 Mehr.

## Mandatory rules
- Never delete `nextFollowUp`.
- Never migrate/copy `nextFollowUp` into `reminderDate` merely because a reminder is absent.
- Never clear `nextFollowUp` on save or to simplify the UI.
- Preserve both values independently in the canonical model, editor, serialization, repositories, and backup/restore.
- Keep separate UI controls for «پیگیری بعدی» and «یادآور پیگیری مستقل».
- Do not introduce a parallel Task store or duplicate Follow-up/Reminder model.

## Calendar
A FollowUp Calendar reminder is eligible only when an explicit `reminderDate` exists. Its scheduled time is authoritative for that reminder. Calendar projection/display rules must not mutate either field. Where a general calendar view must choose between a reminder and the next action date, display the reminder when one is configured; otherwise fall back to `nextFollowUp` without changing stored data.

## Reports and filters
Future follow-ups (`nextFollowUp`) and reminders (`reminderDate`) must be independently queryable. One value must never be treated as proof that the other exists.

## Validation required
- Regression tests for both values present, each value absent, and each value present alone.
- Editor save/reopen and JSON round-trip preserve both independently.
- Calendar projection includes only explicitly configured reminders and uses the reminder timestamp.
- Backup/restore preserves both values; legacy data remains readable without silent semantic migration.
- Exact-head Analyze, all test shards, Debug/Release APK, Calendar Provider Acceptance and relevant Device Smoke must pass before code acceptance.
- Physical-device Calendar and Backup/Restore acceptance remain separate release gates.

## Status
The product decision is accepted. Documentation and code correction are in review; implementation and release acceptance are not yet fully validated.


## Owner clarification — one-time initialization (2026-10-12)
This addendum supersedes conflicting rules above that prohibit any automatic reminder creation from Next Follow-up. The clarified lifecycle is:
- Next Follow-up is initially empty and becomes active only when the user explicitly sets it.
- On its first setting, create one initial reminder at the same date/time; if Next Follow-up is date-only, create an all-day reminder.
- Later edits to Next Follow-up do not change the reminder. Deleting Next Follow-up does not delete the reminder.
- A reminder may exist without Next Follow-up; either may be independently edited or deleted. Editing/deleting the reminder never changes Next Follow-up.
- FollowUp record `dateTime` is the timestamp of the recorded Follow-up action and is distinct from `nextFollowUp`.
- **Unresolved edge case:** if `reminderDate` already exists when Next Follow-up is first set, owner clarification is required before deciding whether to preserve/skip creation or take another action. Do not overwrite or duplicate it by assumption.
- **Implementation audit finding:** the currently inspected `FollowUp` model stores both fields as nullable `DateTime`, and the editor's `_pickNext()` currently reuses the recorded Follow-up's hour/minute. The inspected code does not establish date-only/all-day semantics or the one-time creation bridge. Do not claim implementation complete; assess a backward-compatible all-day representation and test it across calendar projection and persistence before coding.
- Required validation includes first-set matching, all-day creation, independent later edits/deletes, reminder-only, recorded dateTime separation, JSON/SQL/backup-restore and same-event/no-duplicate calendar behavior.

## Owner clarification — reminder is independent; creation is user-controlled (2026-10-13)
The owner explicitly reconfirms:
- A reminder for a follow-up is independent of the previous and next follow-up. It must never be treated as the follow-up record itself or as a continuously linked copy of Next Follow-up.
- Creating a reminder for Next Follow-up is optional and must happen only if the user wants/chooses it; do not silently create a reminder merely because Next Follow-up was set.
- When the user chooses to create a reminder for Next Follow-up, prefill its title from the title of the Task that has follow-up enabled, and prefill its date/time from Next Follow-up. These are initial values only. The user can edit reminder title/date/time independently afterward.
- After initialization, changing or deleting Next Follow-up does not move or delete any reminder. Editing or deleting a reminder does not change Next Follow-up. A reminder can exist without Next Follow-up.
- Each concept independently supports date-only (all-day) or date-and-time values. Never infer date-only intent from midnight alone; preserve legacy values safely.
- This clarification resolves the previously open product question about what the user expects from initial reminder creation: seed from Task title + Next Follow-up date/time, then independent editing. Existing reminder collision/duplicate handling still must be implemented conservatively: preserve existing data and do not overwrite or duplicate without explicit user intent.
