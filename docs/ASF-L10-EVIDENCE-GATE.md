# ASF L10 Evidence Gate

The factory must distinguish configuration from proven autonomy.

## Required chain

1. Queue task exists and is uniquely identified.
2. Event or scheduled watchdog wakes the task.
3. Correct worker is dispatched exactly once for the task/head.
4. Worker produces traceable branch/commit output when code changes are required.
5. Automated tests run on the candidate.
6. Security checks run on the candidate.
7. Build/package validation runs on the candidate.
8. PR is associated with the task and candidate head.
9. Exact-head/current-main promotion gates pass.
10. Merge is guarded and attributable to the candidate head.
11. Release evidence is produced when a release is required.
12. Monitoring observes the resulting state.
13. Failures create bounded recovery/self-fix work.
14. Recovery verifies state and resumes the queue.

## Evidence rules

- Evidence must identify the exact commit SHA.
- A skipped, stale, failed or mismatched gate is not PASS.
- A successful workflow on another SHA cannot validate the candidate.
- Manual claims do not replace machine evidence.
- Merge is never an evidence substitute for tests/security/build.

## L10 status vocabulary

- `CONFIGURED`: infrastructure exists.
- `OPERATIONAL`: infrastructure has executed successfully.
- `PROVEN`: complete end-to-end chain has been demonstrated with evidence.
- `BLOCKED`: a required gate or dependency prevents progression.

**L10 is PROVEN only after operational end-to-end evidence.**
