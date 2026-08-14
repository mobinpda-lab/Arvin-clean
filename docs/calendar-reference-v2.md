# Calendar Reference v2

## Baseline

The Calendar feature in Arvin-clean is already a stabilized product surface. Its current implementation keeps Jalali conversion, Persian digits, RTL weekday ordering, selected-day reminder filtering, and a compact fixed month grid for constrained Flutter test viewports.

## Reference comparison

`mobinpda-lab/arvin-task-tracker` was reviewed as a reference. It uses `shamsi_date` for Jalali conversion and centralizes date/time formatting, while its FollowUp reminder flow uses Tehran timezone scheduling. Those patterns are useful references.

The reference implementation does not provide a strictly superior CalendarPage implementation: its date editing still relies on Flutter's standard Gregorian date picker. Therefore no CalendarPage replacement is justified at this stage.

## Current decision

Do not rewrite CalendarPage or replace its conversion logic merely to match the reference repository. Calendar changes require a dedicated regression wave covering:

1. Jalali month/day conversion
2. Persian digits
3. RTL weekday ordering
4. selected-day reminders
5. empty-state rendering
6. constrained 800x544 layout
7. reminder time rendering
8. navigation between Jalali months

Only a measured defect or a demonstrably better tested implementation should trigger a Calendar code change.
