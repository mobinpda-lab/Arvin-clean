# V19 Occurrence and Recurrence Report — COMMAND 49-R

**Verdict: BLOCKED — non-empty Occurrence migration exposes a parity failure; Recurrence transfer not reached.**

## Historical data
- The immutable V7 source fixture has a non-empty daily recurrence JSON for `task-active-001`, including the unknown field `unknownScheduleField`.
- The workflow creates an additional Task in an isolated copy with a non-empty Occurrence history entry. The source fixture itself is not changed.
- The latest test uses a canonical pending Occurrence entry to avoid adding completion/result semantics to the first parity probe.

## Actual result
The original V19 Occurrence codec throws:

`Bad state: Occurrence migration parity mismatch for Task command49-occurrence-task`

This is an observed failure in the actual historical migration path, not a PASS. The installer transaction aborts before the Recurrence migration stage, so recurrence transfer, unknown-field preservation after migration, and occurrence ID/row parity remain unproven.

Evidence:
- Run `44313646995`
- Job `134833931852`
- Artifact `14430913354`

The historical installer and codec were not patched to force a pass.
