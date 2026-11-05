# ARVIN UI/UX + Issue #823 Execution Audit — 2026-11-05

Repository: mobinpda-lab/Arvin-clean  
Audit baseline: c35929c1cc2022b8470cd86b6f6fe8e2ae771e5b  
Authorized branch: fix/recovery-calendar-device-smoke-2026-10-31  
PR #3052: OPEN / DRAFT / UNMERGED  
Release: BLOCKED — RELEASE: NO-GO

## 1. Canonical documentation and registration

The following references exist on the authorized branch:
- docs/project-continuity/task_home_screen_spec.md — fourteen-point Home specification.
- docs/project-continuity/task_detail_ui_ux_spec.md — unified View/Edit Task Details and all eleven sections.
- docs/project-continuity/calendar_ui_ux_spec.md — Calendar hierarchy, date triad, view modes and agenda filters.
- docs/project-continuity/PRODUCT_DECISIONS.md, CURRENT_STATE.md, IMPLEMENTATION_LOG.md, OPEN_ISSUES.md, ARVIN_CONTINUATION_LEDGER.md, root CHANGELOG.md and docs/CHANGELOG-2026-10-30.md.

Registration is partial, not a blanket proof of completion. The three screen specifications and a changelog entry exist, but the durable Product Decisions register does not reconcile the Naskh/Vazirmatn typography conflict. Its current content also contains a duplicate Quick Capture decision row. A document's presence is not evidence of runtime implementation or visual acceptance.

## 2. Home — active runtime path

Primary source is lib/main.dart: _homeFilterCards, _matchesTimeFilter, visible, _homeGroups, _groupJalaliDate and _overdue. Supporting source includes lib/services/home_task_filter_matcher.dart, lib/services/task_list_sort_service.dart and lib/home/home_filter_ui.dart.

| Requirement | Status | Evidence / gap |
|---|---|---|
| Five filters in RTL order, then separate sort icon | پیاده‌سازی‌شده ولی آزموده‌نشده | Active row is built in main.dart and contains five ActionChips followed by a separate sort IconButton. |
| Canonical labels, including «مرکز» and «دسته‌ها» | پیاده‌سازی‌شده ولی آزموده‌نشده | Active category label was «دسته‌بندی‌ها», inconsistent with approved «دسته‌ها». Corrected in lib/main.dart; an exact widget assertion was added to test/home/home_filter_contract_test.dart. Fresh-SHA CI is required. |
| No sixth «همه» chip; internal unrestricted option remains in filter panels | پیاده‌سازی‌شده ولی آزموده‌نشده | Five chips are built in the active row; filter sheets separately provide CheckboxListTile «همه». Existing test asserts five ActionChips and no home-filter-card-all. |
| Checkbox multi-select; OR within a dimension, AND across dimensions | پیاده‌سازی‌شده ولی آزموده‌نشده | Time uses _timeFilters.any; Center/Category/Project selections form unions within each dimension; tag matching uses homeTaskMatchesAnySelectedTag with .any. The visible pipeline chains dimension-specific where clauses, implementing AND across dimensions. Existing widget tests do not prove combined OR/AND results end-to-end. |
| Past filter and completed-task presentation | پیاده‌سازی‌شده ولی آزموده‌نشده | Time filtering uses Task Due Date; Past includes dates before Iran-local today. _overdue explicitly excludes completed Tasks. Past ordering delegates to TaskListSortService.sortPast. A focused mixed completed/incomplete exact-SHA assertion is still required. |
| Five time groups in canonical order | پیاده‌سازی‌شده ولی آزموده‌نشده | _homeGroups returns Past, Today, Tomorrow, Future and Timeless in that order, classified by Due Date. |
| Full dynamic Jalali weekday/date headings | ناقص | _groupJalaliDate derives Today and Tomorrow dynamically. Past and Timeless have no fabricated dates. Future is an aggregate group and currently has no date suffix; clarify whether the requirement expects per-task dates or one group date before changing it. |
| Sort/filter independence and default Follow-up-date sort | پیاده‌سازی‌شده ولی آزموده‌نشده | Sort state and filter sets are separate; choices include Follow-up Date, Due Date, Latest Changes and Title. All cross-operation combinations are not yet proven by focused tests. |

The current Home contract test proves structural parts of the row and internal «همه» options. It does not establish the full OR/AND behavioral matrix or all dynamic heading acceptance.

## 3. Templates, clone and Drift

Inspected: lib/services/g1_drift_schema.dart (schema version 8), lib/services/project_template_store.dart, lib/services/project_template_service.dart, lib/models/project_template.dart, lib/project_template_management_page.dart, lib/services/task_clone_service.dart, test/services/task_clone_service_test.dart, lib/settings_page.dart and lib/task_detail_page.dart.

