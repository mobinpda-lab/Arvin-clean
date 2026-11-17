# COMMAND 32 — Test Acceptance Report
Code SHA: `687341469152035053f6325b671c4bad9dab8c96`

## Exact-SHA CI
| Workflow / job | Run | Result at last observation |
|---|---:|---|
| Flutter Analyze | 44192597572 | SUCCESS |
| Debug APK | 44192597572 | SUCCESS |
| Release APK | 44192597572 | SUCCESS |
| Unit/Widget shard 0 | 44192597572 | SUCCESS |
| Unit/Widget shard 1 | 44192597572 | SUCCESS |
| Unit/Widget shard 2 | 44192597572 | FAILURE — 259 passed, 1 failed |
| Unit/Widget shard 3 | 44192597572 | SUCCESS |
| Unit/Widget shard 4 | 44192597572 | SUCCESS |
| Unit/Widget shard 5 | 44192597572 | SUCCESS |
| Follow-up File Persistence | 44192597315 | SUCCESS |
| Device Smoke | 44192597544 | Home + Quick Capture SUCCESS; SQL Migration + SQL Persistence IN PROGRESS; Backup/Restore, Calendar, People QUEUED |
| COMMAND 20-E / H01 | 44192597243 | Analyze + ProjectStore file-backed test SUCCESS; real SharedPreferences restart / Stage B IN PROGRESS |

## New tests verified PASS
- `task_editor_full_entry_test.dart`: All-Day off restores previously selected due time.
- `task_contract_test.dart`: unknown Follow-up metadata survives JSON serialization.
- `task_store_followup_test.dart`: unknown Follow-up metadata survives file-backed SQL close/reopen.
- `canonical_backup_manager_test.dart`: restore retains historical Follow-up Person IDs absent from active directory.

## Single failing regression
`test/release_closure_product_gate_test.dart` fails because `.github/workflows/release-closure.yml` does not contain the expected `await hideUnapprovedPrereleases();` call, `HIDDEN_UNAPPROVED_PRERELEASE=` evidence, and Draft-only publication contract. The workflow currently creates a non-draft prerelease. The test was not weakened and the release workflow was not executed or changed in this checkpoint. This remains a release-security blocker.

## W01
Zero-Dollar expressions and KVM chmod corrected, but workflow run 44192076499 on the prior documentation SHA ended FAILURE with no executable jobs. The workflow file is absent from Main and its PR-label trigger has not been proven operational. W01 is NOT ACCEPTED.

## Remaining
- Complete all in-progress Device Smoke and H01 Stage B jobs.
- Fix release-closure gate implementation without weakening tests, then rerun all shards.
- Execute authorized W01 diagnostic on a supported trigger.
- Run actual v7→v8 migration fixture and Backup/Restore round trip.
- Complete full RTL/PDF/visual regression.

No PASS inferred from queued or in-progress jobs.
