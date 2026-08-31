# Arvin-clean — Live AI Handoff

## Primary Rule

GitHub تنها Source of Truth عملیاتی است. این فایل فقط checkpoint فشرده برای ادامه سریع است؛ هر اجرای جدید باید قبل از اقدام، `main`، PRها، Issueها و exact-head CI را تازه بخواند.

## Live Checkpoint — 2026-08-31

Current `main`:

`a9078ee58263b7d8fa8cf862305467992e178575`

آخرین Merge تأییدشده: PR #601 — AI Worker reliability hardening.

Mergeهای مهم همین موج:
- #573 — deterministic Production feedback loop
- #574 — GitHub-native fallback برای AI Code Worker
- #575 — Jalali Calendar date jump
- #579 — AI patch validation + provider timeout/budget hardening
- #582 — Backup restore confirmation safety
- #592 — Calendar integration settings UI
- #598 — Android Calendar Provider discovery
- #601 — Worker single-launch authority + safe patch recount reliability

## Active Parallel Lanes

### 1. Calendar provider selection — PR #602 / Issue #597

- PR #602: open / Draft / mergeable
- historical head: `1b28ab5fa2e6efa4da56c584fac7fa1445a67f1e`
- Fast/Parallel run `33396542638`: ✅ complete success on that historical exact head
- quality/analyze/test + calendar/typography/backup/followup/guide/release surfaces all green
- implementation uses existing `SystemCalendarBridge` + existing `CalendarIntegrationSettings` / `AppSettingsService`
- provider permission/listing starts only after explicit user action; opening page does not perform platform permission access or settings mutation
- target calendar + visible calendar IDs are persisted through canonical settings
- Google/Samsung/other calendars remain one Android Calendar Provider path; no vendor-specific engine
- no WRITE_CALENDAR, direct event read/write/delete, recurrence sync or background sync in this slice
- PR #602 base predates merged #601, so historical Fast evidence is not sufficient for promotion
- current-main replay branch `feat/calendar-provider-selection-settings-v2` is now 3 commits ahead of `main` and 0 behind
- live compare shows exactly three replayed paths: `lib/calendar_integration_settings_page.dart`, `test/calendar_integration_settings_page_test.dart`, `docs/CALENDAR_PROVIDER_SELECTION_SETTINGS_2026-08-31.md`
- current-main replay still needs a fresh PR/exact-head Fast before any Ready → Heavy/Device promotion

### 2. Duplicate/superseded cleanup

- PR #599 overlaps merged provider-discovery #598; do not spend Heavy/Device or merge budget unless live diff proves a non-duplicate gap.
- PR #600 is superseded by merged #601; it is historical evidence only and must not be promoted again.
- Issues #588 and #590 are completed/closed by #601. Issue #595 is completed/closed by #598.

### 3. Live Progress Score — #578 / #583

- reuse existing `tool/progress_score.py` and canonical scorecards
- no second score source
- exact-main SHA and PASS/FAIL/BLOCKED evidence required
- stale evidence must never increase score
- do not manually invent/update percentages

## Calendar Reality

Provider discovery foundation is on `main` through #598:
- READ_CALENDAR only
- permission status/request
- Android CalendarContract calendar/provider enumeration
- typed provider metadata in existing bridge
- no WRITE_CALENDAR
- no direct event read/write/delete sync

PR #602 has Fast-proven provider-selection UI/persistence behavior on a historical base. The current-main replay is now materialized as the same bounded three-file slice on `feat/calendar-provider-selection-settings-v2`, but it has not yet received fresh current-main PR/CI evidence. #516/#348 still own the larger bidirectional integration work after selection: event projection/read/write policy, sync execution/idempotency, delete/recurrence behavior and related safety gates.

## Automation Reality

PR #601 is merged to current `main`:
- normal AI Worker launch is `workflow_dispatch`-only
- ARVIN Orchestrator is canonical launch authority
- Production Loop keeps explicit dispatch for GITHUB_TOKEN-created Auto-Fix issues
- concurrency is issue-input keyed
- Git native `--recount` is used after structural validation; malformed/context-invalid patch still fails closed

Validation evidence for #601:
- exact-head Fast/Parallel ✅
- Build run `33395334403`: quality + debug APK + release APK ✅
- Device run `33395336405`: Home + People smoke ✅
- latest observed Production Loop on current main: run `33405071453` ✅ success

## Production / Merge Contract

- Production Orchestrator remains canonical promotion/merge authority.
- Worker/Production Loop cannot merge or bypass gates.
- Draft → exact-head Fast/Parallel.
- Ready → Heavy Build/APK + Device on same head/current-main ancestry.
- merge serially; independent development lanes may run in parallel.
- if `main` moves, affected lane must reconcile/rebuild; do not force merge stale work.
- do not restart/cancel healthy workflows merely to accelerate another lane.
- duplicate/superseded lanes must not receive duplicate Heavy/merge work.

## Core / Data / Backup Safety

- preserve existing Task / Reminder / FollowUp / History foundations.
- no duplicate TaskStore, Settings store, Calendar engine, scheduler, report path or Backup repository.
- #601 changed automation/test/docs boundaries, not product model/store data.
- Restore mutation remains behind successful read/validation and explicit confirmation before destructive replacement; no newer verified Backup change after #582 was found in this checkpoint.
- Calendar integration remains provider-neutral Android Calendar Provider based; no independent Google/Samsung engine.
- no open Issue with exact `release-blocker` label was found at this checkpoint, but RC readiness still depends on unresolved operational/product lanes and exact-head evidence.

## Continuation Priority

1. Open/reconcile the current-main provider-selection replay from `feat/calendar-provider-selection-settings-v2` without modifying its bounded three-file scope.
2. Run fresh exact-head Fast on that current-main replay; only then Ready → Heavy Build/APK + Device → guarded serial merge.
3. Reconcile/supersede #599 and #600 so duplicate historical Drafts cannot consume validation/merge budget.
4. Continue #516/#348 only from canonical merged provider/settings foundations and after provider selection is production-current.
5. Continue #578/#583 only by extending the existing canonical score tool.
6. Keep documentation in this existing separate Draft lane; update it only on meaningful GitHub changes and never use docs commits to interrupt healthy Product/Automation validation.

## Continuation Trigger

`Fresh GitHub audit → parallel independent implementation → exact-head Fast → serial Ready/Heavy → guarded merge → post-merge re-audit → reconcile docs → next smallest real gap`

Repository reality always overrides conversation memory and this checkpoint.