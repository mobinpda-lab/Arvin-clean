# Arvin — Visual + Voice Execution Audit — 2026-08-15

## Pre-change audit
- Reviewed `docs/PROJECT_STATUS.md` before this wave.
- Preserved the existing Unified Item + FollowUps[] source of truth.
- Preserved Calendar foundation and the existing Reminder boundary.
- Confirmed Widget Foundation remains a gate; no native AppWidget implementation is introduced here.
- Confirmed Voice Input remains an entry method, not a parallel storage model.

## Visual direction
The approved visual direction is now an explicit product target:
- Persian RTL-first UI.
- Right-edge drawer navigation with gesture open/close.
- Home cards with rounded corners, restrained transparency/shadow, clear hierarchy and large touch targets.
- Reminder card: `یادآور` with a slightly smaller time beside it; item title on the next line.
- All-day Reminder: no invented time; show an all-day/date state instead.
- Expand/collapse for quick details and actions such as done, snooze, edit and convert to item.
- Visual consistency across Reminder, FollowUp, Calendar and Home.
- Final acceptance must be checked on the actual APK, not only widget/test snapshots.

## Voice direction
Voice Input is a future entry method over the existing domain:
- speech-to-text first;
- optional extraction of title/date/time/category/reminder;
- timed and all-day input must both be supported;
- no guessed time for date-only speech;
- ambiguous/destructive actions require confirmation;
- offline-first is preferred for basic speech-to-text where platform support exists.

## Execution order
1. Complete and validate date-only FollowUp UI.
2. Implement Reminder → Unified Item on the existing source of truth.
3. Stabilize Calendar real providers.
4. Establish the shared Widget Foundation.
5. Implement visual Home/Reminder polish against the approved visual target.
6. Implement Voice Input on the same domain paths.

## Safety rule
No parallel storage, Reminder model, Calendar foundation or Widget foundation may be created for speed. Every product change must close a documented gap, receive focused tests, run repository CI, and update project documentation/AI handoff when behavior changes.
