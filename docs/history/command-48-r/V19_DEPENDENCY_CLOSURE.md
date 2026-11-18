# V19 Dependency Closure

| Dependency | Exact historical source | Why required | Status |
|---|---|---|---|
| Drift QueryExecutor API | v19 `pubspec.yaml`, drift `^2.32.1` | Installer executor and transaction operations | Pinned by historical lockfile |
| Flutter / Dart | Flutter 3.47.0; Dart resolved by that SDK | Historical test/runtime | Workflow records exact output |
| Task model | `lib/models/task.dart`, blob `328c402318878717d9165bccf8303fa6674321bf` | Legacy JSON decode and TaskReminder conversion | Included by exact source checkout |
| Occurrence codec | `lib/services/occurrence_sql_codec.dart`, blob `ae9fb8548fa57a8a3a48e1faa2e98a44e636003e` | Occurrence/checklist envelope migration and parity checks | Included by exact source checkout |
| Recurrence codec | `lib/services/recurrence_sql_codec.dart`, blob `29ee7c0c778d99135daf376ba19f7773e4760ce4` | Strict recurrence validation and canonical rule writes | Included by exact source checkout |
| Installer | `lib/services/g1_drift_schema.dart`, blob `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21` | Original v19 schema installation/migration | Exact blob asserted in workflow |
| Native SQLite executor | `drift/native.dart` and historical `sqlite3` dependency | Physical database file execution | Workflow runtime |
| Fixture | Fixture source commit `f211326e7615f1c907494232dd3aec8d4732c83c` | Exact Main v7 physical data | SHA-256 verified before copy and execution |

## Model/codec behavior

- SQL/DDL work is performed by the original `G1DriftSchema.install` through Drift's QueryExecutor.
- `Task.fromLegacyJson` decodes Task JSON and converts legacy Task/Follow-up reminder data. Invalid non-empty date values throw rather than being silently discarded.
- `OccurrenceSqlCodec` validates occurrence-history/checklist shapes, writes normalized occurrence rows, reads them back and compares canonical JSON.
- `RecurrenceSqlCodec` rejects malformed/unknown frequency, invalid interval/count/date and conflicting recurrence sources. Unknown keys in the raw recurrence source are not used by the normalized rule, while the original recurrence_json remains available in the Task row.
- The source includes transactional rollback. No external Store is required to call the installer entry point.

The runner must checkout the entire exact historical source commit so transitive imports, generated sources and lockfile remain historical. Copying only the schema file is prohibited.
