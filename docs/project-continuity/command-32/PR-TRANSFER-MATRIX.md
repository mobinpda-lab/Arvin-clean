# COMMAND 32 — PR Transfer Matrix
Checkpoint: 2026-11-18
Canonical PR: #3495
Canonical branch: recovery-02/main-based-integration
Canonical HEAD: `ed93d6ad30bfe4e75199f297efda0a2b8099ce49`
Main: `45e4202b03a434459e4c021a04efa7e8396359db`

Status: IN PROGRESS. This is a source-backed decision matrix for the high-risk/currently relevant PR chain, not a claim that all historical PRs have been exhaustively classified. No PR or branch was closed or deleted.

| PR | Scope / source facts | Transfer decision | Reason / remaining proof |
|---|---|---|---|
| #3495 | REV10 canonical route; 143 commits, 127 changed files; OPEN / DRAFT / UNMERGED | KEEP — sole destination | Current HEAD verified; Main unchanged. |
| #3470 | Vazirmatn weight contract; 24 commits, 21 files | SELECTIVE REVIEW | 21 UI files change weights and add a static test. Requires screenshot/accessibility review against REV10 before port. |
| #3463 | M2M v19/v20 migration; 139 commits, 42 files; based on feature/command-07-a-sqlite-contract-remediation | DEFERRED — no direct merge | Depends on #3384 and v19 schema/stores/codecs. Canonical is schema v7; sequential file-backed v7→v20 proof is not accepted. ADR/design is retained in REV10 docs. |
| #3384 | Legacy field presence, unknown metadata, SQL/Person/Follow-up refactor; 218 commits, 120 files | SELECTIVE ADAPTATION | Stacked on older product-repair branch; broad Task/FollowUp model and schema v19 refactor. Narrow Follow-up unknown-field preservation independently implemented using extensionData + extension_json. No bulk cherry-pick. |
| #3382 | Independent raw SQL diagnostic evidence; 3 commits, 2 files | PRESERVE AS EVIDENCE | Diagnostic harness/source evidence, not a product feature. |
| #3380 | Diagnostic executor lifecycle recovery; 8 commits, 2 files | PRESERVE AS EVIDENCE | Stacked diagnostic PR; keep until SQL migration root cause is closed. |
| #3376 | Persist-task envelope capture; 7 commits, 2 files | PRESERVE AS EVIDENCE | Forensic evidence, not production code. |
| #3366 | Task editor metadata / due-reminder preservation; 8 commits, 6 files | SELECTIVE REVIEW | Patch references fields absent from current canonical model (e.g. isFavorite/focusDate/legacyFollowUpMetadata). Do not port incompatible constructor fields. |
| #3365 | Device Smoke exact-ref checkout and Calendar navigation test; 4 commits, 3 files | LIKELY REPRESENTED; verify exact diff | Canonical branch already contains modified device-smoke and Calendar interaction/navigation files. Exact equivalence still needs proof. |
| #3364 | SQL envelope parity and legacy field-presence correction; 10 commits, 6 files | PARTIALLY SUPERSEDED BY A02; residual review | Canonical now stores opaque Follow-up extension data in SQL. Task-level missing/null/false semantics and migration-writer conflict detection still require comparison. |
| #3356 | SQL envelope mismatch diagnostic/fix; 1 commit, 1 file | DEFERRED | Stacked on #3052; preserve as root-cause source until exact migration-writer tests pass. |
| #3348 | File-backed Project and multiple-reminder lifecycle tests; 8 commits, 5 files | SELECTIVE TRANSFER / EQUIVALENCE CHECK | Canonical already has file-backed Project and reminder persistence tests plus Calendar/device-smoke paths. Compare test semantics and checkout changes before closing. |
| #3346 | Task editor preserves canonical fields and legacy metadata; 3 commits, 3 files | NOT PORTED | Candidate patch relies on fields absent from current canonical Task model. Re-evaluate against actual REV10 model and targeted preservation tests. |
| #3341 | File-backed SQLite persistence tests; 3 commits, 2 files | DUPLICATE CANDIDATE; NOT CLOSED | Overlaps #3348. Exact assertions and unique commits must be compared. |
| #3052 | Large Main-based Calendar/device-smoke recovery stack; 2,192 commits, 395 files | DO NOT DIRECT-MERGE | Extensive unique history and unrelated/legacy changes. Requires commit-level and file-level selective classification. |
| #3340 | REV9 governance package; closed-unmerged | SUPERSEDED BY REV10 | Preserve source/history; REV9 is not active authority. |
| #3388 | Wave 0 continuity/governance package; closed-unmerged | ARCHIVE / REFERENCE | Retain non-conflicting historical evidence; REV10 remains authority. |
| #3448 | REV10 master charter proposal; closed-unmerged | AUTHORITY ALREADY REPRESENTED | Canonical branch has active REV10 governance and supersession mapping; compare source docs before archival cleanup. |

## Verified transfer already present
- PR #3495 is 143 ahead / 0 behind Main.
- A01 and W01 are committed in `8dee3947939b941a48be4a5882b10fcf3ec20ab4`.
- A02 and A03 are committed in `ed93d6ad30bfe4e75199f297efda0a2b8099ce49`.
- Existing branch includes file-backed Project/Reminder tests, Calendar navigation tests, Backup/Restore improvements and REV10 governance docs.
- No bulk merge/cherry-pick was used.

## Outstanding transfer work
1. Enumerate every open and closed PR beyond the focused list.
2. Compare unique commit SHAs for every PR, including stacked chains.
3. Compare all changed-file patches against canonical HEAD.
4. Check exact-SHA CI for every proposed port.
5. Only then close superseded PRs or delete refs.
