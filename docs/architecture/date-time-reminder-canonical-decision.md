# Arvin Date/Time/Reminder Canonical Decision

Status: Proposed architecture decision for #2301
Base: main `81ed798d6a6d30316f2347242bc478b59e7caa20`
Date: 2026-10-05

## Product contract

1. Date only means a true All-Day Task. It must not be represented to the user as 00:00.
2. Date + Time means a timed Task and exactly one canonical automatic Reminder at the same timestamp.
3. No Date means no due-based automatic Reminder/Event.
4. Date-only <-> Date+Time transitions must be reversible and idempotent.
5. Changing/removing date or time must reconcile the existing canonical Reminder/Calendar projection without duplicates.
6. A manually created Reminder must not be silently overwritten by the automatic due-time Reminder.
7. Provider integrations may use 00:00 only as an adapter compatibility value when required; Arvin UI/domain semantics must remain All-Day.
8. Existing Task identity, historical data, backup/restore compatibility and canonical Reminder/Scheduler/Calendar infrastructure must be preserved.

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
