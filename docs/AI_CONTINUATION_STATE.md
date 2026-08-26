# Arvin AI Continuation State

Last updated: 2026-08-26

## Source of truth
GitHub Reality > approved architecture decisions > `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` > exact-ref CI/workflow evidence > official `docs/progress_scorecard.json` > chat memory.

## Current main
Current verified `main`: `ae3a34257fdee45623f2094aca6a1432a58a2d0b`

Latest merged product PR: #178 — `feat(quick-capture): wire real Home capture and canonical persistence`
- Tested PR head: `816434cd8d767c35d931397f333de74759a0ddeb`
- `Arvin Build #608`: completed / success
- `Arvin Parallel Wave #428`: completed / success
- Merge commit: `ae3a34257fdee45623f2094aca6a1432a58a2d0b`
- Post-merge `Arvin Build #610`: currently running on that exact main commit; Analyze and Test are green, APK validation is in progress.
- Scorecard promotion for Quick Capture must wait for successful post-merge Build #610.

Previous verified progress update:
- PR #177 promoted Waiting for Response to stage 85 after merged UI + exact-head CI/APK + post-merge validation.
- Current official scorecard on main: **12.1% overall Roadmap / 28.7% Wave X1**.
- Do not use older historical progress estimates such as 33% or 61% as current project progress.

## Active parallel product lane
PR #181 — `feat(followup): derive automatic due candidates from canonical history`
- Issue: #180
- Branch: `feat/issue-180-automatic-followup-core`
- Current exact head: `ed764fed8430ef4cb5a8bfd80ed452fbaccebb92`
- Base: current Quick Capture main `ae3a34257fdee45623f2094aca6a1432a58a2d0b`
- Scope: pure AutomaticFollowUpService + focused tests + documentation; no new model/repository/storage/scheduler/UI.
- Fresh `Arvin Build #611` and `Arvin Parallel Wave #430` are running on this exact head.
- Analyze/Test/quality and independent surfaces are green; APK validation is still running.
- Keep Draft until both exact-head gates are fully green.

## Active documentation/experience lane
Branch: `docs/arvin-live-experience-loop`
- Adds `docs/ARVIN_EXECUTION_EXPERIENCE_LOG.md` as a living evidence-based lesson log subordinate to the canonical operating package.
- Updates `docs/ARVIN_CONTINUATION_COMMAND.md` so hourly continuation performs real production, parallelizes independent work, uses the official Scorecard, and documents useful experience without becoming a bottleneck.
- Refreshes this current-state document to remove stale SHA/PR/progress claims.
- This documentation lane is independent from product files and must not delay product merges.

## Next actions
1. Finish post-merge Build #610 for Quick Capture.
2. If #610 succeeds, update the official Scorecard for Quick Capture only to the evidence-backed stage; then run/verify `Arvin Progress Score` before any percentage claim changes.
3. Finish exact-head Build #611 + Parallel Wave #430 for PR #181; if both are green, mark Ready, merge exact head, then require post-merge main Build before score promotion.
4. Continue an independent low-conflict lane while CI runs only when it does not restart healthy validation or overlap shared foundations.
5. Merge the documentation/experience lane through normal CI/PR flow after its exact-head validation, without blocking product work.

## Non-negotiable architecture rules
- Flutter, Persian, RTL.
- `arvin.tasks` remains the main Home data path unless an approved migration explicitly changes it.
- Task, Note, Reminder and FollowUp converge on the shared Unified Item/Task foundation.
- Do not create parallel Model, Repository, Storage, Sync Engine, Router, AppShell, parser, or UI foundation when an existing one can be extended.
- Existing Search, Calendar, Backup, Reminder/FollowUp and Notebook capabilities must be audited before rebuilding.
- CI evidence is valid only for the exact SHA it tested.
- Preserve lossless migration/write boundaries and user data.

## Continuation protocol
`ادامه` and the hourly Automation mean: re-check GitHub first, read the canonical package/current state/experience log as relevant, then perform the nearest real safe action. Status-only repetition is not continuation when executable work exists.

## Speed rule
Development stays parallel, coordinated and fast. Speed comes from independent lanes, small mergeable slices, reuse of existing foundations, exact-head automation, using CI wait time productively, and avoiding duplicate work—not from skipping tests, APK builds, review, documentation or evidence.

## Progress rule
The only current numeric project progress is the official Scorecard. Until a validated Scorecard change is merged, the current figures remain **12.1% overall / 28.7% Wave X1**. Feature-specific stages must use the allowed Scorecard stages rather than subjective percentages.
