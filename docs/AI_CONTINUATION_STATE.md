# Arvin AI Continuation State

Last updated: 2026-08-26

## Source of truth
GitHub Reality > approved architecture decisions > `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` > exact-ref CI/workflow evidence > official `docs/progress_scorecard.json` > chat memory.

## Current main
Current verified `main`: `1f9585dbf8be3b269ee201337c0b011673e5c88b`

Latest merged product PR: #183 — `feat(followup): surface automatic due items in Follow-up Office`
- Tested PR head: `689eccf0eb01aaf9c9bd4334f3c34958f568e0dd`
- `Arvin Build #619`: completed / success
- `Arvin Parallel Wave #437`: completed / success
- Merge commit: `1f9585dbf8be3b269ee201337c0b011673e5c88b`
- Post-merge `Arvin Build #621`: currently running on that exact main commit; Analyze and Test are green and APK validation is in progress.
- Do not promote Automatic FollowUp in the official Scorecard until Build #621 completes successfully and the feature stage is reconciled with its still-missing background scheduler/notification boundary.

Previous merged product foundations:
- PR #178 delivered real Quick Capture Home UI + canonical persistence; post-merge Build #610 succeeded.
- PR #181 merged AutomaticFollowUpService core; post-merge Build #614 succeeded.
- PR #172 delivered Waiting for Response UI; post-merge Build #596 succeeded.

## Official progress
The official Scorecard on current `main` remains **12.1% overall Roadmap / 28.7% Wave X1** until a new validated Scorecard change is merged.

The documentation lane contains a candidate Quick Capture promotion to stage 85 based on PR #178 + Build #610, but that candidate is not official until the refreshed documentation/Scorecard PR passes its own validator and merges. Automatic FollowUp score promotion remains pending post-merge Build #621 and feature-boundary review.

Do not use older historical estimates such as 33% or 61% as current project progress.

## Active product lane — Timeline UI
PR #184 — `feat(timeline): add canonical task timeline page`
- Branch: `feat/issue-92-task-timeline-ui`
- Current exact head: `8e925016635fe92c190ee6caeb13421b284a7121`
- Base: current main `1f9585dbf8be3b269ee201337c0b011673e5c88b`
- Reuses existing `TaskTimelineService` and canonical `Task + FollowUps[]`.
- Adds Persian RTL Timeline page, chronological event rendering, note/result display, empty state, widget tests, and documentation.
- No new model/repository/storage/history source.
- Fresh `Arvin Build #622` + `Arvin Parallel Wave #439` are running on the exact head. Analyze/Test/independent surfaces are green; APK validation is in progress.
- This page is not yet wired into Home/task-detail navigation, so Stage 70 must not be claimed from this slice alone.

## Active documentation/experience lane
PR #182 — `docs(operations): persist live Arvin execution experience loop`
- Branch: `docs/arvin-live-experience-loop`
- Adds `docs/ARVIN_EXECUTION_EXPERIENCE_LOG.md` as evidence-based practical learning subordinate to the canonical operating package.
- Updates the continuation command and current-state/handoff/status references.
- A previous exact head had green Build/Parallel/Progress Score, but product main advanced afterward; therefore the documentation lane is being refreshed and must receive fresh exact-head validation before merge.
- Product work must continue independently while documentation validates.

## Next actions
1. Finish post-merge Build #621 for Automatic FollowUp due-list integration.
2. If #621 succeeds, update Issue #180 and the official Scorecard only to the stage actually earned; do not treat missing scheduler/notification as complete automatic behavior.
3. Finish exact-head Build #622 + Parallel Wave #439 for Timeline PR #184. If both are green, merge the reusable page or continue with a separate Home navigation slice without invalidating already-healthy APK work.
4. Refresh PR #182 Scorecard/Handoff/Project Status from the final verified main state, then require fresh Build/Parallel/Progress Score before merge.
5. Audit the existing `android_alarm_manager_plus` and `flutter_local_notifications` foundations before any Automatic FollowUp background/notification slice; reuse existing platform foundations and do not add duplicate packages/services.

## Non-negotiable architecture rules
- Flutter, Persian, RTL.
- `arvin.tasks` remains the main Home data path unless an approved migration explicitly changes it.
- Task, Reminder and FollowUp converge on the shared Unified Item/Task foundation.
- Do not create parallel Model, Repository, Storage, Sync Engine, Router, AppShell, parser, scheduler, notification foundation, or UI foundation when an existing one can be extended.
- Existing Search, Calendar, Backup, Reminder/FollowUp, Notification and Notebook capabilities must be audited before rebuilding.
- CI evidence is valid only for the exact SHA it tested.
- Preserve lossless migration/write boundaries and user data.

## Continuation protocol
`ادامه` and the hourly Automation mean: re-check GitHub first, read the canonical package/current state/experience log as relevant, then perform the nearest real safe action. Status-only repetition is not continuation when executable work exists.

## Speed rule
Development stays parallel, coordinated and fast. Speed comes from independent lanes, small mergeable slices, reuse of existing foundations, exact-head automation, using CI wait time productively, deduplicating automation output, and avoiding rework—not from skipping tests, APK builds, review, documentation or evidence.

## Progress rule
The only current numeric project progress is the official Scorecard on `main`. Until a validated Scorecard change is merged, the current figures remain **12.1% overall / 28.7% Wave X1**. Feature-specific stages must use the allowed Scorecard stages rather than subjective percentages.
