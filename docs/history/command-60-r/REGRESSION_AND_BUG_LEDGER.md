# REGRESSION AND BUG LEDGER — INITIAL

| ID / source | Defect | Priority | Status | Next action |
|---|---|---|---|---|
| #1901 Home | Visual mismatch, clipped cards, missing REV10 filters | P0 | OPEN | Screenshot audit and five-filter contract |
| #1901 Calendar | Missing edit/export/default-calendar settings | P0 | OPEN | Calendar integration/settings trace |
| #1901 Typography | Font picker and size control absent | P1 | OPEN | Reconcile canonical font decision first |
| #1901 Taxonomy | Category/Tag management and refresh issues | P1 | OPEN | Canonical catalog/store audit |
| #1901 Notebook | Taxonomy mismatch and Tag flow broken | P1 | OPEN | Canonical Task/Notebook taxonomy |
| #1901 Quick Add | Date/Time selectors lead to blank screen | P0 | OPEN | Reproduce and add regression tests |
| #1901 Task editor | Date/time layout and clock-dial regression | P1 | OPEN | Preserve approved picker layout and dial |
| #1901 Checklist | Enable/disable issue | P1 | OPEN | Canonical checklist behavior test |
| Build test-1 | Drift executor not opened before SQL op | P0 | OPEN | Fix test lifecycle without weakening assertions |
| Build test-2 | Person Directory delete dialog text missing | P1 | OPEN | Verify actual dialog behavior and expected copy |
| COMMAND 49 | Occurrence parity mismatch | P0 | OPEN | Instrument exact field diff |
| COMMAND 50 | Reopen idempotency, NULL, unknown-state failures | P0 | OPEN | Historical V19 isolated diagnosis |
| COMMAND 20-E | Final acceptance JSON not PASS | P0 | OPEN | Inspect regression summary and Calendar link checks |

Do not close any item on code inspection alone; require exact-SHA test and, where applicable, physical-device evidence.


## Person Directory rehydration — 2026-11-19
- Reproduced on PR #3547 head `1c83db84145675aa31e67feef95c23ddd84c181c`, Build run `44417802140`, test-2.
- Failure: after deleting a referenced Person from the directory, `loadPeopleDirectory()` returns the Person again.
- Root cause: `G1DriftSchema.migrateTaskPeople` rehydrates all historical `task_people` rows on every install and has no owner-removal exclusion.
- Lane A PR #3549 implements a marker-versioned exclusion tombstone and fresh-file-reopen regression test. Pending exact-head CI; not closed.
