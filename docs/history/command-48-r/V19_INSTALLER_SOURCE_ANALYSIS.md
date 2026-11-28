# V19 Installer Source Analysis

**Forensic reference:** COMMAND 48-R  
**Approved installer source ref:** `310c0e20e3447c488c1e1c102c38bea5040708ca`  
**Installer path:** `lib/services/g1_drift_schema.dart`  
**Installer blob:** `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`  
**Declaration:** `G1DriftSchema.version == 19`

## Source identity

The historical source inventory identifies `3bede0d3615c74b37985905f8b21d70d9b44bcce` as the v19 schema-introduction commit. The explicitly approved ref `310c0e20e3447c488c1e1c102c38bea5040708ca` is a later inventory/documentation commit, but contains the identical installer blob `9f0243...`. The runner checked out the exact approved ref and asserted the blob SHA before running. No source substitution or installer edit occurred.

## Exact source inventory

| Component | Historical path | Blob SHA |
|---|---|---|
| Main v7 schema | `lib/services/g1_drift_schema.dart` | `cd065ff25c680ed064e89068b3d063e737091025` |
| v19 installer | `lib/services/g1_drift_schema.dart` | `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21` |
| Task model | `lib/models/task.dart` | `328c402318878717d9165bccf8303fa6674321bf` |
| Occurrence codec | `lib/services/occurrence_sql_codec.dart` | `ae9fb8548fa57a8a3a48e1faa2e98a44e636003e` |
| Recurrence codec | `lib/services/recurrence_sql_codec.dart` | `29ee7c0c778d99135daf376ba19f7773e4760ce4` |
| Installer tests | `test/services/g1_drift_schema_test.dart` | `7a154b499278d9193977e88a3806a36906346806` |
| Package manifest | `pubspec.yaml` | `8c703b55a820a325a5d10d9ade1fd24dccf043f3` |

## Original execution path

The runner invoked the unchanged `G1DriftSchema.install(QueryExecutor)` from the exact historical checkout. It calls Drift `executor.ensureOpen(schema)`, then runs the original transactional DDL and migration methods, including `migrateTaskPeople`, `migrateCanonicalEntities`, `Task.fromLegacyJson`, `OccurrenceSqlCodec.migrateLegacyEnvelopes`, and `RecurrenceSqlCodec.migrateLegacyRules`. The installer checks foreign keys before commit and rolls back on thrown errors.

The installer source contains no explicit SQL `PRAGMA user_version = ...` statement and comments that the storage metadata marker is canonical. However, the actual Drift `ensureOpen(schema)` call advanced the physical database `PRAGMA user_version` from 7 to 19 in the runtime execution. This observed behavior is authoritative; no manual version write was used.

## SQL-owned Task fields and compatibility envelope

The migration builds a legacy JSON envelope using `Task.fromLegacyJson` from a partial projection of Task columns. This can add default values for SQL-owned fields to the envelope (for example, a completed Task's generated envelope may contain `completed:false` while the SQL column remains `completed=1`). The historical v19 `TaskStore._decodeTask` explicitly overwrites those envelope keys from canonical SQL columns before decoding. This is not SQL-row data loss in the observed run, but consumers must use the historical TaskStore read boundary rather than treating those duplicated envelope values as authoritative.

## Result

The exact historical Installer executed successfully against a physically separate copy of the verified Main v7 fixture. See `V19_EXECUTION_RUNNER_REPORT.md` and `V19_EXECUTION_EXCEPTION_LEDGER.md` for runtime evidence and residual observations.
