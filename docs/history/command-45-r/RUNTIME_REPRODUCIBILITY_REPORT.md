# Runtime Reproducibility Report — COMMAND 45-R

Status: NOT REPRODUCIBLE / NOT ACCEPTED.

## Completed evidence

Run 44287318505 on SHA 2c07983f262f1114f5e158d1a2d0b3d2253949d8 failed at test compilation because the snapshot test used an invalid Map.data access.

Run 44287623079 on SHA 3532cc1c1c1d204697f33ceb5fd856162ea6d35c used the corrected Map conversion. Both v19 and v20 lanes resolved dependencies, preserved the lockfile, verified the same fixture SHA, and then terminated with SIGBUS during the physical SQLite smoke test.

These are distinct workflow SHAs, not two successful runs on one identical SHA. The available GitHub action interface in this execution supports reading runs, jobs, logs and artifacts, and retrying failed jobs; it does not expose workflow_dispatch or a full rerun-all operation. Therefore the required two independent full executions on the exact same SHA were not established.

## Comparability

- Flutter version in completed runs: 3.47.0 — same.
- Dart version: 3.13.0 — same.
- Lockfile SHA-256: 146c122f71109fae332a2dcfcffc63f8b48e51eebcd183758b0808443f4bcabc — same.
- Fixture SHA-256: 68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0 — same.
- Snapshot content: unavailable because the SQLite test aborted before generation.
- Time and runner metadata normalization: not applicable until snapshots exist.

## Artifacts

Run 44287318505:
- v20 artifact ID 14420635129
- v19 artifact ID 14419009490

Run 44287623079:
- v20 artifact ID 14420406514
- v19 artifact ID 14419238255

The artifacts are real GitHub Actions uploads, but they contain diagnostic logs and runtime evidence, not successful database snapshots.

## Final disposition

No content-equivalence claim can be made. Reproducibility acceptance requires a stable NativeDatabase smoke test, a complete snapshot, and two successful independent executions on the same SHA. Migration v19/v20, schema changes, Main changes, merge, release and deployment remain prohibited.

## Addendum — latest diagnostic evidence

Run 44295851388 (SHA 80ffa54ae9f2d5b2556eccb6dbfe697b6006fa88) produced matching toolchain, dependency and fixture evidence in v19/v20. Both lanes read all tables and completed integrity checks; both encoded a normalized 3,886-character snapshot JSON, then terminated with SIGBUS before asynchronous file write completion. This is not a successful snapshot and cannot be used for parity comparison.

A follow-up commit 5646cfc06977e3d0b4999874b33aa8c0892c9296 changes the snapshot output to synchronous file writing. Run 44296037837 on that SHA was still in progress at the time of this update. No reproducibility pass is claimed. Acceptance still requires two successful independent runs on one identical SHA with matching normalized snapshot content.

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
