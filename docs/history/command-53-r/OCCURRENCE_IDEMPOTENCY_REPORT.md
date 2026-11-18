# Occurrence Idempotency Report — COMMAND 53-R

**Status: BLOCKED / NOT IMPLEMENTED**

COMMAND 50 evidence confirms the first successful migration retires `occurrenceHistory` and `checklistOccurrences`; the subsequent invocation then compares existing normalized SQL rows with empty source maps and fails parity. No idempotency receipt or per-Task completion marker was established by the forensic evidence.

Required implementation contract:
- Distinguish absent source keys from present source keys using `containsKey`.
- Validate an already-migrated destination by deterministic occurrence identity, Task ownership, scheduled timestamp, status, ordinal and checklist relations.
- Treat absent source plus absent destination as no migrated history.
- Treat present source as pending transfer; write destination and receipt atomically.
- Write receipt only after full source/destination parity.
- Reject duplicate identities and conflicting destination rows; never hide conflicts with INSERT OR IGNORE or blanket upsert.
- Repeated execution 1/2/3 must produce byte-identical logical snapshots.

No code or physical execution for this repair was performed. The receipt schema, receipt version/key, conflict policy and transaction boundary remain unimplemented and unverified.