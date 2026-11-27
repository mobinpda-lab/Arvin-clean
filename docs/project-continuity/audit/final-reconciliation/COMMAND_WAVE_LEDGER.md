# COMMAND / WAVE LEDGER — INITIAL RECONCILIATION
Snapshot: 2026-11-27  
Rule: A report, PR description or authored test does not establish completion. Status requires source and exact-SHA evidence.

## Commands with direct evidence reviewed
| Command | Status | Evidence / disposition |
|---|---|---|
| COMMAND 03 | PARTIALLY_COMPLETED | PR #3495 body records source/schema audit and selected ProjectStore work; full migration/repository integration remains blocked. |
| COMMAND 16 | HISTORICAL | Earlier Build, persistence and Device Smoke successes on c4432... are historical and do not verify current head. |
| COMMAND 17 | BLOCKED | Isolated SQLite prototype was reported; application-level v7→v9 and backup acceptance not established. |
| COMMAND 20-E | BLOCKED | Run 45883634996 failed its complete-evidence gate; storage persistence sub-job passed. Newer run 45914037201 was IN_PROGRESS at last poll. |
| COMMAND 35 | UNRESOLVED | Source reports exist; complete command-to-PR/commit/test mapping not yet audited. |
| COMMAND 37–50 | UNRESOLVED | Full command documents and source diffs not yet reconciled. |
| COMMAND 60-R | PARTIALLY_COMPLETED | PRs #3547–#3549 contain quality, UI token and data-safety slices; not yet proven transferred/accepted on canonical SHA. |
| COMMAND 63-R | PARTIALLY_COMPLETED | PRs #3564–#3569 contain tracker, design and Home work on the old #3052 chain; conflicts and transfer state remain under review. |
| COMMAND 68-R | UNRESOLVED | Full source/PR/commit mapping pending. |
| COMMAND 76-R | UNRESOLVED | Full source/PR/commit mapping pending. |
| COMMAND 82-R–83-R | UNRESOLVED | Stacked explicit-null work is present in later PR chain; exact source command mapping pending. |
| COMMAND 84-R | PARTIALLY_COMPLETED | PR #3613 and #3616 address explicit NULL serialization/parity; exact canonical transfer and acceptance pending. |
| COMMAND 86-R | PARTIALLY_COMPLETED | PR #3620 adds independent SQLite A→B test; PR #3634 adds a distinct second backup file. Acceptance not established. |
| COMMAND 88-R | PARTIALLY_COMPLETED | PR #3622 four-filter proposal conflicts with latest five-filter owner decision; PR #3625 unknown-field preservation is potentially valuable. |
| COMMAND 90-R | PARTIALLY_COMPLETED | PR #3633 exposes canonical Task JSON field contract; PR #3634 second-backup coverage; not accepted on canonical SHA. |
| COMMAND 91-R | PARTIALLY_COMPLETED | PR #3639 fixes loss of unknown nested Follow-up/Reminder fields; exact canonical transfer and tests pending. |
| COMMAND 97-R | BLOCKED | Issue #3646 four-action reminder window remains NOT ACCEPTED. |
| COMMAND 103-R | PARTIALLY_COMPLETED | Owner-approved governance addendum and Primary Blue source exist; exact-head governance passed on d3a82, but newer candidate checks must be rerun. |
| COMMAND 150–157 | UNRESOLVED | Complete source and evidence mapping pending. |
| COMMAND 202-R | UNRESOLVED | Complete source and evidence mapping pending. |

## Wave status
- Waves 1–5: HISTORICAL DEVELOPMENT GENERATIONS; individual sub-wave transfer and acceptance mapping remains UNRESOLVED.
- Wave 6: HISTORICAL / PARTIALLY RECOVERED; selected persistence, calendar and checklist work is represented in PR #3495.
- Wave 7, including 7.36, 7.45, 7.61 and 7.68: HISTORICAL; exact sub-wave inventory, unique commit attribution and completion evidence remain UNRESOLVED.
- No Wave is a separate active development route. New parallel Wave/feature branches are not authorized.

## Next audit
Extract every command/wave file from canonical and historical docs, then link each row to exact PR, branch, commit SHA, changed files, test runs, remaining gaps and final status. Never infer COMPLETED from a title or narrative.