| Requirement | Status | Evidence / gap |
|---|---|---|
| Existing Project Template storage/service | پیاده‌سازی‌شده ولی آزموده‌نشده | project_templates and project_template_tasks tables, Store/Service and management page exist. Current-SHA suite must finish. |
| Independent Task Template model/storage | ناقص | Schema v8 has Project Template tables but no independent Task Template table/model/store/service. templateTaskId identifies generated Tasks sourced from a Project Template task; it is not a standalone Task Template contract. |
| Non-destructive Task Template migration and existing-data test | فاقد مشخصات کافی | G1 install is additive/idempotent and tests preserve a legacy Task row, but Task Template field semantics are not approved. Do not guess retention rules for due date, recurrence, checklist execution state, reminders, people or provenance. No migration was added. |
| Two operational Settings tabs | ناقص | settings_page.dart routes to ProjectTemplateManagementPage; no independent Task Template tab is evidenced. |
| Convert existing Task to Template from Task Details | ناقص | TaskDetailPage has no verified Task Template store/service callback or conversion action. |
| Convert existing Project to Project Template from Project Details | ناقص | Existing template creation/generation exists, but conversion from an existing Project with confirmation and feedback was not found in inspected surfaces. |
| Task clone with source preserved and no source mutation | پیاده‌سازی‌شده ولی آزموده‌نشده | TaskCloneService creates a new ID, «— رونوشت» suffix and Persian sequential numbering; preserves descriptive/due/checklist/template fields; clears completion, reminders and historical Follow-ups. Focused service tests exist; current-SHA CI is required. |

Safe boundary: Task Template must not be implemented by relabeling ProjectTemplateTask or storing executable Task rows as templates. Define a distinct immutable template-definition contract and conversion rules first; reuse the existing G1/Drift executor and canonical TaskStore pathways, not a parallel database.

## 4. Calendar and Task Details

| Requirement | Status | Evidence / gap |
|---|---|---|
| Existing local Arvin calendar and external-provider separation | پیاده‌سازی‌شده ولی آزموده‌نشده | Existing code/docs describe an app-owned local calendar and read-only external sources. Do not rewrite without a demonstrated defect. |
| Internal Task survives deletion of its projected provider event | پیاده‌سازی‌شده ولی آزموده‌نشده | Existing provider evidence is referenced historically. Current exact-SHA Provider attempt initially failed before test execution because Dart Development Service did not start (0 tests passed); a retry is running. This is infrastructure failure, not a behavioral test failure. |
| Independence from deleting an entire external calendar | فاقد مشخصات کافی | Deleting one projected event and deleting an entire external calendar are different operations. Do not infer the latter from the former or invent destructive behavior. |
| Unified Task Detail View/Edit with eleven defined sections | ناقص | Canonical document defines all eleven sections. Current TaskDetailPage supports inline title/description/category/tags plus separate description/checklist interactions; it does not prove one unified editable form across all eleven sections. |
| No scroll jump entering/exiting edit mode | پیاده‌سازی‌شده ولی آزموده‌نشده | Inline state changes on the same page, but explicit scroll-offset preservation assertion and exact-SHA interaction evidence were not established. |
| Runtime timestamp and assignee mapping | فاقد مشخصات کافی | Canonical Task model does not establish a separate runtime timestamp or explicit assignee role from Task.people. Do not synthesize either. |

## 5. Product-owner decision required — typography

The Home specification requires a delicate Naskh-style Arabic calligraphy treatment for the Bismillah phrase, while the durable typography decision says Vazirmatn is the official app font and every page uses Vazirmatn. The Home document describes calligraphy as a separate Arabic-script display treatment, but the global decision register does not explicitly approve this exception.

Decision required from Mobin: approve a narrowly scoped Naskh display treatment for the sacred Arabic phrase only, with Vazirmatn remaining the exclusive UI font for all other text; or require Vazirmatn for the phrase too. Until confirmed, preserve current rendering and do not silently change font assets or typography policy.

## 6. Exact-SHA CI snapshot at baseline c35929c

At the live check:
- Analyze: SUCCESS.
- quality test-0: SUCCESS.
- quality test-1: SUCCESS.
- quality test-3: SUCCESS.
- quality test-4: SUCCESS.
- quality test-5: SUCCESS.
- quality test-2: IN_PROGRESS.
- standalone visual: IN_PROGRESS.
- Follow-up file-backed SQLite persistence: SUCCESS.
- Device Smoke: Preparation SUCCESS; Boot and Navigation IN_PROGRESS; Calendar Segmented View, Follow-up Persistence, Quick Capture, Reminder/Vazirmatn and Task Lifecycle QUEUED. Not 7/7.
- Calendar Provider first attempt failed before test execution: Dart Development Service startup failure; 0 tests passed. Failed job was rerun; retry is IN_PROGRESS.
- Draft Review APK: IN_PROGRESS. APK matrix job was SKIPPED under the Draft guard; no publishable APK claim.

All statuses apply only to baseline SHA c35929c1cc2022b8470cd86b6f6fe8e2ae771e5b. They do not transfer to later commits.

## 7. Governance

Only fix/recovery-calendar-device-smoke-2026-10-31 under PR #3052 may be changed. Keep PR OPEN / DRAFT / UNMERGED; do not modify main; no merge, publication or release. Preserve tests/assertions/scenarios; no skip, weakening or artificial timeout. Official UI font remains Vazirmatn pending the narrowly scoped calligraphy decision above.

**BLOCKED — RELEASE: NO-GO.**
