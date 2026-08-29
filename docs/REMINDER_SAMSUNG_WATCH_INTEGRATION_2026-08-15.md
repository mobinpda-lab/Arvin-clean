# Arvin — Reminder / Samsung Galaxy Watch Integration Decision — 2026-08-15

## Product decision
Arvin does **not** need a separate Galaxy Watch/Tizen application.

The Arvin Reminder Core remains the source of truth on the Android phone. Watch support is an integration/output concern.

## Target device confirmed
The user's watch is a Samsung Galaxy Watch 46mm, model **SM-R800**, using Tizen.

## Preferred integration order
1. Arvin Reminder Core on Android remains independent from Samsung Reminder.
2. Standard Android notification is the safe baseline for showing Arvin reminders on a compatible Galaxy Watch through the phone/Galaxy Wearable notification path.
3. Direct creation/synchronization into the Samsung Reminder app is **not yet treated as a supported public API contract** and must not become a hard dependency without verified official third-party API support.
4. Microsoft To Do / Samsung Reminder synchronization is an optional ecosystem path to investigate separately; it must not replace Arvin's own Reminder Core.

## Safety / architecture constraints
- Do not create a Tizen codebase for Arvin.
- Do not create a second Reminder database for watch synchronization.
- Do not couple FollowUp history timestamps to Reminder scheduling.
- A FollowUp may be date-only (`allDay=true`); a Reminder may independently have its own date/time.
- Samsung integration must remain an adapter boundary so removal or failure of Samsung services cannot break Arvin core functionality.

## Validation plan
Before implementation of any direct Samsung Reminder bridge:
- verify the exact Android/Samsung APIs available to third-party applications;
- verify required permissions and whether they are public/grantable;
- test create/update/delete behavior on a Samsung phone;
- verify resulting behavior on Galaxy Watch SM-R800;
- verify failure/fallback to Arvin's native notification path.

## Current scope
This document records the product/architecture decision only. It does not claim that direct Arvin -> Samsung Reminder synchronization is currently implemented.

## Related roadmap
Reminder Popup, Quick Reminder, date-only FollowUp UX, Android notification delivery, and Samsung/Watch integration remain separate implementation steps. The existing Unified Item + FollowUps[] and CalendarReminder foundations must be reused.
