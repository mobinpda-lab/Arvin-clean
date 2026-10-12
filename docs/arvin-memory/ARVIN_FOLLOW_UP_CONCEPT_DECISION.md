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
