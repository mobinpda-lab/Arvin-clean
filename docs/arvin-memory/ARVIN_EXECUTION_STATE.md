# Arvin Execution State

Updated: 2026-10-11 (live continuation checkpoint)
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write verified by live read/write operations.
Authority: live GitHub refs, source, tests, workflow evidence.

## Current release state
**IN PROGRESS — RELEASE BLOCKED.** No physical-device acceptance has been provided.

## Last completed step
- Read this execution state and the evidence map before continuing.
- Rechecked repository default branch, latest main commit, PR #2585, #2587 and #2600, Issue #2580, the canonical PCTADP ADR, Task model and Project model.
- Verified main remains `72a2f4cc24df7a38eff9856ce403461615db5280`; the latest main commit is documentation-only.
- Verified Memory PR #2600 current head `0b5b6a90c3fb30988528baf85bcc2ee4c914d9f9`. Exact-head Build [#38126660822](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38126660822) is now SUCCESS: Analyze, test shards 0–5, Debug APK and Release APK all passed. Device Smoke [#38126660831](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38126660831) was SKIPPED by the docs-only workflow trigger; this is not product validation.
- Confirmed PR #2585 remains OPEN / NOT MERGED at head `5e0ad6ddd1675359b84a3ab9c351be4d8ac38a27`; PR #2587 remains OPEN / NOT MERGED at head `4442ce450e4295e500a9db6d5dc5b4d9657b3770`. Both remain subject to real-device acceptance.
- Continued the taxonomy conformance audit and posted a checkpoint on Issue #2580.

## Current GitHub reality
- Main: [72a2f4c](https://github.com/mobinpda-lab/Arvin-clean/commit/72a2f4cc24df7a38eff9856ce403461615db5280), documentation-only PCTADP decision registration.
- Calendar linked-event edit fix [PR #2570](https://github.com/mobinpda-lab/Arvin-clean/pull/2570) is merged in [34a6cee](https://github.com/mobinpda-lab/Arvin-clean/commit/34a6cee9ae05ad1cf632960b96e98f2a5448e128). Automated regression expects update=1/create=0 and stable external event ID; physical-device proof is still absent.
- Backup/restore [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585): open, not merged; head `5e0ad6ddd1675359b84a3ab9c351be4d8ac38a27`. Exact-head Build #38124942112 and Device Smoke #38124941815 succeeded; all six emulator lanes passed. Actual Android system file-picker/provider and data-integrity acceptance remain unverified.
- Calendar action visibility [PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587): open, not merged; head `4442ce450e4295e500a9db6d5dc5b4d9657b3770`. Exact-head Build #38089112669 and Device Smoke #38089112675 succeeded; physical-device action visibility, recurrence and same-event/no-duplicate acceptance remain unverified.
- Memory [PR #2600](https://github.com/mobinpda-lab/Arvin-clean/pull/2600): open, draft; head `0b5b6a90c3fb30988528baf85bcc2ee4c914d9f9`. Exact-head Build #38126660822 succeeded. Device Smoke skipped as docs-only; no need to interpret as a failed product smoke test.
- Taxonomy audit [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580) remains open. Canonical concepts are Project, Category and Tag; Category/Group is one concept; no independent Group entity is permitted.

## Taxonomy audit findings (partial, not closure)
- `lib/models/task.dart` declares `Task.category` and `Task.tags` as separate fields, consistent with the canonical distinction.
- `lib/models/goal_project.dart` stores Project membership as references to canonical Task IDs (`itemIds`); it does not itself declare a Category relation.
- The ADR explicitly says the semantic Project → Category → Task hierarchy is not evidence of a physical Category-to-Project foreign key. The current model inspection supports keeping this question open until the full persistence, serialization, assignment and UI paths are inspected. No schema/model change was made.
- `lib/home/grouping/home_grouping_service.dart` uses `HomeGroup<Task>` as a presentation grouping abstraction. This name alone is not evidence of a fourth domain entity.
- Broad repository search surfaces older/historical documents and technical uses of “group”. Do not mass-replace. Classify each finding as domain entity, user-facing wording, presentation-only grouping, generic technical term or historical document.

## In progress
1. Continue Issue #2580 audit across Category/Tag catalog persistence, Task assignment, filters/search, UI copy, serialization and backup/restore.
2. Keep PR #2585 and #2587 open until the real-device acceptance gates are evidenced.
3. Review the documentation PR #2600 after exact-head Build success; retain draft until memory content is reviewed.

## Blocked / unproven
- Physical Android system file-picker/provider backup and restore, including rollback recovery and data integrity.
- Physical-device Calendar same-ID edit/no-duplicate behavior, action visibility and recurrence/checklist acceptance.
- Full Golden Flow: Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore.
- Complete taxonomy conformance inventory.
- Release handover documents and explicit owner acceptance.

## Next actions
- Inspect the actual Category/Tag persistence and backup/restore paths without changing schemas or user data.
- Record file-level taxonomy findings and focused tests in Issue #2580; update this state/evidence map only with verifiable results.
- Recheck PR heads and exact-head CI before any merge. Do not merge based on CI alone.
- Complete real-device acceptance and Golden Flow before release claims.

## Risk rules
Task remains the only source of truth; Calendar is a projection; Repeat must not create copied Tasks; preserve stable Task ID and external event ID. No merge/release based on CI alone. Never claim user/device acceptance without direct evidence.
