# Arvin — Project Status

Last verified: 2026-08-26

## مرجع و منبع حقیقت
- Repository: `mobinpda-lab/Arvin-clean`
- Canonical operating reference: `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md`
- Reality authority: live GitHub code / PR / exact-ref CI.
- Official extension progress: `docs/progress_scorecard.json` + `Arvin Progress Score` workflow.
- Living execution lessons: `docs/ARVIN_EXECUTION_EXPERIENCE_LOG.md` (subordinate to the canonical operating package).

## وضعیت فعلی main
- Verified main SHA after Quick Capture merge: `ae3a34257fdee45623f2094aca6a1432a58a2d0b`.
- PR #178 `feat(quick-capture): wire real Home capture and canonical persistence` is merged.
- Exact PR head `816434cd8d767c35d931397f333de74759a0ddeb` passed `Arvin Build #608` and `Arvin Parallel Wave #428`.
- Post-merge `Arvin Build #610` on exact main `ae3a34257fdee45623f2094aca6a1432a58a2d0b` completed successfully, including Analyze, Test, release APK, debug APK and verification/upload steps.

## قابلیت‌های Extension با شواهد رسمی
- **Waiting for Response (#10): stage 85** — canonical contract + real FollowUp UI/filter + regression + exact-head CI/APK + post-merge validation are complete; final roadmap handoff/closure remains for 100.
- **Quick Capture (#11): delivery complete** — canonical parser, Persian RTL Home entry, canonical persistence, focused/widget integration tests, exact-head CI/APK, post-merge main validation and delivery documentation are complete. Current-state/handoff documentation is being refreshed in the documentation lane so the official Scorecard may close it at stage 100.
- **Next Action (#1): stage 40** — core service/tests; no final real UI yet.
- **Timeline (#3): stage 40** — canonical projection/tests; full Timeline UI/history coverage remains.
- **Semantic Search (#7): stage 25** — SearchService foundation strengthened; semantic behavior itself remains incomplete.

## مسیرهای فعال موازی
### Product lane — Automatic FollowUp
- Issue #180
- PR #181 (Draft)
- Branch: `feat/issue-180-automatic-followup-core`
- Exact head: `ed764fed8430ef4cb5a8bfd80ed452fbaccebb92`
- Base: Quick Capture main `ae3a34257fdee45623f2094aca6a1432a58a2d0b`
- Scope: pure due-candidate projection on canonical `Task.followUps`; focused tests and documentation; no new model/repository/storage/scheduler/UI.
- Fresh `Arvin Build #611` + `Arvin Parallel Wave #430` validate this exact head. Quality/Analyze/Test/surface checks are green; final APK gates must be complete before Ready/Merge.

### Documentation/experience lane
- PR #182 (Draft)
- Branch: `docs/arvin-live-experience-loop`
- Documentation-only and independent from product code.
- Adds live execution experience lessons, strengthens continuation/hourly rules, refreshes current state/handoff and removes stale progress claims.
- This lane must not block Product lanes.

## معماری و ضد دوباره‌کاری
- Persian RTL Flutter application.
- Unified Item/Task is the shared product foundation.
- `Task.followUps` is the canonical FollowUp history path.
- `arvin.tasks` / existing migration boundaries remain the Home persistence path unless an approved migration changes it.
- No duplicate Model, Repository, Storage, Parser, Scheduler, Search engine, Calendar foundation or Workflow without a verified gap and explicit architectural reason.
- Existing capability must be audited before building a new capability.

## مدل اجرای سریع
`Audit live GitHub → separate independent lanes → implement → focused test → documentation → exact-head CI/APK → Ready/Merge → post-merge Build → Score/Handoff update → next real gap`

When a lane waits for CI, unrelated low-conflict product/documentation work proceeds in parallel. Healthy APK validation must not be restarted by cosmetic or low-value commits.

## Definition of Done برای Extensionها
A roadmap extension is Done only when applicable requirements, shared architecture compatibility, domain/application, persistence, real UI, RTL/Jalali/font requirements, regression/E2E tests, exact-head CI, APK validation, post-merge validation, `PROJECT_STATUS.md`, `AI_HANDOFF_CURRENT_FA.md` and feature Issue closure are complete.

## درصد رسمی
Do not use historical estimated percentages from older status documents. The only current extension percentage is the value committed in `docs/progress_scorecard.json` and accepted by `Arvin Progress Score`. Any new percentage is reported only after the corresponding Scorecard change is validated and merged.

## قدم بعد اجرایی
1. Close Quick Capture delivery/handoff and validate its Scorecard promotion.
2. Finish fresh exact-head CI for PR #181; if both gates are green, Ready + Merge + post-merge main Build.
3. Continue FollowUp automatic integration only by reusing existing Reminder/Calendar/notification foundations after a live audit; no parallel storage/model is allowed.
4. Keep experience/current-state documentation synchronized in a separate low-conflict lane.
