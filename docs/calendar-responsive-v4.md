# Calendar Responsive v4

Date: 2026-08-14

## Problem

The full Flutter test suite reproduced two Calendar failures in an 800x544 test viewport. The page body overflowed by 198 pixels, hiding the selected-day reminder and the empty state.

## Fix

The month grid now calculates the required row count and uses a compact fixed row extent. The grid is placed inside a bounded `SizedBox`, while the selected-day reminder list remains the flexible portion of the page.

## Scope

- Calendar layout only.
- Reminder filtering and selection logic unchanged.
- No changes to Backup, FollowUp, Typography, or release logic.

## Validation target

Both `calendar_page_test.dart` widget tests must pass, followed by the full Flutter test suite and Android release validation.

## Commits

- Code: `5022bcf96cdb1264454bea2828ad1bcbe5c73f12`
