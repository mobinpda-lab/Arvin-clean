# Repository Cleanup Register — REV9 / WAVE 0

**Baseline:** 2026-11-10 · Main `45e4202b03a434459e4c021a04efa7e8396359db` · PR #3340 baseline head `5f934bfb4ee0cfa96d838f1d61f08c794c0676ed`.
**Current owner direction:** LOCAL-FIRST; multi-device sync SUSPENDED.
**Write scope:** documentation-only on PR #3340 branch. No deletions authorized.

## Reverified live inventory

| Item | Live finding | Disposition |
|---|---|---|
| Branches | 1,413 | WAVE 1 inventory; no deletion |
| Duplicate branch HEADs | 35 groups / 109 refs | WAVE 1 ancestry/dependency audit |
| Open PRs | 101; 75 Draft | Review individually; no auto-close |
| Stale open PRs | 99 not updated since 2026-11-01 | Candidate register only |
| PR #3340 | OPEN / READY FOR REVIEW / UNMERGED; 66 docs-only changed files | Authorized documentation branch |
| PR #3052 | OPEN / DRAFT / UNMERGED; 395 changed files | Protected; untouched |
| Main | `45e4202...` | Protected; untouched |
| Main repository tree | 811 entries / 734 blobs / 225 Markdown-like docs | WAVE 0 baseline |
| PR #3340 branch tree | 883 entries / 799 blobs / 290 Markdown-like docs | Includes 66 changed docs/agent instructions |

## WAVE 0 change register

| ID | Candidate / finding | Evidence | Safe action | Status |
|---|---|---|---|---|
| CL-001 | Duplicate branch refs | 35 exact-HEAD groups / 109 refs reverified | Inventory ancestry, PR association and dependency in WAVE 1; no deletion | REGISTERED |
| CL-002 | Reused PR head branches | Prior 33 groups / 72 PR records not re-counted in this Wave 0 | Recompute in WAVE 1 before action | NEEDS REVALIDATION |
| CL-003 | Stale open PRs | 99/101 open PRs last updated before 2026-11-01 | Review by issue, branch, CI and dependency; no auto-close | REGISTERED |
| CL-004 | Closed-unmerged PRs | Prior inventory only; not re-counted in this Wave 0 | Preserve; WAVE 1 verification | HISTORICAL / NEEDS REVALIDATION |
| CL-005 | Repeated commit subjects | Prior inventory only; not re-counted in this Wave 0 | Compare patches/parents in WAVE 1 | NEEDS REVALIDATION |
| CL-006 | Identical commit trees | Prior inventory only; not re-counted in this Wave 0 | Compare parent/diff semantics in WAVE 1 | NEEDS REVALIDATION |
| CL-007 | Legacy governance documents | Multiple historical docs and snapshots across root/docs/continuity/QA/memory | Label authority/status; preserve | WAVE 3 |
| CL-008 | Parallel decision records | DECISIONS.md vs PRODUCT_DECISIONS.md | DECISIONS remains historical/technical archive; active product decisions in PRODUCT_DECISIONS | SAFE DOC CLARIFICATION |
| CL-009 | Parallel Calendar specs | CALENDAR_UIUX_SPEC.md vs calendar_ui_ux_spec.md | Preserve both; establish authority and links in WAVE 3 | NEEDS WAVE 3 |
| CL-010 | Same-basename UI docs | docs/ARVIN_UI_CANONICAL.md vs docs/UI/ARVIN_UI_CANONICAL.md; different content | Preserve; map inbound links/authority before rename | NEEDS WAVE 3 |
| CL-011 | Exact duplicate AI adapters | CLAUDE.md, GEMINI.md and .github/copilot-instructions.md share exact blob content intentionally | Keep thin entry points; one canonical AI policy | INTENTIONAL |
| CL-012 | Broken REV8 archive link | MASTER_GOVERNANCE.md linked to absent archive/MASTER_GOVERNANCE_REV8.md | Correct to MASTER_GOVERNANCE_REV8_ARCHIVE.md | FIXED IN THIS PASS |
| CL-013 | Stale continuity snapshots | README, CURRENT_STATE, PROJECT_STATE, ROADMAP, OPEN_ISSUES, HANDOFF, IMPLEMENTATION_LOG and TODO | Add current pointer; preserve dated history | FIXED / LABELLED IN THIS PASS |
| CL-014 | Conflicting sync direction | Older P2P Phase 1 / Cloud Phase 2 approval vs latest LOCAL-FIRST / SYNC SUSPENDED owner instruction | Record latest direction; preserve old decision as SUPERSEDED | FIXED IN THIS PASS |
| CL-015 | Historical WAVE 4 implementation authorization | AGENTS.md / AI_CONTINUITY_PROTOCOL.md retain REV8 implementation text | Explicitly supersede for current docs-only mission | FIXED IN THIS PASS |
| CL-016 | Orphaned docs | Full content/link/consumer audit of all 290 branch docs not completed | WAVE 3 inventory; no deletion | OPEN |
| CL-017 | Historical typography conflict | Vazirmatn vs VazirHarf remains NEEDS OWNER DECISION | Preserve all records; ask owner | OPEN |
| CL-018 | Reminder state machine | Four states/transitions unresolved | No invented contract | OPEN |

