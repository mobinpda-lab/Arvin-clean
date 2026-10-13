# Person Directory Synchronization Plan — 2026-10-14

## Status

**BLOCKED — do not merge PR #2681 or cherry-pick it wholesale.**

This plan is the continuation point for integrating the already owner-approved lightweight Person directory and Person-based Follow-up reporting into the active release branch without losing current reminder/calendar fixes.

## Exact repository state checked

- Active release integration branch: `integration/task-multiple-reminders-safe-20261013`
- Active release PR: [#2666](https://github.com/mobinPda-lab/Arvin-clean/pull/2666)
- Parent code head checked: `a7be929a844038d64fcf20e5a6681a1c8732b2fc`
- Person implementation PR: [#2681](https://github.com/mobinPda-lab/Arvin-clean/pull/2681)
- Person branch: `integration/follow-up-person-model-20261013`
- Person branch head checked: `4c2795e92d70cee208f38a150a28b1f63f31c7f2`
- Compare result: **diverged**, Person branch 101 commits ahead and 159 behind parent, common ancestor `68724d6191590b81b2d611f59b7944a7fcbb06e0`.
- Parent PR #2666 has green Build, Calendar Provider Acceptance, Device Smoke, and orchestration runs on the parent code head. Those runs do **not** validate the unmerged Person branch changes.

## Current gap

The parent Task model already understands structured Follow-up Person IDs, but the active branch does not yet contain the complete reusable Person directory persistence/UI, portable backup/restore, and Person-specific per-Follow-up reporting path. The child PR contains a broad set of changes across 40 files and has conflicts/divergence with the current parent.

## Non-negotiable safeguards

1. Do not merge PR #2681 as-is, force-update it, or cherry-pick all 101 commits.
2. Do not add a second Task store, Person store, or backup format.
3. Task remains the source of truth; Person remains a lightweight directory, not CRM.
4. Validate all Person IDs and Follow-up `personIds` before the first destructive restore mutation.
5. A legacy backup with no `people` field remains valid only when its Tasks do not contain structured Person references. Never silently restore dangling references.
6. Preserve the current parent’s multi-reminder, calendar identity, migration tombstone, and rollback behavior.
7. Any schema/migration change must include upgrade, rollback, persistence, and backup/restore tests before integration.

## Reviewed integration sequence

1. **Freeze a clean integration base:** use the current parent head, not the old common ancestor.
2. **Port the Person persistence slice first:** inspect and selectively adapt `PersonReference`, the existing SQL migration/schema, and the existing TaskStore transaction boundaries. Do not copy the child TaskStore wholesale.
3. **Port Settings UI and routes:** add the directory to the existing Settings flow and verify add/edit/delete/search. Deleting a Person must not delete or rewrite Tasks/Follow-ups.
4. **Port portable backup/restore:** extend the existing `CanonicalBackupCandidate` and existing payload with optional `people`; validate duplicate/blank IDs and every structured Follow-up reference before applying changes; include Person records in emergency snapshots and rollback.
5. **Port reporting separately:** add Person selection and per-Follow-up result rows (Task, note/result, waiting state, Person labels, `nextFollowUp`, and independent `reminderDate`). Date filtering for these rows must use `nextFollowUp`, never `reminderDate`.
6. **Validate each slice before the next:** SQL migration/persistence → Settings directory → backup/restore round-trip and injected rollback failure → report filtering → complete acceptance scenario.
7. **Run exact-head gates:** Analyze, all test shards, debug/release APK, Calendar Provider Acceptance, and Device Smoke. Then record physical-device evidence separately.
8. **Only after clean review:** update PR base/stacking strategy and request merge review. Do not close #2681 until its useful changes are either safely integrated or explicitly superseded.

## Work advanced on the child branch in this execution

- Added restore preflight validation to reject Follow-up Person IDs missing from the portable Person directory and to reject structured Person references when the directory field is omitted.
- Added tests for dangling references and legacy-backup compatibility.
- Added Person and waiting-state report filters, per-Follow-up rows, distinct display of next action vs Reminder, and tests for selected Person, active waiting, and removed Person labels.
- These changes are on the divergent child branch and have **not** been validated by CI or integrated into the parent. Treat them as unvalidated work, not release evidence.

## Next action

**BLOCKED on safe integration strategy:** use this plan to port the approved Person directory in small, reviewed slices onto the active parent. Keep release NO-GO until backup/restore integrity, report acceptance, exact-head CI, and physical-device evidence are complete.
