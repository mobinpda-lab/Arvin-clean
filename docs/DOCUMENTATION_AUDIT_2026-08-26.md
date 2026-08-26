# Arvin documentation audit — 2026-08-26

**بسم الله الرحمن الرحیم**

## Scope
A repository-wide documentation audit was performed before continuing production work. The review covered root project documentation, `docs/`, `docs/contracts/`, current-state/handoff files, roadmaps, scorecards, UI/UX contracts, migration/storage records, FollowUp/Reminder/Calendar/Quick Capture/Timeline/Next Action/Recurrence/Widget records, CI notes, changelogs, and the historical v48 transfer artifacts.

## Authority result
- GitHub repository reality is the executable source of truth.
- `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 is the single active operating/governance reference.
- v48.x packages/transfer parts, dated snapshots, changelogs and old wave records are historical evidence, not current-state authority.
- Current implementation must continue to reuse `Unified Item/Task + Reminder + FollowUps[] + History` and the existing `arvin.tasks` path unless an approved migration changes that contract.

## Verified documentation discrepancies
1. `AI_CONTINUATION_STATE.md`, `ARVIN_STATUS.md`, `ARVIN_PROJECT_STATE.md` and parts of `PROJECT_STATUS.md` contain old PR/main/current-work references and must not override live GitHub.
2. Historical progress snapshots contain manual estimates such as 61%. They are not official current progress. `PROJECT_PROGRESS_METRIC.md` defines the only official score systems.
3. `progress_scorecard.json` and `project_completion_scorecard.json` are evidence-backed official metrics, but their committed stages predate some newer merged product delivery and must be changed only through an evidence-backed scorecard PR after exact-head and post-merge validation.
4. `SIMPLE_NOTEBOOK_PRODUCT_CONTRACT.md` contained an old separate Note storage decision (`arvin.simple_notes`) that conflicts with the newer Unified Item architecture. The current contract must not create a second Note model/repository/storage path.
5. Several Quick Capture checkpoint/next files describe a pre-Home-wiring state, while the later `QUICK_CAPTURE_UI_2026-08-26.md` records the real Home path. Those earlier files are historical checkpoints and must not restart completed work.
6. Calendar documentation confirms official Iranian holidays are integrated on the existing Calendar foundation; the authoritative Prayer Times provider remains a genuine Gate D gap.
7. Automatic FollowUp documentation forms one delivery chain: core → due UI → background notification → Android reboot runtime → alarm scheduler → real write-path rescheduling. PR #189 closes the documented write-path integration slice; post-merge validation remains required before score promotion.
8. Timeline has a documented real product entry. Next Action has merged core and an active user-facing UI PR. Scorecard promotion requires current evidence rather than narrative inference.

## Production checkpoint at audit time
- `main`: `21fc74cf6db7e6f9b9feffd0ab94a1cbd056c3de` — PR #189 merged.
- PR #189 exact head `35902d5b21eba9d68dcd861717349f3868c489a4` passed Arvin Build #652 and Parallel Wave #469 before merge.
- Post-merge Arvin Build #654 was running when this record was created.
- PR #190 Next Action UI was rebuilt unchanged in feature scope on the post-#189 main as exact head `db64b37f816f8814563f5a20e7445eb56caf4abf`; fresh Build #655 and Parallel Wave #471 were running.

## Execution decision
- Do not pause independent product work for documentation cleanup.
- Keep product PRs and documentation PRs on separate branches.
- Do not open duplicate implementation lanes while #190 is validating.
- Update scorecards only after the relevant merge and post-merge evidence exists.
- Reconcile current-state/handoff files before merging this documentation lane.

## Permanent rule
Fast delivery means parallel independent work + automation + exact-head feedback + controlled integration + simultaneous documentation. It never means skipping tests, weakening gates, creating duplicate foundations, or reporting unverified success.
