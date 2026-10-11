# Arvin Execution State

Updated: 2026-10-11 (catalog portability gate and exact-head CI recheck)
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write verified by live read/write operations.
Authority: live GitHub refs, source, tests and workflow evidence.

## Current release state
**IN PROGRESS — RELEASE BLOCKED.** No physical-device acceptance has been provided.

## Last completed step
- Read the saved execution state and evidence map first.
- Rechecked main, PR #2585, #2587, #2600, Issue #2580, canonical ADR and taxonomy source files.
- Confirmed main head is `72a2f4cc24df7a38eff9856ce403461615db5280`; latest main commit is documentation-only.
- Memory PR #2600 current head before this state refresh was `f276ed70c7d0bdfb22548dd2d34b7d5843a93ea3`. Exact-head Build [#38127838095](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38127838095) was IN PROGRESS at last poll; Device Smoke [#38127838161](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38127838161) was SKIPPED due docs-only trigger. Orchestrator, Production Loop, Parallel Wave and G1 lock-sync runs completed successfully; these do not substitute for Build or device acceptance.
- Confirmed PR #2585 is OPEN / NOT MERGED at code head `5e0ad6ddd1675359b84a3ab9c351be4d8ac38a27`; PR #2587 is OPEN / NOT MERGED at code head `4442ce450e4295e500a9db6d5dc5b4d9657b3770`.
- Continued the taxonomy audit and posted a source-backed backup/restore catalog gap to [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580). Independent unused Category/Tag catalog entries are supported by TaskStore/UI, but the current canonical backup payload only includes Tasks, settings and Projects. No code/data mutation was made because preserving catalog-only values is a product data-integrity decision.

## Current GitHub reality
- Data-integrity owner gate: [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580) records the source-level backup/restore gap for unused Category/Tag catalog entries. Recommendation is to preserve them as portable user data. No owner approval has been received in this execution context; no backup format, schema or restore code was changed.
- Main: [72a2f4c](https://github.com/mobinpda-lab/Arvin-clean/commit/72a2f4cc24df7a38eff9856ce403461615db5280), documentation-only PCTADP decision registration.
- Calendar linked-event edit fix [PR #2570](https://github.com/mobinpda-lab/Arvin-clean/pull/2570) is merged in [34a6cee](https://github.com/mobinpda-lab/Arvin-clean/commit/34a6cee9ae05ad1cf632960b96e98f2a5448e128). Automated regression expects update=1/create=0 and stable external event ID; physical-device proof remains absent.
- Backup/restore [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585): open/unmerged at `5e0ad6d`; exact-head Build #38124942112 and Device Smoke #38124941815 succeeded, all six emulator lanes. Actual Android system file-picker/provider and data-integrity acceptance remain unverified.
- Calendar action visibility [PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587): open/unmerged at `4442ce4`; exact-head Build #38089112669 and Device Smoke #38089112675 succeeded, all six emulator lanes. Physical-device action visibility, recurrence/checklist and provider behavior remain unverified.
- Memory [PR #2600](https://github.com/mobinpda-lab/Arvin-clean/pull/2600): open/draft at `f276ed70c7d0bdfb22548dd2d34b7d5843a93ea3` before this state refresh. Exact-head Build #38127838095 was still running at last poll; Device Smoke #38127838161 was skipped because the PR is docs-only. Any further memory commit creates a new head and requires a fresh exact-head check.
- Taxonomy audit [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580) remains open.

## Taxonomy audit findings (partial)
- `lib/models/task.dart`: `Task.category` and `Task.tags` are separate.
- `lib/models/goal_project.dart`: Project membership stores canonical Task IDs in `itemIds`; this model does not declare a Category relation.
- `lib/home/grouping/home_grouping_service.dart`: `HomeGroup<Task>` is a presentation grouping abstraction, not proof of a fourth domain entity.
- `lib/services/task_store.dart`: canonical Category catalog uses SQL `taxonomy_categories`; canonical Tag catalog uses SQL `tags`; Task assignments are stored on canonical Task / task-tag persistence.
- `lib/services/tag_store.dart` defines SharedPreferences key `arvin.tags`, but the only path-specific historical commit found is `3073cb8` (“Add tag storage”), which added only this file; no caller is found in current code search. Current migration reads `arvin.tasks` and derives SQL Tag rows from each Task's `task.tags`, not `arvin.tags`. Disposition: **legacy orphan candidate / low-confidence risk**, not a confirmed shipped migration gap. Preserve the key/file absent evidence of shipped use.
- **Confirmed source-level backup coverage gap:** `TaskStore` supports independently created unused catalog entries through `createCategory()` / `createTag()` and `loadCategories()` / `loadTags()`. `TaskTaxonomyManagementPage` test verifies an unused category remains visible. However `BackupPage` supplies Tasks/settings/Calendar links, `ProjectBackupBridge` adds Projects, and `ArvinBackupService` encodes only Tasks/settings/Projects. No independent Category/Tag catalog fields are serialized. Thus a backup/restore round-trip cannot guarantee preserving unused catalog-only entries. This is a source-level gap; real-world loss occurs if such an entry exists and that backup is restored.
- Do not infer a physical Category-to-Project foreign key from the semantic hierarchy. Do not mass-replace “group”; classify domain, user-facing, presentation, generic technical and historical uses first.

## In progress
1. Owner decision required: confirm the product data contract for independently created unused Categories/Tags during backup/restore. Recommendation recorded in Issue #2580: preserve them as portable user data.
2. After owner decision, design a backward-compatible backup/restore extension, with tests for unused and Task-assigned catalog values, legacy v1 backups and rollback on failed restore. No implementation before this decision.
3. Continue Issue #2580 audit across persistence, Task assignment, filters/search, UI copy, serialization and restore.
4. Keep PR #2585 and #2587 unmerged until real-device acceptance is evidenced.
5. Recheck PR #2600 exact head and Build after this update; keep draft pending review.

## Blocked / unproven
- Physical Android system file-picker/provider backup and restore, failed-restore recovery and data integrity.
- Physical-device Calendar same-ID edit/no-duplicate behavior, action visibility, recurrence/checklist acceptance.
- Full Golden Flow: Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore.
- Complete taxonomy conformance inventory; backup/restore does not currently preserve unused catalog-only Category/Tag entries, and owner decision is pending.
- Release handover documents and explicit owner acceptance.

## Next actions
- Await owner decision on backup portability of unused Category/Tag catalog entries; do not change format/restore behavior until the contract is confirmed.
- Then implement only a backward-compatible, rollback-safe change with focused tests for legacy backups and unused catalog entries.
- Keep the legacy `TagStore` key/file unchanged absent evidence of shipped use.
- Record file-level findings and focused regression tests in Issue #2580.
- Recheck PR heads and exact-head CI before any merge. Never merge/release on CI alone.

## Risk rules
Task remains the only source of truth; Calendar is a projection; Repeat must not create copied Tasks; preserve stable Task ID and external event ID. No merge/release based on CI alone. Never claim user/device acceptance without direct evidence.
