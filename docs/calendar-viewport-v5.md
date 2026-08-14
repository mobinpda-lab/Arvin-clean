# Calendar viewport v5

Date: 2026-08-14

## Problem

The full Flutter test suite was consistently failing the two Calendar widget tests on an `800x544` viewport with a `RenderFlex overflowed by 198 pixels` error in `CalendarPage`.

## Fix

The calendar grid is now flex-constrained instead of using a shrink-wrapped grid with a fixed `childAspectRatio: 1.05`. The reminder section receives an explicit flex share of the remaining viewport.

## Scope

- Calendar layout only.
- Reminder filtering and selection logic unchanged.
- No changes to other feature surfaces.
- Intended to preserve the existing visual language while making the calendar responsive to constrained viewports.

## Validation target

- Calendar reminder test passes.
- Calendar empty-state test passes.
- Full test suite remains green.
- Independent Android/Backup/FollowUp/Typography waves remain unaffected.

## Code commit

`eda4c6459ad588834163e1ecf2e03572f47cfff5`
