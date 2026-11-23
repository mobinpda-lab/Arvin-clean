# COMMAND 45-R — Runtime Results

Status: BLOCKED — RUNTIME NOT VERIFIED

Repository: mobinpda-lab/Arvin-clean
Canonical branch: recovery-02/main-based-integration
Reference SHA supplied: acc2f46dd070e7ba7e19f7bac1c0749d359414be
Latest branch head at this report: b7cbaba6f07fb2de8e5b3085740498449e78719e
PR #3495: OPEN / DRAFT / UNMERGED
Main: 45e4202b03a434459e4c021a04efa7e8396359db (unchanged)

## Executed runs

- Run 44287318505, event push, SHA 2c07983f262f1114f5e158d1a2d0b3d2253949d8: FAILURE. Both v19 and v20 reached dependency resolution and fixture verification; test compilation failed because the generated smoke test treated a Map as if it had a .data getter.
- Run 44287623079, event push, SHA 3532cc1c1c1d204697f33ceb5fd856162ea6d35c: FAILURE. The compile defect was corrected. Both matrix jobs opened the NativeDatabase connection and completed the first table-list query, then the Dart process terminated with SIGBUS / BUS_ADRERR (exit 134) before a snapshot was produced.
- Run 44287872905, event push, SHA c7885d77b0ab326d59c5e5a4130cb33af66d6b30: diagnostic execution; job logs showed constructor, ensureOpen and first query completion before the native crash in the v19 lane. The run was still in progress when this report was authored.
- Run 44288042082, event push, SHA b7cbaba6f07fb2de8e5b3085740498449e78719e: diagnostic stage markers added; execution was in progress when this report was authored.

## Proven in completed job logs

- Flutter 3.47.0 stable; framework revision 4cf24164269a5ebf0c16a028a00727d0e77bbb05.
- Dart SDK 3.13.0 stable.
- Flutter Doctor ran. Flutter/Chrome checks passed; Android licenses were not accepted and Linux desktop GTK3 development libraries were absent. These warnings do not establish a migration failure.
- Dependency resolution passed with --enforce-lockfile.
- pubspec.lock SHA-256: 146c122f71109fae332a2dcfcffc63f8b48e51eebcd183758b0808443f4bcabc; no lockfile diff.
- Extracted fixture SHA-256 matched: 68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0; size 106,496 bytes.

## Not accepted

- NativeDatabase full read-only inspection and integrity checks: NOT ACCEPTED.
- Snapshot generation: NOT ACHIEVED.
- Two successful independent runs on one identical SHA: NOT ACHIEVED.
- Content snapshot parity: NOT TESTED.
- COMMAND 45-R acceptance: NO-GO.

No v19 or v20 migration was invoked. The workflow uses a temporary extracted copy of the fixture. No Main change, merge, release or deployment was performed.

## Addendum — additional diagnostic run (18 Nov 2026)

Run 44295851388 executed on SHA 80ffa54ae9f2d5b2556eccb6dbfe697b6006fa88 and failed in both matrix lanes. Detailed logs now prove that all 12 expected tables were read, the task IDs and SQLite metadata were queried, `integrity_check` and `foreign_key_check` completed, and the normalized snapshot JSON was encoded (3,886 characters). The process then crashed with SIGBUS during asynchronous `File.writeAsString`, before the write-complete marker and artifact snapshot could be confirmed. This narrows the current failure to the asynchronous snapshot output / Dart runner interaction, not fixture opening or table reads.

A follow-up change switched the snapshot write to synchronous `writeAsStringSync` on SHA 5646cfc06977e3d0b4999874b33aa8c0892c9296. Run 44296037837 was started on that SHA and was still in progress at report refresh. Its outcome is not yet accepted. No snapshot success is claimed until the new logs and uploaded files confirm it.

The two required independent successful runs on the exact same SHA remain outstanding.

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
