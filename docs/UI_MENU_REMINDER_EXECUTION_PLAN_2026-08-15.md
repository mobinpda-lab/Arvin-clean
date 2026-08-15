# Arvin — UI/Menu/Reminder Execution Plan 2026-08-15

## Design gate
Use ChatGPT-style principles as a permanent inspiration: simple, calm hierarchy, obvious primary actions, compact navigation, minimal visual noise, RTL-first. Do not copy pixels or branding.

## Scope
- Top-right two-line menu button; menu invoked by tap, not dependent on swipe.
- Reminder card: `یادآور` with a smaller time beside it; large title below; all-day leaves time empty.
- Reminder quick actions: complete, snooze, edit, convert to Item.
- Recurring Item uses the same Unified Item source of truth.
- No new storage/repository.

## Implementation order
1. Finish recurring domain/model + pure tests.
2. Implement Reminder/recurring card and quick actions on existing Item path.
3. Implement menu shell and navigation.
4. Visual regression on real APK.
5. CI + release validation.

## Safety
UI work must not bypass Unified Item, Calendar, notification, or Widget foundations. Every production slice requires audit, tests, commit, workflow validation, and status/documentation update.
