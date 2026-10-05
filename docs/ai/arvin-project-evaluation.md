# Arvin — Project Evaluation Snapshot & Remaining Work

Date: 2026-10-05
Verified main for this snapshot: `81ed798d6a6d30316f2347242bc478b59e7caa20`

## Executive status

Arvin is NOT Release-Ready yet. Several important foundations are implemented, but product-level acceptance and integration remain incomplete. The highest-value unfinished lane is canonical Date/Time/Reminder behavior, followed by Calendar sync, Checklist completion, Repeat, Taxonomy, Notebook, Typography, regression and final release evidence.

## Confirmed recent work

### DONE with exact-head evidence
- PR #2302 merged: restored circular Clock Dial time picker and immediate new Project visibility in the Task Editor.
- PR #2306 merged: Task Detail shows/toggles canonical Checklist and progress.
- PR #2308 merged: Home Task cards show Checklist progress.
- Stale duplicate #2307 was closed as duplicate.
- Main at this snapshot: `81ed798...`.

These are implementation states, not blanket product-release approval.

## P0 — execute first

### 1. Date/Time/Reminder — #2301
Status: IN PROGRESS / architecture gate active.

Required:
- Date only = true All-Day; never show fake 00:00.
- Date + Time = Timed Task + exactly one canonical automatic Reminder at the same timestamp.
- No Date = no due-based automatic Reminder/Event.
- Date-only ↔ Date+Time transitions are reversible and idempotent.
- Editing date/time reconciles Reminder/Calendar without duplicates.
- Manual Reminder is not silently overwritten.
- Preserve Task IDs/history/Backup/Restore.
- Keep date and time side-by-side; circular Clock Dial; Persian RTL.
- Focused tests + Analyze/Test + exact-head Build + Android Smoke.
- Final device acceptance near RC.

Architecture decision document exists at `docs/architecture/date-time-reminder-canonical-decision.md` on PR #2309. Do not create a parallel Date/Reminder engine.

### 2. Calendar — #2248 / #1901
Status: IN PROGRESS / NEEDS VERIFICATION.

Required:
- Selected destination calendar is actually honored after change/edit.
- Previous calendar event is reconciled; no duplicate/orphan.
- Edit/delete/update keeps Task↔Event identity.
- Phone default-calendar opt-in sync works.
- No-date Tasks do not sync as timed events.
- Completed Tasks are removed from phone calendar when contract requires.
- All-Day remains All-Day; provider 00:00 is compatibility only.
- Recurrence mapping/import behavior must be verified.
- Architecture review before fundamental Calendar engine/model/storage changes.

### 3. Checklist — #2230
Status: PARTIAL.

Already implemented:
- canonical Task checklist;
- Task Detail display/toggle/progress;
- Home progress;
- reorder foundation.

Remaining:
- user-facing add/edit/delete/move/reorder completion path;
- active/inactive capability;
- independent occurrence state for Repeat;
- Checklist + Date/Time/Reminder;
- Checklist + Follow-up;
- Checklist + Project/Category/Tag;
- Backup/Restore and migration/history;
- recurring-template change behavior;
- RTL/Persian UI and acceptance.

## P1 — after/alongside P0 where safely independent

### 4. Repeat — #2254
Status: ARCHITECTURE GATE / BACKLOG implementation.

Need lifecycle semantics, not merely recurring reminders:
start/end/count/current/completed/remaining/progress/next/history, Timeline, per-occurrence Checklist, Backup/Restore, integration tests.

### 5. Taxonomy — #847 / #1861
Status: IN PROGRESS / NEEDS VERIFICATION.

Need robust Project/Category/Tag lifecycle using one canonical source:
create, select, rename/edit, archive/disable, safe delete/reassign, immediate visibility, filters, Notebook integration, Backup/Restore.

### 6. Quick Add / Task Edit — #1891
Status: PARTIAL / NEEDS VERIFICATION.

Need:
- date/time side-by-side everywhere;
- no blank date/time picker;
- Reminder works;
- Persian RTL/digits;
- Project/Category/Tag roll boxes with existing values + Create New last;
- immediate refresh;
- Repeat + Priority same row;
- completed↔undone and filters;
- swipe normal Task ↔ Follow-up.

### 7. Home — #1912 / #1901
Status: PARTIAL / NEEDS FINAL DEVICE VERIFICATION.

Need final visual/UX acceptance:
- Home title and approved four group controls;
- Time/Projects/Categories/Tags filters combine correctly;
- no legacy stat cards;
- readable multiline Task cards;
- no clipping;
- filter changes take effect without reopen;
- daily decision-center behavior.

### 8. Notebook — #1911 / #850
Status: IN PROGRESS / NEEDS VERIFICATION.

Need independent Notebook with:
- inline numbering/tick/checklist tools independently on/off;
- continuation from same text point;
- autosave/reopen/undo/redo;
- canonical Project/Category/Tag;
- combined filters;
- Tag selection;
- safe cleanup of legacy Notebook-specific checklist/shopping/travel structures only after dependency audit.

### 9. Typography — #1860
Status: NEEDS VERIFICATION.

Required:
- VazirHarf v34.003 default;
- real system font option;
- real app-wide font size persisted across restart;
- valid font assets/source/license;
- RTL preview;
- no fake selectable fonts.

## P1/P2 — release closure

### 10. Backup/Restore/Data Safety
Status: NEEDS VERIFICATION.

Must preserve:
Task identity, IDs, history, Checklist and occurrence state, Follow-up timeline, taxonomy, Notes/Notebook, Reminder/Calendar relationships as applicable. No reset or data-loss migration.

### 11. Notifications / Widget / Lock Screen
Status: NEEDS VERIFICATION.

Validate Date-only vs Timed semantics and Reminder reconciliation.

### 12. Golden Flow
Status: NOT PROVEN.

Create Task → Date/Time → Reminder → Checklist → Repeat → Follow-up → Timeline → Complete → Backup → Restore.

### 13. Release Gate — #2102 / #2251
Status: NOT RELEASE-READY.

Required fresh evidence on the actual release candidate:
Analyze → full tests → Debug Build → Release Build → Android Smoke → product acceptance → final device verification → release.

## Hygiene / stale work

Old AUTO-FIX issues tied to old SHAs are not current blockers unless the same failure reproduces on current HEAD.

Old PRs such as #1892, #1885, #1847, #1844 must be compared against current main before any reuse. Do not resurrect parallel implementations.

## Execution order

1. Finish #2309 architecture gate and implement #2301.
2. Run exact-head tests/build/smoke and record evidence.
3. Continue Calendar #2248/#1901 integration verification.
4. Finish Checklist #2230.
5. Parallelize safe Taxonomy / Quick Add / Home / Typography / Notebook work.
6. Implement Repeat #2254 after architecture decision.
7. Run Golden Flow + Backup/Restore + release gates.
8. Final device verification only near RC.

## Status vocabulary

DONE | IN PROGRESS | PARTIAL | BLOCKED | NEEDS VERIFICATION | NEEDS FINAL DEVICE VERIFICATION | DUPLICATE | SUPERSEDED | UNKNOWN | BACKLOG

Never upgrade a status without evidence.
