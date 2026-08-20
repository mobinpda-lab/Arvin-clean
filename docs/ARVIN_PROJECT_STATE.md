# Arvin — Canonical Project State

**Updated:** 2026-08-20
**Repository:** mobinpda-lab/Arvin-clean
**Default branch:** `main`
**Current development branch:** `wave-a/core-storage-boundary-v1`

## Source of truth
- GitHub repository state is the source of truth for executable status: code, branches, commits, PRs, workflows, tests, builds and merges.
- Project documentation defines architecture, governance, roadmap and decisions.
- Conversation/memory is continuity context, not a substitute for current GitHub evidence.
- If these sources disagree, identify the gap, verify the repository/code, then update the relevant documentation.

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

Historical documents are not to be silently rewritten merely to make history look current. Current state belongs in the canonical state/handoff documents and dated audit/changelog documents.

## Current verified development state
- PR #107: **MERGED**. Merge commit: `771f1e1776742bbca3e0d1c1110bec9b4adefa54`.
- Wave A / Core + Architecture: **active**.
- PR #108: **OPEN** — `refactor(core): introduce task storage boundary`.
- PR #108 branch: `wave-a/core-storage-boundary-v1`.
- Latest documented corrective test commit: `1a83de14b222abcaf4bf53aa50ccd5fd56a51331`.
- The latest reported `flutter test` result is **94 passed / 1 failed** in `test/widget_test.dart`, test `HomePage loads legacy storage through the unified reader`.
- That failing assertion concerns the legacy/Home date display expectation and must be validated against the current code/test contract before further edits.
- `flutter analyze` was previously observed passing on the earlier validation run; the latest commit must still receive its own real CI validation.
- A workflow result must never be attributed to a newer commit unless GitHub shows that exact commit/ref was tested.

## Current bottleneck
The immediate bottleneck is PR #108 validation. Do not merge until the current commit has a real successful validation covering the required test/analyze/build path.

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

## Collaboration
ChatGPT coordinates architecture, prioritization, audits and development flow. DeepSeek may be used as an independent second reviewer for sensitive architecture, migration, storage, CI or other high-risk decisions. DeepSeek does not replace GitHub evidence or validation.

## Handoff rule
When a new conversation starts with `ادامه آروین`, first verify the live GitHub repository, read/write access, current branch/commit, open PRs, workflows and relevant documentation. Then select the nearest real unfinished task, avoid duplicate work, act where possible, and report the verified result.
