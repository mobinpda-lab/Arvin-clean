# HISTORICAL RECOVERY REGISTER
Canonical destination: PR #3495 / recovery-02/main-based-integration  
Disposition: selective recovery only; no blind merge/cherry-pick.

| Source | Observed contribution | Disposition |
|---|---|---|
| #1901 | Task checklist regression test recovered into canonical history; four-mode Home proposal conflicts with REV10 five-filter contract. | Checklist: RECOVERED, exact current acceptance pending. Four-mode Home: SUPERSEDED. |
| #3341 / #3348 / #3365 | File-backed ProjectStore/TaskStore and TaskReminder persistence coverage; Calendar interaction/navigation tests; stable navigation keys; exact-head Device Smoke checkout. | PR #3495 body records these as represented. Exact-SHA acceptance still required. |
| #3384 | Task/SQLite legacy explicit NULL and unknown metadata handling; large non-Main-based dependency chain. | Do not merge directly. Review selective compatibility fixes against v7→v9 contract. |
| #3463 | v19/v20 M2M schema candidate, migration and tests; based on #3384. | Historical source only; v19/v20 not target under current owner command. Reuse individual tests/design only if compatible with v7→v9. |
| #3470 | Broad Vazirmatn typography proposal with failing test evidence. | No wholesale port. Audit exact font-weight and PDF improvements selectively. |
| #3547 | Exact-SHA test corrections. | Candidate useful test/fixture corrections; base and exact-head results require review. |
| #3548 | Shared UI tokens and navigation styling. | Candidate reusable design-token work; reconcile all values with #4169A1 and owner UI contracts. |
| #3549 | Schema 9 Occurrence/unknown-field preservation tests. | Candidate data-safety evidence; not proof of complete migration acceptance. |
| #3564 | Cumulative product execution tracker on #3052 chain. | Historical documentation; do not use as current authority. |
| #3567 | Teal palette #078B91. | Conflicts with owner-locked Primary Blue #4169A1; do not port as Primary. |
| #3569 | Home five-filter contract, but historical order places Center last. | Product intent aligns on five dimensions; adapt to owner order Time, Center, Project, Category, Tag. |
| #3613 / #3616 | Explicit NULL Task serialization and migration parity. | Potentially valuable; preserve null-vs-absent semantics, transfer selectively after tests. |
| #3620 / #3634 | Independent SQLite A→B restore, rollback and second distinct backup file. | P0 acceptance test source; must run against canonical code. |
| #3622 | Four primary Home filters, Center moved to More. | SUPERSEDED by newest owner command requiring five filters including Center. |
| #3625 / #3633 / #3639 | Unknown Task/Reminder/Follow-up envelope preservation and JSON field contract. | High-value P0 data-safety candidates; verify canonical source and exact-SHA tests. |
| #3646 | Four-action Task reminder window requirement. | Open P0 Issue; implementation not accepted. |

No historical PR was closed, deleted or merged as part of this register. Branches and source history remain preserved.