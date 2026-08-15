# Reminder → Item Conversion Contract

## Goal
Allow a Reminder to be converted into a new Arvin work item without creating a second storage model.

## Rules
- Conversion creates a normal Unified Item and does not create parallel Reminder storage.
- Reminder title becomes the Item title.
- Reminder notes/details are carried into the Item when available.
- Reminder date is carried into the Item when available.
- Reminder time is optional. An all-day Reminder remains without a time.
- The new Item can immediately receive FollowUps through the existing FollowUp model.
- User chooses one of two outcomes for the source Reminder:
  1. Convert and remove the source Reminder.
  2. Convert and keep the source Reminder.
- Conversion must be idempotent from the UI perspective: repeated confirmation must not silently create duplicate Items.
- Existing Calendar/Reminder foundations must be reused; no replacement implementation is introduced by this feature.

## Non-goals
- No Samsung-specific API dependency is introduced here.
- No new native storage layer is introduced.
- No change to the existing Calendar provider contract.

## Validation checklist
- Normal timed Reminder converts with date/time preserved.
- All-day Reminder converts with date preserved and time empty.
- Keep-source option leaves the original Reminder intact.
- Remove-source option removes only the intended source Reminder.
- Converted Item is a normal Unified Item and supports FollowUps.
- Existing data and migrations remain backward compatible.
