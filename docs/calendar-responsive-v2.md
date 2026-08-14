# Calendar Responsive Fix

Date: 2026-08-14

## Problem

CI exposed a `RenderFlex overflowed by 198 pixels` failure in `test/calendar_page_test.dart` at an 800x544 test viewport. The calendar grid consumed too much vertical space and hid the selected-day reminder area.

## Fix

`lib/calendar_page.dart` now sizes the calendar grid from the available viewport using `LayoutBuilder` and a bounded grid height. Reminder and empty-state content remains below the grid.

## Validation target

- `flutter analyze`
- `flutter test test/calendar_page_test.dart`
- Android release validation

Commit: `29e767d54e25337588ab59d29e66c5cfe4f6bedc`
