# Arvin Maximum Parallel — operational plan 2026-08-28

Status: **active permanent execution plan**.

Live baseline after the latest verified integration:
- `main`: `16323a754ba6fd7a2cdedf25cec7a9f003a95c4d`
- PR #374 Jalali PDF: merged; post-merge Build/APKs/Home+People Device all green
- PR #376 independent `Task.dueDate` foundation: merged after Fast + Quality + debug/release APK + Home/People Device success

## Permanent no-stop rule
Arvin production must never become globally idle because one lane is waiting, failing, validating, documenting, reviewing or depending on another lane.

- A blocker pauses **only** the affected lane.
- Every non-conflicting ready lane continues automatically.
- CI waiting time is reused for audit, branch preparation, focused tests, documentation and independent product work.
- Documentation never blocks independent product implementation.
- Stale/conflicted PRs are reconciled or rebuilt while other lanes continue; they are never force-merged merely to create motion.
- Main advances only through exact-head verified, mergeable changes followed by post-merge validation.
- Speed never weakens canonical storage, migration safety, user-data preservation or acceptance evidence.

## Immediate P0 dependency map

### P0-A — canonical due date / list semantics
Owner requirement is now restored at the domain boundary through merged #376.

Next work under #375/#369:
1. preserve `dueDate` in every Task copy/rebuild/update path;
2. expose Jalali due date/time in Task create/edit/detail;
3. implement Today / Future / Overdue from `Task.dueDate` only;
4. implement Move-to-Today by changing the same Task's `dueDate`, never reminder/follow-up timestamps;
5. verify Backup/Sync/Report projections preserve the field.

### P0-B — FollowUp Task UX (#357 / PR #363)
PR #363 already has green Fast, Quality and Device evidence, but it predates canonical `Task.dueDate`.

**Data-safety gate before merge:**
- reconcile the editor against current main;
- explicitly preserve `existing.dueDate` when editing/rebuilding a Task;
- rerun exact-head Fast + Build/APKs + Device on the patched head.

Then continue #357 with:
- Home card -> read-only Task detail;
- round bottom `+` for follow-up-enabled Tasks;
- stacked blank FollowUp title -> `پیگیری` slice (#366);
- final latest-follow-up Home acceptance.

### P0-C — Follow-up Calendar UX (#350 / PR #352)
The owner-approved compact calendar contract is still missing on live main. The old #352 branch is stale/conflicted and must not be merged as-is.

Rebuild from current main and preserve:
- self-contained RTL;
- Jalali day/week/month;
- weekly compact default;
- visible text `امروز`;
- compact day/week/month heights;
- exact one-day / one-week / one-month navigation;
- selected-day vertical list.

**Shared-file rule:** #352 and #363 both modify `integration_test/android_home_smoke_test.dart`. The final Calendar branch must be reconstructed on the latest accepted Home/FollowUp smoke rather than restoring an old smoke file.

### P0-D — Notebook / Category (#362 / PR #365)
Low-overlap lane. Existing implementation has green Fast/Build/Device evidence:
- simple Note stays text-focused;
- Checklist remains separate UX mode;
- visible Edit;
- immediate same-ID category reassignment;
- canonical `TaskStore/arvin.tasks` only.

Its repository mutates the loaded canonical Task rather than rebuilding it, so additive fields such as `dueDate` are naturally preserved. Recheck latest-main overlap/mergeability immediately before merge.

### P0-E — Reminder Widget (#361 / PR #364)
Low-overlap Android resource lane with prior green Fast/Build/Device evidence.

Recheck real mergeability on current main; if conflict is real, rebuild fresh rather than forcing. Final launcher/keyguard/timed/all-day visual acceptance remains separate closure work.

## Independent remembered owner lanes — must always retain an owner
- #369 — All/Notes/FollowUp-enabled + Today/Future/Overdue + sorting + Move-to-Today + list search integration
- #370 — safe Back / autosave or explicit save-discard across editable flows
- #371 — complete Category + Tag lifecycle
- #372 — independent Reminder per FollowUp
- #367 — long-press one/many/all selection, bulk archive/delete/category/tags, Notes Copy/PDF/Share/Print, filtered-list Task PDF/Share/Print
- #341 — Quick Capture Android E2E
- #339 — People final roadmap DoD/status/handoff closure
- #345/#351 — multi-device apply/CAS stack
- #346 — provider-neutral external-calendar idempotency follow-on

## Integration order without global serialization
There is **no single project queue**. Independent work continues in parallel. When multiple PRs are merge-ready at the same time, prefer:

1. canonical domain/persistence foundations;
2. small low-overlap validated surfaces;
3. user-facing surfaces that depend on those foundations;
4. E2E / scorecard / handoff closure.

Current practical order around shared files:
1. #376 merged — due-date foundation complete;
2. patch/revalidate #363 so Task edits cannot drop `dueDate`;
3. reconstruct #352 Calendar on the newest Home smoke baseline;
4. #365 and #364 may integrate whenever their latest-main overlap check is clean and doing so does not invalidate an almost-finished heavier gate;
5. start #369 due-date projection/service slices as soon as current-main domain is stable;
6. start #372 model/scheduler slice after current Task-model churn is settled;
7. #370/#371/#367 integrate after their shared editor/list surfaces stabilize, while service/domain prep proceeds earlier.

## CI throughput rule
Do not move `main` needlessly while another near-merge PR is in the final minutes of heavy APK/Device CI if that move would make its evidence materially stale. This is **not a pause**: use that time for independent Draft/Fast lanes, audits, tests, docs, stale-PR cleanup and next-branch preparation.

A newer `main` does not automatically invalidate unrelated CI. Before merge always verify:
- current main SHA;
- exact PR head SHA;
- mergeability;
- changed-file overlap / canonical data dependency;
- whether existing CI actually covers the current combination.

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
