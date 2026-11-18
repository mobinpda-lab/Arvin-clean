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

## Final Acceptance Addendum — 18 Nov 2026

Status: COMPLETE — TWO INDEPENDENT SUCCESSFUL SNAPSHOT EXECUTIONS PER HISTORICAL LANE.

Corrected workflow commit: c92bf0d5510f02350bb90f2303a627fae7a69f45
Workflow run: 44302817468 (completed / success; final run_attempt 3)
Run URL: https://github.com/mobinpda-lab/Arvin-clean/actions/runs/44302817468
Workflow head SHA: c92bf0d5510f02350bb90f2303a627fae7a69f45

The earlier run 44296337667 on SHA 734987645f07850e86471f8a14dd8c14c3838825 was not accepted: both uploaded snapshot files were only two bytes ({ followed by newline). The cause was line-based shell extraction of a pretty-printed multi-line JSON payload. The workflow was corrected to emit compact JSON, validate it with jq, generate a normalized content-only snapshot, separate environment/validation metadata, record row counts, and calculate SHA-256.

On the corrected SHA, both matrix lanes completed successfully. Each lane was independently rerun through GitHub's job-rerun operation on the same workflow SHA. Four uploaded artifacts were inspected:
- v19 first execution: artifact 14426128125
- v19 independent rerun: artifact 14426369969
- v20 first execution: artifact 14425764008
- v20 independent rerun: artifact 14426603657

All four normalized snapshots are valid JSON and have the identical SHA-256:
724811bbccae6bc40dbda5b2bdc6ab622b692614175e43dc46b615237069aae4

Snapshot acceptance evidence:
- Exactly 12 expected tables are present.
- Table row counts: arvin_storage_meta=1, checklist_items=2, follow_up_people=1, follow_ups=1, people=1, project_items=2, projects=1, tags=1, task_people=1, task_tags=1, tasks=2, taxonomy_categories=1 (15 rows total).
- The normalized snapshot retains 11 NULL values.
- Both task identifiers were explicitly checked: task-active-001 and task-done-002.
- Fixture SHA-256 in every lane: 68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0; extracted size 106,496 bytes.
- SQLite integrity_check=ok; foreign_key_check violations=0.
- Fixture schema version and PRAGMA user_version are 7.
- Environment-specific historical installer version and SQLite runtime version are retained in snapshot-environment-validation.json and excluded from the normalized content hash.
- Flutter 3.47.0 / Dart 3.13.0; dependency resolution passed with --enforce-lockfile; pubspec.lock unchanged (SHA-256 146c122f71109fae332a2dcfcffc63f8b48e51eebcd183758b0808443f4bcabc).

First/rerun comparisons:
- v19: artifact 14426128125 equals artifact 14426369969.
- v20: artifact 14425764008 equals artifact 14426603657.
- Cross-lane normalized content: v19 and v20 hashes also match after removing environment-specific installer/runtime and validation metadata.

The workflow-run record is one run ID with independent job reruns (final run_attempt 3), rather than two newly dispatched run IDs. The connected GitHub Actions interface exposed job reruns but not a full rerun-all/dispatch operation. The independent job executions regenerated the snapshots on the same workflow SHA and produced identical content hashes.

No v19 or v20 migration was invoked. The test opened the fixture with the dedicated schema-v7 read-only inspection user. No schema change, Main change, PR merge, release or deployment occurred.

Main remains 45e4202b03a434459e4c021a04efa7e8396359db. PR #3495 remains OPEN / DRAFT / UNMERGED.
