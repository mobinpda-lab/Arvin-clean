# Arvin — Project Evaluation Snapshot & Remaining Work

Date: 2026-10-09
Verified main baseline before this documentation update: 614b207567b5aa8c6e05e7f3fb530c89b05a118a

## Executive status

**Arvin is NOT Release-Ready yet.**

Live GitHub shows substantial product progress. The remaining gap is product integration, real-device acceptance, and release evidence. Older percentage snapshots are historical and are not current status.

### Fresh Reality Snapshot — 2026-10-09
- PR #2504 merged as `e8f9c3b`: test-only Home date contract stabilization; exact PR-head Analyze, six test shards, Debug/Release builds and six Android Smoke jobs passed. Post-merge main Release Closure still needs explicit confirmation.
- PR #2505 merged as `ff2ec08`: test-only Calendar → More → Timeline smoke synchronization repair. Exact-head Analyze, all six test shards, Debug/Release APK builds and all six Android Smoke jobs passed. This is emulator evidence, not physical-phone Calendar provider acceptance.
- PR #2506's first replacement had an unrelated `people` smoke failure against a stale merge ref. Replacement PR #2509 was based on current main `ff2ec08` and is now merged as `614b207`; its exact-head Analyze, six test shards, Debug/Release APK builds and all six Android Smoke jobs passed. It adds test evidence for Today + Category combined Report Center filtering and verifies the existing report page receives the same filtered scope; it changes tests only.
- Release status remains **NOT RELEASE-READY**. The owner/device ledger #1901 remains the source of physical-device acceptance gaps; emulator smoke and green builds do not close it.

## Confirmed recent work

### Implementation slices with exact-head evidence

- **#2301 Date/Time/Reminder**: merged. Canonical Date-only All-Day and Date+Time automatic Reminder behavior were implemented on the existing Task/Reminder foundation.
  - #2301 exact head bda056efb3e10a3b90f8638f1cdb3c6103c0ca7e: Build SUCCESS, Device Smoke SUCCESS.
  - #2337 exact head 83ba479f69da6b7cdcfee66b16d9f7eb197692cf: Build SUCCESS, Device Smoke SUCCESS.
  - #2345 exact head 387f7e46e66d75cd2e1388479c3f51d1aedf1223: Device Smoke SUCCESS.
  - This is implementation evidence, not final physical-phone acceptance of the complete product contract.
- **#2302**: circular Clock Dial and immediate Project visibility restored.
- **#2306 / #2308**: canonical Checklist display/toggle/progress reached Task Detail and Home.
- **#2406**: Report Center filter surface merged.
- **#2407**: Home filter presentation corrected to the canonical Arvin Bottom Sheet, reusing the existing filter state/semantics. Exact head d5f5de29a24164b9d798b15738e60a9c74d76468 passed Build and Device Smoke; it merged as 638aef6ffb1a5c3a3b9c619016ad75dc85f5df75.

## Active lane

### Typography — #1860 / canonical settings path
**Status: IMPLEMENTATION RECONCILED — DEVICE/UX ACCEPTANCE STILL OPEN**

PR #2413 (`fix(settings): reconcile device font selection with current main`) merged on 2026-10-07 as `d4efd86485113a711e0e0009dda266e051860ece`. It reconciles the existing system-font selection with current main: explicit `system` selection, Flutter system font at the ThemeData boundary, and legacy/unset preference remaining on VazirHarf. PR #2408 is historical implementation context, not the active unmerged lane.

Protected:
- no new storage/model/controller;
- no new font engine;
- VazirHarf remains the legacy/unset default;
- existing canonical AppSettingsService/AppSettings path is reused.

**Still not accepted:** On the installed current-main APK, verify system font visibly applies in light and dark themes, selection persists after restart, switching back to VazirHarf persists after restart, and font-size control/behavior matches #1860. No claim of full Typography completion without this evidence.

## P0/P1 remaining product work

### Calendar — #2248 / #1901
**IN PROGRESS — NEEDS REAL-DEVICE VERIFICATION**

Verify:
- destination calendar change/edit is honored;
- old events reconcile without orphan/duplicate;
- Task↔Event identity remains stable;
- phone default-calendar opt-in sync works;
- no-date Tasks do not become timed events;
- All-Day remains All-Day;
- recurrence/provider behavior is correct.

Use the existing Calendar foundation. No parallel Calendar engine/store/repository.

### Checklist — #2230
**PARTIAL — NEEDS ACCEPTANCE**

Present:
- canonical Task Checklist;
- Task Detail display/toggle/progress;
- Home progress;
- reorder foundation.

