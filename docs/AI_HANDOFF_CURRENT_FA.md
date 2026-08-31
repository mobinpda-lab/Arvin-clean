# Arvin-clean — Live AI Handoff

## Primary Rule

GitHub تنها Source of Truth عملیاتی است. این فایل فقط checkpoint فشرده برای ادامه سریع است؛ هر اجرای جدید باید قبل از اقدام، `main`، PRها، Issueها و exact-head CI را تازه بخواند.

## Live Checkpoint — 2026-08-31

Current `main`:

`6dcb368db8565018384c4a6fb7aad9be22ea9e8c`

آخرین Merge تأییدشده: PR #592 — Device Calendar Settings UI روی main.

Mergeهای مهم همین موج:
- #573 — deterministic Production feedback loop
- #574 — GitHub-native fallback برای AI Code Worker
- #575 — Jalali Calendar date jump
- #579 — AI patch validation + provider timeout/budget hardening
- #582 — Backup restore confirmation safety
- #592 — Calendar integration settings UI

## Active Parallel Lanes

### 1. Android Calendar Provider discovery — PR #598

- Ready / open / mergeable
- head: `2cb663e2a14b68dae70b411289bd22fc5b49f6d9`
- Fast/Parallel Wave #1286: ✅
- Heavy Build `33376483721`: quality + Debug APK + Release APK ✅
- Device `33376485193`: Home + People ✅
- READ_CALENDAR only; no WRITE_CALENDAR
- provider enumeration + permission boundary only
- no direct event read/write/delete sync in this slice
- next action is only guarded serial merge after a fresh current-main ancestry/mergeability recheck

PR #599 is an overlapping Draft provider-discovery lane. Do not spend duplicate Heavy or attempt parallel merge on it while #598 remains the validated canonical lane; reconcile/supersede using live GitHub state first.

### 2. AI Worker reliability — PR #600

- Draft
- head: `92c33573ef94b8e6e4e76a5b35df997b84a9cac0`
- Fast run `33376661169`: ✅ complete
- quality/analyze/test + release/followup/typography/guide/calendar/backup surfaces all green
- Heavy/Device intentionally pending behind current product promotion lane
- normal Worker launch authority = Orchestrator explicit dispatch
- Worker is workflow_dispatch-only for normal launch
- Git native `--recount` after structural validation only
- malformed/context-invalid patch remains fail-closed
- supersedes closed #593; historical #589/#591 must not be promoted independently
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
- duplicate lanes must not receive duplicate Heavy/merge work.

## Core / Data Safety

- preserve existing Task / Reminder / FollowUp / History foundations.
- no duplicate TaskStore, Settings store, Calendar engine, scheduler, report path or Backup repository.
- Restore mutation remains behind successful read/validation and explicit confirmation before destructive replacement.
- Calendar integration remains provider-neutral Android Calendar Provider based; no independent Google/Samsung engine.
- no open Issue with exact `release-blocker` label was found at this checkpoint, but RC readiness still depends on unresolved operational lanes and exact-head evidence.

## Continuation Priority

1. Re-read live `main` and PR #598 immediately; if current-main ancestry and mergeability still hold, let the canonical Production path complete its guarded serial merge.
2. After `main` moves, reconcile PR #600 before Heavy; never reuse pre-main-move Heavy evidence.
3. Resolve/supersede duplicate PR #599 before it can create redundant validation or merge competition.
4. Continue #578/#583 only by extending the existing canonical score tool.
5. Keep documentation in its separate Draft lane; update existing docs PR rather than creating repetitive hourly docs PRs.

## Continuation Trigger

`Fresh GitHub audit → parallel independent implementation → exact-head Fast → serial Ready/Heavy → guarded merge → post-merge re-audit → reconcile docs → next smallest real gap`

Repository reality always overrides conversation memory and this checkpoint.