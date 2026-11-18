# SQLITE TEST RESULTS — COMMAND 41-R
**Status:** MIXED HISTORICAL EVIDENCE / NO MAIN v7 ACCEPTANCE  
**Current canonical SHA:** `f5c64285687cd2665cc383e10277cb6e0266f4c2`

## Current canonical exact-SHA workflows
| Workflow | Run ID | Result | Detail |
|---|---:|---|---|
| Build | 44273882049 | FAIL | Analyze, Debug APK, Release APK passed; test shards 1 and 2 failed |
| COMMAND 20-E | 44273881957 | FAIL | Storage persistence passed; evidence collector returned NO-GO and final `overall == PASS` gate failed |
| Follow-up File Persistence | 44273881944 | PASS | Exact SHA run completed successfully |
| Device Smoke | 44273881994 | PASS | Exact SHA run completed successfully |

### Build failures
- `test/services/g1_drift_schema_test.dart`: “v8 to v9 hierarchy migration preserves legacy rows and classifies ambiguous links” failed because the test tried to use QueryExecutor before calling `ensureOpen()` (stack points to test line 76).
- `test/person_directory_page_test.dart`: expected the removal confirmation text “حذف فقط این شخص را از دفترچه اشخاص خارج...” but found zero matching widgets.
- Shard 2: 262 passed, 1 failed.
- Shard 1: 168 passed, 1 failed.

### COMMAND 20-E failure
- Storage-persistence job succeeded.
- Evidence collection completed as `NO-GO`.
- Final gate required `regression_summary.json` overall to equal PASS; it evaluated false.
- Artifact was uploaded: https://github.com/mobinpda-lab/Arvin-clean/actions/runs/44273881957/artifacts/14414403853

## Historical v20 PR SHA — not current canonical
Tested SHA: `812082964c649be7660c41213209ec34aea7167b`.
- Run 43629840018: canonical v20 lifecycle, historical parity and M2M integrity — PASS.
- Run 43629839832: SQLite A-D snapshots with five real reopen cycles — PASS.
- The lifecycle test source includes failure injection stages and physical SQLite backup/restore.
- These runs validate only the v19→v20 historical branch test fixture and its selected assertions. They do not establish Main v7→v20 compatibility and do not transfer to current canonical #3495 because Git histories diverge.

## COMMAND 41-R fixture execution
No new Main v7 historical fixture was run in this command. No SQL test output has been fabricated. The repository currently has no `test/fixtures/database/historical/` fixture files and no pre-existing `docs/history/sqlite-test-results/` directory at the reference SHA.

**Result: BLOCKED.** Historical Main v7 physical SQLite migration, record/ID parity, rollback and interruption remain unproven.
