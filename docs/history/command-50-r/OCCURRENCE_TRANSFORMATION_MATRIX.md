# COMMAND 50-R — Occurrence Transformation Matrix

**Status:** PHYSICAL MATRIX EXECUTED — run `44367002583`, job `135024297667`, artifact `14456982207`. The forensic test job completed successfully; expected historical codec defects are recorded as FAIL_CONFIRMED, not treated as passing migration behavior.

| Scenario | Historical source / target behavior | Evidence status |
|---|---|---|
| One pending Occurrence | Timestamp key and status map to SQL row | First V19 install succeeded on COMMAND 49 fixture |
| Completed Occurrence | `completionDate` → nullable `completed_at`; `result` → nullable `result` | PASS — final physical matrix run |
| Cancelled | Enum `RecurrenceOccurrenceStatus.cancelled` exists | PASS — final physical matrix run |
| Missed / skipped | Both enum values exist | Source support confirmed; expanded physical run pending |
| Multiple Occurrences per Task | Ordinal follows iteration order of history map | PASS — final physical matrix run |
| Multiple Tasks | Each row retains its Task ID | PASS — final physical matrix run |
| Recurrence linked | Recurrence definition stored in `task_recurrence_rules` | PASS — linked and unlinked Task recurrence physically checked |
| No Recurrence | No normalized recurrence row expected | Expanded physical run pending |
| Omitted optional NULL values | SQL NULL is read back with optional JSON keys omitted | Simple pending path passed |
| Explicit JSON NULL keys | Readback omits null-valued keys | FAIL_CONFIRMED — physical negative fixture; rollback and legacy source preservation verified |
| Timestamp boundaries | Occurrence codec stores scheduled timestamp strings without parsing them | Physical boundary matrix pending |
| Unknown Task-level JSON field | Task model retains it under legacy metadata | PASS — physical TaskStore readback |
| Unknown Occurrence-state field | Destination codec has no corresponding SQL field and readback omits it | Code-level mismatch identified; physical negative test pending |

## Confirmed single-row physical result

From COMMAND 49 run `44314123737`, the post-first-install database artifact contains:

- Task ID: `command49-occurrence-task`
- Scheduled timestamp: `2026-11-01T08:00:00.000Z`
- Status: `pending`
- Completed timestamp: SQL NULL
- Result: SQL NULL
- Ordinal: `0`
- Generated ID: `occ-Y29tbWFuZDQ5LW9jY3VycmVuY2UtdGFza3wyMDI2LTExLTAxVDA4OjAwOjAwLjAwMFo`

The generated ID, Task ID, timestamp and status match the source probe. This confirms the first transfer of that simple record.

## Interpretation

Do not treat a successful first transfer as proof of idempotency. The historical codec removes the source history fields after its first successful parity check, but its next invocation compares an empty source map with the already-populated destination rows. See `OCCURRENCE_PARITY_RESULTS.md`.

## Final physical matrix result

The final COMMAND 50 run passed its forensic assertions. The base fixture contains eight Occurrence rows across four Tasks. Expected SQL rows were derived from the captured V7 JSON and compared by composite identity `task_id|scheduled_at`, with ID, status, completed timestamp, result and ordinal checked. TaskStore readback and recurrence conversion were exercised. The negative explicit-NULL and unknown-state cases intentionally reproduced the historical parity errors; their original JSON rows remained present, no partial Occurrence rows remained, SQLite integrity was `ok`, and foreign-key violations were zero.

## Fields explicitly absent from the historical contract

The old JSON Occurrence shape and V19 destination schema have no per-Occurrence `createdAt`, `executedAt` or `recurrenceId`. No such values can be compared or preserved because the source does not define them. Recurrence is owned by Task (`task_recurrence_rules.task_id`), not directly by an Occurrence. V19 synthesizes the destination Occurrence ID from Task ID + scheduled timestamp.

The COMMAND 50 workflow has now been corrected to compare by the composite identity `task_id|scheduled_at` and derive its expected rows from the captured V7 source JSON snapshot. A later completed run is required before those strengthened assertions count as accepted evidence.
