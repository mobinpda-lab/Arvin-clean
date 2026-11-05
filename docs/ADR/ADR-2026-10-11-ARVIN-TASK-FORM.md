# ADR — Canonical Arvin Task Creation Experience (Quick Add + Full Editor)

- **Status:** Accepted product direction; implementation and acceptance in progress
- **Date:** 2026-10-11
- **Owner decision / tracking:** [Issue #2593](https://github.com/mobinpda-lab/Arvin-clean/issues/2593)
- **Documentation PR:** [#2594](https://github.com/mobinpda-lab/Arvin-clean/pull/2594)
- **Scope:** UX/UI and use of existing architecture; this ADR does not authorize a data-model redesign.

## Goal
Provide two entry experiences—Quick Add for speed and the Full Task Editor for depth—that create or edit the same canonical Task, in Persian RTL, with a calm visual hierarchy and progressive disclosure.

## Context / Problem
Task-form requirements are distributed across older roadmap and focused issues. Fragmentation can cause inconsistent fields, terminology, selectors, date/time controls, or parallel editing/persistence paths. Quick Add must remain fast without becoming a second Task system.

## Decision
Reuse the existing Quick Capture/Quick Add surface, the existing `ArvinTaskEditorDialog`, the canonical `Task` model and the existing write/services path. Quick Add is the default lightweight creation path; Full Task Editor is the detailed path. They are two experiences over one Task—not two entities or persistence systems.

### Quick Add contract
- Keep the compact first view focused on **عنوان کار**, importance, and optional fast **تاریخ**, **زمان**, **تکرار**, and **یادآور** controls, with a discoverable **«جزئیات بیشتر»** entry to the Full Task Editor.
- Quick Add must create/persist only through the existing canonical Task path. It must not own a separate store, schema, repository, or scheduling engine.
- **«جزئیات بیشتر»** hands the current draft—including its identity and already-entered values—to `ArvinTaskEditorDialog`; it must not quick-save first and then create another Task.
- If the Full Editor is cancelled, preserve the Quick Add draft/input for retry and do not mutate stored Task data. If the Full Editor saves, save that same canonical Task once and clear/reset Quick Add only after confirmed success.
- Existing multi-entry quick-capture behavior, validation, project/category/tag context and callbacks must be preserved where already supported. Any contextual exception must be documented and tested.

### Full Task Editor contract
1. Title (primary hierarchy; priority and completion remain semantically distinct).
2. Optional short description (not a substitute for Note).
3. Due date via the existing Jalali date picker.
4. Due time via Universal Arvin Time Picker (#2589).
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

## Additive Task Note data decision (2026-10-11)\n- Short description remains `Task.description`; optional Note is a separate `Task.note` field. `FollowUp.note` remains the note of an individual follow-up and must not be reused.\n- Storage audit on main `72a2f4cc24df7a38eff9856ce403461615db5280` confirmed that `TaskStore` retains the canonical JSON envelope in `legacy_payload_json`, decodes it through `Task.fromJson`, and preserves unknown legacy keys.\n- Implement Note as an additive field in the existing Task model/JSON envelope, defaulting to `''` for older records that do not contain it. Add it to the TaskStore canonical-known-fields list. Keep the existing SQL `description` column for short description; do not add a separate Note table/store or dedicated SQL column for this change.\n- This does not require a destructive SQL schema migration. It still requires legacy-read, TaskStore save/load, backup/restore round-trip, and edit-save tests proving description and Note remain independent. No claim of data safety until those tests pass.\n\n## Visual decision
- Full Persian RTL, readable contrast, clear hierarchy and spacing.
- Quick Add stays compact; advanced information belongs in the Full Editor or a clearly disclosed section.
- Calm card surfaces, consistent corner radius and icons; restrained color.
- Primary `#4A4CAB`; light primary `#E9EAFF`; background `#F8F8FB`; card `#FDFDFE`; text `#232433`; secondary `#80829C`.
- Do not use «مرحله» to label checklist items.
- No broad redesign of unrelated screens without a separate decision.

## Consequences and audit scope
This is the reference for Quick Add → Full Editor and canonical Create/Edit Task. Audit Quick Add, Create/Edit, Task Detail, Calendar entry points, Repeat, Reminder, Follow-up, Checklist, Search, Report, taxonomy selectors and Backup/Restore. A surface may differ only where its role requires it and that reason is documented.

## Protected
Canonical Task identity/storage; existing user data and history; Repeat/Occurrence semantics; independent checklist state per occurrence; Jalali user-facing dates; canonical Project/Category/Tag catalogs; Reminder/Follow-up/Calendar links; backup/restore compatibility; cancel behavior and multi-entry Quick Add.

## Decision record
- **Goal:** one Task with two coherent entry experiences.
- **Problem:** fragmented requirements risk inconsistent UX and duplicate saves.
- **Solution:** Quick Add for speed, Full Editor for depth, same draft identity and canonical write path.
- **Impact for the person using Arvin:** the first screen asks for less, date/time stay easy to find, and advanced controls remain available without creating a different task. A separate Note keeps free-form context from overwriting the short description; both must survive editing and backup/restore. Cross-feature scope includes Quick Add, Create/Edit, Task Detail, Calendar, Repeat, Reminder, Follow-up, Checklist, Search, Report and Backup/Restore.
- **Changed:** this decision and supporting UX/product/design/model contracts are being recorded; implementation is not claimed by this ADR.
- **Evidence:** current editor and Quick Capture code were inspected; prior Quick Entry convergence/cancel behavior records include [PR #1116](https://github.com/mobinpda-lab/Arvin-clean/pull/1116) and [PR #1122](https://github.com/mobinpda-lab/Arvin-clean/pull/1122). No approved runtime screenshot or physical-device acceptance is claimed here.
- **Remaining:** verify current Quick Add layout and exact draft/save/cancel wiring; audit all related surfaces; capture actual screenshots; run feature/integration tests, Android smoke and real-device acceptance.
- **Next:** implement only confirmed gaps on focused existing paths and record exact-head evidence in #2593 and the implementation PR.

## Validation / release gate
Require Quick Add simple-save, Quick Add → Full Editor save, cancel-preserves-draft, no-double-save/same-identity, checklist, recurrence, tracking, taxonomy, Jalali date/time, Reminder, Calendar, backup/restore, RTL and constrained-viewport scenarios. Analyze, tests, Debug/Release builds, relevant Android smoke, actual screenshot/visual review and device validation are all required. CI green alone is not product acceptance.

## Related records
- [Issue #848](https://github.com/mobinpda-lab/Arvin-clean/issues/848) Quick Entry convergence
- [PR #1116](https://github.com/mobinpda-lab/Arvin-clean/pull/1116) Quick Entry → canonical full Task editor
- [PR #1122](https://github.com/mobinpda-lab/Arvin-clean/pull/1122) cancel preserves Quick Entry draft
- [Issue #2197](https://github.com/mobinpda-lab/Arvin-clean/issues/2197) Checklist implementation slice
- [Issue #2230](https://github.com/mobinpda-lab/Arvin-clean/issues/2230) Checklist contract
- [Issue #2254](https://github.com/mobinpda-lab/Arvin-clean/issues/2254) Repeat/Occurrence architecture gate
- [Issue #2589](https://github.com/mobinpda-lab/Arvin-clean/issues/2589) Universal Arvin Time Picker
