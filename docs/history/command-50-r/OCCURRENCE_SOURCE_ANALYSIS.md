# COMMAND 50-R — Occurrence Source Analysis

**Disposition:** COMPLETE — root cause and expanded physical matrix verified by COMMAND 50-R final run `44368276255`.
**Historical source commit:** `310c0e20e3447c488c1e1c102c38bea5040708ca`
**Immutable V7 fixture source commit:** `f211326e7615f1c907494232dd3aec8d4732c83c`
**Fixture SHA-256:** `68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0`

## Historical source inventory

| Component | Historical path | Blob SHA |
|---|---|---|
| V19 Installer / schema | `lib/services/g1_drift_schema.dart` | `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21` |
| Occurrence Codec | `lib/services/occurrence_sql_codec.dart` | `ae9fb8548fa57a8a3a48e1faa2e98a44e636003e` |
| Recurrence Codec | `lib/services/recurrence_sql_codec.dart` | `29ee7c0c778d99135daf376ba19f7773e4760ce4` |
| Task Model | `lib/models/task.dart` | `328c402318878717d9165bccf8303fa6674321bf` |
| Task Store | `lib/services/task_store.dart` | `625f7b24523e621adba7ae7a59e4c3e13c272a09` |

The historical Installer calls `migrateCanonicalEntities`, retires eligible legacy Task columns, then calls `OccurrenceSqlCodec.migrateLegacyEnvelopes`, followed by `RecurrenceSqlCodec.migrateLegacyRules`. The historical Installer, codecs, schema and model were read-only in this investigation.

## Old Occurrence representation

The old Task JSON envelope is stored in `tasks.legacy_payload_json`. Occurrence history is an object under `occurrenceHistory`, keyed by the scheduled timestamp. Each value can contain:
- `scheduledDate`
- `status`
- `completionDate`
- `result`

The same envelope may contain `checklistOccurrences`, keyed by scheduled timestamp with a list of strings. The old map key is the timestamp identity; the inspected representation does not define an independent legacy Occurrence row ID.

## Destination representation

V19 creates:
- `task_occurrences(id, task_id, scheduled_at, status, completed_at, result, ordinal)`
- `occurrence_checklist_items(occurrence_id, ordinal, value)`

Occurrence IDs are generated deterministically by `OccurrenceSqlCodec.occurrenceId(taskId, scheduledAt)`; they are not copied from an old per-occurrence ID field. Task identity and scheduled timestamp are the source identity inputs.

## Model and Store behavior

`Task._decodeOccurrenceHistory` accepts the old map and copies each state map. `Task.toJson` serializes non-empty occurrence history. Unknown Task-level JSON fields are captured by `decodeLegacyFollowUpMetadata` under `unknownFields`.

`TaskStore._decodeTask` reads normalized recurrence through `RecurrenceSqlCodec.readTask`, reads Occurrence rows through `OccurrenceSqlCodec.readTask`, and puts the resulting history back into the Task envelope before `Task.fromJson`.

## Test evidence source

The historical COMMAND 49 runner is `test/command49_v19_safety_test.dart` at canonical commit `1efd9b1fc41b15ac94dd67d8b128dc702ab7997c`. The new COMMAND 50 forensic harness is test-only and does not alter the historical migration source.

## Final forensic harness and workflow identity

- COMMAND 50 test harness at execution commit `9032256a9e569c1bf5d7290bcfc966b8c5660c5f`: `test/command50_occurrence_forensic_test.dart`, blob `f778d329f6f17c88174f82e9f53cd8cb977123f7`.
- Workflow: `.github/workflows/command-50-r-occurrence-forensic.yml`; current workflow blob `9c7b0e2e1f6876cba8090d10995cbe045f954447` (workflow logic was fixed before the final run).
- Final physical run: `44368276255`; job `135027809312`; artifact `14458356507`.
- Artifact SHA-256: `eecb19a699a224044e8a868e69e133ee2ecc5ad76660f93e0ee45730fd4071b8`.
- The run verified the exact historical source blobs listed above and the immutable V7 fixture hash.

Final rerun with explicit source-retention assertions: run `44368276255`, artifact `14458356507`, artifact SHA-256 `eecb19a699a224044e8a868e69e133ee2ecc5ad76660f93e0ee45730fd4071b8`. This final harness explicitly verifies that explicit-null keys and the unknown `futureField` remain in their original legacy JSON after rollback.
