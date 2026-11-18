# V19 Retry Results — COMMAND 49-R

**Verdict: BLOCKED — retry phase not reached.**

| Check | Result |
|---|---|
| Immutable V7 fixture SHA verification | PASS |
| Historical V19 source/blob verification | PASS |
| V7 pre-migration snapshot and SQLite integrity assertions | Reached and passed before installer call |
| First V7→V19 installation with non-empty Occurrence | FAIL |
| Snapshot after first successful installation | NOT REACHED |
| Second installation on same database | NOT REACHED |
| Duplicate-row / ID / relation comparison | NOT REACHED |
| Schema version and SQL value comparison after retry | NOT REACHED |
| TaskStore readback after retry | NOT REACHED |

Failure: `Occurrence migration parity mismatch for Task command49-occurrence-task`.

Evidence:
- Run: `44313646995`
- Job: `134833931852`
- Artifact: `14430913354`
- Earlier diagnostic runs: `44312630186` (artifact `14431736141`), `44313242199` (artifact `14431437351`).

No PASS is claimed for safe retry.
