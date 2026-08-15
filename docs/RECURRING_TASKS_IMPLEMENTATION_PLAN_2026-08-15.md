# Arvin — Recurring Tasks Implementation Plan 2026-08-15

## Audit
`Task` is already the Unified Item foundation and currently contains `reminderDate`, `completed`, and `followUps`; no recurrence fields are present. Do not introduce a separate recurring-task model or repository.

## Next implementation slice
1. Add a backward-compatible recurrence value object/fields to `Task`.
2. Keep recurrence optional and absent from legacy JSON when unset.
3. Support daily, monthly, yearly, and once-per-day semantics without inventing a time for all-day items.
4. Add pure recurrence calculation and tests before UI.
5. Implement `Resume From Today` as a future-schedule operation; never rewrite completion/history.
6. Then connect the UI card and quick actions.

## Safety gates
- No parallel storage/repository.
- Preserve existing JSON migration behavior.
- Run unit tests and CI before moving to UI.
- Update project status/roadmap after the implementation slice.
