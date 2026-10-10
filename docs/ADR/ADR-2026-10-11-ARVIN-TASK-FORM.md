# ADR — Canonical Arvin Create/Edit Task Form

- **Status:** Accepted direction; implementation and acceptance in progress
- **Date:** 2026-10-11
- **Owner decision:** Issue [#2593](https://github.com/mobinpda-lab/Arvin-clean/issues/2593)
- **Scope:** UX/UI and use of existing architecture; this ADR does not authorize a data-model redesign.

## Goal
Provide one Persian, RTL, calm and efficient form for creating and editing the canonical Task. Basic use must be quick; advanced controls appear when relevant.

## Context / Problem
Task-form requirements exist across older roadmap and focused issues. Fragmentation can cause inconsistent fields, terminology, selectors, date/time controls or parallel editing paths.

## Decision
Reuse the existing `ArvinTaskEditorDialog`, canonical `Task` model and existing write/services path. Quick Entry's full-form continuation must hand off the same draft/Task identity. No second Task form, Task store, Checklist store/entity, Category/Group entity, Habit system, Tracking entity or time picker may be introduced.

### Canonical information architecture
1. Title (primary hierarchy; do not conflate priority and completion).
2. Optional short description (not a substitute for Note).
3. Due time via Universal Arvin Time Picker (#2589).
4. Due date via existing Jalali date picker.
5. Repeat: none, daily, weekly, monthly, advanced; keep canonical Repeat/Occurrence semantics.
6. Checklist: official term is «چک‌لیست», inside Task, with add/edit/delete/reorder/check and useful completed/total/progress presentation.
7. Project: zero or one canonical Project.
8. Category: canonical taxonomy concept; Group is not a second entity.
9. Tags: multiple canonical Tags, distinct from Category.
10. Tracking level: ordinary or important-and-trackable.
11. Tracking details: conditionally revealed and backed by existing Task/Follow-up contracts.
12. Optional Note, distinct from short description.
13. Bottom actions: «لغو» and «ذخیره», with validation and canonical persistence.

Reminder, attachments, follow-up, history and other currently supported features must not be silently removed. Their placement can use progressive disclosure but requires no semantic regression.

## Visual decision
- Full Persian RTL, readable contrast, clear hierarchy and spacing.
- Calm card surfaces, consistent corner radius and icons; restrained color.
- Primary `#4A4CAB`; light primary `#E9EAFF`; background `#F8F8FB`; card `#FDFDFE`; text `#232433`; secondary `#80829C`.
- Do not use «مرحله» to label checklist items.
- No broad redesign of unrelated screens without a separate decision.

## Consequences
The form is the reference for Create/Edit Task. Quick Entry, Task Detail, Calendar entry points, Repeat, Reminder, Follow-up, Checklist, Search, Report and Backup/Restore must be audited for compatible semantics. A surface may differ only where its role requires it and that reason is documented.

## Protected
Canonical Task identity/storage; existing user data and history; Repeat/Occurrence semantics; independent checklist state per occurrence; Jalali user-facing dates; canonical Project/Category/Tag catalogs; Reminder/Follow-up/Calendar links; backup/restore compatibility.

## Decision record
- **Goal:** one consistent, usable Task form.
- **Problem:** requirements are distributed and UX can drift.
- **Solution:** standardize the existing editor, progressive disclosure, reuse canonical fields and services.
- **Impact:** Create/Edit, Quick Entry, Task Detail, Calendar, Repeat, Reminder, Follow-up, Checklist, Search, Report, Backup/Restore.
- **Changed:** decision documented; implementation is not claimed by this ADR.
- **Evidence:** current editor/model and related issues/PRs are referenced in #2593; no approved screenshot or physical-device acceptance is claimed here.
- **Remaining:** code audit, focused UX alignment, actual screenshots, feature/integration tests, Android smoke and real-device acceptance.
- **Next:** implement small compatible slices through reviewed PRs and update the acceptance ledger with exact-head evidence.

## Validation / release gate
Require simple-task, checklist, recurrence, tracking, taxonomy, Jalali date/time, Calendar, backup/restore, cancel/save, RTL and constrained-viewport scenarios. Analyze, tests, Debug/Release builds, relevant Android smoke, real screenshots/visual review and device validation are all required. CI green alone is not product acceptance.

## Related records
- [Issue #2593](https://github.com/mobinpda-lab/Arvin-clean/issues/2593) canonical form decision and audit
- [Issue #1069](https://github.com/mobinpda-lab/Arvin-clean/issues/1069) implementation roadmap
- [Issue #1852](https://github.com/mobinpda-lab/Arvin-clean/issues/1852) Category/Tag live refresh
- [Issue #1869 / PR #1870](https://github.com/mobinpda-lab/Arvin-clean/pull/1870) Repeat/Priority layout
- [PR #2197](https://github.com/mobinpda-lab/Arvin-clean/pull/2197) Checklist implementation slice
- [Issue #2230](https://github.com/mobinpda-lab/Arvin-clean/issues/2230) Checklist contract
- [Issue #2254](https://github.com/mobinpda-lab/Arvin-clean/issues/2254) Repeat/Occurrence architecture gate
- [Issue #2251](https://github.com/mobinpda-lab/Arvin-clean/issues/2251) release-ready program
- [Issue #2589](https://github.com/mobinpda-lab/Arvin-clean/issues/2589) Universal Arvin Time Picker
