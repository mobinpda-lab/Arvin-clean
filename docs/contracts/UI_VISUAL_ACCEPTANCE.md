# Arvin UI Visual Acceptance

## Purpose
Keep visual quality as a first-class release gate alongside functionality and CI.

## Reference direction
- Persian RTL-first layout.
- Main navigation opens from the right and supports swipe open/close.
- Home remains clean and task-focused rather than dashboard-heavy.
- Calendar, Items, FollowUps and Reminders share one visual language.
- Primary actions are easy to reach, with clear add/quick-entry affordances.
- Reminder popup is concise and readable.
- Voice entry will use the same visual system and must not introduce a separate UI style.
- Typography, spacing, icon sizing and touch targets must remain consistent.
- Light/dark appearance must preserve hierarchy and readability.
- Motion should be subtle and purposeful.

## Release gate
A feature is not considered visually complete only because its logic passes tests. Before APK acceptance, the relevant screen must be checked against the approved visual direction on a real Android device.

## Safety
- This document does not change production behavior.
- No parallel UI foundation or storage model is introduced.
- Existing Calendar, FollowUp, Reminder and Unified Item foundations remain authoritative.

## Next visual work
1. Audit the current Home and right-side drawer against this contract.
2. Audit Calendar and FollowUp Office rendering, especially date-only entries.
3. Audit Reminder popup and quick-entry affordances.
4. Apply small, isolated UI corrections only where the current implementation differs from the approved direction.
5. Validate each UI change through the normal Build + Parallel workflow before APK testing.
