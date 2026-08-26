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
- `main`: `1f9585dbf8be3b269ee201337c0b011673e5c88b`
- Latest merged product PR: #183 — Automatic FollowUp due items in Follow-up Office.
- PR #183 exact head `689eccf0eb01aaf9c9bd4334f3c34958f568e0dd` passed Build #619 + Parallel Wave #437.
- Post-merge Build #621 completed successfully on exact main, including Analyze/Test/release APK/debug APK verification and uploads.
- PR #181 previously delivered the AutomaticFollowUpService core; post-merge Build #614 succeeded.
- Quick Capture real Home UI + canonical persistence from PR #178 remains validated by post-merge Build #610; Issue #174 is closed.

## Current active product lane — Timeline UI
PR #184 — `feat(timeline): add canonical task timeline page`
- Branch: `feat/issue-92-task-timeline-ui`
- Exact head: `8e925016635fe92c190ee6caeb13421b284a7121`
- Base: current main `1f9585dbf8be3b269ee201337c0b011673e5c88b`
- Reuses canonical `TaskTimelineService` + `Task + FollowUps[]`.
- Adds a Persian RTL user-facing Timeline page, chronological history rendering, FollowUp note/result display, empty state, widget tests and documentation.
- `Arvin Parallel Wave #439` is green; `Arvin Build #622` has Analyze/Test/Release APK green and is completing Debug APK validation.
- No new model/repository/storage/history source.
- The page is not yet wired into Home/task-detail navigation; do not claim Timeline Stage 70 from this slice alone.

## Automatic FollowUp remaining gap
Issue #180 remains open.
- Canonical core + due-list UI are merged and post-merge validated.
- Conservative Scorecard target is stage 70, not 85/100.
- Missing product behavior: actual background scheduling/notification trigger, reschedule/cancel behavior and reboot/restart validation.
- Existing foundations must be reused: `android_alarm_manager_plus`, `flutter_local_notifications`, `AndroidBackupScheduler`, `BackupNotificationService`.
- Do not introduce duplicate scheduler/notification packages, storage or models.

## Current documentation/experience lane
PR #182 — `docs(operations): persist live Arvin execution experience loop`
- Branch: `docs/arvin-live-experience-loop`
- Documentation-only; must not block product work.
- Adds `ARVIN_EXECUTION_EXPERIENCE_LOG.md`, strengthens continuation/hourly behavior, refreshes current state/status/handoff and updates the official Scorecard candidate.
- A previous docs head was green but became factually stale as product `main` moved; the refreshed head must pass fresh exact-head Build/Parallel/Progress Score before merge.

## Official Progress
Use only `docs/progress_scorecard.json` + `Arvin Progress Score`.
- Official score currently committed on `main`: **12.1% overall Roadmap / 28.7% Wave X1**.
- Refreshed PR #182 candidate after verified Quick Capture and Automatic FollowUp evidence: **18.2% overall / 43.1% Wave X1**.
- Candidate values are not official until `Arvin Progress Score` accepts the exact refreshed docs head and PR #182 merges.

Feature stages in the refreshed candidate:
- Waiting for Response: 85
- Quick Capture: 85
- Automatic FollowUp: 70 (capped because background Reminder/scheduler/notification trigger is still missing)
- Next Action: 40
- Timeline: 40 until real navigation integration is delivered
- Semantic Search: 25

Historical estimates in older documents are not current truth.

## Product/Foundation Invariants
- Arvin is Persian RTL Flutter.
- Unified Item/Task is the shared product foundation.
- FollowUp history stays on canonical `Task.followUps`.
- Home persistence continues through the existing canonical/migration path; do not create another Task storage.
- Reminder, Calendar, Notification, Search, Backup/Restore and other existing foundations must be audited/reused before extension.
- No parallel Model/Repository/Storage/Parser/Sync/Router/AppShell/Scheduler/Notification foundation without explicit verified need.

## Parallel Delivery
Independent lanes run concurrently. A lane waiting for CI must not stop unrelated work. Shared foundation/file ownership must be checked before concurrent edits. Do not restart healthy APK validation with cosmetic commits.

## Validation
`Implementation → Focused Test → Documentation → exact-head CI/Build/APK → Ready/Merge → post-merge main Build → Score/Handoff Update`.
A workflow result is valid only for the exact ref it tested.

## Experience Continuity
Useful evidence-based lessons that prevent rework live in `docs/ARVIN_EXECUTION_EXPERIENCE_LOG.md`. It is subordinate to the canonical operating package and must help production rather than become a documentation gate. A documentation PR also requires a final live-GitHub freshness check before merge; green CI alone does not make stale status facts correct.

## Communication
Reports stay short and non-technical:
- انجام شد
- وضعیت فعلی
- درصد پیشرفت (official Scorecard only)
- قدم بعد
- نکته

## Continuation
`ادامه` and the hourly Automation mean: audit live GitHub and perform the nearest real safe production action. Status-only repetition is not continuation when executable work exists.
