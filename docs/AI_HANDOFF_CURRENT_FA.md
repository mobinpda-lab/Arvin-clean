# Arvin-clean — Live AI Handoff

**بسم الله الرحمن الرحیم**

## Primary rule
The single active operating authority is `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0. GitHub live state is the executable source of truth. Historical snapshots and v48 transfer artifacts do not override either.

## Start here
1. Read v49.0.
2. Read `docs/DOCUMENTATION_AUDIT_2026-08-26.md` and `docs/AI_CONTINUATION_STATE.md`.
3. Check live `main`, open PRs and exact-head workflow results again because this handoff is only a checkpoint.
4. Inspect current code before changing behavior or architecture.
5. Continue the nearest real unfinished gap; do not restart completed work from old snapshot text.

## Live checkpoint when written
- `main`: `21fc74cf6db7e6f9b9feffd0ab94a1cbd056c3de` — PR #189 merged.
- PR #189 validated exact head `35902d5b21eba9d68dcd861717349f3868c489a4` with Build #652 + Parallel #469 before merge.
- Post-merge Build #654 was running.
- PR #190 Next Action UI was rebuilt on that main as exact head `db64b37f816f8814563f5a20e7445eb56caf4abf`; Build #655 + Parallel #471 were running.
- Documentation reconciliation is isolated on `docs/current-state-audit-2026-08-26` and must not block product delivery.

## Product/foundation invariants
- Persian RTL Flutter product.
- Unified Item/Task is the shared product foundation.
- `arvin.tasks` remains the canonical domain/Home storage path unless an approved migration changes it.
- FollowUp uses canonical `FollowUps[]`; Reminder remains separate; no FollowUp-as-Task-status shortcut.
- Do not create competing Model, Repository, Storage, Sync, Router/AppShell, Search, Calendar, Notification, Scheduler or Widget foundations.
- Notebook is a Unified Item capability; do not revive the superseded `arvin.simple_notes` separate-storage design.
- Existing Calendar/Search/Backup/Dropbox/AlarmManager/notification foundations are extended rather than rebuilt.
- Approved Persian RTL UI is protected from broad redesign.

## Verified roadmap interpretation
- Automatic FollowUp: core, due UI, background notifications, Android reboot runtime, AlarmManager scheduling and real write-path rescheduling have implementation evidence; final score promotion requires post-merge evidence/current scorecard PR.
- Timeline: core + real Home-accessible product entry exist; scorecard may be stale and must be corrected only with evidence.
- Next Action: core exists on main; #190 is the active user-facing integration.
- Quick Capture: real Home UI/persistence path exists; old `NEXT/CHECKPOINT` notes are historical.
- Calendar: official 1405 holidays are integrated; Prayer Times provider remains a real gap.
- Recurrence: canonical core/Resume From Today exists; complete product UI remains incomplete.
- Widget/Lock Screen: historical audit requires a shared foundation; current code must be re-audited before starting it.

## Official progress
Never invent or manually estimate progress.
- Whole Arvin: read `docs/project_completion_scorecard.json` on current main.
- Extension roadmap: read `docs/progress_scorecard.json` on current main.
- If scorecards lag GitHub evidence, correct them through a normal evidence-backed PR before claiming a new official percentage.

## Parallel delivery
Independent product, CI and documentation lanes may proceed simultaneously. Shared foundation/files require coordination. Waiting on CI is used for independent low-conflict work, not artificial commits.

## Validation
`Analyze → Test → APK/Workflow → exact-head evidence → Review → Merge → post-merge main Build` as applicable.

## Continuation
The user command `ادامه` means: audit live GitHub, finish active validated lanes first, update current-state evidence, then choose the next real gap.
