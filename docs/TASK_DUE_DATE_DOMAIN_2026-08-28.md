# Task due date domain contract — Issue #375

Status: first canonical foundation slice.

## Owner requirement restored
Arvin keeps the Task's intended/due date-time independent from both reminder scheduling and FollowUp history.

Canonical meanings:
- `Task.dueDate`: when the Task itself is intended/due;
- `Task.reminderDate`: when the user should be reminded about the Task;
- `FollowUp.dateTime`: FollowUp/history timestamp;
- independent FollowUp reminder is owned separately by Issue #372.

## This slice
- adds optional backward-compatible `Task.dueDate`;
- persists it through existing `Task.toJson/fromJson` only;
- legacy records with no `dueDate` remain valid and decode to null;
- does not infer a due date from reminder/follow-up history;
- tests prove due/reminder/follow-up timestamps remain independent.

## Next slices
- audit copy/update services so future due dates are never dropped by unrelated edits;
- Task create/edit/detail Jalali due date UI;
- Today/Future/Overdue projections in #369 must use `dueDate` rather than reminder/follow-up timestamps;
- Move to Today updates `dueDate` on the same canonical Task;
- backup/sync/report/search integration acceptance.

## Guardrails
No second Task model, database, storage key, date converter or reminder scheduler is introduced.
