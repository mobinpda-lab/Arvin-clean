# Arvin — Project Status

Last verified: 2026-08-26

## مرجع و منبع حقیقت
- Repository: `mobinpda-lab/Arvin-clean`
- Canonical operating reference: `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md`
- Reality authority: live GitHub code / PR / exact-ref CI.
- Official extension progress: `docs/progress_scorecard.json` + `Arvin Progress Score` workflow.
- Living execution lessons: `docs/ARVIN_EXECUTION_EXPERIENCE_LOG.md` (subordinate to the canonical operating package).

## وضعیت فعلی main
- Verified main SHA: `1f9585dbf8be3b269ee201337c0b011673e5c88b`.
- Latest merged product PR: #183 `feat(followup): surface automatic due items in Follow-up Office`.
- Exact PR head `689eccf0eb01aaf9c9bd4334f3c34958f568e0dd` passed `Arvin Build #619` + `Arvin Parallel Wave #437`.
- Post-merge `Arvin Build #621` completed successfully on exact main `1f9585dbf8be3b269ee201337c0b011673e5c88b`, including Analyze, Test, release/debug APK, verification and artifact uploads.
- Previous PR #181 delivered AutomaticFollowUpService core; post-merge Build #614 succeeded.
- Quick Capture real Home UI/persistence remains merged from PR #178; post-merge Build #610 succeeded and Issue #174 is closed.

## قابلیت‌های Extension با شواهد رسمی/کاندید معتبر
- **Waiting for Response (#10): stage 85** — canonical contract + real FollowUp UI/filter + regression + exact-head CI/APK + post-merge validation are complete; final roadmap DoD remains for 100.
- **Quick Capture (#11): candidate stage 85 in this documentation/Scorecard PR** — parser/core, Persian RTL Home entry, canonical persistence, tests, exact-head CI/APK and post-merge Build #610 are complete. It remains below 100 because the roadmap final global font/typography DoD is not yet satisfied.
- **Automatic FollowUp (#2): candidate stage 70** — canonical latest-history due logic, existing persistence path, real Follow-up Office due filter, regression tests, exact-head Build #619/Parallel #437 and post-merge Build #621 are complete. It is deliberately capped at 70 because actual background Reminder/scheduler/notification triggering is still missing.
- **Next Action (#1): stage 40** — core service/tests; no final real UI yet.
- **Timeline (#3): current official stage 40** — canonical projection/tests are merged. PR #184 is adding a reusable real Timeline page, but Home/task-detail entry is not yet merged and no Stage 70 credit is claimed.
- **Semantic Search (#7): stage 25** — SearchService foundation strengthened; semantic behavior itself remains incomplete.

## درصد پیشرفت
- Official percentage on current `main` remains **12.1% overall / 28.7% Wave X1** until the refreshed Scorecard PR merges.
- This documentation lane now proposes the evidence-backed Scorecard values **18.2% overall / 43.1% Wave X1** (Quick Capture 85 + Automatic FollowUp 70). These values are not official until `Arvin Progress Score` validates the exact docs head and PR #182 merges.
- Historical estimates such as 33% or 61% are not current project progress.

## مسیرهای فعال موازی
### Product lane — Timeline UI
- PR #184 (Draft)
- Branch: `feat/issue-92-task-timeline-ui`
- Exact head: `8e925016635fe92c190ee6caeb13421b284a7121`
- Base: current main `1f9585dbf8be3b269ee201337c0b011673e5c88b`
- Scope: Persian RTL `TaskTimelinePage` over existing `TaskTimelineService`, chronological rendering, FollowUp note/result display, empty state, widget tests and docs.
- `Arvin Parallel Wave #439` is green; `Arvin Build #622` has Analyze/Test/Release APK green and is completing Debug APK validation.
- No new model/repository/storage/history source.

### Product lane — Automatic FollowUp next gap
- Issue #180 remains open.
- Existing delivered UI only surfaces due items; it does not yet trigger them automatically in background.
- Existing reusable platform foundations are already present: `android_alarm_manager_plus`, `flutter_local_notifications`, `AndroidBackupScheduler`, `BackupNotificationService`.
- Next slice must reuse/audit these foundations rather than add duplicate scheduling/notification packages or storage.

### Documentation/experience lane
- PR #182 (Draft)
- Branch: `docs/arvin-live-experience-loop`
- Documentation-only and independent from product code.
- Adds a living execution experience log, refreshes continuation/hourly rules and current-state/handoff/status, and validates conservative official progress.
- A prior head was green but became factually stale as product `main` moved; this refreshed head requires fresh Build/Parallel/Progress Score before merge.

## معماری و ضد دوباره‌کاری
- Persian RTL Flutter application.
- Unified Item/Task is the shared product foundation.
- `Task.followUps` is the canonical FollowUp history path.
- `arvin.tasks` / existing migration boundaries remain the Home persistence path unless an approved migration changes it.
- No duplicate Model, Repository, Storage, Parser, Scheduler, Notification package, Search engine, Calendar foundation or Workflow without a verified gap and explicit architectural reason.
- Existing capability must be audited before building a new capability.

## مدل اجرای سریع
`Audit live GitHub → separate independent lanes → implement → focused test → documentation → exact-head CI/APK → Ready/Merge → post-merge Build → Score/Handoff update → next real gap`

When a lane waits for CI, unrelated low-conflict product/documentation work proceeds in parallel. Healthy APK validation must not be restarted by cosmetic or low-value commits.

## Definition of Done برای Extensionها
A roadmap extension is Done only when applicable requirements, shared architecture compatibility, domain/application, persistence, real UI, RTL/Jalali/font requirements, regression/E2E tests, exact-head CI, APK validation, post-merge validation, `PROJECT_STATUS.md`, `AI_HANDOFF_CURRENT_FA.md` and feature closure are complete.

## قدم بعد اجرایی
1. Finish Build #622 for Timeline PR #184; merge only if both exact-head gates are green.
2. Keep Timeline score conservative until a real Home/task-detail navigation entry is merged and post-merge validated.
3. Validate PR #182 refreshed Scorecard with `Arvin Progress Score` and normal Build/Parallel; merge only after a final freshness check against live GitHub.
4. Start Automatic FollowUp background/notification work only by reusing existing AlarmManager/local-notification foundations; no parallel storage/model/package is allowed.
