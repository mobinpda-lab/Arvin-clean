# Arvin Date/Time/Reminder Canonical Decision

Status: Authoritative owner override dated 2026-11-09; supersedes the earlier due-time auto-reminder contract
Base: main `81ed798d6a6d30316f2347242bc478b59e7caa20`
Date: 2026-11-09

## Product contract — authoritative owner override, 2026-11-09

1. Date only means a true All-Day Task. It must not be represented to the user as 00:00.
2. Date + Time remains a timed Task deadline; selecting it must not create a TaskReminder automatically.
3. No Date means no due-date projection.
4. Changing or removing dueDate must not create, modify, or remove an explicitly configured TaskReminder.
5. A TaskReminder is created, edited, enabled, disabled, or removed only through the explicit reminder controls.
6. The canonical Task model stores reminder records only in `taskReminders`.
7. `Task.reminderDate` is a read-only computed compatibility getter: it returns the earliest date/time among enabled TaskReminders, or null when none are enabled.
8. Calendar and notification integrations must project the same canonical TaskReminder records; they must not infer reminders from dueDate or Follow-up history.
9. Existing Task identity, reminder IDs, timestamps, backup/restore compatibility and scheduler delivery state must be preserved during migration.
## Implementation boundary

The implementation must use the existing canonical Task, Reminder/Scheduler and Calendar projection infrastructure. No parallel Task, Reminder, Calendar, repository, storage or recurrence engine may be introduced.

Any schema/model change must include a backward-compatible migration strategy that preserves IDs and existing due/reminder data.

## Validation contract

Before merge:
- focused Date-only / Date+Time / transition / duplicate-reconciliation tests;
- Analyze and relevant test suite;
- exact-head Build;
- exact-head Android Smoke when available.

Final device verification is supplementary and must not block independent development.

## Scope

This document records the decision needed to unblock the implementation lane. Product behavior is binding from #2301; unresolved implementation details must be decided against the canonical existing architecture, not by creating a second implementation.
