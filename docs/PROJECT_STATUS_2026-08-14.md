# Arvin Project Status — 2026-08-14

## Purpose
This document records the current implementation direction so future waves do not repeat completed work or regress stable features.

## Current source of truth
- Repository: `Arvin-clean`
- Main baseline at audit time: `7da7587794b8547a41cddcc52d69dff68e6de609`
- `Arvin-clean` remains the product source of truth.
- `arvin-task-tracker` and `daftar-peygiri` are reference projects only; reuse is selective and must be validated against the current architecture.

## Stable areas — do not rewrite without a regression
- Jalali/Persian/RTL Calendar behavior and constrained-viewport fixes.
- Android release/desugaring pipeline.
- Parallel Wave CI model.
- Existing backup compatibility rules.

## Active product direction
### FollowUp
Approved UX:
- System automatically supplies the current Jalali date and current time when a follow-up is created.
- User can edit both date and time before saving.
- `dateTime` of the recorded follow-up is separate from `nextFollowUp`.
- FollowUp history, agenda, service, entry UI and later Task integration remain separate waves.

### Simple Notebook
Approved UX:
- Simple note has subject and text.
- System automatically supplies date/time on creation.
- User can edit date/time.
- Save is automatic while editing.
- After leaving, the note becomes read-only.
- Returning to a note requires an explicit Edit action to modify it.
- Availability is controlled by a Settings option.
- Note date/time is internal note metadata only.
- A note must NOT create an event in Google Calendar or the device calendar.
- A note must NOT appear in the Arvin Calendar unless a future product decision explicitly adds that behavior.

## Google Calendar / device Calendar
Calendar integration remains reserved for reminder/follow-up scheduling where explicitly required. Simple Notebook dates are intentionally isolated from external/system calendars.

## Dropbox / Backup
Dropbox remains a future independent integration wave for backup/restore. Notes and FollowUps must be included in backup/restore once their storage is integrated. Restore must not create duplicate calendar events.

## Reference-project learnings
### arvin-task-tracker
Use selectively for:
- Jalali date/time UX
- date/time picker interaction
- FollowUp presentation and history
- reminder/timezone patterns
- persistence and serialization patterns

Do not wholesale-copy its Calendar or storage architecture into `Arvin-clean`.

### daftar-peygiri
Use selectively for:
- follow-up workflow/product concepts
- CI/build organization where it is demonstrably useful

Do not treat it as a second source of truth.

## Parallel development rule
- Independent commits/waves should be developed independently.
- Independent Workflow validations should run in parallel and must not wait for another independent wave to become green.
- A dependent integration wave must wait only for the prerequisite contract/API to be validated.
- Before every change, compare the current `main`, active PRs, recent fixes, and reference projects to avoid duplicate work.
- Documentation must accompany material architecture/product decisions.

## Next implementation sequence
1. Validate and consolidate the current FollowUp and Simple Notebook foundation waves.
2. Build Simple Notebook UI: auto date/time, editable date/time, auto-save, read-only-after-exit, explicit Edit.
3. Add Settings toggle for Notebook availability.
4. Integrate FollowUp into TaskStore/service/editor without replacing stable Calendar code.
5. Add Google Calendar/reminder integration only for explicitly scheduled reminders/follow-ups.
6. Add Dropbox backup/restore compatibility for Notes + Tasks + FollowUps.
7. Add end-to-end regression tests.
8. Produce a test APK after the integration baseline is green.
