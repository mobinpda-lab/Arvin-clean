# Arvin — Recurring Tasks Implementation Plan 2026-08-15

## Audit
`Task` is already the Unified Item foundation and currently contains optional recurrence through `RecurrenceRule`; no separate recurring-task model or repository is permitted.

## Current recurrence contract
`RecurrenceFrequency` currently supports:
- daily
- weekly
- monthly
- yearly
- once-per-day

`RecurrenceRule.interval` must be greater than zero. Serialization uses the enum name and `fromJson` falls back to `daily` for an unknown frequency.

Weekly recurrence is implemented as `7 * interval` days and is covered by unit tests. Existing daily/monthly/yearly/once-per-day behavior remains unchanged by this slice.

## Next implementation slice
1. Keep recurrence optional and absent from legacy JSON when unset.
2. Preserve backward compatibility for existing recurrence JSON.
3. Keep recurrence calculation pure and independently testable.
4. Verify boundary behavior for monthly/yearly dates before expanding recurrence semantics further.
5. Implement and test `Resume From Today` as a future-schedule operation; never rewrite completion/history.
6. Then connect recurrence to UI cards and quick actions.

## Safety gates
- No parallel storage/repository.
- Preserve existing JSON migration behavior.
- Do not add additional recurrence frequencies without a contract review and tests.
- Run unit tests, analyze and CI before moving recurrence into UI.
- Update project status/roadmap after each implementation slice.
