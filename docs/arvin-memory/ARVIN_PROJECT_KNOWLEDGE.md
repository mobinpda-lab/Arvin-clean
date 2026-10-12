# CROSS-CONVERSATION KNOWLEDGE PRESERVATION — 2026-10-12

The complete requirement matrix is in [ARVIN_CONVERSATION_REQUIREMENTS_2026-10-12.md](ARVIN_CONVERSATION_REQUIREMENTS_2026-10-12.md). It captures owner requirements that can be lost across branches: origin-aware calendar sync, duplicate-safe manual actions, independent FollowUp reminders, lawful icons/colors, global inline date/time, compact cards on all surfaces, approved Report Filter and Task Form references, Repeat Tracking Level, cleanup boundaries and release evidence.

Important implementation distinctions:
- Issue #2635 is the requirement; PR #2636 is implementation in progress, not proof of release behavior. PR #2631 is the independent-reminder projection/stale-event dependency; validate both on exact heads and test backup/restore.
- PR #2633 is a staged shared date/time rollout, not global completion. PR #2627 is compact Home/Calendar implementation, not all-surface completion.
- Global Auto-sync owner rule is broader than legacy per-source switches; compatibility must be retained while switches must not silently suppress eligible Arvin-owned events.
- Report Filter and Task Form screenshots are requirements captured in #2623/#2624; compare real UI to references. No screenshot reference means acceptance has not been proven.
- Keep Task as the single source of truth; no duplicate Task/storage; Repeat does not copy root Tasks; Category=Group conceptually, with no fourth Group entity; preserve root Task.description guard until note-contract history is reconciled.


## Anti-forget ledger requirement
The owner requirements across the 2026-10-12 conversation are enumerated in [ARVIN_CONVERSATION_REQUIREMENTS_2026-10-12.md](ARVIN_CONVERSATION_REQUIREMENTS_2026-10-12.md). Read that checklist before further work; do not treat a PR, documentation record or in-progress workflow as completion. Preserve all checklist items and update their evidence/status only after exact-head verification.
# Arvin Project Knowledge

Updated: 2026-10-11
Repository: https://github.com/mobinpda-lab/Arvin-clean

## Authoritative continuation rule
Always re-fetch current main, PR heads/bases, issues, source files and exact-head workflow results before acting. A chat summary is only a pointer; GitHub is authoritative. Do not infer current CI state from a previous commit.

## Product and architecture invariants
- Task is the canonical actionable entity and source of truth.
- Quick Add and Full Task Form create/edit the same Task.
- Canonical taxonomy concepts are Project, Category and Tag. Category and Group are one concept; technical name `Category`, Persian UI term «دسته». No independent Group entity/store.
- Checklist and repeat belong to Task. Repeating does not create duplicate root Tasks; past execution/history remains immutable.
- Calendar is a projection of Task, not an owner. Create one external event and then update by stable Task/external event identity; never deduplicate by title/date.
- Home, Reports, Calendar, widgets and backup/restore must not become independent sources of truth.
- Fix existing paths; avoid parallel storage, backup formats, repositories or engines.
- Before migration or data-risk changes, require backup, rollback strategy and restore evidence.

