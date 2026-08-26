# Arvin Execution Experience Log

**Role:** Living evidence-based lessons for faster Arvin production.
**Authority:** Subordinate to `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md`. GitHub reality always wins.
**Update rule:** Add or revise only lessons supported by real repository/CI/PR evidence. This file must help production and must never become a documentation bottleneck.

## Permanent operating lesson
The goal is validated software in hours rather than days through coordinated parallel work, automation, tests, documentation, and controlled integration. Documentation runs beside product work; it never replaces product work.

## Hourly continuation behavior
Each hourly continuation must first inspect live GitHub state: `main`, active branches, open PRs/issues, exact-head CI, builds, and current documentation. Then it must perform the nearest safe real action rather than merely report status.

If a lane is waiting for CI, an independent low-conflict lane should progress in parallel. Shared foundations/files must not be edited concurrently without ownership/conflict review.

## Verified lessons from 2026-08-26
1. **Exact-head evidence only.** A green workflow on an old head is not a merge gate for a rebuilt PR. After `main` changes, rebuild/rebase the unchanged slice and require fresh exact-head CI.
2. **Do not restart healthy CI without value.** Once Analyze/Test are green and APK is building, avoid cosmetic commits that restart validation.
3. **Use CI wait time productively.** While Quick Capture waited on CI, an independent Automatic FollowUp core lane progressed without touching Home/Quick Capture files.
4. **Deduplicate automation output.** When parallel automation produced overlapping scorecard PRs, the duplicate PR was closed and the already-valid lane remained the single source of work.
5. **Preserve canonical storage/model paths.** Quick Capture reused `QuickCaptureService`, canonical `Task`, and `TaskMigrationWriter`; no new database/repository/storage key/parser was created.
6. **Score only earned evidence.** Progress percentages come only from `docs/progress_scorecard.json` and its validator. Core, persistence, UI, CI/APK, and final DoD are distinct stages.
7. **Post-merge validation matters.** A product slice is not promoted in the scorecard until the merged `main` build validates the integrated result.
8. **Documentation must reflect live reality.** Stale continuation/status documents must be updated when their old SHA, PR, or progress number would mislead the next session.

## Production loop
`Audit live GitHub → choose nearest real gap → separate independent lanes → implement → focused tests → documentation → exact-head CI/APK → Ready/Merge → post-merge Build → score/handoff update → next gap`

## Documentation loop
Documentation is updated in parallel when it records one of these useful facts:
- a verified architectural boundary or anti-duplication rule;
- a product acceptance/delivery contract;
- a failure/root-cause lesson that prevents recurrence;
- an exact current-state/handoff fact needed for continuation;
- progress evidence accepted by the official scorecard.

Do not create a new document when an existing current document is the correct owner. Historical documents stay historical; current references must not carry stale claims.

## Reporting contract
Hourly/user reports remain short and non-technical:
- **انجام شد:** only real completed operations.
- **وضعیت فعلی:** real active PR/Build/lane state.
- **درصد پیشرفت:** only official Scorecard metrics; for sections without an official denominator, report stage instead of inventing a percentage.
- **قدم بعد:** nearest real executable action.
- **نکته:** only a material blocker/risk/decision.

## Safety / speed guard
Never trade speed for fabricated status, skipped tests, bypassed gates, destructive migration, duplicate foundations, or conflicting parallel edits. Speed comes from less idle time and less rework.
