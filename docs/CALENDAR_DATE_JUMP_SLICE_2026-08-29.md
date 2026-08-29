# Calendar explicit Jalali date jump — slice record

Status: implementation slice, non-blocking.
Owner requirement: Calendar must support direct «برو به تاریخ» navigation in addition to day/week/month movement.

The dated-task/follow-up projection fix is now on production main via #533. This slice adds only a reusable Jalali date-selection dialog and focused widget coverage on the resulting current main.

Integration rule:
- reuse existing Calendar state and Jalali conversion in `CalendarPage`;
- wire the dialog through the existing day-selection path so month/day state remains canonical;
- cancel must not mutate calendar state;
- no second calendar model, store or settings path;
- integration remains a separate tiny slice so this reusable helper does not create a collision with other Calendar work.

Tracked by #529 and owner decisions recorded under #524.
