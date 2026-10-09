# Arvin — Project Evaluation Snapshot & Remaining Work

Date: 2026-10-09
Verified current main: e8f9c3b409ff5a01804250d46dc05337ea548966

## Executive status

**Arvin is NOT Release-Ready yet.**

The current main includes the Home date-sensitive test repair from PR #2504. The repair changes tests only: Home tests now use the canonical IranClock and identify the Tomorrow group by its stable key instead of ambiguous visible text. It does not change production behavior.

The exact PR-head evidence for #2504 passed Analyze, all six test shards, Debug/Release APK builds and all six Android Smoke lanes. The post-merge main Release Closure has not yet been confirmed green; do not treat PR-head success as proof of current-main Release Closure or final product acceptance.

## Current validation lanes

### Calendar Android smoke — #2498 / PR #2505
**IN PROGRESS — exact-head automation**

The old PR #2499 was stale against main and its old-head Device Smoke failed. PR #2505 replays the same bounded synchronization fix on current main: verify/scroll the canonical More button, tap it, and wait for the existing Timeline action.

Protected: no product navigation, Calendar architecture, model, storage or Timeline implementation changes.

Remaining: exact-head Analyze/Test/Build/Android Smoke results; separately, real-device/provider acceptance with two writable calendars. Emulator smoke is not proof of physical-device Calendar acceptance.

### Report Center combined-filter evidence — #2385 / PR #2506
**IN PROGRESS — exact-head automation**

The old PR #2496 was stale and its test selected Category only, despite claiming combined filtering. PR #2506 corrects the evidence on current main by selecting Today + Category, checking the single task matching both filters, and verifying the canonical TaskReportPage receives the same filtered task scope.

Protected: no production code, Task model/storage, Home, report engine, renderer, sharing/printing/PDF or status semantics.

Remaining: exact-head Analyze/Test/Build/Android Smoke results and separate real-Android visual/interaction acceptance.

## P0/P1 remaining product work

### Calendar — #2248 / #1901
**NEEDS REAL-DEVICE / PROVIDER VERIFICATION**

Use the existing Calendar foundation. Verify destination-calendar changes, edit/delete/move, stable Task↔Event identity, no duplicate/orphan events, opt-in default-calendar sync, All-Day vs Timed behavior and recurrence/provider behavior. The stock emulator's lack of two writable calendars is a limitation, not a pass.

### Home — #1912 / #1901
**IMPLEMENTATION ADVANCED — NEEDS FINAL VISUAL ACCEPTANCE**

Protect the canonical four controls: زمان / پروژه / دسته / برچسب. Compare the exact release APK against the approved visual reference; verify no clipping, readable multiline cards, combined contextual filters and filter changes without reopening. Emulator smoke does not replace owner/physical-device visual acceptance.

### Quick Add / Task Editor / Date-Time / Reminder — #1891
**NEEDS PRODUCT ACCEPTANCE**

Verify Persian RTL/digits, date and time entry, circular Clock Dial, Reminder date/time, Project/Category/Tag selection and Create New, immediate refresh, and no blank picker screen on the exact APK.

### Typography / Settings — #1860 / #2408
**IMPLEMENTED FOUNDATION — NEEDS DEVICE/UX ACCEPTANCE**

Verify system-font effect in light/dark, persistence after restart, return to VazirHarf and persistence, font-size behavior where supported, and data safety. Reuse canonical AppSettingsService/AppSettings; no parallel storage/font engine.

### Taxonomy / Notebook — #847 / #1861 / #1911 / #850
**NEEDS VERIFICATION**

Project/Category/Tag must use one canonical source shared by Task and Notebook. Verify create/select/edit/archive/safe delete, immediate refresh, tag selection, combined filters and legacy cleanup without data loss.

### Checklist — #2230
**PARTIAL — ACCEPTANCE GAP**

One canonical Task may contain an optional internal Checklist. Verify active/inactive toggle, add/edit/delete/reorder/check flow, persistence, inline Task Detail use, Backup/Restore and independent execution state per repeat occurrence. Do not create a separate Checklist entity, storage or engine.

### Repeat — #2254
**ARCHITECTURE-GATED**

Do not create a second recurrence engine. Any lifecycle work must preserve one canonical Task, immutable history, independent Checklist state per occurrence and Backup/Restore compatibility.

### Report Center — #2385
**FILTER EVIDENCE IN PROGRESS; VISUAL ACCEPTANCE OPEN**

Reuse the existing Report Center, TaskReportPage, projection/renderers and share/print paths. No duplicate report engine. PR #2506 is test-only and must pass exact-head validation before it is considered evidence-complete.

### Backup / Restore + Golden Flow
**RELEASE-CRITICAL — NOT FULLY PROVEN**

Existing backup/restore foundation and smoke tests are not proof of the complete combined flow. Prove that IDs, history, occurrence state, taxonomy and relationships survive:

Create → Date/Time → Reminder → Checklist → Repeat → Follow-up → Timeline → Complete → Backup → Restore.

## Release gate

**NOT RELEASE-READY**

Remaining product-level evidence:
- final Home / Task / Date-Time / Reminder visual acceptance;
- Calendar real-device/provider acceptance;
- Settings/Typography acceptance;
- Taxonomy/Notebook acceptance;
- Checklist and Repeat lifecycle acceptance within the canonical architecture;
- complete Golden Flow and Backup/Restore integrity;
- Report Center visual/interaction acceptance;
- one coherent Release Candidate evidence set on an exact SHA;
- final physical-phone acceptance.

A green build, CI run or emulator smoke is not a substitute for these gates.

## Anti-repeat rules

- PR #2499 was superseded by #2505; PR #2496 was superseded by #2506.
- PR #2497 is a stale documentation snapshot and is being superseded by this current-main snapshot.
- Issue/PR #1901 remains a real-device acceptance ledger, not an implementation PR to merge blindly.
- Do not create parallel Task, Reminder, Calendar, Repeat, Taxonomy, Notebook, Checklist, storage, report or renderer systems.
- Do not upgrade a status without exact evidence.

## Current execution order

1. Finish exact-head automation for PRs #2505 and #2506; repair only reproduced failures.
2. Confirm post-merge main Release Closure after PR #2504.
3. Complete Calendar provider/physical-device acceptance.
4. Prove the complete Golden Flow and Backup/Restore integrity.
5. Complete Home, Quick Add, Typography, Taxonomy, Notebook and Checklist acceptance where evidence shows a real gap.
6. Complete Report Center visual/interaction acceptance.
7. Assemble one exact-SHA Release Candidate evidence set and perform final physical-phone acceptance.
8. Only then evaluate Release-Ready.

## Status vocabulary

DONE | IN PROGRESS | PARTIAL | BLOCKED | NEEDS VERIFICATION | NEEDS FINAL DEVICE VERIFICATION | DUPLICATE | SUPERSEDED | UNKNOWN | BACKLOG

Never upgrade a status without evidence.