Remaining:
- complete add/edit/delete/move/reorder user flow;
- active/inactive behavior;
- independent Repeat occurrence state;
- Date/Time/Reminder, Follow-up and taxonomy integration;
- Backup/Restore/history;
- RTL/Persian acceptance.

### Repeat — #2254
**ARCHITECTURE GATE / BACKLOG IMPLEMENTATION**

Do not create a second recurrence engine. Required lifecycle semantics include start/end/count, current/completed/remaining/progress, next/last/history, occurrence-aware Checklist, Timeline/Calendar projection and Backup/Restore.

### Taxonomy — #847 / #1861
**IN PROGRESS / NEEDS VERIFICATION**

One canonical Project/Category/Tag source must support create/select/edit/archive/safe delete, immediate Roll Box visibility, combined filters, Notebook integration and Backup/Restore.

### Quick Add / Task Editor — #1891
**PARTIAL / NEEDS VERIFICATION**

Required:
- Date + Time side-by-side;
- real pickers, no blank screen;
- Reminder Date + Time;
- Persian RTL/digits;
- Project/Category/Tag Roll Boxes with existing values and «ایجاد جدید» last;
- immediate refresh;
- Repeat + Priority;
- Done/Undone and filtering;
- Task ↔ Follow-up swipe.

### Home — #1912 / #1901
**IMPLEMENTATION ADVANCED — NEEDS FINAL DEVICE/OWNER VISUAL ACCEPTANCE**

The existing Home structure and four controls remain protected:
**زمان / پروژه / دسته / برچسب**

PR #2407 now uses the required Bottom Sheet while preserving the existing filter state/semantics.

Still required:
- comparison with the approved visual reference;
- no clipping;
- combined contextual filters;
- filter changes without reopening;
- readable multiline Task cards;
- owner acceptance on the actual APK.

### Notebook — #1911 / #850
**IN PROGRESS / NEEDS VERIFICATION**

Verify independent Notebook editor behavior, numbering/tick/checklist tools, autosave/reopen/undo/redo, canonical taxonomy, combined filters, Tag selection and safe legacy cleanup without data loss.

### Backup/Restore + Data Safety
**NEEDS VERIFICATION**

Must preserve Task IDs/history, Checklist and occurrence state, Follow-up timeline, taxonomy, Notebook data and Reminder/Calendar relationships where applicable.

### Notifications / Widget / Lock Screen
**NEEDS VERIFICATION**

Verify Date-only vs Timed semantics and Reminder reconciliation across all surfaces.

## Golden Flow

**NOT PROVEN**

Create Task → Date/Time → Reminder → Checklist → Repeat → Follow-up → Timeline → Complete → Backup → Restore

The same user data must survive the complete flow.

## Release Gate

**NOT RELEASE-READY**

Fresh evidence is still required on the actual release candidate:

Analyze → Full Test → Debug Build → Release Build → Android Smoke → product acceptance → physical-phone acceptance → release.

Emulator/device-smoke evidence does not replace required physical-phone acceptance for Home, Calendar, Date/Time/Reminder, Settings, Taxonomy and Notebook UX.

## Anti-repeat / hygiene

- Do not resurrect old PRs merely because they remain open.
- #1901 is an owner/device regression reference and must not be merged blindly because its base is stale.
- Old AUTO-FIX issues tied to obsolete SHAs are not current blockers unless the same failure reproduces on current main.
- No parallel Task/Reminder/Calendar/Repeat/Taxonomy/Notebook/Storage/Repository engines.
- Architecture/storage/migration changes must use the existing architecture-review gates.

## Current execution order

0. Confirm post-merge main Release Closure after #2504/#2505/#2509; PR-triggered exact-head green checks are not a substitute for this explicit main-branch gate.
1. Continue the canonical Settings/device-font acceptance lane from the current main without creating duplicate Typography work.
2. Prove Golden Flow using the existing canonical Task/Date-Time/Reminder/Checklist/Repeat/Follow-up/Timeline paths.
3. Prove Backup → Restore integrity on the same dataset.
4. Prove Calendar E2E using the existing provider/sync/link foundation.
5. Final Home and Report Center UX acceptance against the approved product contract.
6. Complete remaining independent Taxonomy/Quick Add/Notebook/Checklist gaps only where live evidence shows a concrete product gap.
7. Produce fresh RC evidence and final physical-phone acceptance.
8. Only then evaluate Release-Ready.

## Status vocabulary

DONE | IN PROGRESS | PARTIAL | BLOCKED | NEEDS VERIFICATION | NEEDS FINAL DEVICE VERIFICATION | DUPLICATE | SUPERSEDED | UNKNOWN | BACKLOG

Never upgrade a status without evidence.
