# HISTORICAL DEPENDENCY REPORT — COMMAND 44-R

**Status:** LOCKFILE INSPECTED / RESOLUTION PENDING

## Exact lockfile

The v19 and v20 historical revisions share lockfile blob:
`ceeb9f91e3dd7f6877b1a024c0903fc6ae9c44c4`.

| Package | Locked version |
|---|---:|
| drift | 2.35.0 |
| drift_dev | 2.35.0 |
| drift_flutter | 0.3.1 |
| sqlite3 | 3.6.0 |
| sqlite3_flutter_libs | 0.6.0+eol |

The historical v19/v20 pubspecs constrain Dart to `>=3.5.0 <4.0.0`. The lockfile is the dependency authority; the runner uses `flutter pub get --enforce-lockfile` and then verifies that `pubspec.lock` has not changed.

## Historical migration dependency closure

The v19 `G1DriftSchema` imports the original Task model, `occurrence_sql_codec.dart` and `recurrence_sql_codec.dart`. The v19 installer calls the original occurrence and recurrence migration routines. These files are compiled from the exact historical v19 checkout; they are not copied, rewritten or replaced.

The v20 schema additionally imports `g1_many_to_many_hierarchy_migration.dart`. That migration declares source version 19 and target version 20. The v20 source checkout is tested independently from the v19 checkout.

## Resolution evidence

The runner captures Flutter/Dart versions, Flutter Doctor, the lockfile checksum and the complete `flutter pub get --enforce-lockfile` log for each historical revision. Resolution is not marked PASS until the GitHub Actions job completes successfully.
