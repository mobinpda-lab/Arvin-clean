# Voice Input Contract

## Goal
Add voice input as another entry method for the existing Arvin domain, without creating a parallel data model.

## Scope
- Speech-to-text for quick entry.
- Optional intent extraction for title, date, optional time, category and reminder.
- Voice-created data must use the existing Unified Item, Reminder and FollowUp paths.
- An utterance without a time must remain all-day/time-empty rather than inventing a time.
- Voice input may create or update a Reminder or Unified Item, and may later create a FollowUp through the existing flow.
- The UI should provide a clear review/confirmation step before destructive or ambiguous actions.
- Offline-first is preferred for basic speech-to-text where the platform supports it; online processing must be optional rather than a hard dependency for already scheduled reminders.

## Non-goals
- No separate voice database or storage layer.
- No replacement of the existing Unified Item architecture.
- No automatic destructive action without user confirmation.

## Implementation order
1. Microphone entry UI.
2. Speech-to-text adapter behind a replaceable interface.
3. Parse recognized text into existing item/reminder fields.
4. Focused tests for timed and all-day input.
5. CI and APK validation.
6. Update AI handoff and project status with the implementation result.
