# Arvin AI Continuation State

Last updated: 2026-08-25

## Source of truth
GitHub Reality > approved architecture decisions > docs/ARVIN_PROJECT_OPERATING_PACKAGE.md v49.0 > CI/workflow evidence > chat memory.

## Current main
Main SHA at the start of this snapshot: `ab9209114aea9cc853b31099cebe75e8206e0b70`

Latest completed PR: #147 — `feat(home): connect RTL drawer to official calendar`
- Merge method: squash
- Tested head: `ef56fd73a4ba1b677adf4db96e08bd89153563cf`
- Arvin Build #534: completed / success
- Arvin Parallel Wave #355: completed / success
- Result: Home now exposes the official Iranian calendar through the existing RTL Scaffold drawer without introducing a Router/AppShell or changing storage/migration foundations.

Previous completed PRs in this wave:
- #145 — preserve canonical fields on transitional Home saves
- #144 — harden FollowUp quick-add task selection and failure tests

## Active work
No feature PR is intentionally marked as the sole active continuation point by this snapshot. Before starting work, re-read live GitHub because new PRs or commits may exist after this file was written.

## Next actions
1. Re-read `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 and verify live `main`, open PRs, and exact-head workflows.
2. Select the nearest real incomplete Definition-of-Done item, preferring independent lanes that can progress in parallel without overlapping foundations.
3. Recommended next lanes after Calendar navigation stabilization:
   - complete remaining Unified Item migration in Home;
   - connect the existing SearchService to UI without creating another search engine;
   - complete Notebook Note/Edit/Checklist contract;
   - implement Reminder/Notification on the shared foundation;
   - audit Backup/Restore end-to-end.
4. Keep PRs small, independently testable, and merge only after Analyze → Test → APK → Evidence → Review on the exact SHA.

## Non-negotiable architecture rules
- Flutter, Persian, RTL.
- `arvin.tasks` remains the main Home data path unless an approved migration explicitly changes it.
- Task, Note, Reminder and FollowUp converge on the shared Unified Item/Task foundation.
- Do not create parallel Model, Repository, Storage, Sync Engine, Router, AppShell, or UI foundation when an existing one can be extended.
- Existing Search, Calendar, Backup and Notebook capabilities must be audited before rebuilding.
- CI evidence is valid only for the exact SHA it tested.
- No force updates or destructive history rewrites for normal continuation.
- Preserve the project identity and «بسم الله الرحمن الرحیم».

## Continuation protocol
The command `ادامه` means: re-check GitHub first, read this file plus the v49 operating package, then continue the nearest real task from repository reality rather than from chat memory.

## Speed rule
Development should stay parallel, coordinated and fast, targeting useful verified output in hours rather than days. Speed must come from independent lanes, small PRs, reuse of existing foundations and avoiding rework—not from skipping tests, APK builds, review or exact-SHA evidence.

## Progress baseline
The last explicitly established v49 progress baseline was 33%. Recalculate only after real merged work is evaluated against the full Definition of Done; do not increase progress just because commits or PRs exist.
