# Calendar Layout Fix — 2026-08-14

## Problem
The full Flutter test suite exposed two Calendar tests failing on an 800x544 test viewport. The page body overflowed by 198px and the selected-day reminder/empty state was pushed outside the visible area.

## Fix
The month grid now computes its actual row count and uses a bounded `SizedBox` with fixed row height. Reminder business logic and selected-day filtering were not changed.

## Commit
- Calendar fix: `64bc7e47e5aeaf07f81a6dc22edfe1408466cb5c`
- PR: #31

## Validation target
`test/calendar_page_test.dart`
