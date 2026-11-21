# COMMAND 50-R — Occurrence and Recurrence Codec Analysis

## Occurrence identity and encoding

Historical source: `lib/services/occurrence_sql_codec.dart`, blob `ae9fb8548fa57a8a3a48e1faa2e98a44e636003e`.

- `occurrenceId(taskId, scheduledAt)` generates a deterministic ID from UTF-8 `taskId|scheduledAt`, Base64URL encoded without padding and prefixed with `occ-`.
- `_scheduledAt` requires a non-empty string and rejects a mismatch between the map key and `scheduledDate`.
- `writeTask` writes status, optional `completionDate`, optional `result`, and ordinal.
- SQL columns `completed_at` and `result` are nullable.
- `readTask` emits `scheduledDate` and `status`; it emits `completionDate` and `result` only when the SQL values are non-NULL.
- Occurrence timestamps are passed as strings to SQL. This codec does not parse them into DateTime or apply an explicit timezone conversion.
- Supported statuses are defined by `RecurrenceOccurrenceStatus`: pending, completed, missed, skipped and cancelled.

## Two exact parity hazards in the historical code

### 1. Reinstall after successful migration

After the first successful migration, the codec removes `occurrenceHistory` and `checklistOccurrences` from `legacy_payload_json`. On the next invocation it still selects every Task envelope, constructs empty history/checklist maps for that Task, and calls `readTask`. Existing SQL Occurrences are then compared with the empty source maps and cause:

`Occurrence migration parity mismatch for Task <task-id>`

The second invocation is therefore not idempotent for a Task whose history was already migrated. The failure is a false mismatch between a retired source representation and its retained normalized destination rows.

### 2. Explicit NULL keys and unknown state fields

The parity check compares the full decoded source state map with the smaller state map reconstructed by `readTask`.

- If source JSON explicitly contains `completionDate: null` or `result: null`, the SQL row stores NULL and `readTask` omits those keys. The maps are not equal even though the SQL values are semantically NULL.
- If a source Occurrence state contains an unrecognized key, `writeTask` has no destination column for it and `readTask` cannot reconstruct it. The parity check fails before the legacy source keys are removed.

These two hazards were confirmed by direct source comparison and physically reproduced in final run `44368276255`. The negative fixtures retained the original JSON fields after rollback.

## Recurrence conversion

Historical source: `lib/services/recurrence_sql_codec.dart`, blob `29ee7c0c778d99135daf376ba19f7773e4760ce4`.

- Frequency and tracking level are decoded against their historical enums; unknown enum names fail closed.
- Missing interval defaults to 1; missing active defaults to true; missing tracking level defaults to normal.
- Interval and count must be positive integers when present.
- Start/end date strings are parsed with `DateTime.tryParse` and stored using `toIso8601String()`.
- The normalized row stores frequency, interval, start/end, count, active and tracking level.
- Unknown recurrence JSON keys are not represented in the normalized row. The legacy `recurrence_json` column is not removed by this codec, so source JSON remains available there as evidence.

No timestamp, timezone, enum, NULL or unknown-field normalization was added by COMMAND 50. All statements above describe the unmodified historical code.

## Timestamp, identity and relation limits

The legacy Occurrence map has no independent `id`, `createdAt`, `executedAt` or `recurrenceId` field in the historical shape. Its identity is the owning Task ID plus the timestamp map key; `scheduledDate` is a redundant consistency check. Therefore no original per-Occurrence creation/execution timestamp or recurrence identifier exists to copy. The destination ID is synthesized deterministically; the destination row has `scheduled_at` and nullable `completed_at`, but no `created_at`, `executed_at` or `recurrence_id` column.

Recurrence is linked at Task level: `task_recurrence_rules.task_id` references `tasks.id`, while `task_occurrences.task_id` also references `tasks.id`. There is no direct foreign key from an Occurrence to a recurrence rule. This is the complete relationship represented by V19, not an omitted value during the migration.

## First-difference boundary

- First installation: A (V7 extraction) reads the legacy map; B (Installer) calls `writeTask`; C (SQL) receives the expected rows; D (Codec readback) reconstructs the expected map and parity passes. Only then are the two legacy Occurrence keys removed.
- Second installation: A now reads no legacy Occurrence keys; B still processes that Task and builds empty history/checklist maps; C leaves the existing destination rows intact; D reads those rows and compares a non-empty readback with the empty extracted maps. The mismatch is raised at D, after the first successful transfer. The transaction aborts the second installation.

The V19 installer does not put an Occurrence migration marker or a per-Task completion marker around `migrateLegacyEnvelopes`, unlike the recurrence migration's `recurrence_rules_migrated_v1` marker.

## Final physical verification

Run `44368276255` completed successfully with the final diagnostic harness. The source snapshot was captured, expected rows were derived from that snapshot, and SQL output was compared by Task ID + scheduled timestamp. The offset-bearing Occurrence timestamp remained byte-for-byte text in SQL; recurrence start/end timestamps with +03:30 were normalized to UTC by the historical Recurrence Codec. Explicit-null and unknown-state negative fixtures raised the expected parity errors while preserving their source JSON and leaving no partial Occurrence rows; integrity and foreign-key checks remained clean.
