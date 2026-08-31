# Calendar Jalali date jump — current-main slice

Status: implementation candidate for issue #529, based on main `908d33f7eac9b5e519bfb3c4cc3023fa4ce345b5`.

## Scope

This slice adds only the remaining explicit date-jump UX to the existing canonical `CalendarPage`:

- a visible «برو به تاریخ» action;
- a Jalali year/month/day selector;
- confirmation through the existing `_selectDay` path so selected day and visible period stay canonical;
- cancellation with zero calendar state mutation;
- invalid-day normalization when year/month changes;
- focused widget coverage for confirm, cancel, and day normalization.

## Preserved architecture

No Calendar, Task, FollowUp, storage, repository, persistence key, or launcher model is introduced. Existing day/week/month navigation, «امروز», selected-day rendering, counts, and the canonical Task/FollowUp projection remain unchanged.

Historical PR #535 is treated only as UX reference and is not merged into current main.

## Delivery gate

Draft PR → exact-head Fast → Ready → Build/APK + Device on the same current-main-containing head → canonical Production Orchestrator promotion. Issue #529 closes only after that validated merge.
