# Arvin-clean — Live AI Handoff

## Primary Rule

GitHub تنها Source of Truth عملیاتی است. این فایل فقط checkpoint فشرده برای ادامه سریع است؛ هر اجرای جدید باید قبل از اقدام، `main`، PRها، Issueها و exact-head CI را تازه بخواند.

## Live Checkpoint — 2026-08-31

Current `main`:

`a4c2a3eca5838808ed0dee7c389f2d0dce997ba6`

آخرین Merge تأییدشده: PR #598 — Android Calendar Provider discovery روی main.

Mergeهای مهم همین موج:
- #573 — deterministic Production feedback loop
- #574 — GitHub-native fallback برای AI Code Worker
- #575 — Jalali Calendar date jump
- #579 — AI patch validation + provider timeout/budget hardening
- #582 — Backup restore confirmation safety
- #592 — Calendar integration settings UI
- #598 — Android Calendar Provider discovery

## Active Parallel Lanes

### 1. AI Worker reliability — PR #600

- Draft / open / mergeable
- head: `92c33573ef94b8e6e4a6fb7aad9be22ea9e8c` is NOT the head; canonical PR head remains `92c33573ef94b8e6e4e76a5b35df997b84a9cac0`
- Fast run `33376661169`: ✅ complete on that exact head
- quality/analyze/test + release/followup/typography/guide/calendar/backup surfaces all green on the historical exact head
- `main` has since advanced through merged #598 to `a4c2a3ec...`
- therefore reconcile/rebuild #600 onto current main before any Heavy/Device or promotion; do not reuse pre-main-move evidence as current-main proof
- normal Worker launch authority = Orchestrator explicit dispatch
- Worker is workflow_dispatch-only for normal launch
- Git native `--recount` after structural validation only; malformed/context-invalid patch remains fail-closed
- supersedes closed #593; historical #589/#591 must not be promoted independently
- owner issues: #588 + #590

### 2. Provider duplicate cleanup — PR #599

- Draft / open
- scope overlaps the now-merged #598 provider discovery
- do not spend Heavy/Device or merge budget on #599 unless a fresh live diff proves a non-duplicate gap
- preferred default is reconcile then supersede/close duplicate history without force merge

### 3. Live Progress Score — #578 / #583

- reuse existing `tool/progress_score.py` and canonical scorecards
- no second score source
- exact-main SHA and PASS/FAIL/BLOCKED evidence required
- stale evidence must never increase score
- do not manually invent/update percentages

## Calendar Reality

Provider discovery foundation is now on `main` through #598:
- READ_CALENDAR only
- permission status/request
- Android CalendarContract calendar/provider enumeration
- typed provider metadata in existing bridge
- no WRITE_CALENDAR
- no direct event read/write/delete sync

Therefore #516/#348 still own the remaining bidirectional integration work: selected calendar wiring, event projection/read/write policy, sync execution/idempotency and related safety gates.

## Production / Merge Contract

- Production Orchestrator remains canonical promotion/merge authority.
- Worker/Production Loop cannot merge or bypass gates.
- Draft → exact-head Fast/Parallel.
- Ready → Heavy Build/APK + Device on same head/current-main ancestry.
- merge serially; independent development lanes may run in parallel.
- if `main` moves, affected lane must reconcile/rebuild; do not force merge stale work.
- do not restart/cancel healthy workflows merely to accelerate another lane.
- duplicate lanes must not receive duplicate Heavy/merge work.

## Core / Data Safety

- preserve existing Task / Reminder / FollowUp / History foundations.
- no duplicate TaskStore, Settings store, Calendar engine, scheduler, report path or Backup repository.
- Restore mutation remains behind successful read/validation and explicit confirmation before destructive replacement.
- Calendar integration remains provider-neutral Android Calendar Provider based; no independent Google/Samsung engine.
- no open Issue with exact `release-blocker` label was found at this checkpoint, but RC readiness still depends on unresolved operational lanes and exact-head evidence.

## Continuation Priority

1. Re-read live `main` and PR #600; reconcile Worker reliability to current main before Heavy.
2. Reconcile/supersede duplicate PR #599 so it cannot consume redundant validation or merge work.
3. Continue #516/#348 from the merged provider-discovery foundation with the smallest non-duplicative calendar sync slice.
4. Continue #578/#583 only by extending the existing canonical score tool.
5. Keep documentation in this separate Draft lane; update this existing docs PR instead of creating repetitive hourly docs PRs.

## Continuation Trigger

`Fresh GitHub audit → parallel independent implementation → exact-head Fast → serial Ready/Heavy → guarded merge → post-merge re-audit → reconcile docs → next smallest real gap`

Repository reality always overrides conversation memory and this checkpoint.