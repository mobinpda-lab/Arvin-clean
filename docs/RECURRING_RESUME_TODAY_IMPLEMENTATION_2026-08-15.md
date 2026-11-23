# Recurring Task — Resume From Today

## Audit result
Recurring rules already live in `Task` as the Unified Item source of truth. This slice extends the existing domain only; no repository, storage, or parallel model is introduced.

## Behavior
`resumeFromToday(scheduledFrom, target)` returns the first recurrence occurrence on or after `target`.

It is a pure calculation: it does not mutate completion state, follow-up history, or the original schedule. UI can use the result to move only the future schedule forward.

## Safety
- Preserve all historical occurrences.
- Preserve optional time; all-day items remain time-agnostic at the UI/scheduling layer.
- Test daily and multi-interval behavior before UI integration.
