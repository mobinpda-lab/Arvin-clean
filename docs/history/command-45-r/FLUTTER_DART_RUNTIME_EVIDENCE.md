# Flutter / Dart Runtime Evidence — COMMAND 45-R

Source: GitHub Actions run 44287318505 and run 44287623079, both with v19 and v20 matrix lanes.
Status: TOOLCHAIN AND DEPENDENCY BOOTSTRAP PASS; SQLITE SMOKE TEST BLOCKED.

## Exact toolchain

- Flutter: 3.47.0, stable
- Flutter framework revision: 4cf24164269a5ebf0c16a028a00727d0e77bbb05
- Flutter engine revision: 5f77625673248ee5846fbcaf5d3e1a3878386fd7
- Dart SDK: 3.13.0 stable
- DevTools: 2.60.0
- Runner OS: Ubuntu 26.04.1 LTS, linux_x64
- SQLite native build prerequisite: libsqlite3-dev 3.46.1-9ubuntu0.3 already installed

## Flutter Doctor

Flutter 3.47.0 and Chrome checks passed. Connected device discovery and network resources passed. Doctor reported two non-blocking environment categories:
- Android toolchain: Android SDK 37.0.0 present, but some Android licenses were not accepted.
- Linux desktop toolchain: GTK 3.0 development libraries missing; eglinfo unavailable.

Doctor therefore reported issues for Android licensing and Linux desktop development. The historical smoke test is a Linux-hosted SQLite test and does not require an Android emulator or Linux desktop build.

## Dependencies and lockfile

- flutter pub get --enforce-lockfile: PASS
- pubspec.lock remained unchanged: PASS
- pubspec.lock SHA-256: 146c122f71109fae332a2dcfcffc63f8b48e51eebcd183758b0808443f4bcabc
- Drift: 2.35.0
- sqlite3: 3.6.0

## Runtime acceptance

Flutter and Dart toolchain identity and dependency installation are proven for the completed runs. NativeDatabase physical fixture inspection is not accepted because the Dart test process terminated with SIGBUS after opening the connection and completing its first query. No migration was run.

## Addendum — runtime crash localization

Run 44295851388 reconfirmed Flutter 3.47.0 and Dart 3.13.0 in both v19 and v20 lanes, with dependency resolution and fixture hash verification passing. The diagnostic markers confirm all expected table queries completed and the JSON snapshot encoded successfully. The SIGBUS occurred after `SNAPSHOT_JSON_ENCODE_DONE` and before `SNAPSHOT_WRITE_DONE`, during asynchronous snapshot file output. The next candidate SHA 5646cfc06977e3d0b4999874b33aa8c0892c9296 changes that operation to synchronous file output; run 44296037837 was in progress when this addendum was written.

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
