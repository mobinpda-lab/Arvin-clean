# COMMAND 50-R — Occurrence Transformation Matrix

**Status:** Partial evidence. The simple pending case and retry path are physically evidenced by COMMAND 49's GitHub Actions artifact. The expanded matrix is encoded in the COMMAND 50 test harness but does not yet have a completed run artifact.

| Scenario | Historical source / target behavior | Evidence status |
|---|---|---|
| One pending Occurrence | Timestamp key and status map to SQL row | First V19 install succeeded on COMMAND 49 fixture |
| Completed Occurrence | `completionDate` → nullable `completed_at`; `result` → nullable `result` | Source logic inspected; expanded physical run pending |
| Cancelled | Enum `RecurrenceOccurrenceStatus.cancelled` exists | Source support confirmed; expanded physical run pending |
| Missed / skipped | Both enum values exist | Source support confirmed; expanded physical run pending |
| Multiple Occurrences per Task | Ordinal follows iteration order of history map | Expanded physical run pending |
| Multiple Tasks | Each row retains its Task ID | COMMAND 49 one-task probe only |
| Recurrence linked | Recurrence definition stored in `task_recurrence_rules` | Existing fixture has non-empty recurrence JSON; full combined matrix pending |
| No Recurrence | No normalized recurrence row expected | Expanded physical run pending |
| Omitted optional NULL values | SQL NULL is read back with optional JSON keys omitted | Simple pending path passed |
| Explicit JSON NULL keys | Readback omits null-valued keys | Code-level mismatch identified; physical negative test pending |
| Timestamp boundaries | Occurrence codec stores scheduled timestamp strings without parsing them | Physical boundary matrix pending |
| Unknown Task-level JSON field | Task model retains it under legacy metadata | Model logic inspected; physical matrix pending |
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

## Fields explicitly absent from the historical contract

The old JSON Occurrence shape and V19 destination schema have no per-Occurrence `createdAt`, `executedAt` or `recurrenceId`. No such values can be compared or preserved because the source does not define them. Recurrence is owned by Task (`task_recurrence_rules.task_id`), not directly by an Occurrence. V19 synthesizes the destination Occurrence ID from Task ID + scheduled timestamp.

The COMMAND 50 workflow has now been corrected to compare by the composite identity `task_id|scheduled_at` and derive its expected rows from the captured V7 source JSON snapshot. A later completed run is required before those strengthened assertions count as accepted evidence.
