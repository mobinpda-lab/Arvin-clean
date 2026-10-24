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


## Owner clarification — one-time initialization (2026-10-12; SUPERSEDED 2026-10-13)
The 2026-10-12 automatic-creation rule below is superseded by the newer owner decision dated 2026-10-13. It is retained only as decision history; do not implement it as current behavior.
- Historical rule (superseded): automatically create a reminder on the first setting of Next Follow-up.
- **Current rule:** setting Next Follow-up does not automatically create a reminder. Creating a reminder for it is optional and happens only if the user explicitly wants/chooses it.
- When the user chooses to create a reminder for Next Follow-up, prefill reminder title from the title of the Task that has follow-up enabled and date/time from Next Follow-up. These are initial values only; the user may edit reminder title/date/time independently.
- Reminder is independent of previous/next follow-up and recorded Follow-up history. Later edits/deletion of Next Follow-up do not move/delete reminders; reminder edit/deletion does not change Next Follow-up. A reminder may exist without Next Follow-up, and the user may request additional reminders.
- FollowUp record `dateTime` is the timestamp of the recorded Follow-up action and is distinct from `nextFollowUp`.
- Each of Next Follow-up and reminder independently supports date-only/all-day or date-and-time values. Never infer date-only intent from midnight alone; preserve legacy values safely.
- **Implementation audit finding:** the inspected `FollowUp` model stores both fields as nullable `DateTime`, and the editor's `_pickNext()` inherits the recorded Follow-up's hour/minute. The inspected code does not establish date-only/all-day semantics or the user-controlled reminder creation path. Do not claim implementation complete; design backward-compatible metadata and test Calendar projection, persistence and backup/restore.
- Required validation includes opt-in creation, Task-title/date-time prefill, additional reminders, independent edits/deletes, reminder-only state, recorded dateTime separation, JSON/SQL/backup-restore and same-event/no-duplicate Calendar behavior.

## Owner clarification — reminder is independent; creation is user-controlled (2026-10-13)
The owner explicitly reconfirms:
- A reminder for a follow-up is independent of the previous and next follow-up. It must never be treated as the follow-up record itself or as a continuously linked copy of Next Follow-up.
- Creating a reminder for Next Follow-up is optional and must happen only if the user wants/chooses it; do not silently create a reminder merely because Next Follow-up was set.
- When the user chooses to create a reminder for Next Follow-up, prefill its title from the title of the Task that has follow-up enabled, and prefill its date/time from Next Follow-up. These are initial values only. The user can edit reminder title/date/time independently afterward.
- After initialization, changing or deleting Next Follow-up does not move or delete any reminder. Editing or deleting a reminder does not change Next Follow-up. A reminder can exist without Next Follow-up.
- Each concept independently supports date-only (all-day) or date-and-time values. Never infer date-only intent from midnight alone; preserve legacy values safely.
- This clarification resolves the previously open product question about what the user expects from initial reminder creation: seed from Task title + Next Follow-up date/time, then independent editing. Existing reminder collision/duplicate handling still must be implemented conservatively: preserve existing data and do not overwrite or duplicate without explicit user intent.


## Owner clarification — multiple follow-ups and reminders per Task (2026-10-13)
- One Task may have multiple recorded Follow-up entries and multiple independent reminders; neither is limited to one per Task.
- Keep each recorded Follow-up as its own history entry. Keep reminder instances independently identifiable, editable, schedulable and deletable; editing/deleting one must not affect another reminder or any Follow-up entry.
- Next Follow-up remains a distinct next-action value, not the whole Follow-up history and not a reminder. Setting it does not automatically create a reminder.
- If the user explicitly chooses to create a reminder for a Next Follow-up, prefill the reminder title from the Task title and its initial date/time from Next Follow-up; these are initial values only.
- Data model, UI, persistence, backup/restore, calendar projection and tests must support multiple entries without overwriting, collapsing or duplicating them. Preserve canonical Task ownership and stable reminder/calendar identities; no parallel Task store.


## Owner clarification — multiple follow-ups and reminders per Task (2026-10-13)
- One Task may have multiple recorded Follow-up entries and multiple independent reminders; neither is limited to one per Task.
- Keep each recorded Follow-up as its own history entry. Keep reminder instances independently identifiable, editable, schedulable and deletable; editing/deleting one must not affect another reminder or any Follow-up entry.
- Next Follow-up remains a distinct next-action value, not the whole Follow-up history and not a reminder. Setting it does not automatically create a reminder.
- If the user explicitly chooses to create a reminder for a Next Follow-up, prefill the reminder title from the Task title and its initial date/time from Next Follow-up; these are initial values only.
- Data model, UI, persistence, backup/restore, Calendar projection and tests must support multiple entries without overwriting, collapsing or duplicating them. Preserve canonical Task ownership and stable reminder/calendar identities; no parallel Task store.


## Owner directive update — 2026-10-24 (Wave 7.26)

This addendum records the latest explicit owner directive and supersedes the 2026-10-13 “creation is opt-in” rule **for first activation only**:
- When the user sets \`nextFollowUp\` for the first time, initialize \`reminderDate\` to the same date/time only if no reminder already exists.
- This is a **one-time, cancellable initial default**, not continuous coupling. The user may edit or clear the reminder independently. Later changes/deletion of \`nextFollowUp\` must not move/delete the reminder; reminder edits/deletion must not mutate \`nextFollowUp\`, recorded Follow-up history, or Task identity.
- A Follow-up without a reminder remains a valid state, including legacy records and after the user clears the initial reminder. Preserve an existing reminder on first activation; never overwrite or duplicate it.
- Date-only/All-Day remains unresolved: \`FollowUp\` stores nullable \`DateTime\` values but no independent All-Day marker for \`nextFollowUp\` and \`reminderDate\`. Midnight must not be inferred as All-Day. Do not change schema/model/backup semantics until the owner-approved data contract and backward-compatible migration/test plan are available.
- The requested approved \`ARVIN_Product_Reference_v1_3_FA.docx\` was not found on current \`main\` or in the searched Library during Wave 7.26. This addendum records the latest owner directive; it does **not** claim that the unavailable v1.3 sections 1.3, 3.4 and 11.2 were reconciled. Locate and compare that exact approved artifact before closing document reconciliation.
