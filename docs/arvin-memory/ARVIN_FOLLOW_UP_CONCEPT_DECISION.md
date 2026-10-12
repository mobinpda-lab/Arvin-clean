# ARVIN FOLLOW-UP CONCEPT DECISION

- **Date:** 2026-10-12
- **Status:** ACCEPTED — owner/product decision
- **Scope:** Task follow-up, reminders, Calendar projection, reporting and filtering

## Problem
The next time a person should act on or review a topic can be confused with the time the system should notify the user. Simplifying the UI must not erase or repurpose either meaning.

## Decision
`nextFollowUp` and `reminderDate` are independent concepts and must remain distinct.

## 1. `nextFollowUp` — next action/review
Represents when the topic should next be acted on or reviewed.

Example: for “خرید فرش اتاق”, `nextFollowUp = 25 مهر` means the user should follow up on the purchase on 25 Mehr. This is task/follow-up management data.

## 2. `reminderDate` — notification time
Represents when the system should notify the user.

Example: `reminderDate = 25 مهر، ساعت 09:00` means notify the user at 9 AM on 25 Mehr to perform the follow-up. This is reminder/notification data.

## Relationship
- `Task → Follow-up → nextFollowUp`
- `Follow-up → Reminder → reminderDate`

## Mandatory rules
- Do not delete `nextFollowUp`.
- Do not move its meaning into `reminderDate` as a replacement.
- Do not clear `nextFollowUp` merely to simplify the UI.
- Do not use `reminderDate` as a substitute for follow-up scheduling.
- Keep both fields independently representable and persisted; preserve legacy data and serialization/backup compatibility.
- UI simplification must preserve the canonical data model. “یادآور پیگیری بعدی” may label the reminder, but it does not replace `nextFollowUp`.

## Calendar rule
1. If a Reminder exists, show its `reminderDate`.
2. If no Reminder exists, show `nextFollowUp`.
3. The display choice must not mutate, erase or merge either stored concept.

## Reports and filters
Reports and filters must query future follow-ups (`nextFollowUp`) separately from reminders (`reminderDate`). A reminder timestamp is not proof that a follow-up date exists, or vice versa.

## Reason
A follow-up date expresses the user's next planned action; a reminder date expresses a system notification schedule. They can be related, but they are not interchangeable.

## Impact and required verification
- Audit the existing Task/Follow-up model, JSON serialization/deserialization, repository/update paths, editor UI and Calendar projection.
- Preserve both values through edits, completion flows, backup/restore and legacy-data round trips.
- Add or retain regression tests for independent values, null values, Calendar precedence/fallback and separate report/filter behavior.
- Do not introduce a parallel Task store or duplicate Follow-up/Reminder domain model.
- Do not claim implementation or release acceptance until exact-head tests/build and applicable device validation provide evidence.

## Status
The product/architecture decision is accepted. Implementation and release validation remain unverified until audited and tested.
