# COMMAND 47-R — V7 → V19 Execution Report

**Disposition: BLOCKED — V7 TO V19 NOT PROVEN**  
**Repository:** mobinpda-lab/Arvin-clean  
**Canonical branch:** recovery-02/main-based-integration  
**PR:** #3495 — OPEN / DRAFT / UNMERGED  
**Reference SHA:** 8cd9b04998cee42dd860d6d95985a8f68d9f2068  
**Main:** 45e4202b03a434459e4c021a04efa7e8396359db (protected; unchanged)

## 1. Source and runtime identity

- Historical v7 source: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Historical v19 source: `310c0e20e3447c488c1e1c102c38bea5040708ca`.
- v19 installer source file: `lib/services/g1_drift_schema.dart`, blob `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`; it declares `G1DriftSchema.version == 19`.
- The historical v19 schema imports `occurrence_sql_codec.dart` and `recurrence_sql_codec.dart`; the runner checked out the exact historical source commit rather than copying or rewriting the installer.
- Runtime bootstrap: Flutter 3.47.0 / Dart 3.13.0; SQLite 3.46.1 in the accepted read-only run.

## 2. Immutable fixture verification

- Fixture source commit: `f211326e7615f1c907494232dd3aec8d4732c83c`.
- Archive: `test/fixtures/database/historical/main_v7_fixture.sqlite.gz`.
- Expected and observed uncompressed SHA-256: `68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0`.
- Extracted size: 106,496 bytes.
- The workflow extracts a temporary runner copy; the tracked archive is not opened as the writable database.

## 3. Existing Actions evidence

- Run `44296337667` is not migration evidence. Its test explicitly opened the fixture with a v7 read-only inspection user and did not invoke a migration. Its uploaded snapshot was separately rejected because it was only two bytes.
- Corrected snapshot run `44302817468`, final attempt 3, completed successfully on workflow SHA `c92bf0d5510f02350bb90f2303a627fae7a69f45`.
- Jobs: v19 and v20 both SUCCESS.
- Four normalized snapshot artifacts were reported with identical SHA-256 `724811bbccae6bc40dbda5b2bdc6ab622b692614175e43dc46b615237069aae4`.
- The actual job logs explicitly show `test('opens physical Main v7 fixture without invoking a migration', ...)` and `TEST_MODE=READ_ONLY_FIXTURE_OPEN; NO_MIGRATION_INVOKED`.
- The read-only snapshot reported fixture schema version 7, `PRAGMA user_version=7`, `integrity_check=ok`, and zero FK violations.

## 4. Execution result

**The original v19 installer has NOT been invoked against the fixture.** No migrated copy, post-migration snapshot, record-by-record comparison, retry, or failure-recovery execution exists in the inspected Actions evidence.

This is a hard stop, not a successful migration and not evidence that v7 is incompatible with v19. No conclusion about direct v7 support can be made until the original installer is actually invoked on a disposable copy.

## 5. Safety

No Main change, merge, release, deployment, production database operation, fixture mutation, manual `user_version` change, synthetic table, SQL/Python replacement, or historical installer modification was performed.
