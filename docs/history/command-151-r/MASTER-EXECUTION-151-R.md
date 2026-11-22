# ARVIN — MASTER EXECUTION 151-R
## FINALIZE 150-R + CENTER ENTITY COMPLETION — LIVE EXECUTION REPORT

**Date:** 2026-11-22 (Iran local date: 1405/09/01)
**Repository:** `mobinpda-lab/Arvin-clean`
**Official PR:** #3495 — OPEN / DRAFT / UNMERGED
**Canonical branch:** `recovery-02/main-based-integration`
**Product authority:** REV10
**Starting Candidate:** `3c72a341fc1aac785a22b6fe151c23507c16793c`
**Main baseline:** `45e4202b03a434459e4c021a04efa7e8396359db`

## 1. Governance and refs
- Live PR #3495 head matched the declared Starting Candidate exactly.
- Main base SHA remained `45e4202b03a434459e4c021a04efa7e8396359db`; no Main write was performed.
- Canonical branch exists; no alternate branch was created.
- Release NO-GO; merge and deployment remain unauthorized.

## 2. Requested CI run ledger
| Workflow | Run | Result | Candidate |
|---|---:|---|---|
| Build | 44933088338 | SUCCESS (9/9 jobs) | exact SHA |
| Governance | 44933088356 | SUCCESS | exact SHA |
| Follow-up Persistence | 44933088362 | SUCCESS | exact SHA |
| Device Smoke | 44933088406 | FAILURE (6/7 scenarios) | exact SHA |
| COMMAND 20-E | 44933088374 | FAILURE / NO-GO | exact SHA |

Build jobs and Device Smoke / COMMAND 20-E logs verify checkout of the exact Candidate. COMMAND 20-E artifact includes `commit_sha.txt` and `sha-verification.txt` matching the Candidate.

## 3. Device Smoke
PASS: Home, Quick Capture, SQL Persistence, SQL Migration, Backup/Restore, People. FAIL: Calendar. The failing assertion is `integration_test/calendar_card_interaction_test.dart:169`. Projection diagnostics show the Task and independent Reminder records are present and projected, but the expected keyed card is absent from the rendered Calendar list. The expected screenshot was not produced. Root cause remains narrowed to Calendar UI/test interaction after projection and is not conclusively isolated.

## 4. COMMAND 20-E
Final artifact `14719705601` inspected. Analyze, six test shards, Debug/Release APK, ProjectStore file persistence, Calendar Link process restart, cleanup and Follow-up persistence passed. Calendar Link process restart compared 8 links × 4 fields = 32 values across process PIDs 2334 and 2406. Cleanup passed without clearing app data. Aggregate NO-GO is attributable to Device Smoke Calendar. Phase artifact: `14718404033`.

## 5. Entity / relationship acceptance
| Area | Evidence | Status |
|---|---|---|
| Center model | `lib/models/center.dart` | IMPLEMENTED |
| Center SQLite/store | v9 `centers`, `center_projects`; CenterStore CRUD/search/archive/restore | IMPLEMENTED (storage layer) |
| Center file persistence | `test/center_store_file_persistence_test.dart`; exact-SHA Build passed | IMPLEMENTED (storage layer) |
| Center management UI | Dedicated screen not evidenced | NOT IMPLEMENTED |
| Center↔Project | M2M schema, additive link, unlink, bidirectional lookup, file-backed tests | IMPLEMENTED (store); product NOT ACCEPTED |
| Center↔Task Editor / Quick Capture / Details | Integrated selection path not evidenced | NOT IMPLEMENTED |
| Center Backup/Restore | Catalog and M2M portability unproven | NOT ACCEPTED |
| Home Center filter | Fifth dimension not integrated/verified | NOT ACCEPTED |
| Project↔Category | Join schema exists; canonical relationship store/UI acceptance absent | PARTIAL / NOT ACCEPTED |
| Reminder four operations | Full four-operation lifecycle not evidenced | PARTIAL / NOT ACCEPTED |
| Full Backup/Restore | Selected smoke passed; complete independent A→B / rollback matrix unproven | NOT ACCEPTED |

## 6. Artifact IDs
Debug APK `14718821042`; Release APK `14718204892`; Smoke People `14718882016`; Smoke Home `14718517988`; Smoke Quick Capture `14718209271`; Persian Time Picker `14718612582`; COMMAND 20-E Phase `14718404033`; COMMAND 20-E Final `14719705601`.

## 7. Changed files / commits
This audit did not change application source or tests. Four existing official records were updated with the 151-R exact-SHA audit addendum. A dedicated report is added at this path. Commit SHAs are listed in the PR execution record and branch history. No safe minimal Calendar fix was committed because its root cause is not isolated.

## 8. Final decision
**150-R: NOT FINALIZED.** **Calendar Device Smoke: NOT ACCEPTED.** **COMMAND 20-E: NOT ACCEPTED (aggregate NO-GO due Calendar).** **Center: PARTIAL.** **Center↔Project: storage IMPLEMENTED; product acceptance pending.** **Project↔Category: PARTIAL / NOT ACCEPTED.** **Home five-filter contract: NOT ACCEPTED.** **Reminder: PARTIAL / NOT ACCEPTED.** **Full Backup/Restore: NOT ACCEPTED.** **REV10: NO-GO. Release / merge / deployment: NOT AUTHORIZED.**