## Backup/restore knowledge from live code review
- Canonical Category and Tag catalogs are independent of whether any Task currently uses them; backups must preserve unassigned values.
- Restore spans Task, Project, Calendar-link, settings and taxonomy stores. A failure can leave partial state unless rollback covers each mutated store.
- Commit [05c080e](https://github.com/mobinpda-lab/Arvin-clean/commit/05c080e706690dd3eb6a96fc5c070971a43d1354) adds Category/Tag snapshots and rollback cleanup for newly imported catalog entries in both Home and BackupPage, plus failure-injection test seams.
- Exact-head Build and Android smoke were not complete at last check. This is an implementation checkpoint, not a validated fix yet.
- Old backup compatibility must be preserved; missing/null optional data must not be confused with an explicitly empty collection.

## Taxonomy and relationship caution
- Current decision is in [ADR-2026-10-10-PCTADP](https://github.com/mobinpda-lab/Arvin-clean/blob/main/docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md), Issue #2582.
- Do not assume the conceptual Project → Category → Task drawing proves a database foreign key from Category to Project. Verify the actual model/schema.
- Issue #2580 remains open until the full cross-surface conformance audit is evidenced.

## User experience memory
- User reported missing «ثبت در تقویم گوشی» and «ویرایش» actions in Arvin's Calendar task view on 2026-10-09. Treat as an open user-reported regression until inspected and validated; do not silently mark fixed.
- Reports should be product-centered and plain Persian, distinguish verified facts from pending/unproven work, and include GitHub Read/Write status for each autonomous run.

## Release quality
Green CI and emulator tests are necessary but insufficient. Release evidence must include physical device/file-provider backup/restore, Calendar no-duplicate identity, and Golden Flow acceptance, plus user/install docs and known issues.

## Repeat Tracking Level — verified product knowledge (2026-10-11)
- All commitment use cases remain canonical Tasks. Loan/debt/payment/habit/contract/customer-follow-up must not become separate product subsystems.
- The existing repeat model already has `RecurrenceTrackingLevel.normal` and `.tracking`, persisted inside `Task.recurrence`; missing values from legacy JSON fall back to `normal`.
- The existing Task JSON already carries repeat occurrence history and per-occurrence checklist state. The recurrence repository/page also already contain some progress/history behavior. Start by completing existing paths, not by creating another engine/store/model.
- Follow-up and Repeat Tracking are different concepts. A Task's follow-up boolean/history must not substitute for the repeat rule's tracking level.
- Requested user language is «نوع پیگیری»، «عادی»، «مهم و قابل پیگیری». Keep developer terms out of normal UI. Advanced tracking details should appear progressively only when requested.
- Current audit targets: primary Task Create/Edit integration, restrained Home cue, Report Center level filter and defensible metrics. No code-level implementation or end-to-end acceptance was performed during the first-pass audit.
- Data invariant: past occurrence/history/checklist state stays unchanged when tracking level or future repeat settings change; backups must remain backward-compatible.

## Report Center filter contract — 2026-10-11
- Report is a read-only consumer of canonical data, not an owner of data.
- Use the existing Persian/Jalali picker for date ranges; internal DateTime values remain Gregorian only as the storage/runtime representation.
- Filter panel is an expandable bottom-sheet accordion. Time is initially open; other sections are compact/collapsed and show selected counts.
- Project, Category, Tag, status and Tracking are multi-select. OR within each group, AND across groups.
- Notebook records remain canonical Task objects with NotebookItemKind. Reports can filter by note/checklist kind, title/description, created/updated dates, and shared Category/Tag/Project dimensions.
- Existing Task follow-up state and RecurrenceRule.trackingLevel remain the sources for Follow-up and Tracking filters.
- No second Task/Note store, report engine, or parallel relation is permitted.
- Explicit limitation: current model has no separate Note-to-another-Task link; do not fake a linked-task filter. Phone-calendar-only external events are not proven Report Center inputs.
- Implementation/evidence pointer: PR #2607, branch feat/calendar-pastel-compact-cards-20261011. Exact-head Analyze/tests/build/device validation and owner acceptance remain pending.


## Repository-wide audit facts — 2026-10-11
- Main snapshot: a6ced27660d34cd87dd8915aff68d3a7555fd57a; 740 paths; 21 workflows; 249 test/integration-test files; 190 docs.
- GitHub scale: 1,248 branches, 19 open PRs and 1,096 open Issues. Search found 876 open AUTO-FIX records; this queue volume needs classification, not bulk closure.
- Main report filter still uses Gregorian showDatePicker/showTimePicker. The Jalali/shared-time implementation is in unmerged #2607/#2591.
- Release automation fan-out is real: 1,535 workflow runs are associated with the current main SHA, dominated by repeated release-closure/final-validation workflow_run events. #2531 is the existing isolation lane.
- TaskStore on main is SQL/Drift-backed with a one-time legacy SharedPreferences migration. #1324 remains open but its latest evidence is old and must be refreshed before closing.
- Open issue #866 tracks unsafe premature Recovery Wave closure; preserve fail-closed acceptance semantics.
- Current product acceptance ledger #1139 has unchecked installed-device requirements. Older #358 physical-device deferral text is stale relative to the newer ledger.


## Live checkpoint 2026-10-12
Current main is `cea76673d871ce52b84dacf69f355c4282802baa`. Documentation cleanup PR #2613 is merged. Exact-main Build #38178428086 and Device Smoke #38178428043 have stale/incomplete status and are not accepted as passing. Release remains blocked by physical-device Calendar, Backup/Restore, golden-flow and owner-approval gates. Read the live `ARVIN_EXECUTION_STATE.md` before acting; historical SHA/run notes above are not current truth.
