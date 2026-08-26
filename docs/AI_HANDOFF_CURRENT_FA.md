# Arvin-clean — Live AI Handoff

Last verified: 2026-08-26

## Primary Rule
The single active operating authority is `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md`. This file is a compact handoff aid, not a competing governance document. GitHub reality overrides stale documentation.

## Start Here
1. Verify live GitHub access and current `main`.
2. Check open PRs/issues and exact-head CI/Build state.
3. Read `docs/AI_CONTINUATION_STATE.md` and `docs/ARVIN_EXECUTION_EXPERIENCE_LOG.md` when relevant.
4. Read `docs/progress_scorecard.json` for official extension progress.
5. Inspect real implementation before changing a foundation.
6. Continue the nearest real unfinished task; do not restart completed work.

## Current verified main
- `main`: `ae3a34257fdee45623f2094aca6a1432a58a2d0b`
- Latest merged product PR: #178 Quick Capture UI + canonical persistence.
- PR #178 exact head `816434cd8d767c35d931397f333de74759a0ddeb` passed Build #608 + Parallel Wave #428.
- Post-merge Build #610 on exact main completed successfully, including Analyze/Test/release APK/debug APK verification.

## Current active product lane
PR #181 — Automatic FollowUp core
- Issue #180
- Branch: `feat/issue-180-automatic-followup-core`
- Exact head: `ed764fed8430ef4cb5a8bfd80ed452fbaccebb92`
- Fresh Build #611 + Parallel Wave #430 run against that exact head.
- Scope is pure due-candidate derivation from canonical `Task.followUps`; no new model/repository/storage/scheduler/UI.
- Keep Draft until both exact-head gates are fully green; after merge require post-merge main Build before score promotion.

## Current documentation/experience lane
PR #182 — `docs(operations): persist live Arvin execution experience loop`
- Branch: `docs/arvin-live-experience-loop`
- Documentation-only; must not block product work.
- Records real execution lessons, updates hourly/continuation behavior, refreshes current state/status and removes stale progress claims.

## Product/Foundation Invariants
- Arvin is Persian RTL Flutter.
- Unified Item/Task is the shared product foundation.
- FollowUp history stays on canonical `Task.followUps`.
- Home persistence continues through the existing canonical/migration path; do not create another Task storage.
- Reminder, Calendar, Notification, Search, Backup/Restore and other existing foundations must be audited/reused before extension.
- No parallel Model/Repository/Storage/Parser/Sync/Router/AppShell/Foundation without explicit verified need.

## Parallel Delivery
Independent lanes run concurrently. A lane waiting for CI must not stop unrelated work. Shared foundation/file ownership must be checked before concurrent edits. Do not restart healthy APK validation with cosmetic commits.

## Validation
`Implementation → Focused Test → Documentation → exact-head CI/Build/APK → Ready/Merge → post-merge main Build → Score/Handoff Update`.
A workflow result is valid only for the exact ref it tested.

## Official Progress
Use only `docs/progress_scorecard.json` + `Arvin Progress Score`. Historical estimates in older docs are not current truth. Feature stages are 0/10/25/40/55/70/85/100; do not invent per-feature percentages outside the Scorecard model.

Quick Capture has now earned the technical/post-merge evidence required for final roadmap closure; the current documentation lane updates the required `PROJECT_STATUS.md` and this handoff so the Scorecard can promote it to stage 100 after Issue closure and validator approval.

## Experience Continuity
Useful evidence-based lessons that prevent rework live in `docs/ARVIN_EXECUTION_EXPERIENCE_LOG.md`. It is subordinate to the canonical operating package and must help production rather than become a documentation gate.

## Communication
Reports stay short and non-technical:
- انجام شد
- وضعیت فعلی
- درصد پیشرفت (official Scorecard only)
- قدم بعد
- نکته

## Continuation
`ادامه` and the hourly Automation mean: audit live GitHub and perform the nearest real safe production action. Status-only repetition is not continuation when executable work exists.
