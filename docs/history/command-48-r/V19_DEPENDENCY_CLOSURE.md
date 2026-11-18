# V19 Dependency Closure

| Dependency | Exact historical source | Runtime evidence |
|---|---|---|
| Flutter | Historical workflow requested stable 3.47.0 | `Flutter 3.47.0` |
| Dart | SDK bundled with Flutter 3.47.0 | `Dart 3.13.0` |
| Drift | Historical lockfile | Resolved `drift 2.35.0` |
| SQLite package | Historical lockfile | Resolved `sqlite3 3.6.0` |
| Native SQLite | Ubuntu runner `libsqlite3-dev` | Physical `NativeDatabase(File)` execution |
| Task model | `lib/models/task.dart`, blob `328c402318878717d9165bccf8303fa6674321bf` | Exact source checkout |
| Occurrence codec | `lib/services/occurrence_sql_codec.dart`, blob `ae9fb8548fa57a8a3a48e1faa2e98a44e636003e` | Exact source checkout |
| Recurrence codec | `lib/services/recurrence_sql_codec.dart`, blob `29ee7c0c778d99135daf376ba19f7773e4760ce4` | Exact source checkout |
| Installer | `lib/services/g1_drift_schema.dart`, blob `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21` | Exact blob asserted in workflow |
| Fixture | Source commit `f211326e7615f1c907494232dd3aec8d4732c83c` | SHA verified before independent copy |

## Runtime resolution

- `flutter pub get --enforce-lockfile`: PASS.
- `git diff --exit-code -- pubspec.lock`: PASS (no lockfile change).
- The full historical source checkout was used; schema/model/codec files were not copied into a modern branch or rewritten.
- No app Store constructor is required for the installer entry point; the original QueryExecutor and native SQLite implementation are used.
