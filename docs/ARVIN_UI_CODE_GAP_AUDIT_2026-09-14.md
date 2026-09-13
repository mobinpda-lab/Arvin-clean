# Arvin UI Code Gap Audit — 2026-09-14

## Purpose

This document is the first implementation audit after establishing the canonical UI and product contracts.
It does not mark features complete. It identifies the comparison path between:

1. Installed real Arvin reference output.
2. Canonical visual reference.
3. Final product implementation contract.
4. Existing Flutter implementation.

## Audit Rules

- Existing data models and services are preserved.
- No parallel storage architecture is allowed for visual similarity.
- Old documents remain historical unless explicitly superseded.
- A documented feature is not considered implemented without runtime evidence.

## Audit Domains

### Home
Check:
- Header and RTL placement.
- Search placement.
- Grouping controls.
- Removal of obsolete statistic cards.
- Real data grouping behavior.

### Task Card
Check:
- Completion control.
- Title hierarchy.
- Project/category display.
- Due date versus follow-up separation.
- Latest follow-up preview.

### Quick Entry
Check:
- Keyboard behavior.
- Continuous creation flow.
- Draft preservation.
- Duplicate prevention.
- Shared save path with full form.

### Follow-up
Check:
- Timeline preservation.
- Append behavior.
- Empty state.
- Detail synchronization.

### Notebook
Check:
- Existing canonical storage.
- Simple note and checklist modes.
- Editor behavior.
- Persistence.

### Calendar and Next Action
Check:
- Real data connection.
- Jalali behavior.
- Separation of events, reminders and tasks.

## Status Model

Each capability receives one status:

- Documented only
- Code exists
- Tested
- Verified on Android
- Production accepted

## Next Audit Step

Inspect actual Flutter screens, widgets, services and tests and populate the capability matrix with evidence.