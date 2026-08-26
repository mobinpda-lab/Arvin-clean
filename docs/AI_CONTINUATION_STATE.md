# Arvin AI Continuation State

Last updated: 2026-08-26

**بسم الله الرحمن الرحیم**

## Source of truth
GitHub Reality > approved architecture decisions > `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 > exact-ref CI evidence > conversation memory.

## Verified main checkpoint
At this documentation checkpoint, `main` is:
`21fc74cf6db7e6f9b9feffd0ab94a1cbd056c3de`

That commit merged PR #189 — real FollowUp add/edit writes now persist through the canonical repository boundary and request AlarmManager rescheduling through the existing scheduler adapter.

PR #189 exact head:
`35902d5b21eba9d68dcd861717349f3868c489a4`
- Arvin Build #652: success
- Arvin Parallel Wave #469: success
- Merge: complete
- Post-merge Arvin Build #654: running at the time this snapshot was written

## Active product work
PR #190 — `feat(next-action): expose canonical ranked actions in UI`
- Branch: `feat/next-action-product-ui`
- Base main: `21fc74cf6db7e6f9b9feffd0ab94a1cbd056c3de`
- Current exact head: `db64b37f816f8814563f5a20e7445eb56caf4abf`
- Scope: real Persian RTL Next Action page + entry from the existing Home-accessible canonical launcher
- No new model/storage/repository/router/AI foundation
- Fresh Arvin Build #655 + Parallel Wave #471 were running at this checkpoint
- Merge is forbidden until both are green on this exact head

## Parallel documentation work
Branch: `docs/current-state-audit-2026-08-26`

Purpose:
- record the repository-wide documentation audit;
- refresh stale current-state/handoff records;
- reconcile the old Notebook separate-storage contract with Unified Item;
- preserve dated/historical documents as history rather than rewriting them;
- update official scorecards only after product merge + post-merge evidence earns a stage change.

## Architecture invariants
- Flutter, Persian, RTL.
- Unified `Task/Item` is the shared product data foundation.
- `arvin.tasks` remains the canonical Home/domain storage path unless an approved migration changes it.
- FollowUp remains `Task.followUps`; Reminder remains a separate concept; History is projected from canonical persisted evidence.
- No parallel Task/Note/FollowUp/Reminder model, repository, database, storage key, Router/AppShell, search engine or scheduler foundation.
- Existing Calendar, Search, Backup/Dropbox, notification and AlarmManager foundations are reused.
- Notebook must not create `arvin.simple_notes`; the older separate-storage decision is superseded.
- CI evidence is valid only for the exact SHA/ref it tested.

## Roadmap facts from documentation audit
- Automatic FollowUp delivery chain is implemented through scheduler + real write-path rescheduling; post-merge validation/score evidence remains the gate before official promotion.
- Timeline has a real product entry on the existing canonical launcher.
- Next Action core is merged; PR #190 is its real UI integration lane.
- Quick Capture has a real Home UI/persistence path; earlier checkpoint/next documents are historical.
- Official Iranian holidays are integrated; authoritative Prayer Times provider remains a real Calendar gap.
- Recurrence core/Resume From Today exists; complete recurring user-facing UI remains incomplete.
- Widget foundation remains a separate audited gate and must be re-audited against current code before implementation.

## Official progress rule
There is no conversational percentage.
- Whole-project official percentage comes only from `docs/project_completion_scorecard.json`.
- 19-feature Extension percentage comes only from `docs/progress_scorecard.json`.
- Historical manual snapshots such as 61% are not current official metrics.
- Scorecards are changed only through evidence-backed PR + validator/CI.

## Next actions
1. Finish post-merge Build #654 for PR #189.
2. Finish exact-head Build #655 + Parallel Wave #471 for PR #190.
3. If #190 is green and head unchanged: Ready → Merge → post-merge main Build.
4. Then update scorecards only to the stages earned by merged/post-merge evidence.
5. Rebase/finalize this documentation lane onto the resulting main and merge after normal validation.
6. Select the next genuine independent product gap from live GitHub, not from stale snapshot text.

## Continuation protocol
`ادامه` means re-audit live GitHub first, then continue the nearest unfinished validated product/documentation work. Do not restart already-completed work from historical documents.
