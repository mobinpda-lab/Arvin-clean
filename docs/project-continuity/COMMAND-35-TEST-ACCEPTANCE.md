# COMMAND 35 — Test Acceptance
## Canonical audit baseline
SHA: `ed4f1e0c0e01f186155b194b34212b7f2ffb584b`

| Workflow | Run ID | Observed state | Acceptance |
|---|---:|---|---|
| Build | 44245512152 | IN_PROGRESS | PENDING |
| Device Smoke | 44245512393 | QUEUED | PENDING |
| COMMAND 20-E | 44245511968 | IN_PROGRESS | PENDING |
| Follow-up File Persistence | 44245511991 | SUCCESS | PASS for this workflow/SHA only |

No aggregate PASS is claimed. Combined status endpoint returned no status entries; workflow-run data is the available evidence.

## Historical SHA evidence (not transferable to Canonical)
| PR | SHA | Relevant result |
|---|---|---|
| #3052 | `aba68e44be0fcac7d4ad425b58fbe75e5aba264e` | Build FAILURE; Device Smoke CANCELLED; Follow-up Persistence SUCCESS; Calendar Provider Acceptance SUCCESS |
| #3384 | `310c0e20e3447c488c1e1c102c38bea5040708ca` | Build FAILURE; Device Smoke CANCELLED; Follow-up Persistence SUCCESS; SQLite Snapshot SUCCESS; Hierarchy Candidate SUCCESS |
| #3463 | `812082964c649be7660c41213209ec34aea7167b` | M2M Lifecycle/Acceptance SUCCESS; SQLite Snapshot SUCCESS; Follow-up Persistence SUCCESS; Build FAILURE; Device Smoke CANCELLED |
| #3470 | `d7c9322afb9cb32e607f53e139f8bd82a984c805` | Build FAILURE; Device Smoke CANCELLED; Follow-up Persistence SUCCESS |
| #3376 | `d7191903af2ea2518f1fedc697d0f8090f780b3a` | Diagnostic Harness FAILURE; Build FAILURE; Device Smoke CANCELLED |
| #3380 | `33a8fb14a9979d0d86775cb5457970c7e445077b` | Diagnostic Harness FAILURE; Build FAILURE; Device Smoke CANCELLED |
| #3382 | `adee525e94fa2daec617255d57f9cfb65e3efe66` | Raw SQL Evidence SUCCESS; Build FAILURE; Device Smoke CANCELLED; Calendar Provider Acceptance SUCCESS |
| #1901 | `ba8e26c2388c4b74bc0ecc40cf50b0fd0b02960a` | No workflow runs returned |

## Required canonical validation still outstanding
- Flutter Analyze
- Full Unit Tests
- Widget Tests
- Integration Tests
- SQLite file-backed tests
- Sequential migration tests
- M2M tests
- Backup/Restore parity and independent reopen
- Regression tests
- Device Smoke and physical-device acceptance

A test not observed as completed successfully on the exact final canonical SHA is NOT PASS. Historical CI results above are not current-head acceptance.
