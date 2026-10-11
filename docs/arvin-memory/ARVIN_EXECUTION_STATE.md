# Arvin Execution State

Updated: 2026-10-11 (taxonomy and migration audit checkpoint)
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write verified by live read/write operations.
Authority: live GitHub refs, source, tests and workflow evidence.

## Current release state
**IN PROGRESS — RELEASE BLOCKED.** No physical-device acceptance has been provided.

## Last completed step
- Read the saved execution state and evidence map first.
- Rechecked main, PR #2585, #2587, #2600, Issue #2580, canonical ADR and taxonomy source files.
- Confirmed main head is `72a2f4cc24df7a38eff9856ce403461615db5280`; latest main commit is documentation-only.
- Verified Memory PR #2600 head before this memory update: `0b5b6a90c3fb30988528baf85bcc2ee4c914d9f9`. Exact-head Build [#38126660822](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38126660822) SUCCESS (Analyze, test shards 0–5, Debug APK, Release APK). Device Smoke [#38126660831](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38126660831) SKIPPED because the change was docs-only. These results predate the current memory commit and are not exact-head checks for the new head.
- Confirmed PR #2585 is OPEN / NOT MERGED at code head `5e0ad6ddd1675359b84a3ab9c351be4d8ac38a27`; PR #2587 is OPEN / NOT MERGED at code head `4442ce450e4295e500a9db6d5dc5b4d9657b3770`.
- Continued the taxonomy audit. Posted a checkpoint to [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580), including a possible legacy Tag catalog migration gap. This is a risk to verify, not a confirmed user-data-loss incident.

## Current GitHub reality
- Main: [72a2f4c](https://github.com/mobinpda-lab/Arvin-clean/commit/72a2f4cc24df7a38eff9856ce403461615db5280), documentation-only PCTADP decision registration.
- Calendar linked-event edit fix [PR #2570](https://github.com/mobinpda-lab/Arvin-clean/pull/2570) is merged in [34a6cee](https://github.com/mobinpda-lab/Arvin-clean/commit/34a6cee9ae05ad1cf632960b96e98f2a5448e128). Automated regression expects update=1/create=0 and stable external event ID; physical-device proof remains absent.
- Backup/restore [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585): open/unmerged at `5e0ad6d`; exact-head Build #38124942112 and Device Smoke #38124941815 succeeded, all six emulator lanes. Actual Android system file-picker/provider and data-integrity acceptance remain unverified.
- Calendar action visibility [PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587): open/unmerged at `4442ce4`; exact-head Build #38089112669 and Device Smoke #38089112675 succeeded, all six emulator lanes. Physical-device action visibility, recurrence/checklist and provider behavior remain unverified.
- Memory [PR #2600](https://github.com/mobinpda-lab/Arvin-clean/pull/2600): open/draft. Its previously checked head passed Build #38126660822, but the current head changed with this memory update; exact-head CI must be rechecked.
- Taxonomy audit [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580) remains open.

## Taxonomy audit findings (partial)
- `lib/models/task.dart`: `Task.category` and `Task.tags` are separate.
- `lib/models/goal_project.dart`: Project membership stores canonical Task IDs in `itemIds`; this model does not declare a Category relation.
- `lib/home/grouping/home_grouping_service.dart`: `HomeGroup<Task>` is a presentation grouping abstraction, not proof of a fourth domain entity.
- `lib/services/task_store.dart`: canonical Category catalog uses SQL `taxonomy_categories`; canonical Tag catalog uses SQL `tags`; Task assignments are stored on canonical Task / task-tag persistence.
- `lib/services/tag_store.dart` defines SharedPreferences key `arvin.tags`, but the only path-specific historical commit found is `3073cb8` (“Add tag storage”), which added only this file; no caller is found in current code search. Current migration reads `arvin.tasks` and derives SQL Tag rows from each Task's `task.tags`, not `arvin.tags`. Disposition: **legacy orphan candidate / low-confidence data risk**, not a confirmed shipped migration gap. No code change is justified without evidence of historical shipped use; preserve the key/file until then.
- Do not infer a physical Category-to-Project foreign key from the semantic hierarchy. Do not mass-replace “group”; classify domain, user-facing, presentation, generic technical and historical uses first.

## In progress
1. If new historical evidence appears, verify whether legacy `TagStore` / `arvin.tags` was ever used in a shipped path; current history shows only the unreferenced file addition.
2. Inspect backup/export/import behavior for catalog-only Tags as part of the broader conformance audit; do not change migration solely on speculation.
3. Continue Issue #2580 audit across persistence, Task assignment, filters/search, UI copy, serialization and restore.
4. Keep PR #2585 and #2587 unmerged until real-device acceptance is evidenced.
5. Recheck PR #2600 exact head and Build after this update; keep draft pending review.

## Blocked / unproven
- Physical Android system file-picker/provider backup and restore, failed-restore recovery and data integrity.
- Physical-device Calendar same-ID edit/no-duplicate behavior, action visibility, recurrence/checklist acceptance.
- Full Golden Flow: Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore.
- Complete taxonomy conformance inventory and legacy Tag migration risk disposition.
- Release handover documents and explicit owner acceptance.

## Next actions
- Inspect Git history and current/legacy UI wiring for `TagStore`; inspect backup and migration tests.
- Make no migration/schema/data change until historical usage and data safety are established.
- Record file-level findings and focused regression tests in Issue #2580.
- Recheck PR heads and exact-head CI before any merge. Never merge/release on CI alone.

## Risk rules
Task remains the only source of truth; Calendar is a projection; Repeat must not create copied Tasks; preserve stable Task ID and external event ID. No merge/release based on CI alone. Never claim user/device acceptance without direct evidence.
