# Arvin Maximum Parallel — operational plan 2026-08-28

Status: **active permanent execution plan**.

Live baseline at the latest audit:
- `main`: `32b429d875ff47c4a3ba2e1360638507ae7aff22`
- #374 Jalali PDF: merged and post-merge validated
- #376 independent `Task.dueDate` foundation: merged and post-merge validated
- #365 Notebook/category UX: merged
- #378 Today/Future/Overdue projection from `Task.dueDate`: merged
- #379 FollowUp current-main correction: merged; blank FollowUp title is canonicalized and Android save visibility is guarded
- #380 fresh Sync plan apply: active Full Gate after Fast success
- #381 fresh idempotent external Calendar Sync plan: Draft, Fast success
- #382 fresh remote Sync CAS/retry transport: Draft stacked/current-main lane

## Permanent no-stop rule
Arvin production must never become globally idle because one lane is waiting, failing, validating, documenting, reviewing or depending on another lane.

- A blocker pauses **only** the affected lane.
- Every non-conflicting ready lane continues automatically.
- CI waiting time is reused for audit, branch preparation, focused tests, documentation and independent product work.
- Documentation never blocks independent product implementation.
- Stale/conflicted PRs are reconciled or rebuilt while other lanes continue; they are never force-merged merely to create motion.
- Main advances only through exact-head verified, mergeable changes followed by post-merge validation.
- Speed never weakens canonical storage, migration safety, user-data preservation or acceptance evidence.
- Heavy Build/APK/Device gates are not duplicated unnecessarily; Draft/Fast work continues while one near-merge Heavy Gate is running.

## Current P0 execution map

### P0-A — canonical due-date/list semantics (#375 / #369)
Delivered foundations:
- `Task.dueDate` is canonical and independent from Reminder/FollowUp timestamps (#376);
- Today/Future/Overdue projection uses `dueDate` only (#378).

Remaining:
1. Jalali due date/time create/edit/detail UX;
2. All / Notes / FollowUp-enabled projections;
3. sorting and direction toggle;
4. Move-to-Today mutating only the same Task's `dueDate`;
5. Home/list/search integration;
6. Backup/Sync/Report acceptance for due-date preservation.

### P0-B — FollowUp Task UX (#357)
Current main already includes the current-main FollowUp correction from #379.

Remaining acceptance must build on that main, not resurrect stale PR #363:
- Home card -> read-only Task detail;
- round bottom `+` for follow-up-enabled Tasks;
- final latest-follow-up Home acceptance;
- every Task rebuild/edit path must preserve `dueDate` and all newer canonical fields.

### P0-C — Follow-up Calendar UX (#350)
The owner-approved compact Jalali Calendar contract remains a current product requirement. Any stale #352 implementation must be rebuilt/reconciled on the newest Home smoke baseline.

Preserve:
- self-contained RTL;
- Jalali day/week/month;
- weekly compact default;
- visible `امروز`;
- compact day/week/month surfaces;
- exact one-day / one-week / one-month navigation;
- selected-day vertical follow-up/event list;
- no restoration of an older Android smoke file over current main.

### P0-D — Sync apply / remote CAS (#342 / #349)
Fresh lanes replace stale-baseline #345/#351:
- #380 applies an already-reviewed deterministic Sync plan through canonical `TaskStore` only after full validation;
- every conflict requires explicit user choice;
- stale local state fails before write;
- no partial writes;
- newer Task fields are compared via canonical `Task.toJson()`;
- #382 adds provider-neutral versioned remote snapshot + compare-and-swap + stable retry operation identity;
- no provider, credential or network choice yet;
- Backup remains separate from live Sync.

Promotion order:
1. finish #380 Full Gate and exact-head merge;
2. post-merge current-main validation;
3. shrink/reconcile #382 onto new main;
4. fresh Fast on current base;
5. Full Build/APK/Device before #382 merge.

### P0-E — External Calendar Sync (#343)
Fresh #381 replaces stale-baseline #346.

Contract:
- active canonical FollowUp reminders only;
- stable SHA-256 event revision;
- deterministic create/update/no-op/delete;
- unchanged repeated sync -> no-op, never duplicate create;
- official holidays/prayer rows remain ineligible;
- no OAuth, Calendar Provider write, permission, link persistence or background sync yet.

#381 has fresh Fast evidence. Promote to Heavy Gate after the currently-running #380 Heavy Gate finishes, avoiding unnecessary heavy CI duplication.

### P0-F — Reminder Widget (#361)
Old #364 must not be force-merged if conflict remains. Rebuild from current main using the approved light/indigo reminder-card hierarchy while preserving canonical Task/FollowUp source and deep links. Launcher/keyguard/timed/all-day physical acceptance remains required.

## Independent remembered owner lanes — must always retain an owner
- #369 — Home/list projections, sorting, Move-to-Today, search integration
- #370 — safe Back / autosave or explicit save-discard across editable flows
- #371 — complete Category + Tag lifecycle
- #372 — independent Reminder per FollowUp
- #367 — long-press selection, bulk actions, Notes/Task Copy/PDF/Share/Print
- #341 — Quick Capture Android E2E
- #339 — People final roadmap DoD/status/handoff closure
- #343/#381 — external Calendar Sync contract and provider follow-on
- #342/#380 + #349/#382 — live multi-device Sync apply + remote CAS/retry

## Integration order without global serialization
There is **no single project queue**. Independent work continues in parallel. When multiple PRs are merge-ready at the same time, prefer:

1. canonical domain/persistence foundations;
2. small low-overlap validated service contracts;
3. user-facing surfaces that depend on those foundations;
4. E2E / scorecard / handoff closure.

Current practical integration order:
1. finish and merge #380 only after Quality + debug/release APK + Home/People Device are all green on exact head;
2. validate post-merge main;
3. reconcile/promote #382 to current main;
4. promote #381 from Fast to Full Gate after #380 Heavy CI finishes;
5. rebuild stale Calendar/Widget UI lanes on the newest main rather than reusing stale merge evidence;
6. continue #369/#370/#371/#372/#367 in independent domain/service slices whenever they do not collide with active user-facing files.

## CI throughput rule
Do not move `main` needlessly while another near-merge PR is in the final part of heavy APK/Device CI if that move would make its evidence materially stale. This is **not a project pause**: use that time for independent Draft/Fast lanes, audits, tests, docs, stale-PR cleanup and next-branch preparation.

Before every merge verify:
- current main SHA;
- exact PR head SHA;
- mergeability;
- changed-file overlap / canonical data dependency;
- whether CI covers the current combination;
- post-merge main Build/Device health.

Rerun only evidence made materially stale.

## Documentation / score / stale-work rules
- GitHub reality is the source of truth.
- `docs/PRODUCT_CONTRACT_MATRIX.md` must keep every accepted Missing/Partial behavior attached to an owning Issue.
- Whole-project score and Product Extension score remain separate.
- No percentage rises from plans, Draft code or optimistic estimates.
- Historical docs stay traceable but cannot override current contracts.
- Old open PRs are classified as Active / Stacked / Needs migration / Superseded-history / Close-not-planned; never mass-close before unique requirements are migrated.

## Reporting rule
Owner-facing reports remain short and nontechnical:
- what merged;
- what is moving now;
- blocker only when real;
- immediate next integration.

The phrase **`ادامه با حالت Maximum Parallel`** means: read live GitHub, resume the nearest unfinished accepted work, keep every independent lane moving, validate, document and integrate without waiting for the owner to repeat technical instructions.
