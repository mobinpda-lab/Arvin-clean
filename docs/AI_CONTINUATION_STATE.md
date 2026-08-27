# Arvin AI Continuation State

Last updated: 2026-08-27

## Source of truth
GitHub Reality > approved architecture decisions > docs/ARVIN_PROJECT_OPERATING_PACKAGE.md > current continuation docs > exact-head CI/workflow evidence > chat memory.

## Current main snapshot
Main SHA at the start of this documentation lane: `20c881d6f744bc53eb22ca63c59523e352433b49`.

Latest merged baseline observed here includes PR #337 — canonical People Android emulator E2E.

This SHA is a snapshot only. Every continuation MUST refresh live `main`, open PRs and exact-head workflows before merge or progress claims.

## Active Maximum Parallel wave
Detailed operational map: `docs/MAXIMUM_PARALLEL_CONTINUATION_2026-08-27.md`.

Current lanes at this snapshot:
- PR #345 — canonical Sync apply through TaskStore; open/Ready/mergeable. Exact-head Fast/quality/APK/device evidence was observed green during the wave; refresh before merge.
- PR #346 — idempotent external Calendar sync planner; open/Ready/mergeable. Provider-neutral contract only.
- PR #347 — comprehensive architecture/target reconciliation; documentation-only, open/Ready/mergeable.
- Issue #348 — next Android Calendar Provider execution lane after #346 contract integration.
- Issue #349 / PR #351 — versioned remote snapshot + compare-and-swap + retry boundary. PR #351 is intentionally stacked on #345 and remains Draft until the parent is merged/reconciled.
- Existing UI/device/E2E lanes remain independent and must not be stopped by documentation, Sync or Calendar work when boundaries do not overlap.

## Highest-value continuation
1. Refresh GitHub state first.
2. If #345 still has full exact-head green evidence and current-main compatibility, merge/revalidate it.
3. Rebuild/reconcile #351 from the resulting fresh `main`, then continue remote transport/retry validation.
4. Independently complete exact-head gates for #346 and start #348 after its contract is safely integrated.
5. Integrate #347 when its documentation gate is clean.
6. Continue non-conflicting UI/device/E2E/product lanes at the same time.

Dependency order does NOT mean global serialization. One blocked lane must not stop unrelated production.

## Permanent Maximum Parallel / no-stop rule
Development stays parallel, coordinated, fast and evidence-driven.

Documentation, architecture reconciliation, reporting, backlog audit and CI observation MUST run as independent lanes and MUST NOT stop non-conflicting product production.

A lane may wait only for a real technical dependency, overlapping canonical ownership, exact-head validation failure, stale-main reconciliation, or a destructive/data/security risk. Waiting in one lane never authorizes stopping unrelated lanes.

## Non-negotiable architecture rules
- Flutter, Persian, RTL.
- `arvin.tasks` remains the canonical Task persistence path unless an approved migration explicitly replaces it.
- Task / FollowUps[] remain canonical product foundations; composition is preferred over a giant duplicate Unified model.
- Calendar projections consume canonical Task/FollowUp data; external calendars are not Arvin's source of truth.
- Backup/Restore uses its canonical serialized path. Dropbox/cloud backup semantics must not be silently reused as live multi-device Sync state.
- Sync uses canonical Task JSON/revision evidence, explicit conflict decisions and fail-closed stale/precondition checks; no timestamp/last-write-wins shortcut.
- Do not create parallel Model, Repository, Storage, Sync Engine, Router, AppShell, Calendar database or UI foundation when an existing one can be extended.
- No credentials/tokens in portable backup or ordinary settings payloads.
- CI evidence is valid only for the exact SHA it tested.
- No force updates or destructive history rewrites for normal continuation.
- Preserve the project identity and «بسم الله الرحمن الرحیم».

## Continuation protocol
The command `ادامه` means:
- re-check GitHub first;
- read this file, `docs/ARVIN_CONTINUATION_COMMAND.md`, `docs/MAXIMUM_PARALLEL_CONTINUATION_2026-08-27.md`, and the operating package relevant to the task;
- continue the nearest real unfinished gaps in parallel when independent;
- never stop unrelated production because one lane is waiting;
- validate exact resulting refs before merge/promotion.

## Progress rule
Do not reuse historical manual percentages as current truth. Recalculate progress only from current scorecards/Definitions of Done and merged validated evidence. Documentation, issue creation, branch creation or PR count earns no product progress by itself.
