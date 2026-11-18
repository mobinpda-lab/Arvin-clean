# Fixture Verification Results — COMMAND 45-R

Status: FIXTURE COPY HASH VERIFIED; DATABASE INSPECTION NOT ACCEPTED.

- Source commit: f211326e7615f1c907494232dd3aec8d4732c83c
- Source archive: test/fixtures/database/historical/main_v7_fixture.sqlite.gz
- Extracted runner copy: /tmp/arvin-main-v7-fixture.sqlite
- Expected SHA-256: 68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0
- Actual SHA-256 in completed v19/v20 jobs: 68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0
- Extracted size: 106,496 bytes
- Result: HASH MATCH — PASS.

The workflow retrieves the compressed archive from the immutable source commit and extracts it to a temporary runner path. The original tracked archive is not used as the SQLite working file.

The smoke test successfully constructed NativeDatabase, completed ensureOpen, and completed the initial sqlite_master table-list query in the diagnostic run. The process then terminated with SIGBUS before the full set of table, task-ID, integrity and foreign-key checks could finish.

Consequently:
- Fixture hash and copy extraction: PASS.
- Full physical database read validation: BLOCKED.
- SQLite integrity_check and foreign_key_check: NOT VERIFIED.
- Full snapshot: NOT GENERATED.
- Original fixture mutation: none reported; only a temporary extracted copy was targeted.

No schema migration or write operation was invoked.

## Addendum — full read evidence

In run 44295851388, both matrix lanes passed fixture SHA-256 verification and read all 12 expected tables from the independent extracted copy. Both task-ID checks, SQLite version and user_version reads, `integrity_check`, and `foreign_key_check` reached their completion markers. All table rows were collected and normalized, and JSON encoding completed. The process crashed during the asynchronous snapshot file write. This confirms broader read access than the earlier report, but it does not yet establish a durable snapshot artifact. The original tracked fixture remains untouched; no migration or schema write was invoked.