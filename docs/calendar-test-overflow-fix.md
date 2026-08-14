# Calendar test overflow fix

- Date: 2026-08-14
- Branch: `fix/calendar-test-overflow-v3`
- Commit: `f18213f10fca87b44620c8d07c20dc0267d2fcbd`

## Problem

The Calendar widget tests failed because the six-week calendar grid used a large square `childAspectRatio`. In the Flutter test viewport, the grid consumed most of the vertical space and pushed the selected-day reminder area out of view, producing a `RenderFlex overflow` and hiding the expected reminder/empty-state text.

## Fix

The calendar grid now uses a deterministic compact row height (`mainAxisExtent: 44`). Reminder filtering and selected-day behavior remain unchanged. This keeps the reminder section visible in both the reminder and empty-state widget tests.

## Validation

Run `flutter test test/calendar_page_test.dart` and the full `flutter test` suite on the branch. Do not treat the previous two Calendar failures as a product-logic regression after this layout-only change until the new CI result is available.
