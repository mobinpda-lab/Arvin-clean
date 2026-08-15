# Arvin — Reminder & Recurring UI Implementation 2026-08-15

## Audit baseline
Recurring is now part of the existing `Task`/Unified Item model and is backward-compatible. `resumeFromToday` is already merged to main. No new storage or repository is allowed for this UI slice.

## UI contract
- Top-right two-line menu button; tap opens the menu.
- Reminder card uses a compact `یادآور` label with a smaller time beside it.
- All-day reminders show no fabricated time.
- Primary actions: complete, snooze, edit, convert Reminder to Task.
- Recurring actions: enable/disable, frequency, interval, resume from today.
- Visual language follows the Arvin UI gate: ChatGPT-inspired simplicity and hierarchy, RTL-first, minimal visual noise, no pixel-copying.

## Implementation order
1. Inspect existing screens/widgets and reuse current design primitives.
2. Add the Reminder/Recurring card without changing persistence.
3. Add quick actions and Resume From Today action.
4. Add top menu shell.
5. Add widget/visual tests where supported and validate on APK.
6. Run Analyze → Test → Build → APK verification → document result.
