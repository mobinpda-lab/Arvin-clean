# ARVIN REPORT FILTER DECISION
Updated: 2026-10-11
Repository: https://github.com/mobinpda-lab/Arvin-clean

## Goal
Make Report Center filters Persian-first, compact, discoverable, multi-select, and visually consistent with Arvin Home and Calendar while keeping reports read-only consumers of canonical data.

## Decisions
- Report date selection must use Arvin's existing Jalali/Persian date picker. Gregorian dates remain the internal DateTime representation only; Gregorian calendar UI is not acceptable in the Persian RTL product.
- The filter panel is a bottom sheet of expandable roll-box/accordion sections. Each section retains its local expanded state while the sheet remains open and shows a selected-count indicator.
- Project, Category, Tag, status, and Tracking selectors support multiple simultaneous selections. Values within one filter group use OR semantics; different filter groups combine with AND semantics.
- Use semantic pastel colors aligned with the Home/Calendar palette. Colors identify domain and state rather than acting as decoration.
- Note filters operate on existing canonical Task records that are Notebook items. Search covers title and description; note kind distinguishes simple notes from checklists; date filtering supports created and updated timestamps. Existing Category/Tag/Project filters also apply to these canonical note records.
- Task remains the source of truth. Notebook items are not copied into a separate report store, and no parallel report engine or data model is introduced.
- Calendar remains a projection of canonical Task data. External phone-calendar-only records are not silently treated as Task or Note records.

## Filter structure
1. Time preset and precise date/time.
2. Project (multi-select).
3. Category (multi-select).
4. Tag (multi-select).
5. Note: title/text, note/checklist kind, created/updated date range.
6. Task status (multi-select).
7. Tracking level (normal/tracking; based on the existing RecurrenceRule field).
8. Follow-up (existing followUpEnabled state).
9. Existing importance and repeat/checklist refinements remain available as additional collapsed sections.

## UX rules
- Compact cards with rounded corners, subtle borders, clear iconography, visible selected counts, and collapsed sections by default except the primary Time section.
- Persian/Jalali date labels and Persian digits are used for visible date/time labels.
- Preserve current selections when a section is collapsed and reopened.
- Clear and Apply remain reachable at the bottom of the filter sheet.
- Selected values in each group are OR'ed; active filter groups are AND'ed.

## Known boundary / not to fake
- The current canonical Notebook representation is a Task with NotebookItemKind; there is no independent Note-to-another-Task relation field. A future explicit linked-Task filter must wait for an approved domain contract rather than inventing a parallel relation.
- ReportCenterPage currently receives canonical tasks and projects. Calendar projections represented by those Tasks are reportable; phone-calendar-only external events are not proven to be included in the report input.
- These changes are not accepted until exact-head Analyze, tests, Debug/Release APK builds, Android visual checks, and product-owner acceptance are recorded.

## Execution status
- Implemented on branch `feat/calendar-pastel-compact-cards-20261011`: Persian/Jalali picker for report date ranges; expandable filter sections; multi-select status and Tracking filters; canonical Notebook note query/kind/created-or-updated date filters; regression tests added.
- Pending: exact-head CI/device validation, review of small-screen RTL layout, and owner acceptance. Do not merge or call release-ready before evidence.
