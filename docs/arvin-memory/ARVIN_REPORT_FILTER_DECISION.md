# Arvin Report Filter & Memory Extension Decision

**Date:** 2026-10-11  
**Status:** Owner-approved product direction; implementation and acceptance pending  
**Repository:** `mobinpda-lab/Arvin-clean`

## Goal
Allow users to build accurate reports by combining the main Arvin information domains while keeping the filter UI compact, Persian-first, visually consistent and easy to operate.

## Non-negotiable data ownership
Report is a read-only consumer/projection. It does not own domain data and must not create parallel Task, Note, Calendar, Tracking, Follow-up or report storage. Reuse canonical models, repositories, IDs and relations. Root Task text remains `Task.description`; do not add root `Task.note`. Existing Notebook and FollowUp note concepts remain as they are.

## Sources and filter sections
The intended report sources are Task, Project, Category, Tag, Tracking, Follow-up, Calendar and Notes. The filter panel contains these expandable sections:
1. Time
2. Project
3. Category
4. Tag
5. Note
6. Task Status
7. Tracking
8. Follow-up

Each section is an Arvin RollBox/accordion: icon, title, selected count and expand/collapse indicator in the header; selected chips and available options in the body. Collapse must not clear the section's selection. Avoid a long always-expanded filter page.

## Persian date and time
All user-facing report date/time filters must use Arvin's Persian/Jalali presentation and Persian digits consistent with the existing calendar/date-picker conventions. In PR #2607, the date range has been changed to `showPersianDatePicker`, but `_pickTime` still uses Flutter's generic `showTimePicker`; therefore the date/time requirement is not fully accepted yet. The shared `showUniversalArvinTimePicker` exists in draft PR #2591. Reconcile/stack these overlapping changes so Report Center uses that existing shared picker without duplicating it. Preserve unambiguous underlying DateTime semantics; this is a presentation/input UX requirement, not permission to alter stored timestamps.

## Multi-select
Project, Category, Tag, task status and note type must support selecting multiple values simultaneously. Show removable selected chips and counts. A single selection remains valid but must not be the only supported mode. Time, Tracking and Follow-up filters must also allow meaningful combinations wherever their domain semantics support it.

## Color and visual system
Extend the approved Home/Calendar pastel visual language to Reports and all other existing Arvin screens, including Notebook, forms, settings and details. Use semantic/domain identity colors (Project, Category, Tag, Note, Status), restrained backgrounds, rounded surfaces, subtle elevation and compact spacing. Color supports fast recognition, not decoration. Preserve Persian RTL, VazirHarf v34.003, the existing approved palette and current product identity.

## Note reporting
Where the canonical Notebook data makes it available, support filtering/reporting by:
- note title and body text;
- note category and tag;
- creation date and last-modified date;
- relation to a Task.
Notes remain in their existing canonical storage and relationship model. Do not introduce a parallel Note system to satisfy reporting. Reportable/searchable note fields should be exposed to the report projection through existing repositories and tested for correct identity and relationship preservation.

## Acceptance checklist
- [ ] Report date/time filter uses Persian/Jalali user-facing controls and Persian digits.
- [ ] Filter panel is compact; sections expand/collapse and preserve selections.
- [ ] Multi-select works for projects, categories, tags, task statuses and note types.
- [ ] Selected chips can be removed; selected counts stay correct.
- [ ] Semantic colors match Home/Calendar and remain readable in RTL.
- [ ] Report data reflects canonical Task and related data accurately.
- [ ] Note title/body/category/tag/dates/Task relationship are filterable when available from canonical data.
- [ ] No parallel domain model, store or duplicate report engine is introduced.
- [ ] Regression tests, Analyze, full tests and Debug/Release builds pass for the exact PR head.
- [ ] Android visual/device validation confirms no clipping and correct Persian/Jalali controls.
- [ ] Owner reviews and accepts the installed build.

## Anti-forget / status discipline
This document records the decision, not proof of implementation. Keep the continuity checkpoint and product/UI governance references in sync. Before work, audit current main, open PRs, branches and CI to avoid duplicate or conflicting work. Report what changed, exact commit/PR, checks, device evidence and remaining blockers. Do not mark any acceptance item complete without evidence.


## Live status override — 2026-10-12
This is a product direction/acceptance contract, not proof of implementation. PR #2591 (shared time picker) and #2607 (visual/report filter) overlap and remain open drafts. Confirm current diffs and exact-head tests before merging. At last live check, #2607 and #2591 were not accepted for release; Persian/Jalali time controls and physical-device RTL/compact-screen acceptance remain open. Preserve root `Task.description`; do not introduce root `Task.note` or parallel report/note storage.


## Source audit correction — 2026-10-12
An earlier note in this document says PR #2607 still uses Flutter's generic `showTimePicker` in Report Center. That statement is **stale for the currently inspected PR head**. Live source fetch of branch `feat/calendar-pastel-compact-cards-20261011` confirms `lib/report_center_page.dart` calls `showUniversalArvinTimePicker` and has no generic `showTimePicker` call. The shared picker file has the same Git blob SHA `caacc5539c5f2304a1a060f5e3610a25987a6619` in PR #2591 and #2607. Remaining work is to reconcile the overlapping `main.dart`, Report Center and picker file changes into one exact-head-tested integration; source inspection does not establish passing tests or physical-device acceptance. See PR comments [#2591](https://github.com/mobinpda-lab/Arvin-clean/pull/2591#issuecomment-6114333837) and [#2607](https://github.com/mobinpda-lab/Arvin-clean/pull/2607#issuecomment-6114334281).


## Owner-approved screenshot reference — 2026-10-12
- Dedicated GitHub acceptance record: [Issue #2623 — owner-approved Report Filter Bottom Sheet reference](https://github.com/mobinpda-lab/Arvin-clean/issues/2623).
- The owner supplied a visual reference image in the conversation. It defines the compact rounded Bottom Sheet, Persian RTL header (فیلتر گزارش‌ها / پاک کردن همه / close), expandable sections, Jalali date range + shared Arvin time picker, multi-select Project/Category/Tag/Status chips, pastel semantic colors, and bottom actions بازنشانی / اعمال فیلتر.
- The screenshot's palette is the current Report Center contract: Primary #4A4CAB, Light Primary #E9EAFF, Background #F8F8FB, Card #FDFDFE, Text #232433, Secondary #80829C.
- This visual reference supplements—not replaces—the broader filter contract here. Keep Note, Tracking and Follow-up filter requirements; preserve canonical read-only data ownership and no-parallel-store rules.
- **Status:** decision/acceptance checklist registered; screenshot binary is not yet committed/attached to GitHub, and implementation/device visual acceptance remain pending. Do not mark Done without evidence.
