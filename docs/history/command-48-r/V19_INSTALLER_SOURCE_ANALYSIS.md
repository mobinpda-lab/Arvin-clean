# V19 Installer Source Analysis

**Forensic reference:** COMMAND 48-R at `c838ddbbdd8bb6f41301d51231ce3d2b71327a4c`  
**Approved source ref supplied by COMMAND 47-R:** `310c0e20e3447c488c1e1c102c38bea5040708ca`  
**Installer path:** `lib/services/g1_drift_schema.dart`  
**Installer blob:** `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`  
**Installer declaration:** `G1DriftSchema.version == 19`

## Source identity clarification

The source inventory identifies `3bede0d3615c74b37985905f8b21d70d9b44bcce` as the v19 schema-introduction commit. The supplied ref `310c0e20e3447c488c1e1c102c38bea5040708ca` is a later documentation/inventory commit, but it contains the exact same installer blob SHA `9f0243...`. The execution runner therefore checks out the explicitly approved ref `310c0e...` and independently verifies the installer blob before execution. No source substitution or code modification is made.

## Exact source inventory

| Component | Historical path | Blob SHA |
|---|---|---|
| v7 schema | `lib/services/g1_drift_schema.dart` at Main v7 | `cd065ff25c680ed064e89068b3d063e737091025` |
| v19 installer | `lib/services/g1_drift_schema.dart` | `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21` |
| Task model | `lib/models/task.dart` | `328c402318878717d9165bccf8303fa6674321bf` |
| Occurrence codec | `lib/services/occurrence_sql_codec.dart` | `ae9fb8548fa57a8a3a48e1faa2e98a44e636003e` |
| Recurrence codec | `lib/services/recurrence_sql_codec.dart` | `29ee7c0c778d99135daf376ba19f7773e4760ce4` |
| v19 installer tests | `test/services/g1_drift_schema_test.dart` | `7a154b499278d9193977e88a3806a36906346806` |
| v19 package manifest | `pubspec.yaml` | `8c703b55a820a325a5d10d9ade1fd24dccf043f3` |

## Execution path

The original entry point is `G1DriftSchema.install(QueryExecutor)`. It opens the executor, disables FK enforcement for the transactional cutover, creates the target tables, conditionally adds missing legacy columns, runs the original people/entity/reminder/occurrence/recurrence transformations, checks foreign keys, commits, and re-enables foreign keys. Any thrown exception enters the original rollback branch.

The installer is SQL/Drift-executor based, but it is not SQL-only: it calls `Task.fromLegacyJson`, `OccurrenceSqlCodec.migrateLegacyEnvelopes`, and `RecurrenceSqlCodec.migrateLegacyRules`. The historical Dart model and both codecs are therefore mandatory parts of the installer closure.

The installer does not write SQLite `PRAGMA user_version`; it explicitly documents `arvin_storage_meta` as its canonical migration marker. A successful run must not be judged by user_version changing to 19.
