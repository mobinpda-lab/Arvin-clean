# Arvin-clean — Live AI Handoff

## Primary Rule

GitHub تنها Source of Truth عملیاتی است. این فایل فقط checkpoint فشرده برای ادامه سریع است؛ هر اجرای جدید باید قبل از اقدام، `main`، PRها، Issueها و exact-head CI را تازه بخواند.

## Live Checkpoint — 2026-08-31

Current `main`:

`377da2dfe0a5de6b998e2cfa520d13972918b4a9`

آخرین Merge تأییدشده: PR #582 — confirmation ایمن قبل از replace کردن داده فعلی در Restore.

Mergeهای مهم همین موج:
- #573 — deterministic Production feedback loop
- #574 — GitHub-native fallback برای AI Code Worker
- #575 — Jalali Calendar date jump
- #579 — AI patch validation + provider timeout/budget hardening
- #582 — Backup restore confirmation safety

## Active Parallel Lanes

### 1. Calendar Settings UI — PR #592

- Draft
- head: `7c75439189221be5d631b7a21866bde82a435e9b`
- Fast/Parallel Wave #1282: ✅
- Build/Device: skipped while Draft, as designed
- reuse: `CalendarIntegrationSettings` + `AppSettingsService`
- provider discovery/read/write هنوز در این slice نیست
- owner issue: #584; umbrella: #516

### 2. AI Worker reliability — PR #593

- Draft
- head: `76aa045af3450fbe3b7855c39d204af1a8babf05`
- Fast/Parallel Wave #1283: ✅
- Build/Device: skipped while Draft, as designed
- single normal launch authority = Orchestrator explicit dispatch
- Worker becomes workflow_dispatch-only
- Git native `--recount` after structural validation for numeric hunk-count recovery
- malformed/context-invalid patch remains fail-closed
- supersedes closed #589 + #591
- owner issues: #588 + #590

### 3. Live Progress Score — #578 / #583

- reuse existing `tool/progress_score.py` and canonical scorecards
- no second score source
- exact-main SHA and PASS/FAIL/BLOCKED evidence required
- stale evidence must never increase score
- do not manually invent/update percentages

## Production / Merge Contract

- Production Orchestrator remains canonical promotion/merge authority.
- Worker/Production Loop cannot merge or bypass gates.
- Draft → exact-head Fast/Parallel.
- Ready → Heavy Build/APK + Device on same head/current-main ancestry.
- merge serially; independent development lanes may run in parallel.
- if `main` moves, affected lane must reconcile/rebuild; do not force merge stale work.
- do not restart/cancel healthy workflows merely to accelerate another lane.

## Core / Data Safety

- preserve existing Task / Reminder / FollowUp / History foundations.
- no duplicate TaskStore, Settings store, Calendar engine, scheduler, report path or Backup repository.
- Restore mutation must remain behind successful read/validation and explicit user confirmation where destructive replacement occurs.
- Calendar target remains provider-neutral Android Calendar integration; no independent Google/Samsung engine unless a future requirement proves it necessary.

## Continuation Priority

1. Re-read live state because PRs may already have promoted/merged.
2. If #592 or #593 is still Draft and exact-head Fast/current-main-safe, promote only at a safe serial point.
3. Require Heavy Build/APK + Device before merge of production/automation code.
4. Close or supersede stale branches rather than stacking stale ancestry.
5. Continue #578/#583 only by extending the existing canonical score tool.
6. Keep docs in a separate non-disruptive lane so documentation does not stale healthy validation PRs.

## Continuation Trigger

`Fresh GitHub audit → parallel independent implementation → exact-head Fast → serial Ready/Heavy → guarded merge → post-merge re-audit → reconcile docs → next smallest real gap`

Repository reality always overrides conversation memory and this checkpoint.