# Arvin — Canonical Project State

**Updated:** 2026-08-21
**Repository:** mobinpda-lab/Arvin-clean
**Default branch:** `main`
**Current verified main head:** `105210c0f509831f3bdf8d493b758de9b500dc9d`
**Current active documentation/test branch:** `test/migration-legacy-compatibility-current`

## Source of truth
- GitHub repository state is the source of truth for executable status: code, branches, commits, PRs, workflows, tests, builds and merges.
- Project documentation defines architecture, governance, roadmap and decisions.
- Conversation/memory is continuity context, not a substitute for current GitHub evidence.
- Real code is inspected whenever implementation behavior or architecture is in question.
- If these sources disagree, identify the gap, verify the repository/code, then update the relevant current-state documentation while preserving historical records.

## Documentation governance
Before every meaningful change:
1. Review current `main`, relevant branch and recent commits.
2. Review open PRs and recent workflow results.
3. Review relevant project documentation and previous decisions.
4. Inspect the real code when the question is implementation-sensitive.
5. Confirm the capability is not already implemented.
6. Identify the smallest real gap.
7. Make a small reversible change.
8. Run focused tests and the required validation pipeline.
9. Verify actual GitHub Actions results; never infer green from an unrun workflow.
10. Record important decisions and resulting state in the relevant documentation.

Historical documents are not to be silently rewritten merely to make history look current. Current state belongs in this canonical document and dated audit/update documents.

## Current verified development state
- Issue #106: **CLOSED / COMPLETED**.
- PR #107: **MERGED** — `771f1e1776742bbca3e0d1c1110bec9b4adefa54`.
- PR #108: **MERGED** — `1d92d03df9b491a10f6b9dd6305ac3045ef0de65`.
- PR #109: **MERGED** — `fe658307465fc446c917d5d0c7d5a303bfabf059`.
- PR #110: **MERGED**; the resulting documentation state commit is `105210c0f509831f3bdf8d493b758de9b500dc9d`.
- PR #111: **OPEN / DRAFT / MERGEABLE** — `test(migration): restore legacy follow-up compatibility coverage`.
- PR #111 base is `main` at `105210c0f509831f3bdf8d493b758de9b500dc9d`.
- PR #111 head is `29edac0047ab116511a7388f69a5369a3ce792f4` and changes one test file only; it makes no production-code changes.
- PR #111 was created to restore the focused legacy FollowUp migration regression coverage from PR #102 on top of the current `main`, rather than merging the old branch.
- The exact PR #111 commit currently has **no combined status checks recorded**, so its CI/test result is **not yet validated** and must not be reported as green.
- The code in `lib/models/task.dart` currently migrates legacy `followUpDate` into a `FollowUp` when `followUps` is absent/empty, and preserves current `followUps` when present.
- The migration documentation explicitly requires regression tests for legacy JSON → `Task` migration before advancing the Unified Item migration.

## Current bottleneck / next gate
The immediate gate is **PR #111 validation**. Run and verify the required focused test and the applicable CI/build path against the exact PR #111 commit before any merge decision.

Do not attribute historical `94 passed / 1 failed` results from an older development slice to the current `main` or PR #111. Historical results remain historical until the exact current ref is tested.

## Migration guardrails
- `Task` in `lib/models/task.dart` remains the single shared Unified Item source of truth.
- Do not introduce a competing model/repository or second persistence path.
- Preserve the `arvin.tasks` storage key.
- Do not delete or rewrite existing user data during migration.
- Do not proceed to Reminder/Recurring UI integration until the migration gate is green.

## Parallel development rule
Arvin is intentionally optimized for **parallel + simultaneous + fast** development, with the goal of producing software in hours rather than days.

Independent lanes should proceed concurrently whenever they do not conflict with shared foundation, files or architecture. Parallel work must be controlled to avoid duplicate implementations, conflicting changes and merge conflicts. A blocked lane must not unnecessarily block independent lanes.

## Product and architecture invariants
- Clean Architecture / feature-oriented separation remains the target.
- Domain logic must remain independent of external infrastructure.
- Unified Item remains the architectural source of truth; do not introduce competing storage/model systems.
- Migration must be incremental and reversible.
- Existing capabilities must be reused rather than rebuilt.
- No direct changes to `main` for ordinary development; use branch → commit → PR → workflow → validation → review → merge.

## Product roadmap
Target capabilities include Task, Reminder, FollowUp, Jalali Calendar, Notification, Backup/Restore, Cloud/Dropbox, Google Calendar, PDF/Print, Security, Widget and Lock Screen, subject to the current architecture and roadmap documents.

The next executable slice must be selected from the nearest verified gap after PR #111 validation; do not skip the migration gate or start a duplicate implementation.

## Collaboration
ChatGPT coordinates architecture, prioritization, audits and development flow. DeepSeek may be used as an independent second reviewer for sensitive architecture, migration, storage, CI or other high-risk decisions. DeepSeek does not replace GitHub evidence or validation.

## Handoff rule
When a new conversation starts with `ادامه آروین`, first verify the live GitHub repository, read/write access, current branch/commit, open PRs, workflows and relevant documentation. Then compare those facts with established memory/decisions and inspect real code when needed. Select the nearest real unfinished task, avoid duplicate work, act where possible, validate the exact resulting ref, update relevant documentation, and report the verified result in simple management language.
