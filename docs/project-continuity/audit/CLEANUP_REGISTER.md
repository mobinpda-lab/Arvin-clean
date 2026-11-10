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