## Protected cleanup rules

- No branch/PR/commit/tag/release/workflow/test/migration/table/column/data deletion.
- No force-push, rebase, history rewrite, merge, release, Main update or ruleset change.
- No source, schema, migration, test or workflow edits in this documentation-only pass.
- No sync implementation while Local P2P/Cloud/remote sync is SUSPENDED.
- Every candidate must be dependency-checked and owner-authorized before deletion.
- A successful commit alone does not complete a wave.

---

## Additional non-destructive review candidate — typography

| ID | Candidate | Evidence | Safe action | Boundary | Status |
|---|---|---|---|---|---|
| CL-017 | Typography decision / implementation divergence | Owner instruction 2026-09-06 says VazirHarf v34.003; later ledger rows claim Vazirmatn approval without Decision ID/source; current code and tests enforce Vazirmatn. | Reconcile primary owner source and register the governing decision; map affected code/tests/PRs. | No font asset/code/test removal or replacement in this audit. | NEEDS OWNER-SOURCE RECONCILIATION |

---

## Post-audit safety refresh — 2026-11-10

Live branch head is a934. Duplicate branch-head, repeated PR-head, repeated commit-subject/tree groups and 99 stale-open-PR candidates remain review candidates only. No branch/PR/commit/tag/release/workflow/test/migration/table/data deletion, history rewrite, merge, or ruleset change is authorized or performed. Main is protected and READ-ONLY; working branch is unprotected.

---

# Arvin Cleanup Register — REV8

**Policy:** identify first; preserve history; do not delete without explicit Mobin approval.

| ID | Candidate | Evidence | Safe action | Destructive boundary | Status |
|---|---|---|---|---|---|
| CL-001 | Duplicate branch refs | 35 head-SHA groups, 109 branch refs | Inventory and group by exact SHA | Branch deletion requires Mobin approval | REGISTERED |
| CL-002 | PR head-branch reuse | 33 groups, 72 PR records | Record PR relationships | Close/delete PR requires Mobin approval | REGISTERED |
| CL-003 | 99 stale open PR candidates | 99/100 open PRs last updated in October; 75 open PRs are drafts | Review by issue/branch/CI dependency | Close requires Mobin approval | REGISTERED |
| CL-004 | 509 closed-unmerged PRs | 1,138 closed; 509 not merged | Preserve as historical evidence | No deletion | HISTORICAL |
| CL-005 | Repeated commit subjects | 36 groups / 107 records in Main history | Compare patch/tree/parents | No rebase or history rewrite | REGISTERED |
| CL-006 | Identical commit trees | 148 groups / 300 records in Main history | Inspect parent/diff semantics | No commit deletion | REGISTERED |
| CL-007 | Legacy governance docs | 178 root docs; many old state/roadmap/governance snapshots | Mark as historical and link canonical authority | File deletion needs approval | REGISTERED |
| CL-008 | Parallel decision records | DECISIONS.md vs PRODUCT_DECISIONS.md | Label DECISIONS as historical/technical archive | Do not delete archive | SAFE DOC CLARIFICATION |
| CL-009 | Parallel Calendar specs | CALENDAR_UIUX_SPEC.md (52 lines) vs calendar_ui_ux_spec.md (135 lines) | Point to dated lower-case canonical spec; retain older proposal | Do not delete older spec | SAFE DOC CLARIFICATION |
| CL-010 | Stale architecture docs | Old docs describe ArvinTask/TaskRepository as current | Add historical status and point to current TaskStore | Do not delete historical docs | SAFE DOC CLARIFICATION |
| CL-011 | Generic TaskStore interface | lib/core/storage/task_store.dart found only in test references; concrete service in lib/services/task_store.dart | Verify all imports/callers | Code removal needs separate approval | NEEDS REVIEW |
| CL-012 | TaskDetailPage.onEdit callback | Callback declared/passed but no use in page body found | Confirm no reflection/indirect caller | Code change needs separate approval | NEEDS REVIEW |
| CL-013 | Legacy AutomaticFollowUp scheduler | Compatibility/no-op service/planner and Android callback files remain | Verify Android entrypoint and all references | Code/file deletion needs approval | NEEDS REVIEW |
| CL-014 | Reminder four-state model | No explicit enum/state machine found | Define contract before implementation | Product decision required | BLOCKED |
| CL-015 | NIRA state-sync PR loop | 292/381 closed PRs with same title/branch; 289 unmerged | Fix idempotent state-sync workflow and comment behavior | PR closure/branch deletion requires approval | NEEDS REVIEW |
| CL-016 | NIRA scheduler comment limit | Issue #162 has >2,500 comments; error feedback fails with 403 | Make scheduler feedback bounded/idempotent and preserve original error | Workflow code change needs separate technical authorization | BLOCKED |

## Protected actions not performed

- No branch, PR, commit, tag, release, workflow, test, migration, table, column, or data was deleted.
- No force-push, rebase, squash, history rewrite, merge, release, Main update, or ruleset change occurred.
- No test was skipped, weakened, or removed.
- No code changes were made.
