# Task Template Data Contract — Issue #823

**Scope:** reusable Task definitions only; distinct from project templates, checklist mode and recurrence occurrences.  
**Storage:** existing G1 Drift database; `task_templates` table. No parallel database/store.  
**Current schema contract:** G1 version 10.  
**Acceptance rule:** source presence is implementation evidence, not test PASS. Exact-SHA CI and owner acceptance remain separate.

## 1. Definition and source of truth

`TaskTemplate` is an immutable reusable definition created from an existing canonical `Task`. `TaskTemplateStore` persists it in the existing G1 Drift database. `TaskStore` remains the source of truth for executable Tasks. `ProjectTemplateStore` remains the source of truth for project templates.

A template is not:
- a live Task;
- a checklist-only object;
- a recurrence occurrence;
- a copy of Follow-up history;
- a second Task repository.

## 2. Transfer matrix

| Source field | Template contract | Reason |
|---|---|---|
| Task title | Preserve | Core reusable identity |
| Description | Preserve | Stable instructions |
| Category | Preserve | Taxonomy definition |
| Priority | Preserve | Reusable importance default |
| Tags | Preserve | Reusable taxonomy |
| Checklist items | Preserve text; strip `[ ]` / `[x]` execution markers | Every generated Task starts with unchecked items |
| People references | Preserve existing `PersonReference` identities | Retain the Task's existing related-people definition; do not relabel them as assignees |
| Center / Project | Preserve source names and optional stable IDs as snapshots | Provenance only; Task has no direct canonical center/project foreign key |
| Reminder title | Preserve | Reusable reminder description |
| Reminder all-day flag | Preserve | Keep reminder mode |
| Reminder time-of-day | Preserve hour/minute | Reapply to a newly selected date on instantiation |
| Reminder enabled flag and sequence | Preserve | Keep schedule definition and ordering |
| Reminder original date and reminder ID | Do not transfer | These identify an execution-specific alarm instance; new IDs are generated |
| Recurrence frequency, interval, start/end bounds, count, active flag and tracking level | Preserve | These are the recurrence rule definition, not occurrence history |
| Task due date | Do not transfer | A source Task's absolute due date is execution scheduling, not a reusable default |
| Legacy singular reminder date | Do not transfer | Do not duplicate the old alarm date into the template |
| Completed / completedAt | Do not transfer | Execution state must not leak into a new Task |
| Archived / trashed state | Do not transfer | Lifecycle state belongs to the source Task |
| Follow-up records, results and timestamps | Do not transfer | Historical actions remain attached only to the source Task |
| Checklist completion state | Do not transfer | Generated checklist starts unchecked |
| Task createdAt / updatedAt | Do not transfer | Template receives its own createdAt / updatedAt |
| Recurrence occurrence history | Do not transfer | Only the rule definition is reusable |

### Reminder instantiation

When a template contains reminder definitions, the user chooses a new Jalali date. Each reminder is recreated using that date plus the preserved hour/minute, all-day mode, enabled flag and sequence; a new reminder ID is assigned. The original alarm date and ID are not reused.

### Center / Project snapshots

The template stores `centerNameSnapshot`, `projectNameSnapshot`, and optional `centerIdSnapshot` / `projectIdSnapshot`. These fields document where the source Task came from. They do not silently attach a newly created Task to the old Project: project membership is canonical in `ProjectPlan.itemIds`, and Task has no direct Project/Center relation. Automatic reassignment is intentionally not inferred.

## 3. Non-destructive migration

- G1 schema version is 10.
- New installations create `task_templates` through the existing G1 DDL.
- Existing installations retain all Task, Project and Project Template rows.
- Version 10 checks `PRAGMA table_info('task_templates')` and adds only the nullable snapshot columns `center_id_snapshot` and `project_id_snapshot` when absent.
- No table is dropped, renamed, copied destructively, or replaced.
- Existing template rows are preserved when those columns are added.
- The migration test seeds a pre-v10 `task_templates` table and an existing Task / Project Template row, installs the current schema, then asserts the old rows and new columns.

## 4. Operational user paths

### Task templates
1. Settings → «الگوها» → tab «الگوهای کار».
2. Select an existing active Task from «انتخاب کار موجود».
3. Enter the template name and confirm conversion.
4. The definition is written by `TaskTemplateStore`; the source Task and its history remain unchanged.
5. The saved definition appears in the same Task Templates tab.
6. A saved template can create a new Task; checklist items are reset and reminder dates are selected for the new Task.

The Task Details header also exposes «تبدیل به الگو». It asks for a name, confirms saving, writes through the injected canonical `TaskTemplateStore`, and shows success or failure feedback.

### Project templates
1. Settings → «الگوها» → tab «الگوهای پروژه».
2. Select an existing Project from the Projects list to open Project Details.
3. Confirm «تبدیل پروژه به الگو».
4. `ProjectTemplateService.createFromProject` reads the canonical Project and its Task IDs, then persists through the existing `ProjectTemplateStore`.
5. The source Project and Tasks are not mutated.

The Settings hub builds only the selected tab at a time so its Drift-backed stores do not initialize concurrently.

## 5. Implementation and test surfaces

- Model: `lib/models/task_template.dart`
- Store: `lib/services/task_template_store.dart`
- G1 schema and migration: `lib/services/g1_drift_schema.dart`
- Task Template list and Settings tabs: `lib/task_template_management_page.dart`
- Task Details conversion and unified edit form: `lib/task_detail_page.dart`
- Project list → detail navigation: `lib/projects_page.dart`
- Project Details conversion: `lib/project_detail_page.dart`
- Project conversion service/store: `lib/services/project_template_service.dart`, `lib/services/project_template_store.dart`
- Data/migration tests: `test/services/task_template_store_test.dart`
- Task list-to-template and instantiate UI: `test/task_template_management_page_test.dart`
- Task Details conversion UI: `test/task_detail_template_conversion_test.dart`
- Project list-to-detail-to-template UI: `test/project_detail_page_test.dart`
- Settings tabs UI: `test/settings_template_tabs_test.dart`

## 6. Status boundary

Code on the authorized branch is implementation evidence only. The new data, migration, interaction, Home, Task Details and Visual tests must all pass on the same live HEAD before they can be called verified. A test result from any earlier SHA does not transfer. Physical-device acceptance is not claimed unless an actual device run and evidence are recorded.

PR #3052 must remain OPEN / DRAFT / UNMERGED; main remains untouched; release remains **BLOCKED — RELEASE: NO-GO**.
