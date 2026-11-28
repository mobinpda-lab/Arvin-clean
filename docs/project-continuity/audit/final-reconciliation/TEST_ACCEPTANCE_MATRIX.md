# TEST / CI ACCEPTANCE MATRIX
Historical exact code SHA: d3a82ebe0e517a2ae4a3b58d32ea4c86cbc53d92  
Canonical PR head before this audit-doc commit: 6b125ddb608a1ae78672f9fa945106bce718d8a6

| Gate | Exact run / evidence | Result |
|---|---|---|
| Governance Validation | 45883635005 | SUCCESS on d3a82... |
| Follow-up File Persistence | 45883635045 | SUCCESS on d3a82... |
| Build / Analyze | 45883635007 | FAILURE overall |
| Debug APK job | 140128945408 | SUCCESS on d3a82... |
| Release APK job | 140128945679 | SUCCESS on d3a82... |
| Analyze job | 140128945694 | SUCCESS on d3a82... |
| Test shards 0–5 | 45883635007 | ALL SIX FAILED |
| Trace JSONL evidence | 140128945089 | FAILURE |
| Device Smoke | 45883635059 | FAILURE |
| COMMAND 20-E | 45883634996 | FAILURE; storage-persistence sub-job succeeded, complete-evidence check failed |
| APK staging/production provenance | User-uploaded APK | NOT VERIFIED |

## Observed failure signatures
- Home: Home did not report load completion after 1200 frames; repeated 10-minute Home test timeouts.
- Center: Center database operation did not complete after 1200 frames during center_store.schema_install.
- Async test framework: Reentrant call to runAsync() denied.
- Backup UX: plaintext/encrypted backup timeout; late restore assertion expected memory-only-secret but observed null.
- Calendar Device Smoke: expected exactly one widget with a key, found zero; expected screenshot artifact missing.
- Trace/backup regression: trace aggregate exit code 1; backup test timed out and unknown value assertion failed.
- RTL swipe test failed in test-5.
- These are observed failures, not yet root-cause fixes. Do not raise timeouts or alter assertions without source-backed diagnosis.

## Device Smoke lanes on d3a82...
Passed: Home, Backup/Restore, Quick Capture, People, SQL Migration, SQL Persistence.  
Failed: Calendar.  
Six of seven selected lanes passed; full smoke gate failed.

## Current-head evidence boundary
After inventory documentation commits, PR #3495 head was observed at 6b125ddb608a1ae78672f9fa945106bce718d8a6. Previous exact-SHA outcomes above do not transfer. Fetch fresh workflow runs for this SHA and all subsequent documentation/code commits. Queued or in-progress is not PASS.

## Required acceptance
Flutter Analyze, Debug and Release builds, all six test shards, SQLite migration/parity, independent Backup/Restore, Calendar, typography/RTL, PDF and seven Device Smoke scenarios must all pass on one exact candidate SHA. No test was deleted, skipped or weakened in this audit.

## Post-Home-change exact-head evidence — 2026-11-27
- Code change: 9aa6d06ff7db974809e2871087f88ddbb577b6a9; test correction: a05c74496f390038afb424e4cf7d53b4427ba648.
- Current PR head: e372cfe99aef6beb59299ec6912ff8c47691ab86 (documentation-only commit after code/test change).
- Governance Validation run 45915214855: SUCCESS on e372cfe... (governance gate only).
- Zero Dollar Environment Smoke run 45915214940: PENDING; not a product acceptance workflow.
- No Arvin Build run or test-shard result was returned for e372cfe... at last poll. Home widget test, Analyze, all six shards and Device Smoke remain VERIFICATION PENDING on the new code.
