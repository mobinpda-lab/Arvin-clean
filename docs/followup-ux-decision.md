# FollowUp UX Decision

## Decision

For a newly created follow-up, Arvin automatically pre-fills the current system date and time. The user may edit both values before saving.

The saved follow-up keeps two distinct concepts:

- `dateTime`: the date/time associated with the follow-up record. It is prefilled from `DateTime.now()` and remains user-editable.
- `nextFollowUp`: the planned date/time for the next follow-up, also editable independently.

The actual record creation moment is represented by the follow-up ID generation and must not be confused with an editable historical follow-up date/time.

## UX reference

The interaction is inspired by the proven experience in `mobinpda-lab/arvin-task-tracker`: date and clock are presented as a simple, quick editing flow, while Arvin-clean remains the source of truth for its data model and Calendar implementation.

The target UX is:

1. Open "ثبت پیگیری".
2. System fills today's date and current time automatically.
3. User may tap the date and change it.
4. User may tap the time and change it.
5. User enters note/result.
6. Save.

No mandatory manual date/time entry is required.

## Compatibility and regression rules

- Do not replace the existing Calendar implementation wholesale.
- Preserve Jalali/Persian/RTL behavior already stabilized in Arvin-clean.
- Preserve existing `FollowUp` JSON serialization and legacy `followUpDate` migration.
- Before changing Calendar or persistence, compare current Arvin-clean behavior with the reference projects and existing regression tests.
- Avoid re-implementing a problem that has already been fixed in an earlier wave.

## Reference projects

- `mobinpda-lab/arvin-task-tracker`: product/UX reference for FollowUp, Jalali date handling, clock presentation, and reminders.
- `mobinpda-lab/daftar-peygiri`: reference for the follow-up-office concept and project workflow/documentation experience.

## Implementation plan

1. Stabilize FollowUp persistence and TaskStore integration.
2. Update FollowUp Entry to use separate editable date and time controls with automatic defaults.
3. Connect Entry to TaskStore through the application service.
4. Integrate the FollowUp Office with Task Editor and HomePage.
5. Connect `nextFollowUp` to Calendar/Reminder without disturbing the existing Calendar regression fixes.
6. Run targeted tests, full tests, and Android release validation in independent parallel workflows.
