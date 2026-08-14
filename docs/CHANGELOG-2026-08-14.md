# Arvin — Change Log 2026-08-14

## Product decisions

- **Model decision revised:** a new item starts as a simple note; enabling FollowUp turns the same item into a follow-up-enabled item. Note and Task must not become two duplicated data paths for the same record.
- FollowUp timestamps default to system date/time and remain user-editable.
- FollowUp history belongs to the same Item; result and next-follow-up concepts remain separate.
- Simple Notebook keeps automatic editable timestamp, auto-save, read-only-after-exit and explicit edit behavior.
- Notebook availability/behavior remains configurable from Settings.
- Note timestamps are internal metadata only and must not create Google Calendar, Android/system calendar or Arvin Calendar events.
- Reminder is a separate explicit scheduling feature, not the Note timestamp.
- Final typography decision: **IRANSans / IranSansX(Eco)** as the primary font, using the font asset previously supplied by the user.

## Reference projects

- `arvin-task-tracker` is a UX reference for the more attractive calendar/clock/date-time entry experience.
- `daftar-peygiri` is a reference for FollowUp Office/tracking patterns.
- Neither reference replaces Arvin-clean as Source of Truth; code is not copied wholesale.

## Superseded documentation

Any earlier document that models Note and Task as two independent records for the same item is superseded by `docs/ITEM_NOTE_FOLLOWUP_PRODUCT_CONTRACT.md`.

## Stable areas

- Jalali/Persian Calendar behavior and its constrained-viewport regression fixes are not rewritten without a new failing regression or explicit product requirement.
- Android release/CI and independent parallel validation remain protected from unrelated feature changes.

## Development rule

Before every product change: audit current `main`, open PRs, recent fixes, reference projects and existing tests. Avoid duplicate fixes. Keep independent commits/Waves and their workflows parallel whenever possible. Update project documentation with every material product or architecture decision.
