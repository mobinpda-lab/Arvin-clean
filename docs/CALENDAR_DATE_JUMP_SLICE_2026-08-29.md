# Calendar explicit Jalali date jump — slice record

Status: implementation slice, non-blocking.
Owner requirement: Calendar must support direct «برو به تاریخ» navigation in addition to day/week/month movement.

This slice adds only a reusable Jalali date-selection dialog and focused widget coverage. It deliberately does not modify `CalendarPage` while the dated-task projection lane (#533) is validating.

Integration rule:
- reuse existing Calendar state and Jalali conversion in `CalendarPage`;
- wire the dialog after the current calendar projection lane is safely merged/reconciled;
- selecting a date must call the existing day-selection path so month/day state remains canonical;
- cancel must not mutate calendar state;
- no second calendar model, store or settings path.

Tracked by #529 and owner decisions recorded under #524.
